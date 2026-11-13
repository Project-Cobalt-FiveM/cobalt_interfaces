<script lang="ts">
  import { colors } from '../lib/colors';
  import type { Row } from '../lib/form';
  import type { InputValue } from '../lib/types';
  import Icon from './Icon.svelte';
  import Select, { fieldBorder } from './Select.svelte';

  type Props = {
    id: string;
    row: Row;
    value: InputValue;
    invalid: boolean;
    onchange: (value: InputValue) => void;
  };

  let { id, row, value, invalid, onchange }: Props = $props();

  const text = $derived(typeof value === 'string' ? value : '');
  const selected = $derived(Array.isArray(value) ? value : value === null || typeof value === 'boolean' ? [] : [value]);
  const sliderMin = $derived(row.min ?? 0);
  const sliderMax = $derived(row.max ?? 100);
  const sliderValue = $derived(typeof value === 'number' ? value : sliderMin);
  const sliderPercent = $derived(sliderMax > sliderMin ? ((sliderValue - sliderMin) / (sliderMax - sliderMin)) * 100 : 0);
  const inputType = $derived(row.kind === 'number' || row.kind === 'date' ? row.kind : row.password ? 'password' : 'text');
  const swatch = $derived(/^#[0-9a-f]{6}$/i.test(text) ? text : colors.cobalt);
</script>

{#if row.kind === 'checkbox'}
  {@const checked = value === true}
  <div class="flex flex-col gap-1.5">
    <label for={id} class="flex cursor-pointer items-center gap-2.5">
      <button
        {id}
        type="button"
        role="checkbox"
        aria-checked={checked}
        disabled={row.disabled}
        onclick={() => onchange(!checked)}
        class="flex size-[1.125rem] shrink-0 items-center justify-center rounded-[0.3125rem] border outline-none transition-colors duration-150 focus-visible:ring-2 focus-visible:ring-cobalt focus-visible:ring-offset-2 focus-visible:ring-offset-card {checked
          ? 'border-cobalt bg-cobalt'
          : invalid
            ? 'border-destructive'
            : 'border-input'}"
      >
        {#if checked}
          <Icon name="checkmark" size={11} color={colors.foreground} />
        {/if}
      </button>
      <span class="text-small font-medium {row.disabled ? 'text-disabled' : 'text-foreground'}">{row.label}</span>
    </label>
    {#if row.description}
      <p class="text-caption text-muted-foreground">{row.description}</p>
    {/if}
  </div>
{:else if row.kind === 'slider'}
  <div class="flex flex-col gap-2.5">
    <div class="flex justify-between">
      <label for={id} class="text-small font-medium text-foreground">{row.label}</label>
      <span class="text-small font-semibold text-foreground tabular-nums">{sliderValue}</span>
    </div>
    <div class="relative flex h-4 items-center">
      <div class="absolute inset-x-0 h-1 rounded-full bg-secondary"></div>
      <div class="absolute left-0 h-1 rounded-full bg-cobalt" style:width="{sliderPercent}%"></div>
      <input
        {id}
        type="range"
        class="slider relative"
        min={sliderMin}
        max={sliderMax}
        step={row.step ?? 1}
        value={sliderValue}
        disabled={row.disabled}
        oninput={(event) => onchange(Number(event.currentTarget.value))}
      />
    </div>
  </div>
{:else}
  <div class="flex flex-col gap-1.5">
    <div class="flex justify-between gap-2">
      <label for={id} class="text-small font-medium text-foreground">{row.label}</label>
      {#if row.required}
        <span class="text-caption text-caret">Required</span>
      {/if}
    </div>
    {#if row.description}
      <p class="text-caption text-muted-foreground">{row.description}</p>
    {/if}
    {#if row.kind === 'select' || row.kind === 'multi-select'}
      <Select
        {id}
        options={row.options}
        {selected}
        multiple={row.kind === 'multi-select'}
        disabled={row.disabled}
        {invalid}
        placeholder={row.placeholder}
        onchange={(next) => onchange(row.kind === 'select' ? (next[0] ?? null) : next)}
      />
    {:else if row.kind === 'textarea'}
      <textarea
        {id}
        rows="3"
        value={text}
        placeholder={row.placeholder}
        disabled={row.disabled}
        oninput={(event) => onchange(event.currentTarget.value)}
        class="resize-none rounded-lg border bg-background px-3 py-2.5 text-label font-medium text-foreground outline-none transition-colors duration-150 placeholder:text-caret disabled:text-disabled {fieldBorder(
          invalid,
        )}"
      ></textarea>
    {:else}
      <div class="flex h-10 items-center gap-2 rounded-lg border bg-background px-3 transition-colors duration-150 {fieldBorder(invalid)}">
        {#if row.kind === 'color'}
          <input
            type="color"
            aria-label="{row.label} swatch"
            value={swatch}
            disabled={row.disabled}
            oninput={(event) => onchange(event.currentTarget.value.toUpperCase())}
            class="color-swatch size-5 shrink-0 cursor-pointer"
          />
          <input
            {id}
            value={text}
            disabled={row.disabled}
            oninput={(event) => onchange(event.currentTarget.value)}
            class="min-w-0 flex-1 bg-transparent text-label font-medium text-foreground uppercase tabular-nums outline-none"
          />
        {:else}
          {#if row.icon}
            <Icon name={row.icon} size={15} color={colors.caret} />
          {/if}
          {#if row.prefix}
            <span class="text-label text-caret">{row.prefix}</span>
          {/if}
          <input
            {id}
            type={inputType}
            value={text}
            placeholder={row.placeholder}
            disabled={row.disabled}
            min={row.min}
            max={row.max}
            step={row.step}
            oninput={(event) => onchange(event.currentTarget.value)}
            class="date-input min-w-0 flex-1 bg-transparent text-label font-medium text-foreground caret-cobalt outline-none placeholder:text-caret disabled:text-disabled {row.kind ===
            'number'
              ? 'tabular-nums'
              : ''}"
          />
        {/if}
      </div>
    {/if}
  </div>
{/if}
