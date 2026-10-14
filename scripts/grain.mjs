// The grain tile: square greyscale noise, each texel the mean of two draws of a linear congruential
// generator seeded with 64, written as a PNG. Flutter draws the same tile at runtime from the same generator.
// The PNG holds its data in stored (uncompressed) deflate blocks: the bytes do not depend on a zlib version, so the
// build gives the same file everywhere.
import { crc32 } from 'node:zlib';

/** The tile's texels, row by row: the generator both platforms share. */
export function grainTexels(size) {
  let state = 64;
  const draw = () => {
    state = (Math.imul(state, 1103515245) + 12345) & 0x7fffffff;
    return (state >> 16) & 0xff;
  };
  const texels = new Uint8Array(size * size);
  for (let i = 0; i < texels.length; i++) texels[i] = (draw() + draw()) >> 1;
  return texels;
}

function chunk(type, data) {
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  out.write(type, 4, 'latin1');
  data.copy(out, 8);
  out.writeUInt32BE(crc32(out.subarray(4, 8 + data.length)), 8 + data.length);
  return out;
}

function adler32(data) {
  let a = 1;
  let b = 0;
  for (const byte of data) {
    a = (a + byte) % 65521;
    b = (b + a) % 65521;
  }
  return ((b << 16) | a) >>> 0;
}

// a zlib stream of stored blocks: header 78 01, then blocks of at most 65 535 bytes, then the Adler-32 of the data
function stored(data) {
  const parts = [Buffer.from([0x78, 0x01])];
  for (let at = 0; at < data.length || at === 0; at += 65535) {
    const block = data.subarray(at, at + 65535);
    const head = Buffer.alloc(5);
    head[0] = at + 65535 >= data.length ? 1 : 0;
    head.writeUInt16LE(block.length, 1);
    head.writeUInt16LE(~block.length & 0xffff, 3);
    parts.push(head, block);
  }
  const check = Buffer.alloc(4);
  check.writeUInt32BE(adler32(data));
  return Buffer.concat([...parts, check]);
}

export function buildGrain(size) {
  const texels = grainTexels(size);
  // each row starts with filter type 0 (none)
  const raw = Buffer.alloc(size * (size + 1));
  for (let y = 0; y < size; y++) raw.set(texels.subarray(y * size, (y + 1) * size), y * (size + 1) + 1);
  const header = Buffer.alloc(13);
  header.writeUInt32BE(size, 0);
  header.writeUInt32BE(size, 4);
  header.set([8, 0, 0, 0, 0], 8); // 8 bits, greyscale, deflate, no filter, no interlace
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', header),
    chunk('IDAT', stored(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}
