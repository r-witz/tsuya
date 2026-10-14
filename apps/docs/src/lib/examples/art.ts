// Generated artwork for the examples: small gradient pictures as data URIs, so that no example needs a
// third-party photo or a file to serve. Real code passes the URL of its own image as `src`.
const picture = (from: string, to: string): string => {
  const svg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120">' +
    `<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${from}"/><stop offset="1" stop-color="${to}"/></linearGradient></defs>` +
    '<rect width="120" height="120" fill="url(#g)"/><circle cx="84" cy="36" r="18" fill="#fff" fill-opacity=".25"/></svg>';
  return `data:image/svg+xml,${encodeURIComponent(svg)}`;
};

export const COVER = {
  ember: picture('#F2722C', '#5B1A0B'),
  teal: picture('#1FB8A6', '#0C2B3A'),
  violet: picture('#B06BD9', '#2A1245'),
};
