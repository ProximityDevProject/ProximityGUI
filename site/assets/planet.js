// Proximity planet: a real-time 3D render in a fragment shader.
// A dark world lit from the top right with a glowing limb, a tilted ring
// that passes behind the planet, is shadowed by it and lights up in front,
// a flare with a streak and soft rays, drifting nebula wisps and stars.
// Points from app.js assemble the shape first, then dissolve into it.
// Shared planet geometry for the shader and the points that build it.
const PLANET = { flat: 0.26, roll: 17 * Math.PI / 180, ringIn: 1.36, ringOut: 1.9, light: [0.72, 0.58, 0.38] };

// Points that fly in and assemble into exactly the planet the shader draws:
// same centre, radius, ring plane and light, so the hand-off is a morph.
window.proximityPlanetPoints = function (canvas, opts) {
  opts = opts || {};
  const ctx = canvas.getContext("2d");
  const L = PLANET.light.slice(); const ll = Math.hypot(...L); L[0] /= ll; L[1] /= ll; L[2] /= ll;
  const ny = Math.sqrt(1 - PLANET.flat * PLANET.flat);
  const N = [-Math.sin(PLANET.roll) * ny, Math.cos(PLANET.roll) * ny, PLANET.flat];
  const e1 = [Math.cos(PLANET.roll), Math.sin(PLANET.roll), 0];
  const e2 = [N[1] * e1[2] - N[2] * e1[1], N[2] * e1[0] - N[0] * e1[2], N[0] * e1[1] - N[1] * e1[0]];
  const pts = [], golden = Math.PI * (3 - Math.sqrt(5)), NS = 1500;
  for (let i = 0; i < NS; i++) { const y = 1 - (i / (NS - 1)) * 2, r = Math.sqrt(1 - y * y), t = golden * i; pts.push({ k: 0, x: Math.cos(t) * r, y, z: Math.sin(t) * r, s: Math.random() }); }
  for (let i = 0; i < 900; i++) { pts.push({ k: 1, t: Math.random() * Math.PI * 2, r: PLANET.ringIn + Math.pow(Math.random(), 1.4) * (PLANET.ringOut - PLANET.ringIn), g: Math.random() < 0.06, s: Math.random() }); }
  let w, h, dpr;
  const resize = () => { dpr = Math.min(devicePixelRatio || 1, 2); w = canvas.clientWidth; h = canvas.clientHeight; canvas.width = w * dpr; canvas.height = h * dpr; ctx.setTransform(dpr, 0, 0, dpr, 0, 0); };
  resize(); addEventListener("resize", resize);
  const t0 = performance.now(), hand = opts.handoff ?? 1.3, morph = opts.morph ?? 1.0;
  function frame(now) {
    const t = (now - t0) / 1000;
    ctx.clearRect(0, 0, w, h);
    const dissolve = opts.solid ? 1 - Math.min(1, Math.max(0, (t - hand) / morph)) : 1;
    if (dissolve <= 0) return;           // the 3D planet has taken over
    const R = (opts.radius ?? 0.27) * h, cx = w * (opts.cx ?? 0.5), cy = h * (opts.cy ?? 0.44);
    const spin = t * 0.12;
    for (const p of pts) {
      let x, y, z, v, a;
      if (!p.k) {
        const c = Math.cos(spin), s = Math.sin(spin);
        x = p.x * c + p.z * s; y = p.y; z = -p.x * s + p.z * c;
        if (z < -0.02) continue;
        const d = Math.max(0, x * L[0] + y * L[1] + z * L[2]), fres = Math.pow(1 - z, 3.2);
        v = Math.min(1, 0.06 + Math.pow(d, 3) * 0.05 + Math.pow(fres, 1.6) * Math.pow(d, 0.9) * 1.1 + (Math.hypot(x, y) > 0.955 ? d * 1.2 : 0));
        a = 0.25 + v * 0.9;
      } else {
        const ang = p.t + t * 0.05, cs = Math.cos(ang) * p.r, sn = Math.sin(ang) * p.r;
        x = cs * e1[0] + sn * e2[0]; y = cs * e1[1] + sn * e2[1]; z = cs * e1[2] + sn * e2[2];
        const dd = x * x + y * y;
        if (dd < 1 && z < Math.sqrt(1 - dd)) continue;   // behind the planet
        const side = 0.45 + 0.55 * Math.min(1, Math.max(0, ((x * L[0] + y * L[1] + z * L[2]) / p.r * 1.4 + 1) / 2));
        v = side * (p.g ? 1 : 0.7); a = 0.2 + v * 0.6;
      }
      const appear = Math.min(1, Math.max(0, (t - p.s * 0.6) / 1.0)), e = 1 - Math.pow(1 - appear, 3);
      const sx = cx + x * R, sy = cy - y * R;
      const fx = cx + Math.cos(p.s * 40) * (300 + p.s * 500), fy = cy + Math.sin(p.s * 53) * (300 + p.s * 400);
      const px = fx + (sx - fx) * e, py = fy + (sy - fy) * e;
      const g = Math.round(50 + v * 205);
      ctx.globalAlpha = a * e * dissolve;
      ctx.fillStyle = `rgb(${g},${g},${g})`;
      const size = p.k ? (p.g ? 2 : 1.4) : (v > 0.5 ? 2.2 : 1.6);
      ctx.fillRect(px - size / 2, py - size / 2, size, size);
    }
    ctx.globalAlpha = 1;
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
};

window.proximityPlanet3D = function (canvas, opts) {
  opts = opts || {};
  const gl = canvas.getContext("webgl", { premultipliedAlpha: false, antialias: true, alpha: true });
  if (!gl) return false;

  const vs = `attribute vec2 p; void main(){ gl_Position = vec4(p, 0.0, 1.0); }`;
  const fs = `
precision highp float;
uniform vec2 res; uniform float time; uniform float appear; uniform vec2 mouse; uniform vec3 place;
float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p){ vec2 i = floor(p), f = fract(p); f = f*f*(3.0-2.0*f);
  return mix(mix(hash(i), hash(i+vec2(1,0)), f.x), mix(hash(i+vec2(0,1)), hash(i+vec2(1,1)), f.x), f.y); }
float fbm(vec2 p){ float v = 0.0, a = 0.5; for (int i = 0; i < 6; i++){ v += a*noise(p); p = p*2.03 + 7.1; a *= 0.5; } return v; }
float noise3(vec3 p){ return noise(p.xy + p.z*1.7) * 0.5 + noise(p.yz*1.3 - p.x) * 0.5; }

void main(){
  vec2 uv = (gl_FragCoord.xy - 0.5*res) / res.y;
  vec2 c = vec2(place.x, place.y) + mouse * vec2(0.02, 0.015);
  float R = place.z;
  vec2 q = uv - c;
  vec3 L = normalize(vec3(0.72, 0.58, 0.38));
  vec3 col = vec3(0.0); float alpha = 0.0;

  // nebula wisps, brightest towards the light like on the cover
  float wis = fbm(uv*2.6 + vec2(time*0.012, -time*0.008));
  float wis2 = fbm(uv*5.0 - vec2(time*0.02, 0.0) + wis*1.6);
  float neb = smoothstep(0.52, 0.95, wis * 0.7 + wis2 * 0.5) * (0.35 + 0.65*smoothstep(-0.2, 0.9, dot(normalize(q + 1e-4), L.xy)));
  neb *= smoothstep(R*0.9, R*1.6, length(q)) * smoothstep(1.4, 0.4, length(q));
  col += vec3(neb) * 0.22; alpha = max(alpha, neb * 0.22);

  // stars
  vec2 g = floor(gl_FragCoord.xy / 3.0);
  float st = step(0.9965, hash(g)) * (0.4 + 0.6*sin(time*1.5 + hash(g+3.0)*6.28));
  col += vec3(st) * 0.6; alpha = max(alpha, st * 0.6);

  // ring plane (tilted) - ray along -z through every pixel
  // ring plane: seen almost edge on (ellipse ratio 0.26), rising to the right
  float flat_ = 0.26, roll = radians(17.0);
  float ny = sqrt(1.0 - flat_ * flat_);
  vec3 N = vec3(-sin(roll) * ny, cos(roll) * ny, flat_);
  float zr = -(N.x*q.x + N.y*q.y) / N.z;            // depth of the ring plane at this pixel
  vec3 rp = vec3(q, zr);
  float rr = length(rp) / R;
  float ringMask = smoothstep(1.3, 1.4, rr) * smoothstep(1.98, 1.82, rr);
  float bands = pow(noise(vec2(rr * 34.0, 0.0)), 1.6) * 0.8 + pow(noise(vec2(rr * 110.0, 1.0)), 2.0) * 0.5;
  // wispy, not a solid band: fade with angle noise like dust lanes
  bands *= 0.45 + 0.55 * noise(vec2(atan(rp.y, rp.x) * 3.0 + time * 0.05, rr * 4.0));
  // sphere
  float d = length(q);
  float zs = d < R ? sqrt(R*R - d*d) : -1e9;
  // the ring is hidden behind the planet disc
  float hidden = (d < R && zr < zs) ? 1.0 : 0.0;
  // planet shadow on the ring (light from L)
  vec3 toL = L; vec3 sp = rp - toL * dot(rp, toL);
  float shadow = (dot(rp, toL) < 0.0 && length(sp) < R) ? 0.25 : 1.0;
  float side = 0.45 + 0.55 * smoothstep(-1.0, 1.0, dot(normalize(rp + 1e-4), L) * 1.4);
  float ring = ringMask * bands * side * shadow * (1.0 - hidden) * 0.75;
  float ringGlint = ringMask * pow(max(0.0, dot(normalize(vec3(q, 0.3)), L)), 22.0) * 0.9 * (1.0 - hidden);

  if (d < R) {
    vec3 n = normalize(vec3(q, zs));
    // slow rotation of the surface detail
    float a = time * 0.12;
    vec3 rn = vec3(n.x*cos(a) + n.z*sin(a), n.y, -n.x*sin(a) + n.z*cos(a));
    float surf = noise3(rn * 6.0) * 0.6 + noise3(rn * 18.0) * 0.4;
    float diff = max(dot(n, L), 0.0);
    float fres = pow(1.0 - n.z, 3.2);
    float limb = smoothstep(0.86, 1.0, d / R);
    vec3 body = vec3(0.006) + vec3(0.035) * surf * diff;
    vec3 lit = vec3(1.0) * (pow(diff, 3.0) * 0.05 + pow(fres, 1.6) * pow(diff, 0.9) * 1.1 + limb * pow(diff, 1.5) * 0.35);
    // thin bright crescent like on the cover
    float crescent = smoothstep(0.955, 0.997, d / R) * smoothstep(0.15, 0.7, diff);
    vec3 pc = body + lit + vec3(1.0) * crescent * 1.4;
    col = mix(col, pc, 1.0); alpha = 1.0;
  } else {
    // atmosphere glow outside the limb, only on the lit side
    float glow = exp(-(d - R) / (R * 0.06)) * smoothstep(-0.3, 0.8, dot(normalize(q), L.xy));
    col += vec3(glow) * 0.9; alpha = max(alpha, glow * 0.9);
  }
  // ring over everything that is in front
  col = col * (1.0 - ring * 0.85) + vec3(1.0) * (ring * 0.85 + ringGlint);
  alpha = max(alpha, ring * 0.9 + ringGlint);

  // flare on the lit limb with a long streak and soft rays
  vec2 fp = c + normalize(L.xy) * R * 0.985;
  vec2 fq = uv - fp;
  float fd = length(fq);
  float flare = exp(-fd / (R * 0.03)) * 1.2 + exp(-fd / (R * 0.16)) * 0.35;
  float streak = exp(-abs(fq.y) / (R * 0.006)) * exp(-abs(fq.x) / (R * 1.6)) * 0.9;
  float ang = atan(fq.y, fq.x);
  float rays = pow(abs(sin(ang * 6.0 + time * 0.2)), 18.0) * exp(-fd / (R * 0.35)) * 0.35;
  float pulse = 0.85 + 0.15 * sin(time * 2.0);
  float fl = (flare + streak + rays) * pulse;
  col += vec3(fl); alpha = max(alpha, min(1.0, fl));

  gl_FragColor = vec4(min(col, vec3(1.0)), alpha * appear);
}`;
  function compile(type, src) {
    const s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) { console.warn(gl.getShaderInfoLog(s)); return null; }
    return s;
  }
  const v = compile(gl.VERTEX_SHADER, vs), f = compile(gl.FRAGMENT_SHADER, fs);
  if (!v || !f) return false;
  const prog = gl.createProgram(); gl.attachShader(prog, v); gl.attachShader(prog, f); gl.linkProgram(prog);
  if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) return false;
  gl.useProgram(prog);
  const buf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW);
  const loc = gl.getAttribLocation(prog, "p"); gl.enableVertexAttribArray(loc); gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
  const U = (n) => gl.getUniformLocation(prog, n);
  const uRes = U("res"), uTime = U("time"), uAppear = U("appear"), uMouse = U("mouse"), uPlace = U("place");
  gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  let mx = 0, my = 0;
  addEventListener("pointermove", (e) => { mx = e.clientX / innerWidth - 0.5; my = 0.5 - e.clientY / innerHeight; }, { passive: true });
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const t0 = performance.now();
  function resize() {
    const dpr = Math.min(devicePixelRatio || 1, 1.75);
    canvas.width = Math.floor(canvas.clientWidth * dpr); canvas.height = Math.floor(canvas.clientHeight * dpr);
    gl.viewport(0, 0, canvas.width, canvas.height);
  }
  resize(); addEventListener("resize", resize);
  const start = opts.delay ?? 1.3;
  function frame(now) {
    const t = (now - t0) / 1000;
    const a = Math.min(1, Math.max(0, (t - start) / 1.0));
    const aspect = canvas.width / canvas.height;
    gl.uniform2f(uRes, canvas.width, canvas.height);
    gl.uniform1f(uTime, reduce ? 10 : t);
    gl.uniform1f(uAppear, a * a * (3 - 2 * a));
    gl.uniform2f(uMouse, mx, my);
    // place: centre x, centre y (in units of height), radius
    gl.uniform3f(uPlace, ((opts.cx ?? 0.5) - 0.5) * aspect, 0.5 - (opts.cy ?? 0.44), opts.radius ?? 0.27);
    gl.clearColor(0, 0, 0, 0); gl.clear(gl.COLOR_BUFFER_BIT);
    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
  return true;
};
