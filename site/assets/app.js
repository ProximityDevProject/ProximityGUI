// Proximity docs: shared header/footer, code highlighting and copy, site
// search (Ctrl+K), table of contents spy, and the particle planet.
(function () {
  const PAGES = [
    ["index.html", "Home"],
    ["start.html", "Start"],
    ["window.html", "Window"],
    ["elements.html", "Elements"],
    ["systems.html", "Systems"],
    ["widgets.html", "Widgets"],
    ["generator.html", "Generator"],
    ["executors.html", "Executors"],
    ["changelog.html", "Changelog"],
  ];
  const LOADER = 'loadstring(game:HttpGet("https://proximitydevproject.github.io/ProximityGUI/Proximity.lua"))()';
  window.PROXIMITY_LOADER = LOADER;
  const here = location.pathname.split("/").pop() || "index.html";

  // header
  const nav = document.createElement("header");
  nav.className = "nav";
  nav.innerHTML = `<div class="in">
    <a class="brand" href="index.html"><img src="assets/logo.png" alt="">Proximity<span>UI</span></a>
    <nav class="links">${PAGES.map(([h, n]) => `<a href="${h}"${h === here ? ' class="on" aria-current="page"' : ""}>${n}</a>`).join("")}</nav>
    <button class="search-btn" id="openSearch" aria-label="Search the docs"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg><span>Search</span><kbd>Ctrl K</kbd></button>
    <a class="gh" href="https://github.com/ProximityDevProject/ProximityGUI"><svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 .5a12 12 0 0 0-3.8 23.4c.6.1.8-.3.8-.6v-2c-3.3.7-4-1.6-4-1.6-.6-1.4-1.4-1.8-1.4-1.8-1.1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1.1 1.8 2.8 1.3 3.5 1 .1-.8.4-1.3.8-1.6-2.7-.3-5.5-1.3-5.5-5.9 0-1.3.5-2.4 1.2-3.2-.1-.3-.5-1.5.1-3.2 0 0 1-.3 3.3 1.2a11.5 11.5 0 0 1 6 0C17.3 4.6 18.3 5 18.3 5c.7 1.7.2 2.9.1 3.2.8.8 1.2 1.9 1.2 3.2 0 4.6-2.8 5.6-5.5 5.9.4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.6A12 12 0 0 0 12 .5Z"/></svg><span>GitHub</span></a>
  </div>`;
  document.body.prepend(nav);

  const foot = document.createElement("footer");
  foot.innerHTML = `<div class="wrap in"><span>Proximity UI · MIT · made for Roblox scripts</span><span><a href="https://github.com/ProximityDevProject/ProximityGUI">GitHub</a> · <a href="changelog.html">Changelog</a> · <a href="executors.html">Executors</a></span></div>`;
  document.body.append(foot);

  // fill loader placeholders
  document.querySelectorAll("[data-loader]").forEach((el) => (el.textContent = LOADER));

  // Lua highlighting (small and good enough for docs)
  const KW = /\b(local|function|end|if|then|else|elseif|for|in|do|while|return|not|and|or|nil|true|false|repeat|until|break)\b/g;
  function highlight(src) {
    const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    const out = [];
    const re = /(--\[\[[\s\S]*?\]\]|--[^\n]*)|("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|(\b\d+(?:\.\d+)?\b)|([\s\S])/g;
    let m, buf = "";
    const flush = () => {
      if (buf) {
        out.push(esc(buf).replace(KW, '<span class="tk-k">$1</span>').replace(/([A-Za-z_]\w*)(?=\s*[({])/g, '<span class="tk-f">$1</span>'));
        buf = "";
      }
    };
    while ((m = re.exec(src))) {
      if (m[1]) { flush(); out.push('<span class="tk-c">' + esc(m[1]) + "</span>"); }
      else if (m[2]) { flush(); out.push('<span class="tk-s">' + esc(m[2]) + "</span>"); }
      else if (m[3]) { flush(); out.push('<span class="tk-n">' + m[3] + "</span>"); }
      else buf += m[4];
    }
    flush();
    return out.join("");
  }
  window.proximityHighlight = highlight;
  document.querySelectorAll("pre > code.lua").forEach((c) => (c.innerHTML = highlight(c.textContent)));

  // copy buttons
  function copyText(text, btn) {
    const done = () => { if (btn) { const t = btn.textContent; btn.textContent = "Copied"; setTimeout(() => (btn.textContent = t), 1400); } };
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(text).then(done, () => fallback(text, done));
    else fallback(text, done);
  }
  function fallback(text, done) {
    const ta = document.createElement("textarea"); ta.value = text; document.body.append(ta); ta.select();
    try { document.execCommand("copy"); done(); } catch (e) {}
    ta.remove();
  }
  window.proximityCopy = copyText;
  document.querySelectorAll("pre").forEach((pre) => {
    const b = document.createElement("button"); b.className = "copy"; b.textContent = "Copy";
    b.onclick = () => copyText(pre.querySelector("code").textContent, b);
    pre.append(b);
  });
  document.querySelectorAll("[data-copy-loader]").forEach((b) => (b.onclick = () => copyText(LOADER, b)));

  // table of contents spy
  const toc = document.querySelector(".toc");
  if (toc) {
    const links = [...toc.querySelectorAll("a[href^='#']")];
    const spy = () => {
      let current = links[0];
      for (const a of links) { const t = document.querySelector(a.getAttribute("href")); if (t && t.getBoundingClientRect().top < 140) current = a; }
      links.forEach((a) => a.classList.toggle("on", a === current));
    };
    addEventListener("scroll", spy, { passive: true }); spy();
  }

  // site search over headings of every page (index built at publish time)
  const dlg = document.createElement("div");
  dlg.className = "sdlg";
  dlg.innerHTML = `<div class="box" role="dialog" aria-label="Search"><input id="sq" placeholder="Search the docs: toggle, configs, key system, fonts..." autocomplete="off"><div class="res" id="sr"></div></div>`;
  document.body.append(dlg);
  let index = null, sel = 0;
  async function ensureIndex() {
    if (index) return index;
    try { index = await (await fetch("assets/search.json")).json(); } catch (e) { index = []; }
    return index;
  }
  function score(q, t) {
    q = q.toLowerCase(); t = t.toLowerCase();
    const i = t.indexOf(q); if (i >= 0) return 100 - i;
    let ti = 0, s = 0; for (const ch of q) { const f = t.indexOf(ch, ti); if (f < 0) return -1; s += f === ti ? 3 : 0; ti = f + 1; } return s;
  }
  async function render() {
    const q = document.getElementById("sq").value.trim();
    const list = (await ensureIndex()).map((e) => [score(q, e.t + " " + (e.d || "")), e]).filter((x) => !q || x[0] >= 0).sort((a, b) => b[0] - a[0]).slice(0, 12);
    sel = 0;
    document.getElementById("sr").innerHTML = list.map(([, e], i) => `<a href="${e.u}" class="${i === 0 ? "on" : ""}">${e.t}<small>${e.p}${e.d ? " · " + e.d : ""}</small></a>`).join("") || '<p style="padding:14px;color:var(--mute)">Nothing found</p>';
  }
  const open = () => { dlg.classList.add("open"); const i = document.getElementById("sq"); i.value = ""; render(); setTimeout(() => i.focus(), 10); };
  const close = () => dlg.classList.remove("open");
  document.getElementById("openSearch").onclick = open;
  dlg.addEventListener("click", (e) => { if (e.target === dlg) close(); });
  document.getElementById("sq").addEventListener("input", render);
  addEventListener("keydown", (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") { e.preventDefault(); open(); }
    if (!dlg.classList.contains("open")) return;
    const items = [...document.querySelectorAll("#sr a")];
    if (e.key === "Escape") close();
    if (e.key === "ArrowDown" || e.key === "ArrowUp") { e.preventDefault(); sel = (sel + (e.key === "ArrowDown" ? 1 : -1) + items.length) % items.length; items.forEach((a, i) => a.classList.toggle("on", i === sel)); }
    if (e.key === "Enter" && items[sel]) location.href = items[sel].href;
  });

  // particle planet (same idea as the in-game loader)
  window.proximityPlanet = function (canvas, opts) {
    opts = opts || {};
    const ctx = canvas.getContext("2d");
    const pts = [];
    const N = opts.points || 1400, R = 1, golden = Math.PI * (3 - Math.sqrt(5));
    for (let i = 0; i < N; i++) { const y = 1 - (i / (N - 1)) * 2, r = Math.sqrt(1 - y * y), t = golden * i; pts.push({ x: Math.cos(t) * r, y, z: Math.sin(t) * r, k: 0 }); }
    for (let i = 0; i < (opts.ring || 700); i++) { const t = Math.random() * Math.PI * 2, rr = 1.42 + Math.pow(Math.random(), 1.6) * 0.5; pts.push({ x: Math.cos(t) * rr, y: (Math.random() - 0.5) * 0.02, z: Math.sin(t) * rr, k: 1, g: Math.random() < 0.06 }); }
    const stars = Array.from({ length: 160 }, () => ({ x: Math.random(), y: Math.random(), s: Math.random() * 1.2 + 0.2, p: Math.random() * 6 }));
    const L = [0.72, 0.55, 0.42]; const ll = Math.hypot(...L); L[0] /= ll; L[1] /= ll; L[2] /= ll;
    let w, h, dpr, angle = 0, t0 = performance.now(), mx = 0, my = 0;
    const resize = () => { dpr = Math.min(devicePixelRatio || 1, 2); w = canvas.clientWidth; h = canvas.clientHeight; canvas.width = w * dpr; canvas.height = h * dpr; ctx.setTransform(dpr, 0, 0, dpr, 0, 0); };
    resize(); addEventListener("resize", resize);
    addEventListener("pointermove", (e) => { mx = e.clientX / innerWidth - 0.5; my = e.clientY / innerHeight - 0.5; }, { passive: true });
    const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const tz = -16 * Math.PI / 180, tx = 74 * Math.PI / 180;
    function frame(now) {
      const t = (now - t0) / 1000;
      angle += reduce ? 0 : 0.0035;
      ctx.clearRect(0, 0, w, h);
      for (const s of stars) { ctx.globalAlpha = 0.15 + 0.35 * (0.5 + 0.5 * Math.sin(t * s.s + s.p)); ctx.fillStyle = "#fff"; ctx.fillRect(s.x * w, s.y * h, s.s, s.s); }
      const size = Math.min(w, h) * (opts.scale || 0.26), cx = w * (opts.cx || 0.5) + mx * 18, cy = h * (opts.cy || 0.48) + my * 12;
      const appear = Math.min(1, t / 1.6), ease = 1 - Math.pow(1 - appear, 3);
      // with a solid 3D planet behind, the points dissolve once assembled
      const dissolve = opts.solid ? Math.max(0, 1 - Math.max(0, t - 1.3) / 1.0) : 1;
      if (opts.solid && dissolve <= 0) { ctx.clearRect(0, 0, w, h); for (const s of stars) { ctx.globalAlpha = 0.15 + 0.35 * (0.5 + 0.5 * Math.sin(t * s.s + s.p)); ctx.fillStyle = "#fff"; ctx.fillRect(s.x * w, s.y * h, s.s, s.s); } ctx.globalAlpha = 1; requestAnimationFrame(frame); return; }
      // soft halo and a dark disc that hides the stars behind the planet
      const halo = ctx.createRadialGradient(cx, cy, size * 0.9, cx, cy, size * 1.9);
      halo.addColorStop(0, `rgba(255,255,255,${0.07 * ease})`); halo.addColorStop(1, "rgba(255,255,255,0)");
      ctx.globalAlpha = 1; ctx.fillStyle = halo; ctx.beginPath(); ctx.arc(cx, cy, size * 1.9, 0, Math.PI * 2); ctx.fill();
      ctx.fillStyle = "#050506"; ctx.beginPath(); ctx.arc(cx, cy, size * 1.0, 0, Math.PI * 2); ctx.fill();
      let flare = null, best = -9;
      for (const p of pts) {
        let x = p.x, y = p.y, z = p.z;
        if (p.k) { const a = angle * 0.6, c = Math.cos(a), s = Math.sin(a); [x, z] = [x * c + z * s, -x * s + z * c]; const c2 = Math.cos(tx), s2 = Math.sin(tx); [y, z] = [y * c2 - z * s2, y * s2 + z * c2]; }
        else { const c = Math.cos(angle), s = Math.sin(angle); [x, z] = [x * c + z * s, -x * s + z * c]; }
        const cz = Math.cos(tz), sz = Math.sin(tz); [x, y] = [x * cz - y * sz, x * sz + y * cz];
        const persp = 3.2 / (3.2 - z), sx = cx + x * size * persp, sy = cy - y * size * persp;
        let a, v;
        if (!p.k) {
          if (z < -0.05) continue;
          const d = Math.max(0, x * L[0] + y * L[1] + z * L[2]); const rim = Math.pow(1 - Math.abs(z), 2.2);
          v = Math.min(1, 0.08 + Math.pow(d, 1.4) * 0.45 + rim * d * 1.7); a = Math.min(1, 0.28 + v * 1.1);
          if (v > 0.6 && y > best) { best = y; flare = [sx, sy]; }
        } else {
          if (z < 0 && x * x + y * y < 1.04) continue;
          v = Math.min(1, 0.35 + x * 0.3 + z * 0.15 + (p.g ? 0.4 : 0)); a = 0.15 + v * 0.65;
        }
        const scatter = (1 - ease) * 400;
        const px = sx + Math.sin(p.x * 99) * scatter, py = sy + Math.cos(p.z * 77) * scatter;
        ctx.globalAlpha = a * ease * dissolve;
        const g = Math.round(55 + v * 200);
        ctx.fillStyle = `rgb(${g},${g},${g})`;
        const r = p.k ? (p.g ? 2.2 : 1.5) : (v > 0.6 ? 2.4 : 1.8);
        ctx.fillRect(px, py, r, r);
      }
      if (flare && appear >= 1) {
        const [fx, fy] = flare, pulse = 0.65 + 0.2 * Math.sin(t * 2.4);
        const grad = ctx.createRadialGradient(fx, fy, 0, fx, fy, size * 0.35);
        grad.addColorStop(0, `rgba(255,255,255,${0.55 * pulse})`); grad.addColorStop(1, "rgba(255,255,255,0)");
        ctx.globalAlpha = 1; ctx.fillStyle = grad; ctx.beginPath(); ctx.arc(fx, fy, size * 0.35, 0, Math.PI * 2); ctx.fill();
        const lg = ctx.createLinearGradient(fx, fy, fx + size * 1.4, fy);
        lg.addColorStop(0, `rgba(255,255,255,${0.7 * pulse})`); lg.addColorStop(1, "rgba(255,255,255,0)");
        ctx.fillStyle = lg; ctx.fillRect(fx, fy - 0.6, size * 1.4, 1.2);
      }
      ctx.globalAlpha = 1;
      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  };
})();
