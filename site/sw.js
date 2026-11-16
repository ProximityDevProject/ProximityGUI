// Proximity docs offline cache. Pages and assets are served from the cache
// right away and refreshed in the background, so the docs open without
// internet once you have visited them.
const CACHE = "px-docs-v2";
const CORE = [
  "./", "index.html", "start.html", "window.html", "elements.html", "systems.html", "widgets.html",
  "generator.html", "executors.html", "changelog.html", "community.html",
  "assets/style.css", "assets/app.js", "assets/i18n.js", "assets/planet.js", "assets/home.js",
  "assets/logo.png", "assets/search.json", "assets/versions.json",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => Promise.all(CORE.map((u) => c.add(u).catch(() => {})))).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(caches.keys().then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))).then(() => self.clients.claim()));
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  const same = url.origin === location.origin;
  const fonts = url.host === "fonts.googleapis.com" || url.host === "fonts.gstatic.com";
  if (!same && !fonts) return; // live data (WEAO, GitHub) always goes to the network
  if (same && /\.(lua|luau)$/.test(url.pathname)) return; // the script itself is never cached here
  e.respondWith(
    caches.open(CACHE).then(async (cache) => {
      const hit = await cache.match(req, { ignoreSearch: same });
      const net = fetch(req).then((res) => { if (res.ok || res.type === "opaque") cache.put(req, res.clone()); return res; }).catch(() => hit);
      return hit || net;
    })
  );
});
