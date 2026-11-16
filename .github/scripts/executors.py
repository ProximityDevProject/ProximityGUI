"""Append the current WEAO executor status to executors-history.json.

Runs in the "Executor history" workflow on a timer. The file lives on the
"data" branch so these commits never touch main. The site reads it from
raw.githubusercontent.com and draws a status timeline for every executor.
"""
import json
import os
import sys
import time
import urllib.request

OUT = sys.argv[1] if len(sys.argv) > 1 else "executors-history.json"
KEEP_DAYS = 60


def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": "WEAO-3PService"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


exploits = get("https://weao.xyz/api/status/exploits")
try:
    current = get("https://weao.xyz/api/versions/current")
except Exception:
    current = {}

history = {"points": [], "info": {}}
if os.path.exists(OUT):
    with open(OUT, encoding="utf-8") as f:
        history = json.load(f)

now = int(time.time())
snap = {}
for ex in exploits:
    key = f'{ex.get("title")} · {ex.get("platform")}'
    platform = ex.get("platform") or ""
    rbx = current.get("Windows") if platform == "Windows" else current.get(platform)
    up = bool(ex.get("updateStatus")) and (not rbx or not ex.get("rbxversion") or ex.get("rbxversion") == rbx)
    snap[key] = [1 if up else 0, ex.get("suncPercentage"), ex.get("version")]
    history["info"][key] = {
        "name": ex.get("title"),
        "platform": platform,
        "free": bool(ex.get("free")),
        "cost": ex.get("cost"),
        "unc": ex.get("uncPercentage"),
        "sunc": ex.get("suncPercentage"),
        "version": ex.get("version"),
        "updated": ex.get("updatedDate"),
        "detected": bool(ex.get("detected")),
        "decompiler": bool(ex.get("decompiler")),
        "multi": bool(ex.get("multiInject")),
        "beta": bool(ex.get("beta")),
        "site": ex.get("websitelink"),
        "up": bool(up),
    }

history["points"].append([now, snap])
cut = now - KEEP_DAYS * 86400
history["points"] = [p for p in history["points"] if p[0] >= cut]
history["updated"] = now

with open(OUT, "w", encoding="utf-8") as f:
    json.dump(history, f, separators=(",", ":"), ensure_ascii=False)
print(f"{len(snap)} executors, {len(history['points'])} points")
