import os
import sys
import time
import threading
from queue import Queue
import requests
from requests.adapters import HTTPAdapter
import shutil

# ─────────────────────────────────────────────
#  CONFIG
# ─────────────────────────────────────────────
ENDPOINT      = "https://usermoderation.roblox.com/v1/not-approved/reactivate"
CSRF_ENDPOINT = "https://auth.roblox.com/v1/authentication-ticket"
USERINFO_URL  = "https://users.roblox.com/v1/users/authenticated"
BAN_URL       = "https://accounts.roblox.com/v1/users/{uid}/ban-status"
CSRF_TIMEOUT  = 5
REQ_TIMEOUT   = 8

# ─────────────────────────────────────────────
#  SHARED STATE
# ─────────────────────────────────────────────
_lock            = threading.Lock()
success_cookies: list[str]             = []
failed_cookies:  list[tuple[str, str]] = []
skipped_cookies: list[tuple[str, str]] = []   # already active / not banned
completed        = 0
total            = 0
start_time       = 0.0
log_lines:        list[tuple[str, int]] = []
MAX_LOG          = 8

# ─────────────────────────────────────────────
#  ANSI + COLOUR
# ─────────────────────────────────────────────
RESET = "\033[0m"
BOLD  = "\033[1m"

def rgb(r: int, g: int, b: int, text: str) -> str:
    return f"\033[38;2;{r};{g};{b}m{text}{RESET}"

_PALETTE: list[tuple[int,int,int]] = []
def _build_palette() -> None:
    steps = 128
    half  = steps // 2
    for i in range(half):
        t = i / half
        _PALETTE.append((int(255 - t*95), int(255 - t*223), int(255 - t*15)))
    for i in range(half):
        t = i / half
        _PALETTE.append((int(160 + t*95), int(32 + t*223), int(240 + t*15)))
_build_palette()

def gradient_text(text: str, offset: int) -> str:
    n   = len(_PALETTE)
    out = ""
    for i, ch in enumerate(text):
        r, g, b = _PALETTE[(i + offset) % n]
        out += f"\033[38;2;{r};{g};{b}m{ch}"
    return out + RESET

def soft_purple(t: str) -> str: return rgb(200, 130, 255, t)
def white(t: str)       -> str: return rgb(240, 240, 255, t)
def dim_purple(t: str)  -> str: return rgb(100,  60, 140, t)
def green(t: str)       -> str: return rgb( 80, 255, 160, t)
def red(t: str)         -> str: return rgb(255,  80, 120, t)
def yellow(t: str)      -> str: return rgb(255, 210,  80, t)
def orange(t: str)      -> str: return rgb(255, 160,  60, t)
def cyan(t: str)        -> str: return rgb( 80, 220, 255, t)

def term_width() -> int:
    return shutil.get_terminal_size((80, 24)).columns

def center(text: str, vlen: int) -> str:
    pad = max(0, (term_width() - vlen) // 2)
    return " " * pad + text

def cprint(text: str, vlen: int) -> None:
    print(center(text, vlen))

# ─────────────────────────────────────────────
#  ANIMATED TITLE
# ─────────────────────────────────────────────
TITLE_ROWS = [
    "╔══════════════════════════════════════════╗",
    "║      ROBLOX  REACTIVATOR  v2             ║",
    "╚══════════════════════════════════════════╝",
]
TITLE_VIS = 44

_offset       = 0
_anim_active  = False
_redraw_fn    = None

def _anim_tick() -> None:
    global _offset
    while _anim_active:
        _offset = (_offset + 1) % len(_PALETTE)
        if _redraw_fn:
            try:   _redraw_fn()
            except Exception: pass
        time.sleep(1 / 60)

def start_anim() -> None:
    global _anim_active
    _anim_active = True
    threading.Thread(target=_anim_tick, daemon=True).start()

def stop_anim() -> None:
    global _anim_active
    _anim_active = False

def title_block() -> str:
    return "\n".join(center(gradient_text(row, _offset), TITLE_VIS) for row in TITLE_ROWS)

# ─────────────────────────────────────────────
#  IDLE SCREEN
# ─────────────────────────────────────────────
_idle_lines: list[str] = []

def _redraw_idle() -> None:
    sys.stdout.write("\033[H")
    sys.stdout.write(title_block() + "\n")
    for line in _idle_lines:
        sys.stdout.write(line + "\n")
    sys.stdout.flush()

def idle_start(lines: list[str]) -> None:
    global _redraw_fn, _idle_lines
    _idle_lines = lines
    clear()
    sys.stdout.write(title_block() + "\n")
    for line in lines:
        sys.stdout.write(line + "\n")
    sys.stdout.flush()
    _redraw_fn = _redraw_idle

def idle_stop() -> None:
    global _redraw_fn
    _redraw_fn = None

# ─────────────────────────────────────────────
#  UTILS
# ─────────────────────────────────────────────
def clear() -> None:
    os.system("cls" if os.name == "nt" else "clear")

def fmt_time(secs: float) -> str:
    if secs in (float("inf"), float("-inf")) or secs < 0:
        return "calculating..."
    ms   = int((secs % 1) * 1000)
    s    = int(secs)
    h, r = divmod(s, 3600)
    m, s = divmod(r, 60)
    if h:   return f"{h}h {m}m {s}.{ms:03d}s"
    elif m: return f"{m}m {s}.{ms:03d}s"
    else:   return f"{s}.{ms:03d}s"

def trunc(cookie: str) -> str:
    prefix = "_|WARNING:-DO-NOT-SHARE-"
    if cookie.startswith(prefix):
        return prefix + "***"
    return cookie[:27] + "***" if len(cookie) > 27 else cookie

def parse_proxy(raw: str) -> dict:
    s = raw.strip()
    if s.startswith("socks5://"):   scheme, s = "socks5", s[9:]
    elif s.startswith("http://"):   scheme, s = "http",   s[7:]
    else:                            scheme    = "http"
    if "@" in s:
        creds, hp  = s.rsplit("@", 1)
        user, pw   = creds.split(":", 1)
        host, port = hp.rsplit(":", 1)
    else:
        parts = s.split(":")
        if len(parts) == 4:   host, port, user, pw = parts
        elif len(parts) == 2: host, port, user, pw = parts[0], parts[1], None, None
        else:                 raise ValueError(f"Bad proxy: {raw}")
    url = (f"{scheme}://{user}:{pw}@{host}:{port}"
           if user and pw else f"{scheme}://{host}:{port}")
    return {"http": url, "https": url}

def load(path: str) -> list[str]:
    with open(path) as f:
        return [l.strip() for l in f if l.strip()]

def ensure_files() -> list[str]:
    created = []
    for name in ("cookies.txt", "proxies.txt", "success.txt", "failed.txt", "skipped.txt"):
        if not os.path.exists(name):
            open(name, "w").close()
            created.append(name)
    return created

def divider() -> None:
    w = min(term_width(), 56)
    cprint(dim_purple("─" * w), w)

# ─────────────────────────────────────────────
#  PROXY ERROR DETAIL
# ─────────────────────────────────────────────
def proxy_err(e: Exception) -> str:
    msg = str(e).lower()
    if "timed out" in msg or "timeout" in msg:
        return "Proxy timed out"
    if "refused" in msg or "connection refused" in msg:
        return "Proxy refused connection"
    if "407" in msg or "authentication" in msg:
        return "Proxy auth failed (407)"
    if "name or service not known" in msg or "nodename nor servname" in msg:
        return "Proxy host not found"
    if "remotedisconnected" in msg or "connection reset" in msg:
        return "Proxy dropped connection"
    return f"Proxy error: {type(e).__name__}"

# ─────────────────────────────────────────────
#  NETWORK
# ─────────────────────────────────────────────
def make_session(cookie: str) -> requests.Session:
    s = requests.Session()
    s.mount("https://", HTTPAdapter(pool_connections=1, pool_maxsize=1, max_retries=0))
    s.cookies.set(".ROBLOSECURITY", cookie, domain=".roblox.com")
    return s

def get_csrf(session, proxies):
    try:
        r     = session.post(CSRF_ENDPOINT, proxies=proxies, timeout=CSRF_TIMEOUT)
        token = r.headers.get("x-csrf-token")
        if token: return token, None
        return None, ("Dead/expired cookie"
                      if r.status_code in (401, 403)
                      else f"No CSRF token ({r.status_code})")
    except requests.exceptions.ProxyError as e:     return None, proxy_err(e)
    except requests.exceptions.ConnectTimeout:      return None, f"CSRF timed out (>{CSRF_TIMEOUT}s)"
    except requests.exceptions.ReadTimeout:         return None, f"CSRF read timeout (>{CSRF_TIMEOUT}s)"
    except requests.exceptions.ConnectionError as e:
        msg = str(e).lower()
        if "proxy" in msg: return None, proxy_err(e)
        return None, "Connection error (no route to host)"
    except Exception as e: return None, f"CSRF: {type(e).__name__}"

def get_user_id(session, proxies) -> tuple[int | None, str | None]:
    """Fetch the authenticated user's ID."""
    try:
        r = session.get(USERINFO_URL, proxies=proxies, timeout=CSRF_TIMEOUT)
        if r.status_code == 200:
            return r.json().get("id"), None
        if r.status_code == 401:
            return None, "Dead/expired cookie (401)"
        return None, f"User info HTTP {r.status_code}"
    except requests.exceptions.ProxyError as e:  return None, proxy_err(e)
    except requests.exceptions.ConnectTimeout:   return None, f"User info timed out (>{CSRF_TIMEOUT}s)"
    except requests.exceptions.ConnectionError as e:
        if "proxy" in str(e).lower(): return None, proxy_err(e)
        return None, "Connection error"
    except Exception as e: return None, f"User info: {type(e).__name__}"

def check_ban_status(session, uid: int, proxies) -> tuple[bool | None, str | None]:
    """
    Returns (is_banned, error).
    is_banned = True  → account IS banned, proceed with reactivation
    is_banned = False → account is NOT banned (already active), skip
    is_banned = None  → could not determine
    """
    try:
        r = session.get(BAN_URL.format(uid=uid), proxies=proxies, timeout=CSRF_TIMEOUT)
        if r.status_code == 200:
            data       = r.json()
            is_banned  = data.get("isBanned", False)
            return is_banned, None
        if r.status_code == 404:
            return None, "Ban status endpoint not found (404)"
        if r.status_code == 401:
            return None, "Dead/expired cookie (401)"
        return None, f"Ban status HTTP {r.status_code}"
    except requests.exceptions.ProxyError as e:  return None, proxy_err(e)
    except requests.exceptions.ConnectTimeout:   return None, f"Ban check timed out (>{CSRF_TIMEOUT}s)"
    except requests.exceptions.ConnectionError as e:
        if "proxy" in str(e).lower(): return None, proxy_err(e)
        return None, "Connection error"
    except Exception as e: return None, f"Ban check: {type(e).__name__}"

def reactivate(cookie: str, proxies):
    session    = make_session(cookie)
    token, err = get_csrf(session, proxies)
    if not token: return "failed", err

    # ── Get user ID ───────────────────────────
    uid, err = get_user_id(session, proxies)
    if uid is None: return "failed", err

    # ── Check ban status ──────────────────────
    is_banned, err = check_ban_status(session, uid, proxies)
    if is_banned is None:
        return "failed", err or "Could not determine ban status"
    if not is_banned:
        return "skipped", "Account already active (not moderated)"

    # ── Reactivate ────────────────────────────
    try:
        r = session.post(
            ENDPOINT,
            headers={"Content-Type": "application/json", "x-csrf-token": token},
            json={},
            proxies=proxies,
            timeout=REQ_TIMEOUT,
        )
        if r.status_code == 200: return "success", "Reactivated"
        if r.status_code == 401: return "failed",  "Dead/expired cookie (401)"
        if r.status_code == 403: return "failed",  "Not eligible (403)"
        if r.status_code == 429: return "failed",  "Rate limited (429)"
        try:
            msg = r.json()["errors"][0]["message"]
            return "failed", f"HTTP {r.status_code} — {msg}"
        except Exception:
            return "failed", f"HTTP {r.status_code}"
    except requests.exceptions.ProxyError as e:   return "failed", proxy_err(e)
    except requests.exceptions.ConnectTimeout:    return "failed", f"Request timed out (>{REQ_TIMEOUT}s)"
    except requests.exceptions.ReadTimeout:       return "failed", f"Read timeout (>{REQ_TIMEOUT}s)"
    except requests.exceptions.ConnectionError as e:
        if "proxy" in str(e).lower(): return "failed", proxy_err(e)
        return "failed", "Connection error"
    except Exception as e: return "failed", f"{type(e).__name__}"

# ─────────────────────────────────────────────
#  LIVE DISPLAY
# ─────────────────────────────────────────────
def push_log(idx: int, total_c: int, cookie: str, status: str, reason: str) -> None:
    if status == "success":  icon = green("✔")
    elif status == "skipped": icon = cyan("◎")
    else:                     icon = red("✘")
    num   = f"{idx}/{total_c}"
    short = trunc(cookie)
    line  = f"{icon}  {yellow(num)}  {soft_purple(short)}  {dim_purple(reason)}"
    vlen  = 4 + len(num) + 2 + len(short) + 2 + len(reason)
    with _lock:
        log_lines.append((line, vlen))
        if len(log_lines) > MAX_LOG:
            log_lines.pop(0)

def render(total_c: int, done: int, ok: int, fail: int, skip: int, t0: float) -> None:
    elapsed   = time.time() - t0
    rate      = done / elapsed if elapsed > 0 else 0
    remaining = (total_c - done) / rate if rate > 0 else float("inf")
    pct       = done / total_c * 100 if total_c else 0

    W      = 34
    filled = int(W * done / total_c) if total_c else 0
    bar    = (gradient_text("█" * filled, _offset)
              + dim_purple("░" * (W - filled)))

    sys.stdout.write("\033[2J\033[H")
    print(title_block())
    print()
    cprint(f"[{bar}]  {white(BOLD + f'{pct:.1f}%' + RESET)}", W + 10)
    print()

    w   = term_width()
    pad = " " * max(0, (w - 30) // 2)

    def stat(label: str, val: str) -> None:
        print(f"{pad}{dim_purple(f'{label:<12}')}{val}")

    stat("Total",   white(str(total_c)))
    stat("Done",    white(str(done)))
    stat("Success", green(str(ok)))
    stat("Skipped", cyan(str(skip)))
    stat("Failed",  red(str(fail)))
    stat("ETA",     soft_purple(fmt_time(remaining)))
    stat("Speed",   soft_purple(f"{rate:.1f} req/s"))
    print()
    divider()
    with _lock:
        for line, vlen in log_lines:
            cprint(line, vlen)
    divider()
    sys.stdout.flush()

# ─────────────────────────────────────────────
#  WORKER
# ─────────────────────────────────────────────
def worker(q: Queue) -> None:
    global completed
    while True:
        item = q.get()
        if item is None: break
        idx, cookie, proxy = item
        status, reason = reactivate(cookie, proxy)
        with _lock:
            completed += 1
            if status == "success": success_cookies.append(cookie)
            elif status == "skipped": skipped_cookies.append((cookie, reason))
            else: failed_cookies.append((cookie, reason))
        push_log(idx, total, cookie, status, reason)
        render(total, completed,
               len(success_cookies), len(failed_cookies),
               len(skipped_cookies), start_time)
        q.task_done()

# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
def ask(prompt: str, valid: set[str]) -> str:
    while True:
        idle_stop()
        v = input(center(soft_purple(prompt), len(prompt))).strip().lower()
        if v in valid: return v
        bad = f"Enter one of: {', '.join(sorted(valid))}"
        print(center(red(bad), len(bad)))

def ask_int(prompt: str, lo: int = 1) -> int:
    while True:
        idle_stop()
        try:
            v = int(input(center(soft_purple(prompt), len(prompt))))
            if v >= lo: return v
        except ValueError: pass
        bad = f"Enter a whole number >= {lo}"
        print(center(red(bad), len(bad)))

def cinput(prompt: str) -> str:
    idle_stop()
    return input(center(soft_purple(prompt), len(prompt)))

# ─────────────────────────────────────────────
#  MAIN
# ─────────────────────────────────────────────
def main() -> None:
    global start_time, total

    if os.name == "nt":
        os.system("color")
        try:
            import ctypes
            ctypes.windll.kernel32.SetConsoleMode(
                ctypes.windll.kernel32.GetStdHandle(-11), 7)
        except Exception: pass

    start_anim()

    created = ensure_files()
    body    = [""]
    if created:
        msg = f"Created: {', '.join(created)}"
        body.append(center(dim_purple(msg), len(msg)))
        body.append("")

    cookies = load("cookies.txt")
    if not cookies:
        msg = "cookies.txt is empty — add cookies and re-run."
        idle_start(body + [center(red(msg), len(msg)), ""])
        cinput("Press Enter to exit...")
        stop_anim()
        return

    ck_msg = f"Cookies loaded : {len(cookies)}"
    div    = dim_purple("─" * 44)
    body  += [center(soft_purple(ck_msg), len(ck_msg)), "",
              center(div, 44), ""]
    idle_start(body)

    use_proxies  = ask("Use proxies? (y/n): ", {"y", "n"}) == "y"
    proxies_list = [None]

    if use_proxies:
        raw_proxies = load("proxies.txt")
        if not raw_proxies:
            print(center(yellow("proxies.txt empty — running direct."), 38))
        else:
            parsed, skipped = [], 0
            for r in raw_proxies:
                try:    parsed.append(parse_proxy(r))
                except: skipped += 1
            if parsed:
                proxies_list = parsed
                msg = f"Proxies loaded : {len(parsed)}" + (f"  ({skipped} skipped)" if skipped else "")
                print(center(soft_purple(msg), len(msg)))
            else:
                print(center(yellow("No valid proxies — running direct."), 38))

    print()
    thread_count = ask_int("Threads: ")
    idle_stop()

    total      = len(cookies)
    start_time = time.time()

    q = Queue()
    for i, cookie in enumerate(cookies, 1):
        q.put((i, cookie, proxies_list[(i - 1) % len(proxies_list)]))

    threads = [
        threading.Thread(target=worker, args=(q,), daemon=True)
        for _ in range(min(thread_count, total))
    ]
    for t in threads: t.start()
    q.join()
    for _ in threads: q.put(None)
    for t in threads: t.join()

    stop_anim()

    # ── Summary ───────────────────────────────
    elapsed = time.time() - start_time
    clear()
    print(title_block())
    print()
    divider()
    print()

    w   = term_width()
    pad = " " * max(0, (w - 30) // 2)

    def sstat(label: str, val: str) -> None:
        print(f"{pad}{dim_purple(f'{label:<12}')}{val}")

    sstat("Total",   white(str(total)))
    sstat("Success", green(str(len(success_cookies))))
    sstat("Skipped", cyan(str(len(skipped_cookies))))
    sstat("Failed",  red(str(len(failed_cookies))))
    sstat("Time",    soft_purple(fmt_time(elapsed)))
    print()
    divider()
    print()

    if success_cookies:
        hdr = f"── Successful ({len(success_cookies)}) " + "─" * 20
        cprint(green(hdr), len(hdr))
        for i, c in enumerate(success_cookies, 1):
            short = trunc(c)
            cprint(f"{yellow(f'{i}/{total}')}  {soft_purple(short)}",
                   len(f"{i}/{total}") + 2 + len(short))

    if skipped_cookies:
        print()
        hdr = f"── Skipped / Already Active ({len(skipped_cookies)}) " + "─" * 10
        cprint(cyan(hdr), len(hdr))
        for i, (c, reason) in enumerate(skipped_cookies, 1):
            short = trunc(c)
            cprint(f"{yellow(f'{i}/{total}')}  {soft_purple(short)}  {dim_purple(reason)}",
                   len(f"{i}/{total}") + 2 + len(short) + 2 + len(reason))

    if failed_cookies:
        print()
        hdr = f"── Failed ({len(failed_cookies)}) " + "─" * 24
        cprint(red(hdr), len(hdr))
        for i, (c, reason) in enumerate(failed_cookies, 1):
            short = trunc(c)
            cprint(f"{yellow(f'{i}/{total}')}  {soft_purple(short)}  {dim_purple(reason)}",
                   len(f"{i}/{total}") + 2 + len(short) + 2 + len(reason))

    print()
    divider()
    print()

    with open("success.txt", "w") as f:
        f.write("\n".join(success_cookies))
    with open("failed.txt", "w") as f:
        f.write("\n".join(c for c, _ in failed_cookies))
    with open("skipped.txt", "w") as f:
        f.write("\n".join(c for c, _ in skipped_cookies))

    msg = "Saved  →  success.txt   failed.txt   skipped.txt"
    cprint(dim_purple(msg), len(msg))
    print()
    cinput("Press Enter to exit...")


if __name__ == "__main__":
    main()