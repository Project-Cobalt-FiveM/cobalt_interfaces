import lbDriver from '../cards/textures/lb-driver.webp';
import lbId from '../cards/textures/lb-id.webp';
import lbWeapon from '../cards/textures/lb-weapon.webp';
import usDriver from '../cards/textures/us-driver.webp';
import usId from '../cards/textures/us-id.webp';
import usWeapon from '../cards/textures/us-weapon.webp';
import { isRecord, str } from './parse';

export type CardStyle = 'american' | 'lebanese';

export type CardKind = 'id' | 'driver' | 'weapon';

export type CardShowData = {
  style: CardStyle;
  kind: string;
  citizenid: string;
  firstname: string;
  lastname: string;
  birthdate?: string;
  gender?: number;
  nationality?: string;
  issued?: string;
  grantedBy?: string;
  photo?: string;
};

export type Card = {
  style: CardStyle;
  kind: CardKind;
  citizenid: string;
  firstname: string;
  lastname: string;
  birthdate?: Date;
  male: boolean | null;
  nationality?: string;
  issued?: Date;
  grantedBy?: string;
  photo?: string;
};

const ISO_DATE = /^(\d{4})-(\d{2})-(\d{2})/;

function parseDate(value: unknown): Date | undefined {
  const match = str(value)?.match(ISO_DATE);
  if (!match) return undefined;

  return new Date(Date.UTC(Number(match[1]), Number(match[2]) - 1, Number(match[3])));
}

function parseKind(value: unknown): CardKind | null {
  return value === 'id' || value === 'driver' || value === 'weapon' ? value : null;
}

export function parseCard(data: unknown): Card | null {
  if (!isRecord(data)) return null;

  const kind = parseKind(data.kind);
  const citizenid = str(data.citizenid);
  const firstname = str(data.firstname);
  const lastname = str(data.lastname);

  if (!kind || !citizenid || !firstname || !lastname) return null;

  return {
    style: data.style === 'lebanese' ? 'lebanese' : 'american',
    kind,
    citizenid,
    firstname,
    lastname,
    birthdate: parseDate(data.birthdate),
    male: data.gender === 0 ? true : data.gender === 1 ? false : null,
    nationality: str(data.nationality),
    issued: parseDate(data.issued),
    grantedBy: str(data.grantedBy),
    photo: str(data.photo),
  };
}

const pad = (value: number) => String(value).padStart(2, '0');

export function formatDate(date: Date | undefined, style: CardStyle): string {
  if (!date) return '—';

  const day = pad(date.getUTCDate());
  const month = pad(date.getUTCMonth() + 1);
  const year = date.getUTCFullYear();

  return style === 'american' ? `${month}/${day}/${year}` : `${day}/${month}/${year}`;
}

export function ghostDate(date: Date | undefined, style: CardStyle): string {
  return formatDate(date, style).replaceAll('/', '').replace(/(\d{4})(\d{2})(\d{2})$/, '$1$3');
}

type Theme = {
  texture: string;
  bandLabel: string;
  bandLabelArabic?: string;
  subtitle: string;
  subtitleArabic?: string;
  issuerLabel: string;
  issuer: string;
  numberLabel: string;
};

const SAN_ANDREAS: Record<CardKind, Theme> = {
  id: {
    texture: usId,
    bandLabel: 'IDENTIFICATION CARD',
    subtitle: 'LOS SANTOS · DEPARTMENT OF STATE',
    issuerLabel: 'ISSUED BY',
    issuer: 'LOS SANTOS CITY HALL',
    numberLabel: '4d ID',
  },
  driver: {
    texture: usDriver,
    bandLabel: 'DRIVER LICENSE',
    subtitle: 'LOS SANTOS · DEPARTMENT OF MOTOR VEHICLES',
    issuerLabel: 'GRANTED BY',
    issuer: 'SAN ANDREAS DMV',
    numberLabel: '4d DL',
  },
  weapon: {
    texture: usWeapon,
    bandLabel: 'FIREARMS LICENSE',
    subtitle: 'LOS SANTOS · POLICE DEPARTMENT',
    issuerLabel: 'GRANTED BY',
    issuer: 'LOS SANTOS POLICE DEPT.',
    numberLabel: '4d LIC',
  },
};

const LEBANON: Record<CardKind, Theme> = {
  id: {
    texture: lbId,
    bandLabel: 'IDENTITY CARD',
    bandLabelArabic: 'بطاقة هوية',
    subtitle: 'MINISTRY OF INTERIOR AND MUNICIPALITIES',
    subtitleArabic: 'وزارة الداخلية والبلديات',
    issuerLabel: 'ISSUED BY',
    issuer: 'MINISTRY OF INTERIOR',
    numberLabel: 'CARD NO.',
  },
  driver: {
    texture: lbDriver,
    bandLabel: 'DRIVING LICENCE',
    bandLabelArabic: 'رخصة سوق',
    subtitle: 'MINISTRY OF INTERIOR AND MUNICIPALITIES',
    subtitleArabic: 'وزارة الداخلية والبلديات',
    issuerLabel: 'GRANTED BY',
    issuer: 'TRAFFIC MANAGEMENT AUTHORITY',
    numberLabel: 'CARD NO.',
  },
  weapon: {
    texture: lbWeapon,
    bandLabel: 'WEAPON CARRY PERMIT',
    bandLabelArabic: 'رخصة حمل سلاح',
    subtitle: 'MINISTRY OF NATIONAL DEFENCE',
    subtitleArabic: 'وزارة الدفاع الوطني',
    issuerLabel: 'GRANTED BY',
    issuer: 'MINISTRY OF NATIONAL DEFENCE',
    numberLabel: 'CARD NO.',
  },
};

export function themeOf(card: Card): Theme {
  return (card.style === 'lebanese' ? LEBANON : SAN_ANDREAS)[card.kind];
}

export function issuerOf(card: Card): string {
  const theme = themeOf(card);
  const grantedBy = card.grantedBy;

  if (card.kind === 'id' || card.style === 'lebanese' || !grantedBy || /^the dmv$/i.test(grantedBy)) return theme.issuer;

  return grantedBy.toUpperCase();
}
