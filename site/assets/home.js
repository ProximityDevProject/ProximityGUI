// Home page: live previews of the loading screens and the menu animations.
// The menu animations run the same spring and the same choreography as the
// library (src/Window/Motion.luau), so what you see here is what players get.
(function () {
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const clamp01 = (x) => Math.min(1, Math.max(0, x));
  const smooth = (x) => { x = clamp01(x); return x * x * (3 - 2 * x); };
  const TAU = Math.PI * 2;

  // ── count-up stats ─────────────────────────────────────────────────
  const counters = document.querySelectorAll("[data-count]");
  const io = new IntersectionObserver((entries) => {
    entries.forEach((e) => {
      if (!e.isIntersecting) return;
      io.unobserve(e.target);
      const el = e.target, to = +el.dataset.count, t0 = performance.now();
      const step = (now) => { const k = clamp01((now - t0) / 1400); el.textContent = Math.round(to * (1 - Math.pow(1 - k, 4))); if (k < 1) requestAnimationFrame(step); };
      if (!reduce) requestAnimationFrame(step);
    });
  }, { threshold: 0.6 });
  counters.forEach((c) => io.observe(c));

  // ── chips helper ───────────────────────────────────────────────────
  function chips(host, names, pick) {
    const els = names.map((n, i) => {
      const b = document.createElement("button");
      b.className = "chip-btn"; b.textContent = n; b.setAttribute("role", "tab");
      b.onclick = () => pick(i, true);
      host.appendChild(b);
      return b;
    });
    return (i) => els.forEach((b, j) => { b.classList.toggle("on", i === j); b.setAttribute("aria-selected", i === j); });
  }

  // ════════════════════════════════════════════════════════════════════
  // Loading screens
  // ════════════════════════════════════════════════════════════════════
  const LOADS = [
    ["Planet", "Points fly in, land on a turning 3D planet and fuse into its surface. When everything is ready it bursts and the window grows out of it."],
    ["Orbit", "Three orbits with moons. Ticks around the outside light up with real progress, the percent sits in the middle. The orbits fold into the centre."],
    ["Eclipse", "A black moon slides over a white sun as the menu loads. At 100% the corona flares and a diamond ring flashes."],
    ["Constellation", "Stars appear and thin lines join them one by one as progress grows. The finished picture flashes and the stars rush in."],
    ["Terminal", "A small boot console types out every loading step with an ASCII bar, the percent and the time left."],
    ["Skeleton", "The window opens at once with a shimmering outline of the menu, and a soft wipe reveals the real thing."],
    ["None", "No loading screen: the window opens with your menu animation as soon as it is built."],
  ];
  const lc = document.getElementById("loadPreview");
  if (lc) {
    const ctx = lc.getContext("2d");
    let style = 0, t0 = performance.now(), W = 0, H = 0;
    const size = () => { const r = lc.getBoundingClientRect(), d = Math.min(devicePixelRatio || 1, 2); W = r.width; H = r.height; lc.width = W * d; lc.height = H * d; ctx.setTransform(d, 0, 0, d, 0, 0); };
    size(); addEventListener("resize", size);
    const mark = chips(document.getElementById("loadChips"), LOADS.map((l) => l[0]), (i) => { style = i; t0 = performance.now(); show(); });
    function show() {
      mark(style);
      document.getElementById("loadName").textContent = LOADS[style][0];
      document.getElementById("loadText").textContent = LOADS[style][1];
      const code = document.getElementById("loadCode");
      code.innerHTML = proximityHighlight(style === 6 ? "Proximity:Window({\n    Loading = false,\n})" : `Proximity:Window({\n    Loading = { Style = "${LOADS[style][0]}" },\n})`);
    }
    show();

    // fixed random sets
    const rnd = (() => { let s = 11; return () => ((s = (s * 16807) % 2147483647) / 2147483647); })();
    const sphere = []; for (let i = 0; i < 380; i++) { const y = 1 - (i / 379) * 2, r = Math.sqrt(1 - y * y), a = 2.39996 * i; sphere.push([Math.cos(a) * r, y, Math.sin(a) * r, rnd()]); }
    const ringPts = []; for (let i = 0; i < 260; i++) ringPts.push([rnd() * TAU, 1.4 + Math.pow(rnd(), 1.3) * 0.55, rnd()]);
    const stars = []; for (let i = 0; i < 15; i++) stars.push([0.18 + rnd() * 0.64, 0.14 + rnd() * 0.56]);
    const edges = []; { const used = new Set([0]); let cur = 0; for (let k = 1; k < stars.length; k++) { let best = -1, bd = 9; stars.forEach((s, j) => { if (!used.has(j)) { const d = Math.hypot(s[0] - stars[cur][0], s[1] - stars[cur][1]); if (d < bd) { bd = d; best = j; } } }); used.add(best); edges.push([cur, best]); cur = best; } edges.push([2, 9], [5, 12], [0, 7]); }
    const dust = []; for (let i = 0; i < 70; i++) dust.push([rnd(), rnd(), rnd()]);

    function info(p, ready) {
      // the progress block under the art
      const x = W * 0.5 - 110, y = H - 54;
      ctx.globalAlpha = 1;
      ctx.fillStyle = "#fff"; ctx.font = "600 12px Manrope"; ctx.textAlign = "left"; ctx.fillText("My Hub", x, y);
      ctx.textAlign = "right"; ctx.font = "600 11px 'JetBrains Mono'"; ctx.fillText(Math.round(p * 100) + "%", x + 220, y);
      ctx.fillStyle = "rgba(255,255,255,.14)"; ctx.fillRect(x, y + 9, 220, 2);
      ctx.fillStyle = "#fff"; ctx.fillRect(x, y + 9, 220 * p, 2);
      ctx.fillStyle = "#9a9aa3"; ctx.textAlign = "left"; ctx.font = "11px Manrope";
      ctx.fillText(ready ? "Ready" : p < 0.5 ? "Building tabs" : "Downloading item database", x, y + 28);
    }

    const R = {};
    R.Planet = (p, t, k) => {
      const cx = W / 2, cy = H * 0.42, r = Math.min(W, H) * 0.17, spin = t * 0.5, solid = smooth((p - 0.35) / 0.5);
      const tilt = 0.26, roll = -0.3;
      // solid planet growing in under the points
      if (solid > 0) {
        ctx.globalAlpha = solid;
        const g = ctx.createRadialGradient(cx + r * 0.45, cy - r * 0.45, r * 0.1, cx, cy, r);
        g.addColorStop(0, "#2a2a2f"); g.addColorStop(0.55, "#0d0d10"); g.addColorStop(1, "#050506");
        ctx.fillStyle = g; ctx.beginPath(); ctx.arc(cx, cy, r, 0, TAU); ctx.fill();
        ctx.strokeStyle = "rgba(255,255,255,.95)"; ctx.lineWidth = 1.6; ctx.beginPath(); ctx.arc(cx, cy, r - 0.5, -1.9, 0.35); ctx.stroke();
      }
      const proj = (x, y, z) => { const c = Math.cos(roll), s = Math.sin(roll); const yy = y * Math.cos(tilt) - z * Math.sin(tilt), zz = y * Math.sin(tilt) + z * Math.cos(tilt); return [cx + (x * c - yy * s) * r, cy - (x * s + yy * c) * r, zz]; };
      // ring (back half, then planet points, then front half)
      for (const pass of [0, 1]) {
        for (const q of ringPts) {
          const a = q[0] + spin * 0.6, x = Math.cos(a) * q[1], z = Math.sin(a) * q[1];
          const [sx, sy, sz] = proj(x, 0, z);
          if ((sz > 0) !== (pass === 1)) continue;
          if (sz <= 0 && Math.hypot(sx - cx, sy - cy) < r && solid > 0.5) continue;
          const arrive = smooth((t - q[2] * 0.8) / 1.0);
          ctx.globalAlpha = arrive * (0.35 + 0.5 * (x > 0 ? 1 : 0.5)) * (1 - solid * 0.3);
          ctx.fillStyle = "#fff"; ctx.fillRect(sx - 0.7, sy - 0.7, 1.4, 1.4);
        }
        if (pass === 0) for (const q of sphere) {
          const c = Math.cos(spin), s = Math.sin(spin);
          const x = q[0] * c + q[2] * s, z = -q[0] * s + q[2] * c, [sx, sy, sz] = proj(x, q[1], z);
          if (sz < 0) continue;
          const arrive = smooth((t - q[3] * 0.8) / 1.0), lit = clamp01(0.3 + x * 0.5 + q[1] * 0.3);
          const fx = cx + (sx - cx) * (1 + (1 - arrive) * 3), fy = cy + (sy - cy) * (1 + (1 - arrive) * 3);
          ctx.globalAlpha = arrive * (0.25 + lit * 0.6) * (1 - solid * 0.9);
          ctx.fillStyle = lit > 0.6 ? "#fff" : lit > 0.35 ? "#9a9aa3" : "#55555c"; ctx.fillRect(fx - 0.8, fy - 0.8, 1.6, 1.6);
        }
      }
    };
    R.Orbit = (p, t) => {
      const cx = W / 2, cy = H * 0.42, a = smooth(t / 0.7);
      [34, 56, 78].forEach((rad, i) => {
        ctx.globalAlpha = a * 0.25; ctx.strokeStyle = "#fff"; ctx.lineWidth = 1; ctx.beginPath(); ctx.arc(cx, cy, rad, 0, TAU); ctx.stroke();
        const ang = t * [1.2, -0.8, 0.5][i] + i * 2;
        ctx.globalAlpha = a; ctx.fillStyle = "#fff"; ctx.beginPath(); ctx.arc(cx + Math.cos(ang) * rad, cy + Math.sin(ang) * rad, i ? 2 : 2.8, 0, TAU); ctx.fill();
      });
      const n = 64;
      for (let i = 0; i < n; i++) {
        const ang = (i / n) * TAU - Math.PI / 2, on = clamp01(p * n - i);
        ctx.globalAlpha = a * (0.12 + on * 0.85); ctx.strokeStyle = "#fff"; ctx.lineWidth = 1.6;
        const r1 = 94, r2 = i % 8 ? 99 : 102;
        ctx.beginPath(); ctx.moveTo(cx + Math.cos(ang) * r1, cy + Math.sin(ang) * r1); ctx.lineTo(cx + Math.cos(ang) * r2, cy + Math.sin(ang) * r2); ctx.stroke();
      }
      ctx.globalAlpha = a; ctx.fillStyle = "#fff"; ctx.font = "600 22px 'JetBrains Mono'"; ctx.textAlign = "center"; ctx.fillText(Math.round(p * 100), cx, cy + 8);
    };
    R.Eclipse = (p, t) => {
      const cx = W / 2, cy = H * 0.42, r = 34, cover = smooth(p), total = smooth((cover - 0.9) / 0.1), a = smooth(t / 0.6);
      const g = ctx.createRadialGradient(cx, cy, r, cx, cy, r * 3.4);
      g.addColorStop(0, `rgba(255,255,255,${0.06 + total * 0.4})`); g.addColorStop(1, "rgba(255,255,255,0)");
      ctx.globalAlpha = a; ctx.fillStyle = g; ctx.beginPath(); ctx.arc(cx, cy, r * 3.4, 0, TAU); ctx.fill();
      ctx.fillStyle = "#f2f2f4"; ctx.beginPath(); ctx.arc(cx, cy, r, 0, TAU); ctx.fill();
      const off = (1 - cover) * r * 2.3;
      ctx.fillStyle = "#030304"; ctx.beginPath(); ctx.arc(cx - off, cy + off * 0.35, r + 1, 0, TAU); ctx.fill();
      if (total > 0) {
        const dx = cx + Math.cos(-0.66) * r, dy = cy + Math.sin(-0.66) * r;
        ctx.globalAlpha = total; ctx.fillStyle = "#fff"; ctx.beginPath(); ctx.arc(dx, dy, 3, 0, TAU); ctx.fill();
        ctx.fillRect(dx - 60, dy - 0.5, 120, 1);
      }
    };
    R.Constellation = (p, t) => {
      for (const d of dust) { ctx.globalAlpha = 0.15 + 0.15 * Math.sin(t * 2 + d[2] * 9); ctx.fillStyle = "#fff"; ctx.fillRect(d[0] * W, d[1] * (H - 70), 1, 1); }
      const want = p * edges.length;
      ctx.strokeStyle = "#fff"; ctx.lineWidth = 1;
      edges.forEach((e, i) => {
        const q = smooth(clamp01(want - i)); if (q <= 0) return;
        const a = stars[e[0]], b = stars[e[1]];
        ctx.globalAlpha = 0.5; ctx.beginPath(); ctx.moveTo(a[0] * W, a[1] * H); ctx.lineTo((a[0] + (b[0] - a[0]) * q) * W, (a[1] + (b[1] - a[1]) * q) * H); ctx.stroke();
      });
      stars.forEach((s, i) => { const k = smooth((t - i * 0.05) / 0.5); ctx.globalAlpha = k; ctx.fillStyle = "#fff"; ctx.beginPath(); ctx.arc(s[0] * W, s[1] * H, i % 4 ? 1.8 : 2.6, 0, TAU); ctx.fill(); });
    };
    R.Terminal = (p, t) => {
      const x = W / 2 - 150, y = H * 0.16, w = 300, h = 150, a = smooth(t / 0.4);
      ctx.globalAlpha = a; ctx.fillStyle = "#0b0b0d"; ctx.strokeStyle = "#2e2e34";
      ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill(); ctx.stroke();
      ctx.fillStyle = "#8a8a92"; ctx.font = "10px 'JetBrains Mono'"; ctx.textAlign = "left"; ctx.fillText("my hub  ·  boot", x + 12, y + 18);
      ctx.fillStyle = "#26262c"; ctx.fillRect(x, y + 27, w, 1);
      const lines = ["$ proximity load", "resolving theme, fonts, configs", `> Downloading item database · ${Math.round(clamp01(p * 1.3) * 100)}%`, `> Scanning players · ${Math.round(clamp01(p * 1.8) * 100)}%`];
      let budget = t * 60;
      lines.forEach((l, i) => { const s = l.slice(0, Math.max(0, Math.floor(budget))); budget -= l.length; ctx.fillStyle = i < 2 ? "#8a8a92" : "#e2e2e6"; ctx.fillText(s, x + 12, y + 46 + i * 15); });
      if (budget > 0) { const n = 20, f = Math.round(p * n); ctx.fillStyle = "#fff"; ctx.fillText("[" + "#".repeat(f) + ".".repeat(n - f) + "] " + Math.round(p * 100) + "%", x + 12, y + 112); if (Math.floor(t * 2.2) % 2 === 0) ctx.fillText("_", x + 12, y + 127); }
    };
    R.Skeleton = (p, t) => {
      const x = W / 2 - 150, y = H * 0.14, w = 300, h = 170;
      ctx.fillStyle = "#0b0b0d"; ctx.strokeStyle = "#26262c"; ctx.beginPath(); ctx.roundRect(x, y, w, h, 8); ctx.fill(); ctx.stroke();
      const shimmer = (t * 0.9) % 1.6 - 0.3;
      const bar = (bx, by, bw, bh) => { const g = ctx.createLinearGradient(x + (shimmer - 0.2) * w, 0, x + (shimmer + 0.2) * w, 0); g.addColorStop(0, "#17171b"); g.addColorStop(0.5, "#26262c"); g.addColorStop(1, "#17171b"); ctx.fillStyle = g; ctx.beginPath(); ctx.roundRect(bx, by, bw, bh, 3); ctx.fill(); };
      for (let i = 0; i < 5; i++) bar(x + 12, y + 16 + i * 22, 64, 10);
      for (let i = 0; i < 5; i++) { bar(x + 96, y + 20 + i * 26, 90, 9); bar(x + 200, y + 20 + i * 26, 84, 9); }
      ctx.fillStyle = "#fff"; ctx.font = "600 11px 'JetBrains Mono'"; ctx.textAlign = "right"; ctx.fillText(Math.round(p * 100) + "%", x + w - 12, y + h - 10);
    };
    R.None = (p, t) => {
      const k = smooth(t / 0.5), x = W / 2 - 150, y = H * 0.14 + (1 - k) * 20;
      ctx.globalAlpha = k; ctx.fillStyle = "#0b0b0d"; ctx.strokeStyle = "#3a3a42"; ctx.beginPath(); ctx.roundRect(x, y, 300, 170, 8); ctx.fill(); ctx.stroke();
      ctx.fillStyle = "#fff"; ctx.font = "600 12px Manrope"; ctx.textAlign = "left"; ctx.fillText("My Hub", x + 14, y + 22);
      ctx.fillStyle = "#1c1c21"; for (let i = 0; i < 4; i++) { ctx.fillRect(x + 96, y + 44 + i * 26, 180, 14); }
    };

    function frame(now) {
      const r = lc.getBoundingClientRect();
      if (r.bottom > 0 && r.top < innerHeight) {
        const t = (now - t0) / 1000, cyc = 6.2, ct = reduce ? 4.5 : t % cyc;
        const p = smooth(clamp01(ct / 4.2)), ready = ct > 4.2, fade = 1 - smooth((ct - 5.4) / 0.6);
        ctx.clearRect(0, 0, W, H);
        ctx.save(); ctx.globalAlpha = 1;
        const name = LOADS[style][0];
        ctx.globalCompositeOperation = "source-over";
        R[name](p, ct);
        ctx.restore();
        if (name !== "Terminal" && name !== "None") info(p, ready);
        if (fade < 1) { ctx.globalAlpha = 1 - fade; ctx.fillStyle = "#08080a"; ctx.fillRect(0, 0, W, H); }
        ctx.globalAlpha = 1;
      }
      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  }

  // ════════════════════════════════════════════════════════════════════
  // Menu animations - a port of Motion.luau
  // ════════════════════════════════════════════════════════════════════
  const ANIMS = {
    Planet: { open: [2.3, 0.74], close: [3.4, 1], text: "Grows out of the planet button with a ripple, curving in, and folds back into it." },
    Rise: { open: [2.1, 0.86], close: [3.2, 1], text: "Lifts into place from slightly below while the shadow deepens." },
    Zoom: { open: [2.7, 0.58], close: [3.6, 1], text: "Springs out of the centre with a lively overshoot." },
    Drop: { open: [2.0, 0.5], close: [3.0, 1], text: "Falls from above with a slight tilt and settles with a wobble." },
    Slide: { open: [2.2, 0.8], close: [3.2, 1], text: "Glides in from the nearest side of the screen." },
    Swing: { open: [1.7, 0.45], close: [3.0, 1], text: "Swings down on its top-left hinge like a hanging sign." },
    Wipe: { open: [1.45, 1], close: [2.3, 1], text: "A glowing diagonal edge sweeps across and reveals it." },
    Unfold: { open: [1.6, 1], close: [2.5, 1], text: "Opens from a bright line in the middle, top and bottom apart." },
    Scan: { open: [1.35, 1], close: [2.2, 1], text: "A scan band runs down and draws it line by line." },
    Glitch: { open: [1.5, 1], close: [2.4, 1], text: "Arrives in flickering horizontal slices with a little jitter." },
    Fade: { open: [1.8, 1], close: [2.8, 1], text: "A quiet fade with a gentle focus pull." },
  };
  const NAMES = Object.keys(ANIMS);
  const win = document.getElementById("miniWin"), fxEl = document.getElementById("miniFx");
  if (win) {
    let cur = 0, p = 1, v = 0, target = 1, auto = true, timer = 0;
    const mark = chips(document.getElementById("animChips"), NAMES, (i, user) => { cur = i; if (user) auto = false; show(); play(); });
    function show() {
      mark(cur);
      document.getElementById("animName").textContent = NAMES[cur];
      document.getElementById("animText").textContent = ANIMS[NAMES[cur]].text;
      document.getElementById("animCode").innerHTML = proximityHighlight(`Proximity:Window({ Animation = "${NAMES[cur]}" })\n-- or later\nWindow:SetAnimation("${NAMES[cur]}")`);
    }
    // css gradient from [position, transparency] pairs (Roblox angle -> css angle)
    const grad = (rot, pts) => `linear-gradient(${90 + rot}deg, ${pts.map(([x, tr]) => `rgba(0,0,0,${1 - clamp01(tr)}) ${(clamp01(x) * 100).toFixed(2)}%`).join(", ")})`;
    const glow = (rot, pts) => `linear-gradient(${90 + rot}deg, ${pts.map(([x, tr]) => `rgba(255,255,255,${1 - clamp01(tr)}) ${(clamp01(x) * 100).toFixed(2)}%`).join(", ")})`;
    const SL = [0.31, 0.72, 0.12, 0.55, 0.86, 0.2, 0.64, 0.41, 0.05];
    function map(name, p) {
      const c = { x: 0, y: 0, s: 1, r: 0, a: 1, e: 1, mask: null, fx: null, fxa: 0 };
      const q = clamp01(p);
      switch (name) {
        case "Planet": c.x = -150 * (1 - Math.pow(q, 0.8)); c.y = 95 * (1 - Math.pow(q, 1.15)); c.s = 0.04 + 0.96 * p; c.r = (1 - q) * -8; c.a = clamp01(p * 2.4); c.e = clamp01(p * 1.3); break;
        case "Rise": c.y = (1 - p) * 30; c.s = 0.95 + 0.05 * p; c.a = clamp01(p * 1.5); c.e = clamp01(p * 1.2); break;
        case "Zoom": c.s = 0.8 + 0.2 * p; c.a = clamp01(p * 2.2); c.e = clamp01(p * 1.5); c.y = (1 - p) * 8; break;
        case "Drop": c.y = -(1 - p) * 100; c.r = (1 - p) * -3.2; c.s = 0.96 + 0.04 * p; c.a = clamp01(p * 2.6); c.e = clamp01(p * 1.4); break;
        case "Slide": c.x = -(1 - p) * 180; c.r = (1 - p) * 1.6; c.a = clamp01(p * 1.9); c.e = clamp01(p * 1.3); break;
        case "Swing": { const th = -(1 - p) * 17, rr = th * Math.PI / 180, vx = 140, vy = 92; c.r = th; c.x = vx * Math.cos(rr) - vy * Math.sin(rr) - vx; c.y = vx * Math.sin(rr) + vy * Math.cos(rr) - vy + (1 - p) * 14; c.s = 0.96 + 0.04 * p; c.a = clamp01(p * 2.4); c.e = clamp01(p * 1.4); break; }
        case "Wipe": { const e = p * 1.42 - 0.21; c.mask = grad(24, [[0, 0], [e - 0.09, 0], [e + 0.09, 1], [1, 1]]); c.fx = glow(24, [[0, 1], [e - 0.05, 1], [e + 0.05, 0.45], [e + 0.11, 1], [1, 1]]); c.fxa = Math.sin(q * Math.PI); c.e = 0.7 + 0.3 * q; c.x = (1 - p) * -10; break; }
        case "Unfold": { const h = q * 0.57; c.mask = grad(90, [[0, 1], [0.5 - h - 0.04, 1], [0.5 - h, 0], [0.5 + h, 0], [0.5 + h + 0.04, 1], [1, 1]]); c.fx = glow(90, [[0, 1], [0.5 - h - 0.035, 1], [0.5 - h, 0.35], [0.5 - h + 0.03, 1], [0.5 + h - 0.03, 1], [0.5 + h, 0.35], [0.5 + h + 0.035, 1], [1, 1]]); c.fxa = (1 - clamp01((p - 0.8) / 0.2)) * clamp01(p * 6); c.s = 0.985 + 0.015 * p; c.e = 0.75 + 0.25 * q; break; }
        case "Scan": { const e = p * 1.16 - 0.08; c.mask = grad(90, [[0, 0], [e, 0], [e + 0.03, 1], [1, 1]]); c.fx = glow(90, [[0, 1], [e - 0.14, 1], [e - 0.005, 0.72], [e + 0.004, 0.15], [e + 0.02, 1], [1, 1]]); c.fxa = Math.pow(Math.sin(q * Math.PI), 0.6); c.e = 0.8 + 0.2 * q; break; }
        case "Glitch": { const calm = q * q, seed = Math.floor(performance.now() / 45); const r = (k) => { const x = Math.sin(seed * 12.9898 + k * 78.233) * 43758.5453; return x - Math.floor(x); }; const pts = []; SL.forEach((at, k) => { let on = p * 1.18 - 0.08 > at; if (p < 0.97 && r(k) < 0.14 * (1 - calm)) on = !on; pts.push([k / 9, on ? 0 : 1], [(k + 1) / 9 - 0.001, on ? 0 : 1]); }); c.mask = grad(90, pts); c.x = (r(20) - 0.5) * 16 * (1 - calm); c.e = 0.65 + 0.35 * q + (r(30) < 0.2 ? 0.25 * (1 - calm) : 0); c.fx = "linear-gradient(#fff,#fff)"; c.fxa = (r(40) < 0.25 ? 0.18 : 0.04) * (1 - calm); break; }
        case "Fade": c.s = 1.018 - 0.018 * p; c.a = q; c.e = q; break;
      }
      return c;
    }
    function apply() {
      const c = map(NAMES[cur], p);
      win.style.transform = `translate(${c.x}px, ${c.y}px) rotate(${c.r}deg) scale(${Math.max(c.s, 0.01)})`;
      win.style.opacity = c.a;
      win.style.filter = `brightness(${0.42 + 0.58 * clamp01(c.e)})`;
      win.style.webkitMaskImage = win.style.maskImage = c.mask || "none";
      fxEl.style.background = c.fx || "none";
      fxEl.style.opacity = c.fxa;
      win.classList.toggle("tilted", Math.abs(c.r) > 0.5);
    }
    let last = performance.now();
    function tick(now) {
      const dt = Math.min((now - last) / 1000, 1 / 20); last = now;
      const spec = ANIMS[NAMES[cur]][target ? "open" : "close"], w = spec[0] * TAU, z = spec[1];
      const n = Math.ceil(dt / (1 / 240)), h = dt / n;
      for (let i = 0; i < n; i++) { const a = -w * w * (p - target) - 2 * z * w * v; v += a * h; p += v * h; }
      if (!target) p = Math.max(p, -0.02);
      apply();
      requestAnimationFrame(tick);
    }
    function play() {
      clearTimeout(timer);
      target = 0;
      timer = setTimeout(() => {
        target = 1;
        timer = setTimeout(() => { if (auto) { cur = (cur + 1) % NAMES.length; show(); } play(); }, 2400);
      }, 650);
    }
    show();
    if (!reduce) { requestAnimationFrame(tick); const o = new IntersectionObserver((e) => { if (e[0].isIntersecting) { play(); o.disconnect(); } }); o.observe(win); }
  }
})();
