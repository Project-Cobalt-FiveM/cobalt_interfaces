<script lang="ts">
  import '../cards/fonts.css';
  import CardFront from '../cards/CardFront.svelte';
  import { parseCard, type Card } from '../lib/card';
  import { EXIT_MS, motion } from '../lib/motion';
  import { onNui } from '../lib/nui';

  const SCREEN_SHARE = 0.56;

  let card = $state<Card | null>(null);
  let viewportHeight = $state(window.innerHeight);

  const scale = $derived((viewportHeight / 1080) * SCREEN_SHARE);

  $effect(() => onNui('cardShow', (data) => (card = parseCard(data))));
  $effect(() => onNui('cardHide', () => (card = null)));
</script>

<svelte:window bind:innerHeight={viewportHeight} />

{#if card}
  <div
    class="absolute top-1/2 right-[4vh]"
    style:width="{856 * scale}px"
    style:height="{540 * scale}px"
    style:margin-top="{-270 * scale}px"
    in:motion={{ x: 2 }}
    out:motion={{ x: 2, duration: EXIT_MS }}
  >
    <div class="origin-top-left" style:transform="scale({scale})">
      <CardFront {card} />
    </div>
  </div>
{/if}
