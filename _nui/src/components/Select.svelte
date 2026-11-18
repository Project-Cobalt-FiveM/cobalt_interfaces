<script lang="ts" module>
  import type { SelectOption, SelectValue } from '../lib/form';

  export function fieldBorder(invalid: boolean): string {
    return invalid ? 'border-destructive' : 'border-input focus-visible:border-cobalt focus-within:border-cobalt';
  }

  function optionClass(option: SelectOption, selected: boolean, active: boolean): string {
    if (option.disabled) return 'cursor-default text-disabled';
    if (active) return 'bg-secondary text-foreground';
    if (selected) return 'bg-muted text-foreground';

    return 'text-muted-foreground';
  }
</script>

<script lang="ts">
  import { tick } from 'svelte';
  import { colors } from '../lib/colors';
  import { t } from '../lib/locale.svelte';
  import { EXIT_MS, motion } from '../lib/motion';
  import Icon from './Icon.svelte';

  type Props = {
    id: string;
    options: SelectOption[];
    selected: SelectValue[];
    multiple: boolean;
    disabled: boolean;
    invalid: boolean;
    placeholder?: string;
    onchange: (selected: SelectValue[]) => void;
  };

  let { id, options, selected, multiple, disabled, invalid, placeholder, onchange }: Props = $props();

  let open = $state(false);
  let active = $state(-1);

  const summary = $derived.by(() => {
    const labels = options.filter(isSelected).map((option) => option.label);
    return multiple && labels.length > 2 ? t('ui.selected_count', labels.length) : labels.join(', ');
  });

  function isSelected(option: SelectOption): boolean {
    return selected.includes(option.value);
  }

  function reveal(index: number) {
    document.getElementById(`${id}-opt-${index}`)?.scrollIntoView({ block: 'nearest' });
  }

  function openList() {
    active = Math.max(0, options.findIndex(isSelected));
    open = true;
    void tick().then(() => reveal(active));
  }

  function choose(option: SelectOption | undefined) {
    if (!option || option.disabled) return;

    if (!multiple) {
      onchange([option.value]);
      open = false;
      return;
    }

    onchange(isSelected(option) ? selected.filter((value) => value !== option.value) : [...selected, option.value]);
  }

  function move(step: number) {
    const count = options.length;

    for (let i = 1; i <= count; i++) {
      const next = (((active + step * i) % count) + count) % count;
      if (options[next] && !options[next].disabled) {
        active = next;
        reveal(next);
        return;
      }
    }
  }

  function onkeydown(event: KeyboardEvent) {
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault();
      if (!open) return openList();
      return move(event.key === 'ArrowDown' ? 1 : -1);
    }

    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      if (!open) return openList();
      return choose(options[active]);
    }

    if (event.key === 'Escape' && open) {
      event.preventDefault();
      open = false;
    }
  }
</script>

<div class="relative">
  <button
    {id}
    type="button"
    role="combobox"
    aria-expanded={open}
    aria-controls="{id}-list"
    {disabled}
    onclick={() => (open ? (open = false) : openList())}
    {onkeydown}
    onblur={() => (open = false)}
    class="flex h-10 w-full items-center gap-2 rounded-lg border px-3 text-left outline-none transition-colors duration-150 disabled:text-disabled {open
      ? 'bg-muted'
      : 'bg-background hover:bg-muted'} {fieldBorder(invalid)}"
  >
    <span class="flex-1 truncate text-label font-medium {summary ? 'text-foreground' : 'text-caret'}">{summary || placeholder || t('ui.select')}</span>
    <Icon name="caret-down" size={12} color={open ? colors.mutedForeground : colors.caret} class="transition-transform duration-200 {open ? 'rotate-180' : ''}" />
  </button>
  {#if open}
    <div
      id="{id}-list"
      role="listbox"
      tabindex="-1"
      aria-multiselectable={multiple}
      onmousedown={(event) => event.preventDefault()}
      class="absolute top-full right-0 left-0 z-10 mt-2 flex max-h-56 flex-col gap-0.5 overflow-y-auto rounded-[0.625rem] border border-input bg-popover p-1"
      in:motion={{ y: 0.25 }}
      out:motion={{ y: 0.25, duration: EXIT_MS }}
    >
      {#each options as option, index (option.value)}
        <div
          id="{id}-opt-{index}"
          role="option"
          tabindex="-1"
          aria-selected={isSelected(option)}
          aria-disabled={option.disabled}
          onmouseenter={() => !option.disabled && (active = index)}
          onmousedown={(event) => {
            event.preventDefault();
            choose(option);
          }}
          class="flex h-[2.125rem] shrink-0 items-center gap-2 rounded-md px-2.5 text-small font-medium transition-colors duration-150 {optionClass(
            option,
            isSelected(option),
            index === active,
          )}"
        >
          <span class="flex-1 truncate">{option.label}</span>
          {#if isSelected(option)}
            <Icon name="checkmark" size={12} color={colors.cobalt} />
          {/if}
        </div>
      {/each}
    </div>
  {/if}
</div>
