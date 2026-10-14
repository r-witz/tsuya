<!-- Don't: two bars with the same default label are told apart by nothing (DESIGN.md, Progress: "Named"). -->
<script lang="ts">
  import { Progress } from '@tsuya/svelte';
</script>

<div style="display: grid; gap: 12px; width: 100%">
  <Progress value={0.6} />
  <Progress value={0.2} />
</div>
