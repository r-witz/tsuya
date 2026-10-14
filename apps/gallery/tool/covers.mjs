// Draws the gallery's sample covers: soft gradients with one shape each, made for this repository (no third-party
// picture, no licence to carry). `node apps/gallery/tool/covers.mjs` rewrites assets/covers/*.png; the output is
// committed and does not change from one run to the next.
import { mkdirSync, writeFileSync } from 'node:fs';
import { deflateSync, crc32 } from 'node:zlib';
import { fileURLToPath } from 'node:url';

const OUT = fileURLToPath(new URL('../assets/covers/', import.meta.url));
const SIZE = 384;

// two gradient ends, a blob colour and the shape drawn on top
const COVERS = [
  { name: 'dusk', from: [38, 22, 84], to: [232, 118, 72], blob: [255, 196, 120], shape: 'disc' },
  { name: 'tide', from: [8, 52, 92], to: [38, 166, 154], blob: [168, 238, 224], shape: 'rings' },
  { name: 'ember', from: [74, 12, 28], to: [236, 92, 56], blob: [255, 170, 110], shape: 'bars' },
  { name: 'moss', from: [16, 56, 40], to: [158, 196, 84], blob: [226, 240, 150], shape: 'disc' },
  { name: 'sand', from: [150, 108, 60], to: [244, 224, 176], blob: [255, 250, 226], shape: 'rings' },
  { name: 'slate', from: [34, 44, 74], to: [214, 132, 168], blob: [250, 200, 220], shape: 'bars' },
];

const mix = (a, b, t) => a.map((v, i) => v + (b[i] - v) * t);
const clamp = (v) => Math.min(1, Math.max(0, v));
const smooth = (t) => t * t * (3 - 2 * t);

function pixel(cover, x, y) {
  const u = x / (SIZE - 1);
  const v = y / (SIZE - 1);
  let rgb = mix(cover.from, cover.to, smooth(clamp((u * 0.4 + v * 0.8) / 1.2)));
  // a light blob off the centre, which is what the ambient background will pick up
  const blob = clamp(1 - Math.hypot(u - 0.72, v - 0.3) / 0.55);
  rgb = mix(rgb, cover.blob, smooth(blob) * 0.55);
  const d = Math.hypot(u - 0.5, v - 0.56);
  let shape = 0;
  if (cover.shape === 'disc') shape = clamp((0.2 - d) / 0.004) * 0.9;
  if (cover.shape === 'rings') shape = d > 0.1 && d < 0.34 && Math.floor((d - 0.1) / 0.06) % 2 === 0 ? 0.5 : 0;
  if (cover.shape === 'bars')
    shape = u > 0.2 && u < 0.8 && v > 0.52 && Math.floor((u - 0.2) / 0.1) % 2 === 0 ? 0.55 : 0;
  rgb = mix(rgb, [14, 14, 22], shape * 0.55);
  return rgb.map((c) => Math.round(c));
}

function chunk(type, data) {
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const out = Buffer.alloc(body.length + 8);
  out.writeUInt32BE(data.length, 0);
  body.copy(out, 4);
  out.writeUInt32BE(crc32(body), body.length + 4);
  return out;
}

function png(cover) {
  const rows = Buffer.alloc(SIZE * (SIZE * 3 + 1));
  for (let y = 0; y < SIZE; y++) {
    const row = y * (SIZE * 3 + 1);
    for (let x = 0; x < SIZE; x++) rows.set(pixel(cover, x, y), row + 1 + x * 3);
  }
  const header = Buffer.alloc(13);
  header.writeUInt32BE(SIZE, 0);
  header.writeUInt32BE(SIZE, 4);
  header.set([8, 2, 0, 0, 0], 8);
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(rows, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

mkdirSync(OUT, { recursive: true });
for (const cover of COVERS) writeFileSync(`${OUT}${cover.name}.png`, png(cover));
console.log(`✓ ${COVERS.length} covers in assets/covers`);
