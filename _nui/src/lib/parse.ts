export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

export function str(value: unknown): string | undefined {
  return typeof value === 'string' && value !== '' ? value : undefined;
}

export function num(value: unknown): number | undefined {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

export type NonEmpty<T> = [T, ...T[]];

export function nonEmpty<T>(items: T[]): NonEmpty<T> | null {
  const [head, ...rest] = items;
  return head === undefined ? null : [head, ...rest];
}

export function pick<T>(items: NonEmpty<T>): T {
  return items[Math.floor(Math.random() * items.length)] ?? items[0];
}
