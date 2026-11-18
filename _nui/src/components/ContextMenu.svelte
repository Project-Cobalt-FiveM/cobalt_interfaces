<script lang="ts" module>
  import { colors } from '../lib/colors';
  import { resolveIcon } from '../lib/icons';
  import { isRecord, num, str } from '../lib/parse';
  import type { ContextOptionKey } from '../lib/types';

  type Option = {
    key: ContextOptionKey;
    title: string;
    description?: string;
    icon?: string;
    iconColor?: string;
    progress?: number;
    progressColor: string;
    progressText: string;
    arrow: boolean;
    disabled: boolean;
    readOnly: boolean;
  };

  type Menu = {
    id: string;
    title: string;
    canBack: boolean;
    canClose: boolean;
    options: Option[];
  };

  const schemes: Record<string, string> = {
    blue: colors.cobalt,
    green: colors.success,
    teal: colors.success,
    yellow: colors.warning,
    orange: colors.warning,
    red: colors.destructive,
  };

  function parseScheme(value: unknown): string {
    const scheme = str(value);
    if (!scheme) return colors.cobalt;

    return schemes[scheme] ?? (scheme.startsWith('#') ? scheme : colors.cobalt);
  }

  function parseOption(value: unknown): Option | null {
    if (!isRecord(value)) return null;

    const key = typeof value.key === 'number' ? value.key : str(value.key);
    if (key === undefined) return null;

    const progressColor = parseScheme(value.colorScheme);

    return {
      key,
      title: str(value.title) ?? '',
      description: str(value.description),
      icon: resolveIcon(str(value.icon)),
      iconColor: str(value.iconColor),
      progress: num(value.progress),
      progressColor,
      progressText: progressColor === colors.cobalt ? colors.cobaltForeground : progressColor,
      arrow: value.arrow === true,
      disabled: value.disabled === true,
      readOnly: value.readOnly === true,
    };
  }

  function parseMenu(data: unknown): Menu | null {
    if (!isRecord(data)) return null;

    const id = str(data.id);
    if (!id || !Array.isArray(data.options)) return null;

    return {
      id,
      title: str(data.title) ?? '',
      canBack: data.canBack === true,
      canClose: data.canClose !== false,
      options: data.options.map(parseOption).filter((option) => option !== null),
    };
  }

  function selectable(option: Option | undefined): option is Option {
    return option !== undefined && !option.disabled && !option.readOnly;
  }

  function optionSurface(option: Option, lit: boolean): string {
    if (option.disabled) return 'cursor-default border-muted bg-popover';
    if (option.readOnly) return 'cursor-default border-border bg-popover';
    if (lit) return 'border-input bg-muted';

    return 'border-border bg-popover';
  }

  function optionIconColor(option: Option, lit: boolean): string {
    if (option.disabled) return colors.disabled;
    if (lit) return colors.cobalt;

    return option.iconColor ?? colors.foreground;
  }
</script>

<script lang="ts">
  import { insideDialog } from '../lib/focus';
  import { t } from '../lib/locale.svelte';
  import { EXIT_MS, motion } from '../lib/motion';
  import { onNui, post } from '../lib/nui';
  import Icon from './Icon.svelte';

  let menu = $state<Menu | null>(null);
  let focus = $state(-1);
  let optionEls = $state<HTMLButtonElement[]>([]);

  function show(next: Menu | null) {
    if (next && next.id !== menu?.id) focus = next.options.findIndex(selectable);
    menu = next;
  }

  function select(option: Option | undefined) {
    if (menu && selectable(option)) post('contextSelect', { id: menu.id, key: option.key });
  }

  function back() {
    if (menu?.canBack) post('contextBack', { id: menu.id });
  }

  function close() {
    if (menu?.canClose) post('contextClose', { id: menu.id });
  }

  function move(step: number) {
    if (!menu) return;

    const count = menu.options.length;

    for (let i = 1; i <= count; i++) {
      const next = (((focus + step * i) % count) + count) % count;
      if (selectable(menu.options[next])) {
        focus = next;
        optionEls[next]?.scrollIntoView({ block: 'nearest' });
        return;
      }
    }
  }

  function onkeydown(event: KeyboardEvent) {
    if (!menu || insideDialog(event.target)) return;

    switch (event.key) {
      case 'ArrowDown':
      case 'Tab':
        event.preventDefault();
        return move(event.shiftKey ? -1 : 1);
      case 'ArrowUp':
        event.preventDefault();
        return move(-1);
      case 'Enter':
      case ' ':
        event.preventDefault();
        return select(menu.options[focus]);
      case 'Backspace':
      case 'ArrowLeft':
        return back();
      case 'Escape':
        return close();
    }
  }

  $effect(() => onNui('contextShow', (data) => show(parseMenu(data))));
  $effect(() => onNui('contextHide', () => (menu = null)));
</script>

<svelte:window {onkeydown} />

{#if menu}
  <div class="absolute top-1/2 right-8 w-80 -translate-y-1/2">
    <div class="flex flex-col gap-2" in:motion={{ x: 0.25 }} out:motion={{ x: 0.25, duration: EXIT_MS }}>
      <div class="flex h-11 items-center gap-3 rounded-[0.625rem] border border-border bg-popover px-3.5">
        {#if menu.canBack}
          <button type="button" aria-label={t('ui.back')} onclick={back} class="-m-1 rounded p-1 transition-colors duration-150 hover:bg-muted">
            <Icon name="arrow-left" size={14} color={colors.mutedForeground} />
          </button>
        {/if}
        <p class="flex-1 truncate text-heading font-semibold text-foreground">{menu.title}</p>
        {#if menu.canClose}
          <button type="button" aria-label={t('ui.close')} onclick={close} class="-m-1 rounded p-1 transition-colors duration-150 hover:bg-muted">
            <Icon name="close" size={13} color={colors.mutedForeground} />
          </button>
        {/if}
      </div>
      {#key menu.id}
        <div class="flex max-h-[calc(100vh-8rem)] flex-col gap-2 overflow-y-auto" role="menu" aria-label={menu.title}>
          {#each menu.options as option, index (option.key)}
            {@const lit = index === focus && selectable(option)}
            <button
              bind:this={optionEls[index]}
              type="button"
              role="menuitem"
              tabindex="-1"
              aria-disabled={!selectable(option)}
              onmouseenter={() => selectable(option) && (focus = index)}
              onclick={() => select(option)}
              class="flex w-full shrink-0 items-center gap-3.5 rounded-[0.625rem] border px-3.5 py-3 text-left transition-colors duration-150 {optionSurface(option, lit)}"
            >
              {#if option.icon}
                <Icon name={option.icon} size={18} color={optionIconColor(option, lit)} />
              {/if}
              <div class="flex min-w-0 flex-1 flex-col {option.progress === undefined ? 'gap-0.5' : 'gap-[0.4375rem]'}">
                <div class="flex items-baseline justify-between gap-2">
                  <p class="truncate text-label font-medium {option.disabled ? 'text-disabled' : 'text-foreground'}">{option.title}</p>
                  {#if option.progress !== undefined}
                    <p class="text-caption font-semibold tabular-nums" style:color={option.disabled ? colors.disabled : option.progressText}>
                      {Math.round(option.progress)}%
                    </p>
                  {/if}
                </div>
                {#if option.description}
                  <p class="text-caption {option.disabled ? 'text-disabled' : 'text-muted-foreground'}">{option.description}</p>
                {/if}
                {#if option.progress !== undefined}
                  <div class="h-[0.1875rem] rounded-sm bg-secondary">
                    <div
                      class="h-full rounded-sm"
                      style:width="{Math.min(100, Math.max(0, option.progress))}%"
                      style:background-color={option.disabled ? colors.disabled : option.progressColor}
                    ></div>
                  </div>
                {/if}
              </div>
              {#if option.arrow}
                <Icon name="caret-right" size={12} color={option.disabled ? colors.disabled : colors.caret} />
              {/if}
            </button>
          {/each}
        </div>
      {/key}
    </div>
  </div>
{/if}
