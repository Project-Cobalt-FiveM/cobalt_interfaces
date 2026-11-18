<script lang="ts" module>
  import { colors } from '../lib/colors';
  import { resolveIcon } from '../lib/icons';
  import { t } from '../lib/locale.svelte';
  import { isRecord, num, str } from '../lib/parse';

  export type Toast = {
    key: number;
    id?: string;
    title: string;
    description?: string;
    duration: number;
    icon: string;
    color: string;
    createdAt: number;
  };

  const MAX_VISIBLE = 4;
  const DEFAULT_DURATION = 5000;

  const types = {
    success: { title: 'ui.notify.success', icon: 'check-circle', color: colors.success },
    error: { title: 'ui.notify.error', icon: 'warning-circle', color: colors.destructive },
    warning: { title: 'ui.notify.warning', icon: 'warning', color: colors.warning },
    info: { title: 'ui.notify.info', icon: 'info', color: colors.cobalt },
  } as const;

  type NotifyType = keyof typeof types;

  const typeAliases: Record<string, NotifyType> = { inform: 'info', warn: 'warning' };

  let nextKey = 0;

  function parseType(value: unknown): NotifyType {
    if (value === 'success' || value === 'error' || value === 'warning' || value === 'info') return value;
    if (typeof value !== 'string') return 'info';

    return typeAliases[value] ?? 'info';
  }

  function parseToast(data: unknown): Toast | null {
    if (!isRecord(data)) return null;

    const type = types[parseType(data.type)];

    return {
      key: nextKey++,
      id: str(data.id),
      title: str(data.title) ?? t(type.title),
      description: str(data.description),
      duration: num(data.duration) ?? DEFAULT_DURATION,
      icon: resolveIcon(str(data.icon)) ?? type.icon,
      color: str(data.iconColor) ?? type.color,
      createdAt: Date.now(),
    };
  }
</script>

<script lang="ts">
  import { onNui } from '../lib/nui';
  import ToastCard from './ToastCard.svelte';

  let toasts = $state<Toast[]>([]);

  function remove(key: number) {
    toasts = toasts.filter((toast) => toast.key !== key);
  }

  $effect(() =>
    onNui('notify', (data) => {
      const toast = parseToast(data);
      if (!toast) return;

      const rest = toast.id ? toasts.filter((current) => current.id !== toast.id) : toasts;
      toasts = [toast, ...rest].slice(0, MAX_VISIBLE);
    }),
  );
</script>

<div class="absolute top-8 right-8 flex w-[21.25rem] flex-col gap-2">
  {#each toasts as toast (toast.key)}
    <ToastCard {toast} ondone={() => remove(toast.key)} />
  {/each}
</div>
