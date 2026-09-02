/**
 * 抽取类别：吃什么 | 喝什么
 */
export type TabType = 'eat' | 'drink';

/**
 * 历史记录条目
 */
export interface HistoryItem {
  name: string;
  time: string;
  type: TabType;
}

/**
 * 音效服务接口
 */
export interface SoundService {
  soundEnabled: { value: boolean };
  playClick: () => void;
  playTick: () => void;
  playResult: () => void;
}

/**
 * Tab 切换上下文接口
 */
export interface TabContext {
  activeTab: { value: TabType };
  setActiveTab: (tab: TabType) => void;
}

/**
 * 像素功能图标名称（统一 16×16 viewBox，crispEdges）
 */
export type FunctionalIconName =
  | 'px-speaker-on'
  | 'px-speaker-off'
  | 'px-trash'
  | 'px-history';
