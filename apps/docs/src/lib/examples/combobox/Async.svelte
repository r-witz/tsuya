<script lang="ts">
  import { Combobox } from '@tsuya/svelte';

  const CITIES = ['Paris', 'Lyon', 'Lille', 'Nantes', 'Nice', 'Toulouse', 'Bordeaux'];

  let inputValue = $state('');
  let loading = $state(false);
  let options = $state<{ value: string; label: string }[]>([]);

  // a stand-in for a request: the options are already filtered when they arrive, so filter keeps all of them
  $effect(() => {
    const query = inputValue.trim().toLowerCase();
    if (!query) {
      options = [];
      return;
    }
    loading = true;
    const timer = setTimeout(() => {
      options = CITIES.filter((city) => city.toLowerCase().includes(query)).map((city) => ({
        value: city,
        label: city,
      }));
      loading = false;
    }, 400);
    return () => {
      clearTimeout(timer);
    };
  });
</script>

<div class="wide">
  <Combobox bind:inputValue label="City" placeholder="Type a city" {options} {loading} filter={() => true} />
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
