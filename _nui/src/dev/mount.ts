import { mount } from 'svelte';
import DevPanel from './DevPanel.svelte';
import './mock';

const target = document.createElement('div');
document.body.append(target);
mount(DevPanel, { target });
