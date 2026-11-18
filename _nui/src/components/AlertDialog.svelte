<script lang="ts" module>
  import { resolveIcon } from '../lib/icons';
  import { t } from '../lib/locale.svelte';
  import { isRecord, num, str } from '../lib/parse';
  import type { AlertResult } from '../lib/types';

  type Alert = {
    id: number;
    run: number;
    danger: boolean;
    header: string;
    content?: string;
    icon: string;
    showCancel: boolean;
    confirmText: string;
    cancelText: string;
  };

  let runs = 0;

  function parseAlert(data: unknown): Alert | null {
    if (!isRecord(data)) return null;

    const id = num(data.id);
    if (id === undefined) return null;

    const danger = data.type === 'danger';
    const labels = isRecord(data.labels) ? data.labels : {};

    return {
      id,
      run: runs++,
      danger,
      header: str(data.header) ?? '',
      content: str(data.content),
      icon: resolveIcon(str(data.icon)) ?? (danger ? 'warning' : 'question'),
      showCancel: data.cancel !== false,
      confirmText: str(labels.confirm) ?? t('ui.confirm'),
      cancelText: str(labels.cancel) ?? t('ui.cancel'),
    };
  }
</script>

<script lang="ts">
  import { colors } from '../lib/colors';
  import { onNui, post } from '../lib/nui';
  import ActionButton from './ActionButton.svelte';
  import DialogShell from './DialogShell.svelte';
  import Icon from './Icon.svelte';

  let alert = $state<Alert | null>(null);

  function finish(result: AlertResult) {
    if (!alert) return;

    const id = alert.id;
    alert = null;
    post('alertDialogSubmit', { id, result });
  }

  $effect(() => onNui('alertDialogOpen', (data) => (alert = parseAlert(data))));
  $effect(() => onNui('alertDialogClose', (data) => finish(isRecord(data) && data.reason === 'confirm' ? 'confirm' : 'cancel')));
</script>

{#if alert}
  {#key alert.run}
    <DialogShell width="w-[23.75rem]" label={alert.header} oncancel={() => finish('cancel')} onconfirm={() => finish('confirm')}>
      <div class="flex flex-col items-center gap-3.5 rounded-[0.625rem] border border-border bg-popover px-[1.125rem] pt-6 pb-[1.375rem]">
        <div class="flex size-11 shrink-0 items-center justify-center rounded-xl {alert.danger ? 'bg-destructive-solid' : 'bg-cobalt'}">
          <Icon name={alert.icon} size={22} color={colors.foreground} />
        </div>
        <div class="flex flex-col items-center gap-1.5 text-center">
          <p class="text-title font-semibold text-foreground">{alert.header}</p>
          {#if alert.content}
            <p class="text-prose whitespace-pre-line text-muted-foreground">{alert.content}</p>
          {/if}
        </div>
      </div>
      <div class="flex gap-2">
        {#if alert.showCancel}
          <ActionButton variant="cancel" onclick={() => finish('cancel')}>{alert.cancelText}</ActionButton>
        {/if}
        <ActionButton variant={alert.danger ? 'danger' : 'confirm'} onclick={() => finish('confirm')}>{alert.confirmText}</ActionButton>
      </div>
    </DialogShell>
  {/key}
{/if}
