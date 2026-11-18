<script lang="ts" module>
  import { resolveIcon } from '../lib/icons';
  import { t } from '../lib/locale.svelte';
  import { isRecord, nonEmpty, num, str, type NonEmpty } from '../lib/parse';

  type Item = {
    id: string;
    label: string;
    icon?: string;
    disabled: boolean;
    submenu: boolean;
    count?: number;
  };

  type Menu = {
    key: string;
    label?: string;
    parent?: string;
    clickMode: boolean;
    items: NonEmpty<Item>;
  };

  type Hover = number | 'centre' | null;

  const RING_RADIUS = 142;
  const TILE = 80;
  const STAGE_MARGIN = 18;
  const BAND_RADIUS = 76;
  const HOVER_RADIUS = 84;
  const CENTRE_SIZE = 136;
  const ARC_HALF_DEGREES = 20;

  let shows = 0;

  function parseItem(data: unknown): Item | null {
    if (!isRecord(data)) return null;

    const label = str(data.label);
    if (!label) return null;

    return {
      id: str(data.id) ?? label,
      label,
      icon: resolveIcon(str(data.icon)),
      disabled: data.disabled === true,
      submenu: data.submenu === true,
      count: num(data.count),
    };
  }

  function parseMenu(data: unknown): Menu | null {
    if (!isRecord(data) || !Array.isArray(data.items)) return null;

    const items = nonEmpty(data.items.map(parseItem).filter((item) => item !== null));
    if (!items) return null;

    return {
      key: `${str(data.menu) ?? 'root'}-${shows++}`,
      label: str(data.label),
      parent: str(data.parent),
      clickMode: data.clickMode === true,
      items,
    };
  }

  function ringRadius(count: number): number {
    if (count < 2) return RING_RADIUS;

    return Math.max(RING_RADIUS, TILE / Math.SQRT2 / Math.sin(Math.PI / count));
  }

  function point(degrees: number, radius: number, centre: number): [number, number] {
    const radians = (degrees * Math.PI) / 180;
    return [centre + radius * Math.sin(radians), centre - radius * Math.cos(radians)];
  }

  function rem(px: number): string {
    return `${px / 16}rem`;
  }

  function arcPath(degrees: number, centre: number): string {
    const [x0, y0] = point(degrees - ARC_HALF_DEGREES, BAND_RADIUS, centre);
    const [x1, y1] = point(degrees + ARC_HALF_DEGREES, BAND_RADIUS, centre);

    return `M${x0} ${y0} A${BAND_RADIUS} ${BAND_RADIUS} 0 0 1 ${x1} ${y1}`;
  }

  function itemDetail(item: Item): string | undefined {
    if (item.disabled) return t('ui.unavailable');
    if (item.submenu && item.count) return t(item.count === 1 ? 'ui.actions_one' : 'ui.actions_other', item.count);
  }

  function tileLabelClass(item: Item, lit: boolean): string {
    if (item.disabled) return 'text-disabled';
    return lit ? 'text-foreground' : 'text-muted-foreground';
  }
</script>

<script lang="ts">
  import { colors } from '../lib/colors';
  import { insideDialog } from '../lib/focus';
  import { EXIT_MS, motion } from '../lib/motion';
  import { onNui, post } from '../lib/nui';
  import Icon from './Icon.svelte';

  let menu = $state<Menu | null>(null);
  let hover = $state<Hover>(null);
  let stage: HTMLDivElement | undefined = $state();

  const step = $derived(menu ? 360 / menu.items.length : 0);
  const radius = $derived(menu ? ringRadius(menu.items.length) : RING_RADIUS);
  const stageSize = $derived(2 * (radius + TILE / 2 + STAGE_MARGIN));
  const stageCentre = $derived(stageSize / 2);
  const hovered = $derived(typeof hover === 'number' ? menu?.items[hover] : undefined);
  const arc = $derived(hovered && !hovered.disabled && typeof hover === 'number' ? arcPath(hover * step, stageCentre) : null);
  const detail = $derived(
    hovered ? itemDetail(hovered) : (menu?.parent ?? t(menu?.clickMode ? 'ui.click_to_close' : 'ui.release_to_close')),
  );

  function select(index: number) {
    const item = menu?.items[index];
    if (!item || item.disabled) return;

    post('radialSelect', { index: index + 1 });
  }

  function centre() {
    post(menu?.parent ? 'radialBack' : 'radialClose', {});
  }

  function onmousemove(event: MouseEvent) {
    if (!menu || !stage) return;

    const rect = stage.getBoundingClientRect();
    const scale = rect.width / stageSize;
    const dx = event.clientX - (rect.left + rect.width / 2);
    const dy = event.clientY - (rect.top + rect.height / 2);

    if (Math.hypot(dx, dy) < HOVER_RADIUS * scale) {
      hover = 'centre';
      return;
    }

    const degrees = ((Math.atan2(dx, -dy) * 180) / Math.PI + 360) % 360;
    hover = Math.round(degrees / step) % menu.items.length;
  }

  function onkeydown(event: KeyboardEvent) {
    if (!menu || insideDialog(event.target)) return;

    if (event.key === 'Escape') post('radialClose', {});
    if (event.key === 'Backspace') post('radialBack', {});
  }

  $effect(() =>
    onNui('radialShow', (data) => {
      menu = parseMenu(data);
      hover = null;
    }),
  );

  $effect(() => onNui('radialHide', () => (menu = null)));

  $effect(() =>
    onNui('radialClickMode', () => {
      if (menu) menu = { ...menu, clickMode: true };
    }),
  );

  $effect(() =>
    onNui('radialRelease', () => {
      if (typeof hover === 'number' && hovered && !hovered.disabled) return select(hover);

      post('radialClose', {});
    }),
  );
</script>

<svelte:window {onmousemove} {onkeydown} />

{#if menu}
  <div class="absolute inset-0 flex items-center justify-center">
    <div
      bind:this={stage}
      class="relative shrink-0"
      style:width={rem(stageSize)}
      style:height={rem(stageSize)}
      in:motion={{ scale: 0.96 }}
      out:motion={{ scale: 0.96, duration: EXIT_MS }}
    >
      <svg viewBox="0 0 {stageSize} {stageSize}" class="absolute inset-0 size-full" aria-hidden="true">
        <circle cx={stageCentre} cy={stageCentre} r={BAND_RADIUS} fill="none" stroke={colors.card} stroke-width="16" />
        {#if arc}
          <path d={arc} fill="none" stroke={colors.cobalt} stroke-width="3" stroke-linecap="round" />
        {/if}
      </svg>
      {#key menu.key}
        <div class="absolute inset-0 animate-radial motion-reduce:animate-none">
          {#each menu.items as item, index (item.id)}
            {@const [x, y] = point(index * step, radius, stageCentre)}
            {@const lit = hover === index && !item.disabled}
            <button
              type="button"
              disabled={item.disabled}
              onmouseenter={() => (hover = index)}
              onclick={() => select(index)}
              aria-label={item.label}
              class="absolute flex flex-col items-center justify-center gap-[0.4375rem] rounded-2xl border outline-none transition-colors duration-150 {lit
                ? 'border-cobalt bg-cobalt'
                : 'border-border bg-card'}"
              style:left={rem(x - TILE / 2)}
              style:top={rem(y - TILE / 2)}
              style:width={rem(TILE)}
              style:height={rem(TILE)}
            >
              {#if item.icon}
                <Icon name={item.icon} size={22} color={item.disabled ? colors.disabled : colors.foreground} />
              {/if}
              <span class="max-w-[4.5rem] truncate text-caption font-medium {tileLabelClass(item, lit)}">{item.label}</span>
              {#if item.submenu}
                <Icon name="caret-right" size={9} color={lit ? colors.foreground : colors.caret} class="absolute top-[0.5625rem] right-[0.5625rem]" />
              {/if}
            </button>
          {/each}
        </div>
      {/key}
      <button
        type="button"
        onclick={centre}
        onmouseenter={() => (hover = 'centre')}
        class="absolute flex flex-col items-center justify-center gap-1 rounded-full border border-border bg-card outline-none"
        style:left={rem(stageCentre - CENTRE_SIZE / 2)}
        style:top={rem(stageCentre - CENTRE_SIZE / 2)}
        style:width={rem(CENTRE_SIZE)}
        style:height={rem(CENTRE_SIZE)}
      >
        {#if hovered}
          <span class="max-w-[7rem] truncate text-heading font-semibold text-foreground">{hovered.label}</span>
        {:else}
          <Icon name={menu.parent ? 'arrow-left' : 'close'} size={16} color={colors.mutedForeground} />
          <span class="text-small font-medium text-muted-foreground">{t(menu.parent ? 'ui.back' : 'ui.close')}</span>
        {/if}
        {#if detail}
          <span class="max-w-[7rem] truncate text-caption text-caret">{detail}</span>
        {/if}
      </button>
    </div>
  </div>
{/if}
