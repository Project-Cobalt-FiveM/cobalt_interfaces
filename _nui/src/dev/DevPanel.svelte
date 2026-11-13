<script lang="ts">
  import { send, showCard, showMenu, showRadial } from './mock';

  const BACKDROP = 'https://app.paper.design/file-assets/01M6B1MGR3HSCNKXHHZBTP3Q0D/6MT7N7ER3XJS1TRTC2SWC7BBQV.jpg';

  function scene() {
    send('notify', { type: 'info', title: 'New message', description: 'Maya Chen: on my way.', duration: 30000 });

    setTimeout(() => {
      send('notify', { type: 'error', title: 'Not enough cash', description: 'You need $250 more to buy this.', duration: 40000 });
    }, 120);

    setTimeout(() => {
      send('notify', { type: 'success', title: 'Vehicle locked', description: 'Your Sultan RS is locked.', duration: 60000 });
    }, 240);

    send('textUiShow', { text: '[E] - Open trunk' });
    send('progressStart', { label: 'Repairing engine', duration: 30000, icon: 'wrench', cancelKey: 'X' });
    send('skillCheckStart', { difficulty: [{ areaSize: 50, speedMultiplier: 0.05 }, 'medium', 'hard'], inputs: ['e'] });
    showMenu('vehicle');
  }

  function inputDialog() {
    send('inputDialogOpen', {
      heading: 'Sell vehicle',
      rows: [
        { type: 'input', label: 'Buyer state ID', icon: 'user', placeholder: 'NKX42817', required: true },
        { type: 'number', label: 'Price', prefix: '$', default: 42500 },
        {
          type: 'select',
          label: 'Payment',
          default: 'bank',
          options: [
            { value: 'cash', label: 'Cash' },
            { value: 'bank', label: 'Bank transfer' },
            { value: 'cheque', label: 'Cheque' },
            { value: 'crypto', label: 'Crypto (unavailable)', disabled: true },
          ],
        },
        {
          type: 'multi-select',
          label: 'Extras',
          options: [
            { value: 'tint', label: 'Tint' },
            { value: 'neon', label: 'Neon' },
          ],
        },
        { type: 'slider', label: 'Fuel included', default: 60, min: 0, max: 100 },
        { type: 'date', label: 'Handover date' },
        { type: 'color', label: 'Plate colour', default: '#5078D7' },
        { type: 'textarea', label: 'Note', placeholder: 'Anything the buyer should know' },
        { type: 'checkbox', label: 'Hand over the spare key', checked: true },
      ],
      options: { description: 'Sultan RS · 58KRT221', icon: 'car', submitText: 'Sell vehicle' },
    });
  }

  const actions: [string, () => void][] = [
    ['Scene', scene],
    ['Notify success', () => send('notify', { type: 'success', title: 'Vehicle locked', description: 'Your Sultan RS is locked.' })],
    ['Notify warning', () => send('notify', { type: 'warning', title: 'Low fuel', description: '8% left in the tank.' })],
    ['Notify no title', () => send('notify', { type: 'warn', description: '12% left. Nearest pump is 400 m away.' })],
    ['Progress', () => send('progressStart', { label: 'Repairing engine', duration: 5000, icon: 'wrench', cancelKey: 'X' })],
    ['Complete progress', () => send('progressStop', { completed: true, volume: 0.3 })],
    ['Cancel progress', () => send('progressStop', { completed: false, volume: 0.3 })],
    ['Text UI', () => send('textUiShow', { text: '[E] - Open trunk' })],
    ['Hide text UI', () => send('textUiHide')],
    ['Skill check', () => send('skillCheckStart', { difficulty: ['easy', 'medium', 'hard'], inputs: ['w', 'a', 's', 'd'] })],
    ['Cancel skill check', () => send('skillCheckCancel')],
    ['Context menu', () => showMenu('vehicle')],
    ['Radial', showRadial],
    ['Radial release', () => send('radialRelease')],
    ['Input dialog', inputDialog],
    [
      'Alert danger',
      () =>
        send('alertDialogOpen', {
          type: 'danger',
          header: 'Delete "Night shift" outfit?',
          content: "It's removed from your wardrobe and every saved outfit code stops working. This can't be undone.",
          labels: { confirm: 'Delete outfit', cancel: 'Keep it' },
        }),
    ],
    [
      'Alert confirm',
      () =>
        send('alertDialogOpen', {
          header: 'Join Los Santos Customs?',
          content: "You'll start as a Trainee mechanic and go on duty right away. You can leave from the job menu.",
          icon: 'briefcase',
          labels: { confirm: 'Join', cancel: 'Not now' },
        }),
    ],
    ['ID card', () => showCard('american', 'id')],
    ['Driver license', () => showCard('american', 'driver')],
    ['Firearms license', () => showCard('american', 'weapon')],
    ['Lebanese ID card', () => showCard('lebanese', 'id')],
    ['Lebanese driving licence', () => showCard('lebanese', 'driver')],
    ['Lebanese weapon permit', () => showCard('lebanese', 'weapon')],
    ['Hide card', () => send('cardHide')],
  ];

  const cardDemos = {
    'card-us-id': () => showCard('american', 'id'),
    'card-us-driver': () => showCard('american', 'driver'),
    'card-us-weapon': () => showCard('american', 'weapon'),
    'card-lb-id': () => showCard('lebanese', 'id'),
    'card-lb-driver': () => showCard('lebanese', 'driver'),
    'card-lb-weapon': () => showCard('lebanese', 'weapon'),
  };

  const demos: Record<string, () => void> = { scene, input: inputDialog, radial: showRadial, ...cardDemos };
  const params = new URLSearchParams(location.search);
  const clean = params.has('clean');

  $effect(() => {
    document.body.style.background = `#0A0A0A url(${BACKDROP}) center / cover`;
    demos[params.get('demo') ?? '']?.();
  });
</script>

<div class="absolute bottom-4 left-4 flex max-w-[40rem] flex-wrap gap-1" class:hidden={clean}>
  {#each actions as [label, run] (label)}
    <button
      type="button"
      onclick={(event) => {
        event.currentTarget.blur();
        run();
      }}
      class="h-8 rounded-md border border-border bg-card px-3 text-caption text-foreground hover:bg-muted"
    >
      {label}
    </button>
  {/each}
</div>
