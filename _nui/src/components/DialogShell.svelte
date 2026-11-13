<script lang="ts">
  import type { Snippet } from 'svelte';
  import { focusFirstField, trapFocus } from '../lib/focus';
  import { EXIT_MS, motion } from '../lib/motion';

  type Props = {
    width: string;
    label: string;
    oncancel: () => void;
    onconfirm: () => void;
    children: Snippet;
  };

  let { width, label, oncancel, onconfirm, children }: Props = $props();

  let root: HTMLDivElement | undefined = $state();

  $effect(() => {
    if (root) focusFirstField(root);
  });

  function onkeydown(event: KeyboardEvent) {
    if (event.defaultPrevented) return;

    if (event.key === 'Escape') {
      event.preventDefault();
      oncancel();
      return;
    }

    if (event.key === 'Enter') {
      const target = event.target;
      if (target instanceof HTMLTextAreaElement || target instanceof HTMLButtonElement) return;

      event.preventDefault();
      onconfirm();
      return;
    }

    if (event.key === 'Tab' && root) trapFocus(event, root);
  }
</script>

<div class="absolute inset-0 flex items-center justify-center">
  <div
    bind:this={root}
    role="dialog"
    aria-modal="true"
    aria-label={label}
    tabindex="-1"
    {onkeydown}
    class="flex flex-col gap-2 outline-none {width}"
    in:motion|global={{ scale: 0.98 }}
    out:motion|global={{ scale: 0.98, duration: EXIT_MS }}
  >
    {@render children()}
  </div>
</div>
