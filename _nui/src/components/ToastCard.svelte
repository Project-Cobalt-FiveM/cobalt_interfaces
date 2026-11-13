<script lang="ts">
  import { EXIT_MS, motion } from '../lib/motion';
  import Icon from './Icon.svelte';
  import type { Toast } from './Notifications.svelte';

  const AGE_TICK_MS = 15000;

  type Props = {
    toast: Toast;
    ondone: () => void;
  };

  let { toast, ondone }: Props = $props();

  let now = $state(Date.now());

  const age = $derived.by(() => {
    const minutes = Math.floor((now - toast.createdAt) / 60000);
    return minutes < 1 ? 'now' : `${minutes}m`;
  });

  $effect(() => {
    const hide = setTimeout(ondone, toast.duration);
    const tick = setInterval(() => (now = Date.now()), AGE_TICK_MS);

    return () => {
      clearTimeout(hide);
      clearInterval(tick);
    };
  });
</script>

<div
  role="status"
  class="relative flex items-start gap-3 overflow-hidden rounded-[0.625rem] border border-border bg-popover py-3.5 pr-3 pl-3.5"
  in:motion|global={{ x: 0.25 }}
  out:motion|global={{ x: 0.25, duration: EXIT_MS }}
>
  <div class="flex size-[1.375rem] shrink-0 items-center justify-center">
    <Icon name={toast.icon} size={20} color={toast.color} />
  </div>
  <div class="flex min-w-0 flex-1 flex-col gap-0.5">
    <p class="text-label font-semibold text-foreground">{toast.title}</p>
    {#if toast.description}
      <p class="text-description text-muted-foreground">{toast.description}</p>
    {/if}
  </div>
  <p class="shrink-0 text-caption text-caret tabular-nums">{age}</p>
  <div class="absolute bottom-0 left-0 h-0.5 w-full origin-left bg-keycap" style:animation="timer {toast.duration}ms linear forwards"></div>
</div>
