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
    ["generator.html", "Builder"],
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

  // ── nav: phone menu, scrolled state, reading progress ──────────────
  const navIn = nav.querySelector(".in");
  const burger = document.createElement("button");
  burger.className = "burger"; burger.setAttribute("aria-label", "Menu"); burger.innerHTML = "<span></span><span></span>";
  navIn.append(burger);
  burger.onclick = () => nav.classList.toggle("menu-open");
  nav.querySelectorAll(".links a").forEach((a) => a.addEventListener("click", () => nav.classList.remove("menu-open")));
  const bar = document.createElement("div"); bar.className = "readbar"; nav.append(bar);
  const onScroll = () => {
    nav.classList.toggle("scrolled", scrollY > 8);
    const max = document.documentElement.scrollHeight - innerHeight;
    bar.style.transform = `scaleX(${max > 0 ? Math.min(1, scrollY / max) : 0})`;
  };
  addEventListener("scroll", onScroll, { passive: true }); onScroll();

  // ── reveal on scroll, staggered inside a row ───────────────────────
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  document.querySelectorAll("article > h2, article > h3, article > pre, article > .note, article > .tablewrap, article > .grid").forEach((el) => el.classList.add("reveal"));
  const revealed = new IntersectionObserver((entries) => {
    entries.forEach((e) => {
      if (!e.isIntersecting) return;
      const el = e.target, sibs = [...el.parentElement.children].filter((c) => c.classList.contains("reveal"));
      const delay = el.closest(".grid") ? Math.min(sibs.indexOf(el), 8) * 60 : 0;
      setTimeout(() => el.classList.add("in-view"), delay);
      revealed.unobserve(el);
    });
  }, { threshold: 0.12, rootMargin: "0px 0px -6% 0px" });
  document.querySelectorAll(".reveal").forEach((el) => (reduce ? el.classList.add("in-view") : revealed.observe(el)));

  // ── cards: a soft light follows the cursor ─────────────────────────
  document.querySelectorAll(".card").forEach((card) => {
    card.addEventListener("pointermove", (e) => {
      const r = card.getBoundingClientRect();
      card.style.setProperty("--mx", e.clientX - r.left + "px");
      card.style.setProperty("--my", e.clientY - r.top + "px");
    });
  });

  // ── buttons: a tiny magnetic pull ──────────────────────────────────
  if (!reduce && matchMedia("(pointer: fine)").matches) {
    document.querySelectorAll(".btn.primary").forEach((b) => {
      b.addEventListener("pointermove", (e) => { const r = b.getBoundingClientRect(); b.style.transform = `translate(${(e.clientX - r.left - r.width / 2) * 0.12}px, ${(e.clientY - r.top - r.height / 2) * 0.2}px)`; });
      b.addEventListener("pointerleave", () => (b.style.transform = ""));
    });
  }

  // ── page enters softly ─────────────────────────────────────────────
  requestAnimationFrame(() => document.body.classList.add("ready"));
})();
