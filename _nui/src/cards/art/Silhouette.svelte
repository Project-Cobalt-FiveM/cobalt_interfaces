<script lang="ts">
  let { class: className = '' }: { class?: string } = $props();
</script>

<svg class={className} viewBox="0 0 196 244" aria-hidden="true">
  <defs>
    <radialGradient id="card-silhouette-head" cx="0.42" cy="0.35" r="0.7">
      <stop offset="0" stop-color="#A9B4BD" />
      <stop offset="1" stop-color="#7F8C97" />
    </radialGradient>
    <linearGradient id="card-silhouette-body" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#6F7C87" />
      <stop offset="1" stop-color="#56636E" />
    </linearGradient>
  </defs>
  <path d="M98 50c-27 0-44 21-44 50 0 22 9 40 21 51l-1 15c-30 6-56 22-60 78h168c-4-56-30-72-60-78l-1-15c12-11 21-29 21-51 0-29-17-50-44-50z" fill="url(#card-silhouette-body)" />
  <ellipse cx="98" cy="102" rx="41" ry="52" fill="url(#card-silhouette-head)" />
</svg>
