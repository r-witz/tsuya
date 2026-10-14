<script lang="ts">
  import { Avatar } from '@tsuya/svelte';
</script>

<Avatar initials="AL" colors={['#1F7A6E', '#0C2B3A']} label="Ada Lovelace" />
<Avatar initials="GH" colors={['#B06BD9', '#2A1245']} label="Grace Hopper" />
<!-- white would not reach 4.5:1 on the darker of these two: the avatar falls back to the neutral fill -->
<Avatar initials="KJ" colors={['#F2E96B', '#F7C948']} label="Katherine Johnson" />
