import { isRecord } from './parse';
import type { NuiAction, NuiCallback, NuiCallbacks } from './types';

declare global {
  interface Window {
    GetParentResourceName?: () => string;
  }
}

export type MockHandlers = { [K in NuiCallback]: (data: NuiCallbacks[K]) => void };

type Listener = (data: unknown) => void;

export const inGame = 'GetParentResourceName' in window;

const resourceName = window.GetParentResourceName?.() ?? 'cobalt_interfaces';
const listeners = new Map<string, Set<Listener>>();

let mockHandlers: MockHandlers | null = null;

window.addEventListener('message', (event: MessageEvent<unknown>) => {
  const message = event.data;
  if (!isRecord(message) || typeof message.action !== 'string') return;

  listeners.get(message.action)?.forEach((listener) => listener(message.data));
});

export function installMock(handlers: MockHandlers): void {
  mockHandlers = handlers;
}

export function onNui(action: NuiAction, listener: Listener): () => void {
  const set = listeners.get(action) ?? new Set<Listener>();
  set.add(listener);
  listeners.set(action, set);

  return () => set.delete(listener);
}

export function post<K extends NuiCallback>(name: K, data: NuiCallbacks[K]): void {
  if (mockHandlers) {
    const handler: MockHandlers[K] = mockHandlers[name];
    handler(data);
    return;
  }

  if (!inGame) return;

  fetch(`https://${resourceName}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data),
  }).catch(() => {});
}
