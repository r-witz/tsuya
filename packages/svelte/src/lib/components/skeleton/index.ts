// Skeleton, with its composed Skeleton.Text.
import Simple from './Skeleton.svelte';
import Text from './SkeletonText.svelte';

// typed by name, so that its declaration can be written; marked pure, or an app that never uses it still bundles
// it (Object.assign changes its first argument)
export const Skeleton: typeof Simple & { Text: typeof Text } = /* @__PURE__ */ Object.assign(Simple, { Text });
