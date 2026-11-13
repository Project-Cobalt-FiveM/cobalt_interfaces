import type { TransitionConfig } from 'svelte/transition';

export const ENTER_MS = 200;
export const EXIT_MS = 150;

const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

function bezier(x1: number, y1: number, x2: number, y2: number): (t: number) => number {
  const axis = (a: number, b: number, t: number) => 3 * a * t * (1 - t) ** 2 + 3 * b * t ** 2 * (1 - t) + t ** 3;

  return (x: number) => {
    let low = 0;
    let high = 1;

    for (let i = 0; i < 24; i++) {
      const mid = (low + high) / 2;
      if (axis(x1, x2, mid) < x) low = mid;
      else high = mid;
    }

    return axis(y1, y2, (low + high) / 2);
  };
}

export const ease = bezier(0.2, 0, 0, 1);

export type MotionParams = {
  x?: number;
  y?: number;
  scale?: number;
  duration?: number;
};

export function motion(_node: Element, { x = 0, y = 0, scale = 1, duration = ENTER_MS }: MotionParams = {}): TransitionConfig {
  const moves = !reducedMotion.matches;

  return {
    duration,
    easing: ease,
    css: (t, u) => {
      const transform = moves ? `transform: translate(${x * u}rem, ${y * u}rem) scale(${1 - (1 - scale) * u});` : '';
      return `opacity: ${t}; ${transform}`;
    },
  };
}
