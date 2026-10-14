// The accent of an image element, read through a canvas.
import { accentFromPixels, type ImageAccent } from '../engine/color.ts';

/**
 * The accent pair and ambient opacities of a loaded image, sampled at most `size` pixels on a side. The image must be
 * same-origin or served with CORS headers (`crossorigin="anonymous"`): a canvas cannot read it otherwise. It takes
 * some tens of milliseconds and browsers decode images differently: compute it once, at upload time with
 * `accentFromPixels` when you can, and store it with the content.
 */
export function accentFromImage(image: HTMLImageElement | ImageBitmap | HTMLCanvasElement, size = 256): ImageAccent {
  const width = 'naturalWidth' in image ? image.naturalWidth : image.width;
  const height = 'naturalHeight' in image ? image.naturalHeight : image.height;
  if (!width || !height) throw new Error('accentFromImage: the image is not loaded');
  const scale = Math.min(1, size / Math.max(width, height));
  const canvas = document.createElement('canvas');
  canvas.width = Math.max(1, Math.round(width * scale));
  canvas.height = Math.max(1, Math.round(height * scale));
  const context = canvas.getContext('2d', { willReadFrequently: true });
  if (!context) throw new Error('accentFromImage: no 2D canvas');
  context.drawImage(image, 0, 0, canvas.width, canvas.height);
  let data: Uint8ClampedArray;
  try {
    data = context.getImageData(0, 0, canvas.width, canvas.height).data;
  } catch (cause) {
    throw new Error('accentFromImage: the image is cross-origin; serve it with CORS headers', { cause });
  }
  return accentFromPixels(data, canvas.width, canvas.height);
}
