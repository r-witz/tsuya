// Built-in sample covers for the home page's picker: generated artwork, drawn on a canvas, not third-party
// photos. A handful of distinct hues, and one deliberately low-chroma ("Slate") so the neutral-accent fallback
// (DESIGN.md, The engine: "seed is null for an image without colour") shows up live, not only in Material's playground.
export interface Cover {
  name: string;
  draw: (ctx: CanvasRenderingContext2D, size: number) => void;
}

function linear(ctx: CanvasRenderingContext2D, size: number, degrees: number, from: string, to: string): void {
  const radians = (degrees * Math.PI) / 180;
  const dx = (Math.sin(radians) * size) / 2;
  const dy = (-Math.cos(radians) * size) / 2;
  const gradient = ctx.createLinearGradient(size / 2 - dx, size / 2 - dy, size / 2 + dx, size / 2 + dy);
  gradient.addColorStop(0, from);
  gradient.addColorStop(1, to);
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, size, size);
}

function disc(ctx: CanvasRenderingContext2D, x: number, y: number, radius: number, color: string): void {
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.arc(x, y, radius, 0, Math.PI * 2);
  ctx.fill();
}

export const COVERS: Cover[] = [
  {
    name: 'Ember',
    draw: (ctx, s) => {
      linear(ctx, s, 160, '#F2722C', '#5C1A1A');
      disc(ctx, s * 0.72, s * 0.28, s * 0.16, '#FFD39B');
    },
  },
  {
    name: 'Reef',
    draw: (ctx, s) => {
      linear(ctx, s, 200, '#1FB8A6', '#0C2B3A');
      disc(ctx, s * 0.25, s * 0.78, s * 0.2, '#A6F2E6');
    },
  },
  {
    name: 'Dusk',
    draw: (ctx, s) => {
      const gradient = ctx.createRadialGradient(s * 0.4, s * 0.3, 0, s * 0.4, s * 0.3, s * 0.95);
      gradient.addColorStop(0, '#B06BD9');
      gradient.addColorStop(1, '#241038');
      ctx.fillStyle = gradient;
      ctx.fillRect(0, 0, s, s);
    },
  },
  {
    name: 'Moss',
    draw: (ctx, s) => {
      linear(ctx, s, 135, '#7BA05B', '#1E2E16');
      ctx.fillStyle = 'rgb(255 255 255 / 0.08)';
      for (let x = -s; x < s; x += 24) {
        ctx.beginPath();
        ctx.moveTo(x, s);
        ctx.lineTo(x + s, 0);
        ctx.lineTo(x + s + 12, 0);
        ctx.lineTo(x + 12, s);
        ctx.fill();
      }
    },
  },
  {
    // low chroma on purpose: the engine finds no colourful cell and falls back to the neutral pair
    name: 'Slate',
    draw: (ctx, s) => {
      linear(ctx, s, 180, '#9AA0A6', '#5B6168');
    },
  },
  {
    name: 'Dawn',
    draw: (ctx, s) => {
      linear(ctx, s, 150, '#F6A6C1', '#F2D9A0');
    },
  },
];

/** A cover drawn at `size` px, as a canvas: accentFromImage reads it directly, with no decode round trip. */
export function renderCover(cover: Cover, size = 512): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('no 2D canvas');
  cover.draw(ctx, size);
  return canvas;
}
