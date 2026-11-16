// Proximity planet: thousands of points fly in and land on a real 3D planet
// with a tilted ring. The planet turns on its own axis the whole time and the
// solid surface is grown patch by patch exactly where the points have landed:
// the points and the WebGL render share one geometry, one spin and one
// "build" front, so nothing is swapped for a picture.
(function () {
  const TAU = Math.PI * 2;
  const FLAT = 0.26, ROLL = 17 * Math.PI / 180;           // ring seen almost edge on, rising to the right
  const RING_IN = 1.36, RING_OUT = 1.9;
  const SPIN_SPEED = 0.22;                                 // rad / s, a full turn in ~28 s
  const ny = Math.sqrt(1 - FLAT * FLAT);
  const N = [-Math.sin(ROLL) * ny, Math.cos(ROLL) * ny, FLAT];   // planet axis = ring normal
  const E1 = [Math.cos(ROLL), Math.sin(ROLL), 0];
  const E2 = [N[1] * E1[2] - N[2] * E1[1], N[2] * E1[0] - N[0] * E1[2], N[0] * E1[1] - N[1] * E1[0]];
  const L = (() => { const v = [0.72, 0.58, 0.38], l = Math.hypot(...v); return v.map(x => x / l); })();

  // the order in which the surface materialises, in planet (object) space -
  // the shader has the exact same function
  const thrSphere = (a, h, c) => Math.min(0.98, Math.max(0.02, 0.5 + 0.24 * Math.sin(3.7 * a + 1.3 + 2.0 * h) + 0.2 * Math.sin(3.1 * h + 2.1) * Math.cos(2.9 * c - 0.6) + 0.14 * Math.sin(5.3 * c + 1.7 * a + 0.4)));
  const thrRing = (th, r) => Math.min(1, Math.max(0, 0.08 + 0.8 * (th / TAU + 0.5) + 0.12 * (r - RING_IN) / 0.6));
  const wrap = a => { a = (a + Math.PI) % TAU; if (a < 0) a += TAU; return a - Math.PI; };

  const FS = `
precision highp float;
uniform vec2 res; uniform float time; uniform float build; uniform float spin; uniform vec3 place;
uniform vec3 uN; uniform vec3 uE1; uniform vec3 uE2;
const float PI = 3.14159265;
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p){ vec2 i = floor(p), f = fract(p); f = f*f*(3.0-2.0*f);
  return mix(mix(hash(i), hash(i+vec2(1,0)), f.x), mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)), f.x), f.y); }
float fbm(vec2 p){ float v = 0.0, a = 0.5; for (int i = 0; i < 5; i++){ v += a*noise(p); p = p*2.03 + 7.1; a *= 0.5; } return v; }
float hash3(vec3 p){ return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453); }
float noise3(vec3 p){ vec3 i = floor(p), f = fract(p); f = f*f*(3.0-2.0*f);
  float a = mix(hash3(i), hash3(i+vec3(1,0,0)), f.x), b = mix(hash3(i+vec3(0,1,0)), hash3(i+vec3(1,1,0)), f.x);
  float c = mix(hash3(i+vec3(0,0,1)), hash3(i+vec3(1,0,1)), f.x), d = mix(hash3(i+vec3(0,1,1)), hash3(i+vec3(1,1,1)), f.x);
  return mix(mix(a, b, f.y), mix(c, d, f.y), f.z); }
float fbm3(vec3 p){ float v = 0.0, a = 0.5; for (int i = 0; i < 4; i++){ v += a*noise3(p); p = p*2.02 + 3.1; a *= 0.5; } return v; }
float thrS(vec3 o){ return clamp(0.5 + 0.24*sin(3.7*o.x + 1.3 + 2.0*o.y) + 0.2*sin(3.1*o.y + 2.1)*cos(2.9*o.z - 0.6) + 0.14*sin(5.3*o.z + 1.7*o.x + 0.4), 0.02, 0.98); }
vec3 toObj(vec3 v){ float a1 = dot(v, uE1), c1 = dot(v, uE2), cs = cos(spin), sn = sin(spin);
  return vec3(a1*cs + c1*sn, dot(v, uN), -a1*sn + c1*cs); }
// ring structure by radius: faint inner ring, bright main ring, a dark gap,
// the outer ring with its own thin gap, all made of fine ringlets
float ringDensity(float r){
  float c = smoothstep(1.25, 1.31, r) * smoothstep(1.41, 1.37, r) * 0.22;
  float b = smoothstep(1.40, 1.44, r) * smoothstep(1.71, 1.68, r) * (0.82 + 0.18 * sin(r * 97.0));
  float a = smoothstep(1.75, 1.78, r) * smoothstep(1.93, 1.90, r) * 0.62;
  a *= 1.0 - smoothstep(0.011, 0.0, abs(r - 1.86)) * 0.85;
  float fine = 0.72 + 0.2 * noise(vec2(r * 230.0, 3.0)) + 0.16 * noise(vec2(r * 61.0, 1.0));
  return clamp((c + b + a) * fine, 0.0, 1.0);
}

void main(){
  vec2 q = (gl_FragCoord.xy - place.xy) / place.z;      // planet radii, y up
  vec3 L = normalize(vec3(0.72, 0.58, 0.38));
  vec3 col = vec3(0.0); float alpha = 0.0;
  float settle = smoothstep(0.75, 1.05, build);

  // nebula wisps, brighter towards the light
  float wis = fbm(q*0.7 + vec2(time*0.012, -time*0.008));
  float wis2 = fbm(q*1.35 - vec2(time*0.02, 0.0) + wis*1.6);
  float neb = smoothstep(0.52, 0.95, wis*0.7 + wis2*0.5) * (0.35 + 0.65*smoothstep(-0.2, 0.9, dot(normalize(q + 1e-4), L.xy)));
  neb *= smoothstep(0.9, 1.6, length(q)) * smoothstep(5.2, 1.5, length(q)) * smoothstep(0.2, 1.0, build);
  col += vec3(neb) * 0.07; alpha = max(alpha, neb * 0.07);

  // stars
  vec2 g = floor(gl_FragCoord.xy / 3.0);
  float st = step(0.9965, hash(g)) * (0.4 + 0.6*sin(time*1.5 + hash(g+3.0)*6.28)) * min(1.0, time / 1.5);
  col += vec3(st) * 0.45; alpha = max(alpha, st * 0.6);

  // sphere
  float d = length(q);
  float zs = d < 1.0 ? sqrt(1.0 - d*d) : -1e9;
  float sm = 0.0;
  if (d < 1.0) {
    vec3 n = vec3(q, zs);
    vec3 o = toObj(n);
    float thr = thrS(o);
    sm = clamp((build - thr) / 0.05, 0.0, 1.0);
    float edge = exp(-pow((build - thr) / 0.025, 2.0));
    // a gas giant: cloud belts bent by turbulence, fine streaks, a great
    // oval storm and small ones, darker poles - all turning with the planet
    float warp = fbm3(o * vec3(2.2, 6.0, 2.2) + vec3(0.0, 0.0, time * 0.015)) - 0.5;
    float lat = o.y + warp * 0.13;
    float b1 = 0.5 + 0.5 * sin(lat * 19.0);
    float b2 = 0.5 + 0.5 * sin(lat * 43.0 + 1.7);
    float b3 = 0.5 + 0.5 * sin(lat * 7.0 - 0.6);
    float streaks = fbm3(o * vec3(9.0, 42.0, 9.0));
    float tone = 0.16 + 0.3 * b3 + 0.26 * b1 + 0.12 * b2 + 0.3 * (streaks - 0.5);
    vec3 sc = normalize(vec3(0.55, -0.34, 0.76));
    vec3 so = o - sc;
    float sd = length(so * vec3(1.0, 2.1, 1.0));
    float storm = smoothstep(0.26, 0.02, sd);
    float swirl = 0.5 + 0.5 * sin(atan(so.y, dot(so, normalize(cross(sc, vec3(0.0, 1.0, 0.0))))) * 2.0 + sd * 46.0);
    tone = mix(tone, 0.62 + 0.3 * swirl, storm * 0.85);
    tone += smoothstep(0.64, 0.8, fbm3(o * 6.0 + 7.0)) * 0.3;
    tone *= 1.0 - smoothstep(0.72, 0.98, abs(o.y)) * 0.55;
    // the ring's shadow on the planet: from this point towards the light
    float ringShade = 1.0;
    float ln = dot(L, uN);
    if (abs(ln) > 0.001) {
      float tr = -dot(n, uN) / ln;
      if (tr > 0.0) ringShade = 1.0 - ringDensity(length(n + L * tr)) * 0.8;
    }
    float lamb = dot(n, L);
    float diff = max(lamb, 0.0);
    float soft = clamp((lamb + 0.16) / 1.16, 0.0, 1.0);   // gentle terminator
    float fres = pow(1.0 - n.z, 3.2);
    float limb = smoothstep(0.86, 1.0, d);
    vec3 body = vec3(0.006) + vec3(0.3) * tone * pow(soft, 1.3) * ringShade;
    vec3 lit = vec3(1.0) * (pow(diff, 3.0) * 0.05 * ringShade + pow(fres, 1.6) * pow(diff, 0.9) * 1.1 + limb * pow(diff, 1.5) * 0.35);
    float crescent = smoothstep(0.955, 0.997, d) * smoothstep(0.15, 0.7, diff);
    vec3 pc = body + lit + vec3(1.0) * crescent * 1.4;
    col = mix(col, pc, sm); alpha = mix(alpha, 1.0, sm);
    // the building front glows where points are fusing into surface
    float fe = edge * (1.0 - sm * 0.6) * (0.35 + 0.65*diff + 0.3);
    col += vec3(fe) * 0.8; alpha = max(alpha, fe * 0.8);
  } else {
    float glow = exp(-(d - 1.0) / 0.06) * smoothstep(-0.3, 0.8, dot(normalize(q), L.xy)) * settle;
    col += vec3(glow) * 0.6; alpha = max(alpha, glow * 0.6);
  }

  // ring plane: depth of the plane at this pixel, then polar coords in it
  float zr = -(uN.x*q.x + uN.y*q.y) / uN.z;
  vec3 rp = vec3(q, zr);
  float rr = length(rp);
  float ringMask = smoothstep(1.22, 1.3, rr) * smoothstep(1.97, 1.9, rr);
  float th = atan(dot(rp, uE2), dot(rp, uE1)) - spin;
  th = mod(th + PI, 2.0*PI) - PI;
  float rthr = clamp(0.08 + 0.8*(th/(2.0*PI) + 0.5) + 0.12*(rr - 1.36)/0.6, 0.0, 1.0);
  float rm = clamp((build - rthr) / 0.05, 0.0, 1.0);
  float redge = exp(-pow((build - rthr) / 0.02, 2.0)) * ringMask;
  float dens = ringDensity(rr) * ringMask;
  // slow clumps in the particles that travel round with the ring
  dens *= 0.86 + 0.14 * noise(vec2(cos(th), sin(th)) * 3.0 + rr * 2.0);
  float hidden = (d < 1.0 && zr < zs) ? sm : 0.0;
  vec3 sp = rp - L * dot(rp, L);
  // the planet's shadow falls on the ring behind it, with a soft edge
  float shadow = dot(rp, L) < 0.0 ? mix(1.0, 0.82, smoothstep(1.15, 0.85, length(sp))) : 1.0;
  // one long, even fade from white on the lit side to grey on the far side
  float lk = 0.5 + 0.5 * dot(normalize(rp + 1e-4), L);
  // a long, very soft fade: bright on the lit side, still light on the far
  // side (sunlight scattered through the ring keeps it glowing)
  float side = mix(0.8, 1.0, smoothstep(0.0, 1.0, lk)) + 0.08 * pow(1.0 - lk, 2.0);
  float ring = min(1.0, dens * side * shadow * (1.0 - hidden) * 0.95 * rm);
  float ringGlint = ringMask * pow(max(0.0, dot(normalize(vec3(q, 0.3)), L)), 22.0) * 0.9 * (1.0 - hidden) * rm;
  float re = redge * (1.0 - hidden) * 0.55;
  col = col * (1.0 - ring * 0.85) + vec3(1.0) * (ring * 0.85 + ringGlint + re);
  alpha = max(alpha, ring * 0.9 + ringGlint + re);

  // flare on the lit limb with a long streak and soft rays
  vec2 fq = q - normalize(L.xy) * 0.985;
  float fd = length(fq);
  float flare = exp(-fd / 0.03) * 1.2 + exp(-fd / 0.16) * 0.35;
  float streak = exp(-abs(fq.y) / 0.006) * exp(-abs(fq.x) / 1.6) * 0.9;
  float rays = pow(abs(sin(atan(fq.y, fq.x) * 6.0 + time * 0.2)), 18.0) * exp(-fd / 0.35) * 0.35;
  float fl = (flare + streak + rays) * (0.85 + 0.15 * sin(time * 2.0)) * settle;
  col += vec3(fl); alpha = max(alpha, min(1.0, fl));

  // everything here is light on black: output so that what you see equals col
  // (before, rgb and alpha were both scaled, so faint parts like the ring off
  // the planet came out squared - nearly invisible)
  col = min(col, vec3(1.0));
  float outA = clamp(max(sm, max(col.r, max(col.g, col.b))), 0.0, 1.0);
  gl_FragColor = vec4(outA > 0.001 ? col / outA : vec3(0.0), outA);
}`;

  function makeGL(canvas) {
    const gl = canvas.getContext("webgl", { premultipliedAlpha: false, antialias: true, alpha: true });
    if (!gl) return null;
    const sh = (type, src) => { const s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s); if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) { console.warn(gl.getShaderInfoLog(s)); return null; } return s; };
    const v = sh(gl.VERTEX_SHADER, "attribute vec2 p; void main(){ gl_Position = vec4(p, 0.0, 1.0); }"), f = sh(gl.FRAGMENT_SHADER, FS);
    if (!v || !f) return null;
    const prog = gl.createProgram(); gl.attachShader(prog, v); gl.attachShader(prog, f); gl.linkProgram(prog);
    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) return null;
    gl.useProgram(prog);
    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
    const loc = gl.getAttribLocation(prog, "p"); gl.enableVertexAttribArray(loc); gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
    const U = {}; ["res", "time", "build", "spin", "place", "uN", "uE1", "uE2"].forEach(n => (U[n] = gl.getUniformLocation(prog, n)));
    gl.uniform3f(U.uN, ...N); gl.uniform3f(U.uE1, ...E1); gl.uniform3f(U.uE2, ...E2);
    gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    return { gl, U };
  }

  // glCanvas: the solid render, ptsCanvas: the points on top of it
  window.proximityPlanetScene = function (glCanvas, ptsCanvas, opts) {
    opts = opts || {};
    const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
    const GL = makeGL(glCanvas);
    const ctx = ptsCanvas.getContext("2d");
    const small = innerWidth < 640;
    const NS = small ? 1800 : 3200, NR = small ? 1300 : 2400;
    const rnd = (() => { let s = 7; return () => ((s = (s * 16807) % 2147483647) / 2147483647); })();

    // points live in planet space: sphere (a, h, c) with h along the axis, ring (angle, radius)
    const pts = [];
    const golden = Math.PI * (3 - Math.sqrt(5));
    for (let i = 0; i < NS; i++) {
      const h = 1 - (i / (NS - 1)) * 2, r = Math.sqrt(1 - h * h), t = golden * i;
      const a = Math.cos(t) * r, c = Math.sin(t) * r;
      pts.push({ k: 0, a, h, c, thr: thrSphere(a, h, c), s: rnd(), fa: rnd() * TAU, fd: rnd() });
    }
    for (let i = 0; i < NR; i++) {
      const th = rnd() * TAU - Math.PI, r = RING_IN + Math.pow(rnd(), 1.3) * (RING_OUT - RING_IN);
      pts.push({ k: 1, th, r, thr: thrRing(th, r), g: rnd() < 0.05, s: rnd(), fa: rnd() * TAU, fd: rnd() });
    }
    const grey = []; for (let i = 0; i < 256; i++) grey.push(`rgb(${i},${i},${i})`);
    for (const p of pts) { const r = rnd(); p.tone = r < 0.45 ? 1 : r < 0.75 ? 0.62 : 0.34; p.dir = rnd() < 0.5 ? 1 : -1; }

    let w = 0, h = 0, dpr = 1, gdpr = 1;
    const host = ptsCanvas.parentElement;
    function resize() {
      w = host.clientWidth; h = host.clientHeight;
      dpr = Math.min(devicePixelRatio || 1, 2); gdpr = Math.min(devicePixelRatio || 1, small ? 1.5 : 1.75);
      ptsCanvas.width = w * dpr; ptsCanvas.height = h * dpr; ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      if (GL) { glCanvas.width = Math.floor(w * gdpr); glCanvas.height = Math.floor(h * gdpr); GL.gl.viewport(0, 0, glCanvas.width, glCanvas.height); }
    }
    resize(); addEventListener("resize", resize);
    let mx = 0, my = 0;
    addEventListener("pointermove", e => { mx = e.clientX / innerWidth - 0.5; my = e.clientY / innerHeight - 0.5; }, { passive: true });

    // the same "how built is this spot" as the shader, for a view-space point on the front
    function coverAt(x, y, b, cs, sn) {
      const z = Math.sqrt(Math.max(0, 1 - x * x - y * y));
      const a1 = x * E1[0] + y * E1[1] + z * E1[2], c1 = x * E2[0] + y * E2[1] + z * E2[2], hh = x * N[0] + y * N[1] + z * N[2];
      const thr = thrSphere(a1 * cs + c1 * sn, hh, -a1 * sn + c1 * cs);
      return Math.min(1, Math.max(0, (b - thr) / 0.05));
    }

    const t0 = performance.now();
    const BUILD_AT = opts.buildAt ?? 1.6, BUILD_FOR = opts.buildFor ?? 2.4;
    let pointsDone = false;
    function frame(now) {
      const t = reduce ? 30 : (now - t0) / 1000;
      const u = Math.min(1, Math.max(0, (t - BUILD_AT) / BUILD_FOR)), b = -0.08 + 1.16 * u * u * (3 - 2 * u);
      const spin = t * SPIN_SPEED, cs = Math.cos(spin), sn = Math.sin(spin);
      // layout: fit the ring inside narrow screens, sit a bit higher on phones
      // wide screens: the planet sits beside the text; narrow: above it
      const wide = w >= 980;
      const R = wide ? Math.min(h * 0.25, w * 0.13) : Math.min(h * 0.15, w * 0.235);
      const cx = (wide ? w * 0.71 : w * 0.5) + mx * 14, cy = (wide ? h * 0.5 : h * 0.25) + my * 10;

      if (GL) {
        const { gl, U } = GL;
        gl.uniform2f(U.res, glCanvas.width, glCanvas.height);
        gl.uniform1f(U.time, t); gl.uniform1f(U.build, b); gl.uniform1f(U.spin, spin);
        gl.uniform3f(U.place, cx * gdpr, (h - cy) * gdpr, R * gdpr);
        gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
        gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
      }

      if (!pointsDone) {
        ctx.clearRect(0, 0, w, h);
        let drawn = 0;
        for (const p of pts) {
          let x, y, z, v, alpha;
          if (!p.k) {
            const a1 = p.a * cs - p.c * sn, c1 = p.a * sn + p.c * cs;
            x = E1[0] * a1 + N[0] * p.h + E2[0] * c1; y = E1[1] * a1 + N[1] * p.h + E2[1] * c1; z = E1[2] * a1 + N[2] * p.h + E2[2] * c1;
            if (z < 0) {
              // far side: seen through the unfinished planet, hidden once the front is solid
              v = 0.35; alpha = 0.22 * (1 - coverAt(x, y, b, cs, sn));
            } else {
              const d = Math.max(0, x * L[0] + y * L[1] + z * L[2]), fres = Math.pow(1 - z, 3.2);
              v = Math.min(1, 0.22 + Math.pow(d, 1.2) * 0.35 + Math.pow(fres, 1.6) * Math.pow(d, 0.9) * 1.1);
              alpha = 0.35 + v * 0.65;
            }
            if (z >= 0) {
              const e = (b - p.thr) / 0.03;
              v = Math.min(1, v + Math.exp(-e * e) * 0.9);                  // flare as it fuses
              alpha *= 1 - Math.min(1, Math.max(0, (b - p.thr - 0.02) / 0.06));
            }
          } else {
            const ang = p.th + spin, a1 = Math.cos(ang) * p.r, c1 = Math.sin(ang) * p.r;
            x = E1[0] * a1 + E2[0] * c1; y = E1[1] * a1 + E2[1] * c1; z = E1[2] * a1 + E2[2] * c1;
            const dd = x * x + y * y;
            const behind = dd < 1 && z < Math.sqrt(1 - dd);
            const lk = Math.min(1, Math.max(0, 0.5 + 0.5 * (x * L[0] + y * L[1] + z * L[2]) / p.r));
            const side = 0.62 + 0.38 * lk * lk * (3 - 2 * lk);
            v = side * (p.g ? 1 : 0.75); alpha = 0.3 + v * 0.6;
            if (behind) alpha *= 1 - coverAt(x, y, b, cs, sn);
            const e = (b - p.thr) / 0.025;
            v = Math.min(1, v + Math.exp(-e * e) * 0.8);
            alpha *= 1 - Math.min(1, Math.max(0, (b - p.thr - 0.02) / 0.05));
          }
          if (alpha <= 0.01) continue;
          // spiral in around the planet's own axis, in roughly the order the
          // surface will form, tightening and settling onto the exact spot
          const k = Math.min(1, Math.max(0, (t - p.thr * 0.75 - p.s * 0.35) / 1.4)), ease = 1 - Math.pow(1 - k, 4);
          if (k <= 0) continue;
          let px, py;
          if (ease < 1) {
            const left = 1 - ease, swirl = left * (2.4 + p.fd * 1.6) * p.dir, grow = 1 + left * left * (2.2 + p.fd * 3.2);
            const lift = left * Math.sin(p.fa) * 0.9;
            let fa, fh, fc;
            if (!p.k) { fa = p.a; fh = p.h; fc = p.c; } else { fa = Math.cos(p.th) * p.r; fh = 0; fc = Math.sin(p.th) * p.r; }
            const ws = Math.cos(spin + swirl), wn = Math.sin(spin + swirl);
            const a1 = (fa * ws - fc * wn) * grow, c1 = (fa * wn + fc * ws) * grow, hh = fh * grow + lift;
            px = cx + (E1[0] * a1 + N[0] * hh + E2[0] * c1) * R;
            py = cy - (E1[1] * a1 + N[1] * hh + E2[1] * c1) * R;
          } else { px = cx + x * R; py = cy - y * R; }
          ctx.globalAlpha = alpha * Math.min(1, k * 2.5);
          ctx.fillStyle = grey[Math.max(38, Math.round((60 + v * 195) * (v > 0.9 ? Math.max(p.tone, 0.8) : p.tone)))];
          const size = p.k ? (p.g ? 2 : 1.3) : (z < 0 ? 1.1 : v > 0.6 ? 2 : 1.5);
          ctx.fillRect(px - size / 2, py - size / 2, size, size);
          drawn++;
        }
        ctx.globalAlpha = 1;
        if (u >= 1 && drawn === 0) { ctx.clearRect(0, 0, w, h); pointsDone = true; }
      }
      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
    return !!GL;
  };
})();
