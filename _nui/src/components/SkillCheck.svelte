<script lang="ts" module>
  import { isRecord, nonEmpty, num, pick, str, type NonEmpty } from '../lib/parse';

  type Round = { areaSize: number; speed: number };

  type Check = {
    run: number;
    rounds: NonEmpty<Round>;
    inputs: NonEmpty<string>;
  };

  type Dot = 'passed' | 'failed' | 'current' | 'pending';

  const presets: Record<string, Round> = {
    easy: { areaSize: 50, speed: 1 },
    medium: { areaSize: 40, speed: 1.5 },
    hard: { areaSize: 25, speed: 1.75 },
  };

  const DEGREES_PER_SECOND = 150;
  const ZONE_MIN_START = 90;
  const RESULT_HOLD_MS = 300;

  const dotColors: Record<Dot, string> = {
    passed: 'bg-success',
    failed: 'bg-destructive',
    current: 'bg-cobalt',
    pending: 'bg-input',
  };

  let runs = 0;

  function parseRound(value: unknown): Round | null {
    if (typeof value === 'string') return presets[value] ?? null;
    if (!isRecord(value)) return null;

    const areaSize = num(value.areaSize);
    const speed = num(value.speedMultiplier);
    if (!areaSize || !speed) return null;

    return { areaSize: Math.min(Math.max(areaSize, 5), 180), speed: Math.max(speed, 0.1) };
  }

  function parseCheck(data: unknown): Check | null {
    if (!isRecord(data)) return null;

    const list: unknown[] = Array.isArray(data.difficulty) ? data.difficulty : [data.difficulty];
    const rounds = nonEmpty(list.map(parseRound).filter((round) => round !== null));
    if (!rounds) return null;

    const keys = Array.isArray(data.inputs) ? data.inputs.map(str).filter((key) => key !== undefined) : [];

    return {
      run: runs++,
      rounds,
      inputs: nonEmpty(keys.map((key) => key.toLowerCase())) ?? ['e'],
    };
  }

  function point(angle: number, radius: number): [number, number] {
    const radians = (angle * Math.PI) / 180;
    return [80 + radius * Math.sin(radians), 80 - radius * Math.cos(radians)];
  }

  function arcPath(start: number, size: number): string {
    const [x1, y1] = point(start, 60);
    const [x2, y2] = point(start + size, 60);
    return `M${x1} ${y1} A60 60 0 ${size > 180 ? 1 : 0} 1 ${x2} ${y2}`;
  }

  function randomZone(round: Round): number {
    const latest = 360 - round.areaSize - 10;
    return ZONE_MIN_START + Math.random() * Math.max(0, latest - ZONE_MIN_START);
  }
</script>

<script lang="ts">
  import { EXIT_MS, motion } from '../lib/motion';
  import { onNui, post } from '../lib/nui';
  import Keycap from './Keycap.svelte';

  let check = $state<Check | null>(null);
  let roundIndex = $state(0);
  let key = $state('e');
  let zone = $state(0);
  let angle = $state(0);
  let result = $state<boolean | null>(null);
  let hold: ReturnType<typeof setTimeout> | undefined;

  const round = $derived(check ? (check.rounds[roundIndex] ?? check.rounds[0]) : null);
  const label = $derived(key.toUpperCase());
  const needle = $derived([point(angle, 48), point(angle, 72)] as const);
  const dots = $derived<Dot[]>(
    check?.rounds.map((_, index) => {
      if (index < roundIndex) return 'passed';
      if (index > roundIndex) return 'pending';
      if (result === null) return 'current';
      return result ? 'passed' : 'failed';
    }) ?? [],
  );

  function start(next: Check) {
    clearTimeout(hold);
    check = next;
    roundIndex = 0;
    key = pick(next.inputs);
    zone = randomZone(next.rounds[0]);
    angle = 0;
    result = null;
  }

  function finish(success: boolean) {
    clearTimeout(hold);
    check = null;
    post('skillCheckOver', success);
  }

  function finishRound(success: boolean) {
    if (!check || result !== null) return;

    const next = check.rounds[roundIndex + 1];

    if (success && next) {
      roundIndex += 1;
      key = pick(check.inputs);
      zone = randomZone(next);
      angle = 0;
      return;
    }

    result = success;
    const run = check.run;
    hold = setTimeout(() => {
      if (check?.run === run) finish(success);
    }, RESULT_HOLD_MS);
  }

  function onkeydown(event: KeyboardEvent) {
    if (!check || !round || result !== null || event.repeat) return;

    const pressed = event.key.toLowerCase();
    if (!check.inputs.includes(pressed)) return;

    finishRound(pressed === key && angle >= zone && angle <= zone + round.areaSize);
  }

  $effect(() =>
    onNui('skillCheckStart', (data) => {
      const parsed = parseCheck(data);
      if (parsed) start(parsed);
      else post('skillCheckOver', false);
    }),
  );

  $effect(() =>
    onNui('skillCheckCancel', () => {
      if (check) finish(false);
    }),
  );

  $effect(() => {
    if (!round || result !== null) return;

    const speed = round.speed;
    const end = zone + round.areaSize;
    let last = performance.now();
    let frame = requestAnimationFrame(tick);

    function tick(now: number) {
      angle += ((now - last) / 1000) * DEGREES_PER_SECOND * speed;
      last = now;

      if (angle > end) return finishRound(false);

      frame = requestAnimationFrame(tick);
    }

    return () => cancelAnimationFrame(frame);
  });

  $effect(() => () => clearTimeout(hold));
</script>

<svelte:window {onkeydown} />

{#if check && round}
  <div class="absolute top-[calc(50%-6.25rem)] left-1/2 -translate-x-1/2">
    <div class="flex w-[16.25rem] flex-col items-center gap-3.5" in:motion={{ scale: 0.98 }} out:motion={{ scale: 0.98, duration: EXIT_MS }}>
      <div class="relative flex size-40 items-center justify-center">
        <svg viewBox="0 0 160 160" class="absolute inset-0 size-full" aria-hidden="true">
          <circle cx="80" cy="80" r="60" fill="none" stroke="#262626" stroke-width="6" />
          <path d={arcPath(zone, round.areaSize)} fill="none" stroke="#5078D7" stroke-width="6" stroke-linecap="round" />
          <line x1={needle[0][0]} y1={needle[0][1]} x2={needle[1][0]} y2={needle[1][1]} stroke="#FAFAFA" stroke-width="4" stroke-linecap="round" />
        </svg>
        <Keycap {label} size="lg" />
      </div>
      <div class="flex h-[1.875rem] items-center gap-2.5 rounded-lg border border-border bg-card px-3">
        <div class="flex gap-1">
          {#each dots as dot, index (index)}
            <span class="size-2 rounded-full transition-colors duration-150 {dotColors[dot]}"></span>
          {/each}
        </div>
        <p class="text-small font-semibold whitespace-nowrap text-foreground">Press {label} in the blue zone</p>
      </div>
    </div>
  </div>
{/if}
