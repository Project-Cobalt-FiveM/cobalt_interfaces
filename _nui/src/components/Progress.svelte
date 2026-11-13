<script lang="ts" module>
  import { resolveIcon } from '../lib/icons';
  import { isRecord, num, str } from '../lib/parse';

  type Outcome = 'complete' | 'cancel';

  type Bar = {
    run: number;
    label: string;
    duration: number;
    icon: string;
    cancelKey?: string;
    outcome?: Outcome;
  };

  const SEGMENTS = 20;
  const RESULT_HOLD_MS = 700;

  const sounds: Record<Outcome, HTMLAudioElement> = {
    complete: new Audio('./sounds/complete.ogg'),
    cancel: new Audio('./sounds/cancel.ogg'),
  };

  let runs = 0;

  function playSound(outcome: Outcome, volume: number) {
    if (volume <= 0) return;

    const sound = sounds[outcome];
    sound.volume = Math.min(1, volume);
    sound.currentTime = 0;
    sound.play().catch(() => {});
  }

  function parseBar(data: unknown): Bar | null {
    if (!isRecord(data)) return null;

    const duration = num(data.duration);
    if (!duration || duration <= 0) return null;

    return {
      run: runs++,
      label: str(data.label) ?? '',
      duration,
      icon: resolveIcon(str(data.icon)) ?? 'hourglass-medium',
      cancelKey: str(data.cancelKey),
    };
  }

  function outcomeIcon(bar: Bar): string {
    if (bar.outcome === 'complete') return 'check-circle';
    if (bar.outcome === 'cancel') return 'x-circle';

    return bar.icon;
  }
</script>

<script lang="ts">
  import { colors } from '../lib/colors';
  import { EXIT_MS, motion } from '../lib/motion';
  import { onNui } from '../lib/nui';
  import Icon from './Icon.svelte';
  import Keycap from './Keycap.svelte';

  let bar = $state<Bar | null>(null);
  let elapsed = $state(0);
  let hold: ReturnType<typeof setTimeout> | undefined;

  const running = $derived(bar !== null && bar.outcome === undefined);
  const percent = $derived(bar?.outcome === 'complete' ? 100 : elapsed);
  const filled = $derived(Math.floor(percent / (100 / SEGMENTS)));
  const cancelled = $derived(bar?.outcome === 'cancel');
  const fillClass = $derived(cancelled ? 'bg-destructive' : 'bg-cobalt');

  $effect(() =>
    onNui('progressStart', (data) => {
      clearTimeout(hold);
      elapsed = 0;
      bar = parseBar(data);
    }),
  );

  $effect(() =>
    onNui('progressStop', (data) => {
      const outcome: Outcome = isRecord(data) && data.completed === true ? 'complete' : 'cancel';

      clearTimeout(hold);
      if (bar) bar = { ...bar, outcome };
      playSound(outcome, isRecord(data) ? (num(data.volume) ?? 0) : 0);
      hold = setTimeout(() => (bar = null), RESULT_HOLD_MS);
    }),
  );

  $effect(() => {
    if (!running || !bar) return;

    const duration = bar.duration;
    const start = performance.now();
    let frame = 0;

    const tick = (now: number) => {
      elapsed = Math.min(100, Math.floor(((now - start) / duration) * 100));
      frame = requestAnimationFrame(tick);
    };

    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  });

  $effect(() => () => clearTimeout(hold));
</script>

{#if bar}
  <div class="absolute bottom-24 left-1/2 w-[23.75rem] -translate-x-1/2">
    <div in:motion={{ y: 0.25 }} out:motion={{ y: 0.25, duration: EXIT_MS }}>
      {#key bar.run}
        <div
          class="flex flex-col gap-2.5 motion-reduce:animate-none {cancelled ? 'animate-shake' : ''}"
          role="progressbar"
          aria-valuenow={percent}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-label={bar.label}
        >
          <div class="flex items-center gap-2.5">
            <Icon name={outcomeIcon(bar)} size={16} color={cancelled ? colors.destructive : colors.cobalt} />
            <p class="flex-1 truncate text-label font-semibold text-foreground">{cancelled ? 'Cancelled' : bar.label}</p>
            <p class="text-label font-semibold tabular-nums transition-colors duration-200 {cancelled ? 'text-destructive' : 'text-foreground'}">
              {percent}%
            </p>
          </div>
          <div class="flex gap-[0.1875rem] motion-reduce:animate-none {bar.outcome === 'complete' ? 'animate-settle' : ''}">
            {#each { length: SEGMENTS }, index (index)}
              <div
                class="h-1.5 flex-1 rounded-sm transition-colors duration-200 {index < filled ? fillClass : 'bg-secondary'}"
              ></div>
            {/each}
          </div>
          {#if bar.cancelKey}
            <div class="flex items-center justify-center gap-2 transition-opacity duration-150 {running ? 'opacity-100' : 'opacity-0'}">
              <Keycap label={bar.cancelKey} size="sm" />
              <p class="text-caption font-medium text-hint">Cancel</p>
            </div>
          {/if}
        </div>
      {/key}
    </div>
  </div>
{/if}
