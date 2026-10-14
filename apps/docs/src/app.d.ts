// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
  namespace App {
    // interface Error {}
    // interface Locals {}
    interface PageData {
      /** A component page's highlighted code, by name (routes/components/+layout.server.ts). */
      code?: Record<string, string>;
      /** A block page's example, as text and highlighted (routes/blocks/+layout.server.ts). */
      example?: { source: string; html: string };
    }
    // interface PageState {}
    // interface Platform {}
  }
}

export {};
