// The mode before the first paint (DESIGN.md, Theme and mode): the light or dark an app persisted, set on the
// document before the page is painted, so that a forced mode does not flash the system's.

/**
 * The source of a script for the `<head>`, before any stylesheet or app code: it sets `data-theme` on `<html>` to the
 * `light` or `dark` found in `localStorage` under `storageKey`, and does nothing for anything else (the system's
 * mode) or where storage is unavailable. The app writes the key when the user chooses; `TsuyaProvider` then
 * takes over the attribute.
 */
export function themeScript(storageKey = 'tsuya-mode'): string {
  const key = JSON.stringify(storageKey).replace(/</g, '\\u003c');
  return `try{var m=localStorage.getItem(${key});if(m==='light'||m==='dark')document.documentElement.dataset.theme=m}catch(e){}`;
}
