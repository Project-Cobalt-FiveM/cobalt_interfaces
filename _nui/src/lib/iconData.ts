const sources = import.meta.glob<string>('../../node_modules/@phosphor-icons/core/assets/fill/*.svg', {
  query: '?raw',
  import: 'default',
  eager: true,
});

const bodies: [string, string][] = Object.entries(sources).map(([path, svg]) => [
  path.slice(path.lastIndexOf('/') + 1, -'-fill.svg'.length),
  svg.replace(/^<svg[^>]*>|<\/svg>$/g, ''),
]);

export default bodies;
