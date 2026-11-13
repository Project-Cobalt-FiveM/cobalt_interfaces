<script lang="ts">
  const sizes = {
    sm: 'h-6 min-w-6 px-1 rounded-[0.375rem] border-b-[3px] text-[0.75rem] leading-[0.75rem]',
    md: 'h-7 min-w-7 px-1 rounded-[0.375rem] border-b-[3px] text-small',
    lg: 'h-11 min-w-11 px-2 rounded-[0.625rem] border-b-4 text-[1.25rem] leading-6',
  } as const;

  type Props = {
    label: string;
    size: keyof typeof sizes;
  };

  let { label, size }: Props = $props();
</script>

<kbd class="flex shrink-0 items-center justify-center border border-keycap bg-secondary font-sans font-bold text-foreground {sizes[size]}">
  {label}
</kbd>
