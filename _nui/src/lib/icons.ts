import { SvelteMap } from 'svelte/reactivity';

const icons = new SvelteMap<string, string>();
const ICON_NAME = /^[a-z0-9]+(-[a-z0-9]+)*$/;

let loaded = false;

void import('./iconData').then(({ default: bodies }) => {
  for (const [name, body] of bodies) icons.set(name, body);
  loaded = true;
});

icons.set(
  'close',
  '<path d="M205.66,194.34a8,8,0,0,1-11.32,11.32L128,139.31,61.66,205.66a8,8,0,0,1-11.32-11.32L116.69,128,50.34,61.66A8,8,0,0,1,61.66,50.34L128,116.69l66.34-66.35a8,8,0,0,1,11.32,11.32L139.31,128Z"/>',
);

icons.set('checkmark', '<path d="M232.49,80.49l-128,128a12,12,0,0,1-17,0l-56-56a12,12,0,1,1,17-17L96,183,215.51,63.51a12,12,0,0,1,17,17Z"/>');

const aliases: Record<string, string> = {
  'circle-check': 'check-circle',
  'circle-xmark': 'x-circle',
  'circle-info': 'info',
  'triangle-exclamation': 'warning',
  xmark: 'close',
  'chevron-right': 'caret-right',
  'chevron-left': 'caret-left',
  'screwdriver-wrench': 'wrench',
  box: 'package',
  'box-open': 'package',
  'car-side': 'car-profile',
  'money-bill': 'money',
  'money-bill-wave': 'money',
  'dollar-sign': 'currency-dollar',
  'user-group': 'users',
  'location-dot': 'map-pin',
  'hand-holding': 'hand',
  'right-from-bracket': 'sign-out',
  'right-to-bracket': 'sign-in',
  shirt: 't-shirt',
  'mobile-screen': 'device-mobile',
  mobile: 'device-mobile',
  utensils: 'fork-knife',
  'trash-can': 'trash',
  'pen-to-square': 'pencil-simple',
  gears: 'gear-six',
  ban: 'prohibit',
  unlock: 'lock-open',
};

export function iconBody(name: string): string | undefined {
  return icons.get(name);
}

export function resolveIcon(name: string | undefined): string | undefined {
  if (!name) return undefined;

  const bare = name
    .replace(/\b(fa-solid|fa-regular|fas|far|fab|fa)\s+/g, '')
    .replace(/^fa-/, '')
    .trim();
  const alias = aliases[bare];

  if (!loaded) return alias ?? (ICON_NAME.test(bare) ? bare : undefined);

  if (icons.has(bare)) return bare;

  return alias && icons.has(alias) ? alias : undefined;
}
