import { resolveIcon } from './icons';
import { isRecord, num, str } from './parse';
import type { InputRowType, InputValue } from './types';

export type SelectValue = string | number;

export type SelectOption = {
  value: SelectValue;
  label: string;
  disabled: boolean;
};

export type Row = {
  kind: InputRowType;
  label: string;
  description?: string;
  placeholder?: string;
  icon?: string;
  prefix?: string;
  required: boolean;
  disabled: boolean;
  password: boolean;
  returnString: boolean;
  min?: number;
  max?: number;
  step?: number;
  options: SelectOption[];
  initial: InputValue;
};

export type Form = {
  run: number;
  heading: string;
  description?: string;
  icon: string;
  allowCancel: boolean;
  submitText: string;
  cancelText: string;
  rows: Row[];
};

const kinds: readonly InputRowType[] = ['input', 'number', 'select', 'multi-select', 'slider', 'checkbox', 'textarea', 'date', 'color'];

let runs = 0;

function parseKind(value: unknown): InputRowType {
  return kinds.find((kind) => kind === value) ?? 'input';
}

function isSelectValue(value: unknown): value is SelectValue {
  return typeof value === 'string' || typeof value === 'number';
}

function parseOptions(value: unknown): SelectOption[] {
  if (!Array.isArray(value)) return [];

  return value.filter(isRecord).flatMap((option) => {
    const raw = option.value;
    if (!isSelectValue(raw)) return [];

    return [{ value: raw, label: str(option.label) ?? String(raw), disabled: option.disabled === true }];
  });
}

function toDateInput(value: unknown): string {
  if (typeof value === 'string') return value.slice(0, 10);
  if (typeof value !== 'number') return '';

  const date = new Date(value);
  const pad = (n: number) => String(n).padStart(2, '0');

  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

function initialValue(kind: InputRowType, data: Record<string, unknown>, min?: number): InputValue {
  const fallback = data.default;

  switch (kind) {
    case 'number':
      return num(fallback)?.toString() ?? '';
    case 'checkbox':
      return data.checked === true || fallback === true;
    case 'select':
      return isSelectValue(fallback) ? fallback : null;
    case 'multi-select':
      return Array.isArray(fallback) ? fallback.filter(isSelectValue) : [];
    case 'slider':
      return num(fallback) ?? min ?? 0;
    case 'date':
      return toDateInput(fallback);
    case 'color':
      return str(fallback) ?? '#5078D7';
    case 'input':
    case 'textarea':
      return isSelectValue(fallback) ? String(fallback) : '';
    default: {
      const exhaustive: never = kind;
      return exhaustive;
    }
  }
}

function parseRow(data: unknown): Row {
  const row = isRecord(data) ? data : { label: typeof data === 'string' ? data : '' };
  const kind = parseKind(row.type);
  const min = num(row.min);

  return {
    kind,
    label: str(row.label) ?? '',
    description: str(row.description),
    placeholder: str(row.placeholder),
    icon: resolveIcon(str(row.icon)),
    prefix: str(row.prefix),
    required: row.required === true || row.isRequired === true,
    disabled: row.disabled === true,
    password: row.password === true,
    returnString: row.returnString === true,
    min,
    max: num(row.max),
    step: num(row.step),
    options: parseOptions(row.options),
    initial: initialValue(kind, row, min),
  };
}

export function parseForm(data: unknown): Form | null {
  if (!isRecord(data) || !Array.isArray(data.rows)) return null;

  const options = isRecord(data.options) ? data.options : {};

  return {
    run: runs++,
    heading: str(data.heading) ?? '',
    description: str(options.description),
    icon: resolveIcon(str(options.icon)) ?? 'note-pencil',
    allowCancel: options.allowCancel !== false && options.canCancel !== false,
    submitText: str(options.submitText) ?? str(options.confirmLabel) ?? 'Confirm',
    cancelText: str(options.cancelText) ?? 'Cancel',
    rows: data.rows.map(parseRow),
  };
}

export function output(row: Row, value: InputValue): InputValue {
  if (row.kind === 'number') {
    const parsed = typeof value === 'string' && value.trim() !== '' ? Number(value) : NaN;
    return Number.isFinite(parsed) ? parsed : null;
  }

  if (row.kind === 'date') {
    if (typeof value !== 'string' || value === '') return null;
    return row.returnString ? value : new Date(`${value}T00:00:00`).getTime();
  }

  if (value === '' && row.kind !== 'color') return null;

  return value;
}

export function missing(row: Row, value: InputValue): boolean {
  if (!row.required) return false;
  if (Array.isArray(value)) return value.length === 0;

  return value === null || value === '' || value === false;
}

export function fieldId(run: number, index: number): string {
  return `input-dialog-${run}-${index}`;
}
