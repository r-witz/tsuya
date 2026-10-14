<!-- Badges: standalone count and dot, and pinned on an icon button and an avatar, with the meaning folded into the host's label. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Avatar, Badge, IconButton, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  interface Props {
    labels?: TsuyaLabels;
    count?: number;
    dir?: 'ltr' | 'rtl';
  }

  let { labels = labelsEn, count = 3, dir = 'ltr' }: Props = $props();
</script>

{#snippet bell()}
  <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><path d="M6 10a6 6 0 1112 0v5l2 3H4l2-3z" /></svg>
{/snippet}

<TsuyaProvider {labels}>
  <div
    {dir}
    style="display:flex; flex-wrap:wrap; align-items:flex-start; gap: var(--t-space-24); padding: var(--t-space-16)"
  >
    <Badge count={5} data-testid="standalone-count" />
    <Badge count={142} data-testid="standalone-over" />
    <Badge dot data-testid="standalone-dot" />
    <IconButton label="Notifications, {count} unread" icon={bell} data-testid="icon-button">
      {#snippet badge()}<Badge {count} data-testid="icon-button-badge" />{/snippet}
    </IconButton>
    <Avatar initials="JD" label="Jamie Doe, online" data-testid="avatar">
      {#snippet badge()}<Badge dot data-testid="avatar-badge" />{/snippet}
    </Avatar>
  </div>
</TsuyaProvider>
