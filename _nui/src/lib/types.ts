import type { CardShowData } from './card';

export type NotifyData = {
  id?: string;
  title?: string;
  description?: string;
  type?: 'success' | 'error' | 'warning' | 'warn' | 'info' | 'inform';
  duration?: number;
  icon?: string;
  iconColor?: string;
};

export type TextUiPosition = 'left-center' | 'right-center' | 'top-center' | 'bottom-center';

export type TextUiData = {
  text: string;
  key?: string;
  icon?: string;
  position?: TextUiPosition;
};

export type ProgressStartData = {
  label?: string;
  duration: number;
  icon?: string;
  cancelKey?: string;
};

export type ProgressStopData = {
  completed: boolean;
  volume: number;
};

export type SkillCheckDifficulty = 'easy' | 'medium' | 'hard' | { areaSize: number; speedMultiplier: number };

export type SkillCheckStartData = {
  difficulty: SkillCheckDifficulty | SkillCheckDifficulty[];
  inputs?: string[];
};

export type ContextOptionKey = string | number;

export type ContextOptionData = {
  key: ContextOptionKey;
  title?: string;
  description?: string;
  icon?: string;
  iconColor?: string;
  progress?: number;
  colorScheme?: string;
  arrow?: boolean;
  disabled?: boolean;
  readOnly?: boolean;
};

export type ContextShowData = {
  id: string;
  title?: string;
  canBack?: boolean;
  canClose?: boolean;
  options: ContextOptionData[];
};

export type InputRowType = 'input' | 'number' | 'select' | 'multi-select' | 'slider' | 'checkbox' | 'textarea' | 'date' | 'color';

export type InputOptionData = { value: string | number; label?: string; disabled?: boolean };

export type InputRowData = {
  type?: InputRowType;
  label: string;
  description?: string;
  placeholder?: string;
  icon?: string;
  prefix?: string;
  required?: boolean;
  isRequired?: boolean;
  disabled?: boolean;
  default?: unknown;
  checked?: boolean;
  password?: boolean;
  min?: number;
  max?: number;
  step?: number;
  options?: InputOptionData[];
  returnString?: boolean;
};

export type InputDialogOpenData = {
  heading: string;
  rows: (string | InputRowData)[];
  options?: {
    allowCancel?: boolean;
    canCancel?: boolean;
    icon?: string;
    description?: string;
    submitText?: string;
    confirmLabel?: string;
    cancelText?: string;
  };
};

export type InputValue = string | number | boolean | (string | number)[] | null;

export type AlertResult = 'confirm' | 'cancel';

export type AlertDialogOpenData = {
  header: string;
  content?: string;
  type?: 'confirm' | 'danger';
  icon?: string;
  cancel?: boolean;
  labels?: { confirm?: string; cancel?: string };
};

export type RadialItemData = {
  id: string;
  label: string;
  icon?: string;
  disabled?: boolean;
  submenu?: boolean;
  count?: number;
};

export type RadialShowData = {
  menu: string;
  label?: string;
  parent?: string;
  clickMode: boolean;
  items: RadialItemData[];
};

export type NuiMessages = {
  notify: NotifyData;
  textUiShow: TextUiData;
  textUiHide: undefined;
  progressStart: ProgressStartData;
  progressStop: ProgressStopData;
  skillCheckStart: SkillCheckStartData;
  skillCheckCancel: undefined;
  contextShow: ContextShowData;
  contextHide: undefined;
  inputDialogOpen: InputDialogOpenData;
  inputDialogClose: undefined;
  alertDialogOpen: AlertDialogOpenData;
  alertDialogClose: { reason: AlertResult };
  radialShow: RadialShowData;
  radialHide: undefined;
  radialClickMode: undefined;
  radialRelease: undefined;
  cardShow: CardShowData;
  cardHide: undefined;
};

export type NuiAction = keyof NuiMessages;

export type NuiCallbacks = {
  contextSelect: { id: string; key: ContextOptionKey };
  contextBack: { id: string };
  contextClose: { id: string };
  skillCheckOver: boolean;
  inputDialogSubmit: { values: InputValue[] | null };
  alertDialogSubmit: { result: AlertResult };
  radialSelect: { index: number };
  radialBack: Record<string, never>;
  radialClose: Record<string, never>;
};

export type NuiCallback = keyof NuiCallbacks;
