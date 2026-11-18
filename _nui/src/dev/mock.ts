import { installMock } from '../lib/nui';
import type { CardShowData, CardStyle } from '../lib/card';
import type { Locales } from '../lib/locale.svelte';
import { isRecord } from '../lib/parse';
import type { ContextShowData, NuiAction, NuiMessages, RadialShowData } from '../lib/types';

const localeFiles = import.meta.glob<unknown>('../../../locales/en.json', { eager: true, import: 'default' });

function flatten(tree: unknown, prefix = '', into: Locales = {}): Locales {
  if (typeof tree === 'string') {
    into[prefix] = tree;
    return into;
  }

  if (!isRecord(tree)) return into;

  for (const [key, value] of Object.entries(tree)) {
    flatten(value, prefix ? `${prefix}.${key}` : key, into);
  }

  return into;
}

const locales = flatten(Object.values(localeFiles)[0]);

let lastId = 0;

export function send<K extends NuiAction>(action: K, ...data: NuiMessages[K] extends undefined ? [] : [NuiMessages[K]]): void {
  window.postMessage({ action, data: data[0] }, '*');
}

export function nextId(): number {
  lastId += 1;
  return lastId;
}

const menus: Record<'vehicle' | 'trunk', ContextShowData> = {
  vehicle: {
    id: 'vehicle',
    title: 'Sultan RS',
    canBack: true,
    options: [
      { key: 1, title: 'Start engine', description: 'Engine is off', icon: 'car' },
      { key: 2, title: 'Lock doors', description: 'Doors are unlocked', icon: 'key' },
      { key: 3, title: 'Engine health', icon: 'wrench', progress: 42, colorScheme: 'yellow' },
      { key: 4, title: 'Open trunk', description: '12 of 30 slots used', icon: 'package', arrow: true },
      { key: 5, title: 'Hotwire', description: 'Needs a lockpick', icon: 'lock', disabled: true },
    ],
  },
  trunk: {
    id: 'trunk',
    title: 'Trunk',
    canBack: true,
    options: [
      { key: 1, title: 'Take item', icon: 'hand' },
      { key: 2, title: 'Store item', icon: 'tray-arrow-down' },
    ],
  },
};

export const radialRoot: RadialShowData = {
  menu: 'root',
  clickMode: false,
  items: [
    { id: 'vehicle', label: 'Vehicle', icon: 'car', submenu: true, count: 6 },
    { id: 'emotes', label: 'Emotes', icon: 'smiley', submenu: true, count: 12 },
    { id: 'inventory', label: 'Inventory', icon: 'backpack' },
    { id: 'phone', label: 'Phone', icon: 'device-mobile' },
    { id: 'clothing', label: 'Clothing', icon: 't-shirt' },
    { id: 'billing', label: 'Billing', icon: 'receipt' },
    { id: 'id', label: 'Show ID', icon: 'identification-card' },
    { id: 'job', label: 'Job', icon: 'briefcase', disabled: true },
  ],
};

const radialVehicle: RadialShowData = {
  menu: 'vehicle',
  label: 'Vehicle',
  parent: 'Menu',
  clickMode: true,
  items: [
    { id: 'engine', label: 'Engine', icon: 'engine' },
    { id: 'lock', label: 'Lock', icon: 'lock' },
    { id: 'doors', label: 'Doors', icon: 'door' },
    { id: 'trunk', label: 'Trunk', icon: 'package' },
    { id: 'lights', label: 'Lights', icon: 'lightbulb' },
    { id: 'seats', label: 'Seats', icon: 'armchair' },
  ],
};

const holders: Record<CardStyle, Omit<CardShowData, 'kind' | 'style'>> = {
  american: { citizenid: 'LKR20311', firstname: 'Maya', lastname: 'Chen', birthdate: '1996-04-12', gender: 1, nationality: 'American', issued: '2026-11-05' },
  lebanese: { citizenid: 'LKR20311', firstname: 'Karim', lastname: 'Haddad', birthdate: '1994-03-21', gender: 0, nationality: 'Lebanese', issued: '2026-11-05' },
};

const grantedBy: Record<string, string> = { driver: 'the DMV', weapon: 'LSPD' };

export function showCard(style: CardStyle, kind: 'id' | 'driver' | 'weapon'): void {
  send('cardShow', { ...holders[style], style, kind, grantedBy: grantedBy[kind] });
}

export function showMenu(id: keyof typeof menus): void {
  send('contextShow', menus[id]);
}

export function showRadial(): void {
  send('radialShow', radialRoot);
}

installMock({
  contextSelect: ({ id, key }) => {
    if (id === 'vehicle' && key === 4) return showMenu('trunk');
    send('contextHide');
  },
  contextBack: ({ id }) => {
    if (id === 'trunk') showMenu('vehicle');
  },
  contextClose: () => send('contextHide'),
  skillCheckOver: (data) => console.info('skill check', JSON.stringify(data)),
  inputDialogSubmit: (data) => console.info('input dialog', JSON.stringify(data)),
  alertDialogSubmit: (data) => console.info('alert dialog', JSON.stringify(data)),
  radialSelect: ({ index }) => {
    if (index === 1) return send('radialShow', radialVehicle);
    console.info('radial select', index);
    send('radialHide');
  },
  radialBack: () => send('radialShow', { ...radialRoot, clickMode: true }),
  radialClose: () => send('radialHide'),
  ready: () => send('setLocales', locales),
});

send('setLocales', locales);
