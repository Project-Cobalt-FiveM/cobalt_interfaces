<script lang="ts">
  import { colors } from '../lib/colors';
  import { fieldId, missing, outOfRange, output, parseForm, type Form } from '../lib/form';
  import { t } from '../lib/locale.svelte';
  import { onNui, post } from '../lib/nui';
  import type { InputValue } from '../lib/types';
  import ActionButton from './ActionButton.svelte';
  import DialogShell from './DialogShell.svelte';
  import Field from './Field.svelte';
  import Icon from './Icon.svelte';

  let form = $state<Form | null>(null);
  let values = $state<InputValue[]>([]);
  let invalid = $state<ReadonlySet<number>>(new Set());

  function open(next: Form | null) {
    form = next;
    values = next?.rows.map((row) => row.initial) ?? [];
    invalid = new Set();
  }

  function finish(result: InputValue[] | null) {
    if (!form) return;

    const id = form.id;
    form = null;
    post('inputDialogSubmit', { id, values: result });
  }

  function setValue(index: number, value: InputValue) {
    values[index] = value;

    if (!invalid.has(index)) return;

    const next = new Set(invalid);
    next.delete(index);
    invalid = next;
  }

  function cancel() {
    if (form?.allowCancel) finish(null);
  }

  function confirm() {
    if (!form) return;

    const rows = form.rows;
    const failed = new Set(
      rows.flatMap((row, index) => {
        const value = values[index] ?? null;
        return missing(row, value) || outOfRange(row, value) ? [index] : [];
      }),
    );

    if (failed.size > 0) {
      invalid = failed;
      document.getElementById(fieldId(form.run, Math.min(...failed)))?.focus();
      return;
    }

    finish(rows.map((row, index) => output(row, values[index] ?? null)));
  }

  $effect(() => onNui('inputDialogOpen', (data) => open(parseForm(data))));
  $effect(() => onNui('inputDialogClose', () => finish(null)));
</script>

{#if form}
  {#key form.run}
    <DialogShell width="w-[25rem]" label={form.heading} oncancel={cancel} onconfirm={confirm}>
      <div class="flex items-center gap-3 rounded-[0.625rem] border border-border bg-popover p-3.5">
        <div class="flex size-[2.125rem] shrink-0 items-center justify-center rounded-lg border border-border">
          <Icon name={form.icon} size={18} color={colors.cobalt} />
        </div>
        <div class="flex min-w-0 flex-1 flex-col gap-0.5">
          <p class="truncate text-heading font-semibold text-foreground">{form.heading}</p>
          {#if form.description}
            <p class="truncate text-caption text-muted-foreground">{form.description}</p>
          {/if}
        </div>
        {#if form.allowCancel}
          <button
            type="button"
            aria-label={t('ui.close')}
            onclick={cancel}
            class="flex size-6 shrink-0 items-center justify-center rounded-md outline-none transition-colors duration-150 hover:bg-muted focus-visible:ring-2 focus-visible:ring-cobalt"
          >
            <Icon name="close" size={13} color={colors.mutedForeground} />
          </button>
        {/if}
      </div>
      {#if form.rows.length > 0}
        <div class="flex flex-col gap-4 rounded-[0.625rem] border border-border bg-popover px-3.5 py-4">
          {#each form.rows as row, index (index)}
            <Field
              id={fieldId(form.run, index)}
              {row}
              value={values[index] ?? null}
              invalid={invalid.has(index)}
              onchange={(value) => setValue(index, value)}
            />
          {/each}
        </div>
      {/if}
      <div class="flex gap-2">
        {#if form.allowCancel}
          <ActionButton variant="cancel" onclick={cancel}>{form.cancelText}</ActionButton>
        {/if}
        <ActionButton variant="confirm" onclick={confirm}>{form.submitText}</ActionButton>
      </div>
    </DialogShell>
  {/key}
{/if}
