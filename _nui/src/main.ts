import { mount } from 'svelte';
import './app.css';
import App from './App.svelte';
import { setLocales } from './lib/locale.svelte';
import { inGame, onNui, post } from './lib/nui';

const target = document.getElementById('app');

if (target) {
  onNui('setLocales', setLocales);
  mount(App, { target });
  post('ready', {});
  if (import.meta.env.DEV && !inGame) void import('./dev/mount');
}
