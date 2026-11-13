<script lang="ts">
  import { iconBody } from '../lib/icons';

  type Props = {
    name: string;
    size: number;
    color: string;
    class?: string;
  };

  let { name, size, color, class: className = '' }: Props = $props();

  const body = $derived(iconBody(name));
  const rem = $derived(`${size / 16}rem`);
</script>

{#if body}
  <svg
    viewBox="0 0 256 256"
    width={rem}
    height={rem}
    fill={color}
    aria-hidden="true"
    class="shrink-0 transition-[fill] duration-150 {className}"
  >
    {@html body}
  </svg>
{/if}
