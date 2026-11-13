<script lang="ts">
  import { formatDate, ghostDate, issuerOf, themeOf, type Card } from '../lib/card';
  import Silhouette from './art/Silhouette.svelte';
  import holoLebanon from './textures/holo-lb.webp';
  import holoSanAndreas from './textures/holo-us.webp';
  import wearDark from './textures/wear-dark.webp';
  import wearLight from './textures/wear-light.webp';

  let { card }: { card: Card } = $props();

  const theme = $derived(themeOf(card));
  const lebanese = $derived(card.style === 'lebanese');
  const sex = $derived(card.male === null ? '—' : card.male ? 'M' : 'F');
  const sexArabic = $derived(card.male === null ? '' : card.male ? 'ذكر' : 'أنثى');
  const signature = $derived(`${card.firstname} ${card.lastname}`);
  const nationality = $derived((card.nationality ?? '—').toUpperCase());
  const issuer = $derived(issuerOf(card));
</script>

<article class="card" class:lebanese>
  <img class="layer" src={theme.texture} alt="" />

  <div class="photo print">
    {#if card.photo}<img src={card.photo} alt="" />{:else}<Silhouette class="silhouette" />{/if}
  </div>
  <div class="photo-frame print"></div>

  {#if lebanese}
    <header class="header-lb print">
      <span class="arabic-title" dir="rtl" lang="ar">الجمهورية اللبنانية</span>
      <span class="state-lb">République Libanaise · Republic of Lebanon</span>
      <span class="subtitle-lb">
        <span>{theme.subtitle}</span>
        <span class="arabic" dir="rtl" lang="ar">{theme.subtitleArabic}</span>
      </span>
    </header>
  {:else}
    <header class="header-us print">
      <span class="state">San Andreas</span>
      <span class="subtitle">{theme.subtitle}</span>
    </header>
  {/if}

  <div class="band">
    <span class="band-label">{theme.bandLabel}</span>
    {#if theme.bandLabelArabic}
      <span class="band-arabic" dir="rtl" lang="ar">{theme.bandLabelArabic}</span>
    {:else}
      <span class="band-country">USA</span>
    {/if}
  </div>

  {#if lebanese}
    <dl class="data data-lb print">
      <div class="field">
        <dt><span>{theme.numberLabel}</span><span class="arabic" dir="rtl" lang="ar">رقم البطاقة</span></dt>
        <dd class="number">{card.citizenid}</dd>
      </div>
      <div class="pair">
        <div class="field">
          <dt><span>LAST NAME</span><span class="arabic" dir="rtl" lang="ar">الشهرة</span></dt>
          <dd class="name">{card.lastname.toUpperCase()}</dd>
        </div>
        <div class="field">
          <dt><span>FIRST NAME</span><span class="arabic" dir="rtl" lang="ar">الاسم</span></dt>
          <dd class="name">{card.firstname.toUpperCase()}</dd>
        </div>
      </div>
      <div class="pair">
        <div class="field">
          <dt><span>DATE OF BIRTH</span><span class="arabic" dir="rtl" lang="ar">تاريخ الولادة</span></dt>
          <dd>{formatDate(card.birthdate, card.style)}</dd>
        </div>
        <div class="field">
          <dt><span>SEX</span><span class="arabic" dir="rtl" lang="ar">الجنس</span></dt>
          <dd>{sex} <span class="arabic-value" lang="ar">{sexArabic}</span></dd>
        </div>
      </div>
      <div class="pair">
        <div class="field">
          <dt><span>NATIONALITY</span><span class="arabic" dir="rtl" lang="ar">الجنسية</span></dt>
          <dd>{nationality}</dd>
        </div>
        <div class="field">
          <dt><span>ISSUE DATE</span><span class="arabic" dir="rtl" lang="ar">تاريخ الإصدار</span></dt>
          <dd>{formatDate(card.issued, card.style)}</dd>
        </div>
      </div>
      <div class="field">
        <dt>
          <span>{theme.issuerLabel}</span>
          <span class="arabic" dir="rtl" lang="ar">{card.kind === 'id' ? 'صادرة عن' : 'ممنوحة من'}</span>
        </dt>
        <dd class="issuer">{issuer}</dd>
      </div>
    </dl>
  {:else}
    <dl class="data data-us print">
      <div class="row"><dt>{theme.numberLabel}</dt><dd class="number">{card.citizenid}</dd></div>
      <div class="row"><dt class="short">1 LN</dt><dd class="name">{card.lastname.toUpperCase()}</dd></div>
      <div class="row"><dt class="short">2 FN</dt><dd class="name">{card.firstname.toUpperCase()}</dd></div>
      <div class="row gap">
        <div class="row"><dt>3 DOB</dt><dd class="dob">{formatDate(card.birthdate, card.style)}</dd></div>
        <div class="row"><dt>15 SEX</dt><dd>{sex}</dd></div>
      </div>
      <div class="row gap">
        <div class="row"><dt>NAT</dt><dd>{nationality}</dd></div>
        <div class="row"><dt>4a ISS</dt><dd>{formatDate(card.issued, card.style)}</dd></div>
      </div>
      <div class="row"><dt>{theme.issuerLabel}</dt><dd class="issuer">{issuer}</dd></div>
    </dl>
  {/if}

  <span class="signature print">{signature}</span>

  <div class="ghost">
    {#if card.photo}<img src={card.photo} alt="" />{:else}<Silhouette class="silhouette" />{/if}
  </div>
  <span class="ghost-date">{ghostDate(card.birthdate, card.style)}</span>

  <img class="layer holo" src={lebanese ? holoLebanon : holoSanAndreas} alt="" />
  <img class="layer wear-dark" src={wearDark} alt="" />
  <img class="layer wear-light" src={wearLight} alt="" />
  <div class="sheen"></div>
  <div class="laminate"></div>
</article>

<style>
  .card {
    position: relative;
    width: 856px;
    height: 540px;
    border-radius: 30px;
    overflow: hidden;
    isolation: isolate;
    font-family: 'Roboto Condensed', sans-serif;
    color: #17181c;
    box-shadow:
      0 0 0 1px #cfcac0,
      0 26px 50px #00000066,
      0 6px 14px #00000040;
  }

  .layer {
    position: absolute;
    inset: 0;
    width: 856px;
    height: 540px;
    pointer-events: none;
  }

  .print {
    mix-blend-mode: multiply;
  }

  .photo {
    position: absolute;
    left: 32px;
    top: 176px;
    width: 196px;
    height: 244px;
    border-radius: 6px;
    overflow: hidden;
    background-image: linear-gradient(180deg, #c9d6e0 0%, #aebfcc 100%);
  }

  .photo-frame {
    position: absolute;
    left: 31px;
    top: 175px;
    width: 196px;
    height: 244px;
    border: 1px solid #8696a3;
    border-radius: 7px;
  }

  .photo img,
  .ghost img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .card :global(.silhouette) {
    width: 100%;
    height: 100%;
  }

  .header-us {
    position: absolute;
    left: 132px;
    top: 26px;
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .state {
    font-family: 'Libre Baskerville', serif;
    font-size: 42px;
    line-height: 46px;
    font-weight: 700;
    letter-spacing: 0.005em;
    color: #1b2f5b;
  }

  .subtitle {
    font-size: 12.5px;
    line-height: 16px;
    font-weight: 700;
    letter-spacing: 0.3em;
    color: #a3242c;
  }

  .header-lb {
    position: absolute;
    right: 34px;
    top: 16px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    text-align: right;
  }

  .arabic-title {
    font-family: 'Amiri', serif;
    font-size: 38px;
    line-height: 48px;
    font-weight: 700;
    color: #134a2c;
  }

  .state-lb {
    font-family: 'Libre Baskerville', serif;
    font-size: 15px;
    line-height: 20px;
    font-weight: 700;
    letter-spacing: 0.03em;
    color: #134a2c;
  }

  .subtitle-lb {
    display: flex;
    align-items: baseline;
    gap: 10px;
    margin-top: 3px;
    font-size: 11px;
    line-height: 16px;
    font-weight: 700;
    letter-spacing: 0.18em;
    color: #b8152b;
  }

  .arabic {
    font-family: 'Noto Naskh Arabic', serif;
    letter-spacing: 0;
  }

  .subtitle-lb .arabic {
    font-size: 13px;
  }

  .band {
    position: absolute;
    left: 0;
    top: 124px;
    width: 856px;
    height: 32px;
    box-sizing: border-box;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 34px;
    color: #ffffff;
  }

  .lebanese .band {
    height: 34px;
  }

  .band-label {
    font-size: 16px;
    font-weight: 700;
    letter-spacing: 0.36em;
  }

  .band-country {
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.3em;
    color: #d6deef;
  }

  .band-arabic {
    font-family: 'Noto Naskh Arabic', serif;
    font-size: 19px;
    font-weight: 700;
  }

  .data {
    position: absolute;
    left: 254px;
    top: 180px;
    width: 410px;
    display: flex;
    flex-direction: column;
    margin: 0;
  }

  .data dt {
    font-size: 11px;
    line-height: 14px;
    font-weight: 700;
    color: #a3242c;
  }

  .data dd {
    margin: 0;
    font-size: 21px;
    line-height: 26px;
    font-weight: 700;
    color: #17181c;
  }

  .data-us {
    gap: 12px;
  }

  .row {
    display: flex;
    align-items: baseline;
    gap: 8px;
  }

  .row.gap {
    gap: 30px;
  }

  .short {
    width: 30px;
  }

  .data .number {
    font-size: 31px;
    line-height: 34px;
    letter-spacing: 0.04em;
    color: #a3242c;
  }

  .data .name {
    font-size: 27px;
    line-height: 30px;
  }

  .data .dob {
    font-size: 23px;
    color: #a3242c;
  }

  .data .issuer {
    font-size: 16px;
    line-height: 20px;
    letter-spacing: 0.04em;
    color: #1b2f5b;
  }

  .data-lb {
    gap: 8px;
  }

  .field {
    display: flex;
    flex-direction: column;
  }

  .data-lb dt {
    display: flex;
    justify-content: space-between;
    font-size: 10px;
    line-height: 15px;
    letter-spacing: 0.08em;
    color: #b8152b;
  }

  .data-lb dt .arabic {
    font-size: 12px;
  }

  .pair {
    display: flex;
    gap: 22px;
  }

  .pair .field {
    width: 194px;
  }

  .data-lb .number {
    font-size: 28px;
    line-height: 32px;
    letter-spacing: 0.05em;
    color: #b8152b;
  }

  .data-lb .name {
    font-size: 25px;
    line-height: 29px;
  }

  .data-lb .issuer {
    color: #134a2c;
  }

  .arabic-value {
    font-family: 'Noto Naskh Arabic', serif;
    font-size: 17px;
  }

  .signature {
    position: absolute;
    left: 38px;
    top: 428px;
    font-family: 'Homemade Apple', cursive;
    font-size: 25px;
    line-height: 40px;
    color: #1d2a4f;
    transform: rotate(-4deg);
    white-space: nowrap;
  }

  .ghost {
    position: absolute;
    left: 694px;
    top: 318px;
    width: 112px;
    height: 138px;
    overflow: hidden;
    opacity: 0.55;
    filter: grayscale(1) contrast(1.4) brightness(1.05);
    mask-image: repeating-linear-gradient(0deg, #000000 0px, #000000 1px, #00000000 1px, #00000000 2.2px);
    mix-blend-mode: multiply;
  }

  .ghost-date {
    position: absolute;
    left: 694px;
    top: 462px;
    width: 112px;
    text-align: center;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.12em;
    color: #7c8794;
    mix-blend-mode: multiply;
    font-variant-numeric: tabular-nums;
  }

  .holo {
    mix-blend-mode: screen;
    opacity: 0.6;
  }

  .wear-dark {
    mix-blend-mode: multiply;
    opacity: 0.9;
  }

  .wear-light {
    mix-blend-mode: screen;
    opacity: 0.8;
  }

  .sheen {
    position: absolute;
    inset: 0;
    pointer-events: none;
    mix-blend-mode: screen;
    background-image:
      linear-gradient(115deg, #00000000 0%, #00000000 30%, #ffffff30 42%, #ffffff0a 52%, #00000000 62%),
      radial-gradient(120% 90% at 20% 0%, #ffffff22 0%, #00000000 60%);
  }

  .laminate {
    position: absolute;
    inset: 0;
    border-radius: 30px;
    pointer-events: none;
    box-shadow:
      inset 0 1px 0 #ffffffaa,
      inset 0 -1px 0 #00000030,
      inset 0 0 0 1px #ffffff40;
  }
</style>
