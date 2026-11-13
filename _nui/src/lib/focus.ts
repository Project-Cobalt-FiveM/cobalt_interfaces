const FOCUSABLE = 'button:not(:disabled), input:not(:disabled), textarea:not(:disabled)';
const FIELDS = 'input:not(:disabled), textarea:not(:disabled), [role="combobox"]:not(:disabled), [role="checkbox"]:not(:disabled)';
const LAST_ACTION = '[data-action]:last-child';

export function insideDialog(target: EventTarget | null): boolean {
  return target instanceof Element && target.closest('[role="dialog"]') !== null;
}

export function focusFirstField(root: HTMLElement): void {
  const first = root.querySelector<HTMLElement>(FIELDS) ?? root.querySelector<HTMLElement>(LAST_ACTION);
  first?.focus();
}

export function trapFocus(event: KeyboardEvent, root: HTMLElement): void {
  const focusable = [...root.querySelectorAll<HTMLElement>(FOCUSABLE)];
  const first = focusable[0];
  const last = focusable[focusable.length - 1];
  if (!first || !last) return;

  if (event.shiftKey && document.activeElement === first) {
    event.preventDefault();
    last.focus();
  } else if (!event.shiftKey && document.activeElement === last) {
    event.preventDefault();
    first.focus();
  }
}
