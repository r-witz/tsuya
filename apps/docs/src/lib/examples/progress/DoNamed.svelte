<script lang="ts">
  import { Progress } from '@tsuya/svelte';
</script>

<div style="display: grid; gap: 12px; width: 100%">
  <Progress value={0.6} label="Uploading photo" />
  <Progress value={0.2} label="Uploading video" />
</div>
