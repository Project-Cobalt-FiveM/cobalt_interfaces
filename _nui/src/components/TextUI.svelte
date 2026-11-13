<script lang="ts" module>
  import { resolveIcon } from '../lib/icons';
  import { isRecord, str } from '../lib/parse';
  import type { TextUiPosition } from '../lib/types';

  type Prompt = {
    key?: string;
    label: string;
    icon?: string;
    position: TextUiPosition;
  };

  const positions = {
    'left-center': { box: 'left-8 top-1/2 -translate-y-1/2', x: -0.25, y: 0 },
    'right-center': { box: 'right-8 top-1/2 -translate-y-1/2', x: 0.25, y: 0 },
    'top-center': { box: 'top-8 left-1/2 -translate-x-1/2', x: 0, y: -0.25 },
    'bottom-center': { box: 'bottom-8 left-1/2 -translate-x-1/2', x: 0, y: 0.25 },
  } as const satisfies Record<TextUiPosition, { box: string; x: number; y: number }>;

  const KEY_PREFIX = /^\[([^\]]{1,8})\]\s*(?:-\s*)?/;

  function parsePosition(value: unknown): TextUiPosition {
    return value === 'right-center' || value === 'top-center' || value === 'bottom-center' ? value : 'left-center';
  }

  function parsePrompt(data: unknown): Prompt | null {
    if (!isRecord(data)) return null;

    const text = str(data.text);
    if (!text) return null;

    const match = text.match(KEY_PREFIX);

    return {
      key: str(data.key) ?? match?.[1],
      label: match ? text.slice(match[0].length) : text,
      icon: resolveIcon(str(data.icon)),
      position: parsePosition(data.position),
    };
  }
</script>

<script lang="ts">
  import { colors } from '../lib/colors';
  import { EXIT_MS, motion } from '../lib/motion';
  import { onNui } from '../lib/nui';
  import Icon from './Icon.svelte';
  import Keycap from './Keycap.svelte';

  let prompt = $state<Prompt | null>(null);

  $effect(() => onNui('textUiShow', (data) => (prompt = parsePrompt(data))));
  $effect(() => onNui('textUiHide', () => (prompt = null)));
</script>

{#if prompt}
  {@const place = positions[prompt.position]}
  <div class="absolute {place.box}">
    <div
      class="flex h-11 items-center gap-2.5 rounded-[0.625rem] border border-border bg-card pr-4 {prompt.key || prompt.icon ? 'pl-2' : 'pl-4'}"
      in:motion={{ x: place.x, y: place.y }}
      out:motion={{ x: place.x, y: place.y, duration: EXIT_MS }}
    >
      {#if prompt.key}
        <Keycap label={prompt.key.toUpperCase()} size="md" />
      {:else if prompt.icon}
        <Icon name={prompt.icon} size={16} color={colors.mutedForeground} class="mx-1.5" />
      {/if}
      <p class="text-label font-medium whitespace-nowrap text-foreground">{prompt.label}</p>
    </div>
  </div>
{/if}
