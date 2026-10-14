<!-- A settings-style list (DESIGN.md Patterns): an account row, sections of rows, a destructive row alone at the end. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { List, ListItem, Section, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  interface Props {
    labels?: TsuyaLabels;
    dir?: 'ltr' | 'rtl';
    current?: 'wifi' | 'bluetooth' | null;
    language?: 'en' | 'fr';
    onpress?: (name: string) => void;
  }

  let { labels = labelsEn, dir = 'ltr', current = 'wifi', language = 'en', onpress = () => {} }: Props = $props();
</script>

{#snippet avatar()}
  <span
    data-testid="account-avatar"
    style="display:grid;place-items:center;width:40px;height:40px;border-radius:999px;background:#2b2b35;color:#fff"
    >JD</span
  >
{/snippet}
{#snippet wifiIcon()}
  <svg viewBox="0 0 24 24" aria-hidden="true" data-testid="wifi-icon"><circle cx="12" cy="12" r="8" /></svg>
{/snippet}

<TsuyaProvider {labels}>
  <div {dir} style="max-width: 420px; margin: 0 auto; padding: var(--t-space-16)">
    <List data-testid="list">
      <ListItem
        tall
        title="Jamie Doe"
        subtitle="jamie@company.com"
        href="/account"
        leading={avatar}
        data-testid="account"
      />
      <Section label="Network">
        <ListItem
          title="Wi-Fi"
          subtitle="Connected to a wireless network named HomeNet Office Extended"
          href="/wifi"
          current={current === 'wifi'}
          leading={wifiIcon}
          data-testid="wifi"
        />
        <ListItem
          title="Bluetooth"
          current={current === 'bluetooth'}
          onclick={() => {
            onpress('bluetooth');
          }}
          data-testid="bluetooth"
        />
        <ListItem title="Storage" data-testid="storage">
          {#snippet trailing()}<span data-testid="storage-value">128 GB</span>{/snippet}
        </ListItem>
      </Section>
      <Section label="Language">
        <ListItem
          title="English"
          selected={language === 'en'}
          onclick={() => {
            onpress('en');
          }}
          data-testid="english"
        />
        <ListItem title="Français" href="?lang=fr" selected={language === 'fr'} data-testid="french" />
      </Section>
      <Section label="Account">
        <ListItem
          title="Sign out"
          destructive
          onclick={() => {
            onpress('sign-out');
          }}
          data-testid="sign-out"
        />
      </Section>
    </List>
  </div>
</TsuyaProvider>
