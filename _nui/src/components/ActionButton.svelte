<script lang="ts">
  import type { Snippet } from 'svelte';

  const variants = {
    cancel: 'border-input bg-secondary font-medium hover:bg-input',
    confirm: 'border-cobalt bg-cobalt font-semibold hover:border-cobalt-hover hover:bg-cobalt-hover',
    danger: 'border-destructive-solid bg-destructive-solid font-semibold hover:border-destructive-hover hover:bg-destructive-hover',
  } as const;

  type Props = {
    variant: keyof typeof variants;
    onclick: () => void;
    children: Snippet;
  };

  let { variant, onclick, children }: Props = $props();
</script>

<button
  type="button"
  data-action
  {onclick}
  class="flex h-11 flex-1 items-center justify-center rounded-[0.625rem] border text-label text-foreground outline-none transition-colors duration-150 focus-visible:ring-2 focus-visible:ring-cobalt focus-visible:ring-offset-2 focus-visible:ring-offset-background {variants[variant]}"
>
  {@render children()}
</button>
