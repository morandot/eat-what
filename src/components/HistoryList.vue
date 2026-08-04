<script setup lang="ts">
import { computed } from 'vue'
import type { HistoryItem, TabType } from '../types'

interface Props {
  history: HistoryItem[];
  activeTab: TabType;
}

const props = defineProps<Props>()

interface Emits {
  (e: 'select', name: string): void;
  (e: 'clear'): void;
}

const emit = defineEmits<Emits>()

const filteredHistory = computed((): HistoryItem[] => {
  return props.history.filter(h => h.type === props.activeTab)
})

const formatDisplayTime = (timeStr: string): string => {
  if (!timeStr) return ''
  if (timeStr.indexOf('-') === -1) {
    return `今日 ${timeStr}`
  }
  return timeStr
}
</script>

<template>
  <section class="history-panel px-panel">
    <header class="panel-header">
      <div class="header-left">
        <h2 class="title font-pixel">抽取记录</h2>
        <span class="count font-pixel" aria-label="抽取总次数">{{ filteredHistory.length }}</span>
      </div>
      
      <button 
        class="clear-btn font-pixel" 
        @click="emit('clear')"
        :disabled="filteredHistory.length === 0"
      >
        清理
      </button>
    </header>

    <div class="list-container">
      <div v-if="filteredHistory.length === 0" class="empty-state">
        <p>暂无抽取记录</p>
      </div>
      
      <ul v-else class="record-list">
        <li v-for="(item, idx) in filteredHistory" :key="idx" class="record-item">
          <button 
            @click="emit('select', item.name)" 
            class="record-btn"
          >
            <span class="item-name">{{ item.name }}</span>
            <span class="item-time">{{ formatDisplayTime(item.time) }}</span>
          </button>
        </li>
      </ul>
    </div>
  </section>
</template>

<style scoped>
.history-panel {
  width: 100%;
  padding: 0;
  overflow: hidden;
  margin-bottom: 40px;
}

.panel-header {
  padding: 12px 16px;
  background-color: var(--border);
  color: #FFFFFF;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.title {
  font-size: 0.95rem;
  margin: 0;
  font-weight: bold;
}

.count {
  font-size: 0.85rem;
  font-weight: bold;
  opacity: 0.8;
}

.clear-btn {
  background: #FFFFFF;
  color: var(--border);
  border: 2px solid var(--border);
  padding: 2px 8px;
  font-size: 0.75rem;
  cursor: pointer;
  transition: all 0.1s steps(2);
  box-shadow: 2px 2px 0 0 rgba(0,0,0,0.3);
}

.clear-btn:hover:not(:disabled) {
  background: var(--inner-bg);
  transform: translate(-1px, -1px);
  box-shadow: 3px 3px 0 0 rgba(0,0,0,0.3);
}

.clear-btn:active:not(:disabled) {
  transform: translate(1px, 1px);
  box-shadow: 0 0 0 0 transparent;
}

.clear-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
}

.list-container {
  background-color: var(--panel-bg);
  min-height: 120px;
}

.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 120px;
  color: var(--text-sub);
  font-size: 0.9rem;
  font-weight: 500;
}

.record-list {
  list-style: none;
  max-height: 280px;
  overflow-y: auto;
}

.record-item {
  border-bottom: 1px solid var(--inner-bg);
}

.record-item:last-child {
  border-bottom: none;
}

.record-btn {
  width: 100%;
  padding: 14px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: transparent;
  border: none;
  cursor: pointer;
  font-family: var(--font-sans);
  transition: all 0.2s ease;
  color: var(--text-main);
  text-align: left;
}

.record-btn:hover {
  background-color: var(--inner-bg);
}

.item-name {
  font-weight: 700;
  font-size: 1.05rem;
}

.item-time {
  font-size: 0.8rem;
  color: var(--text-weak);
  font-family: var(--font-pixel);
  letter-spacing: 1px;
}

.record-list::-webkit-scrollbar {
  width: 6px;
}
.record-list::-webkit-scrollbar-track {
  background: var(--inner-bg);
}
.record-list::-webkit-scrollbar-thumb {
  background: var(--border);
}
</style>
