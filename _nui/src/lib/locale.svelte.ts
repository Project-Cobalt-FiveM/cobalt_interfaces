import { isRecord } from './parse';

export type Locales = Record<string, string>;

let dict: Locales = $state.raw({});

export function t(key: string, ...args: (string | number)[]): string {
  const template = dict[key];
  if (template === undefined) return key;

  let index = 0;
  return template.replace(/%[sd]/g, (placeholder) => {
    const value = args[index++];
    return value === undefined ? placeholder : String(value);
  });
}

function parseLocales(data: unknown): Locales {
  if (!isRecord(data)) return {};

  const locales: Locales = {};

  for (const [key, value] of Object.entries(data)) {
    if (typeof value === 'string') locales[key] = value;
  }

  return locales;
}

export function setLocales(data: unknown): void {
  dict = parseLocales(data);
}
