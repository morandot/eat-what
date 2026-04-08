<script setup lang="ts">
import { inject } from 'vue'
import type { TabContext } from '../types'

const tab = inject<TabContext>('tab')
</script>

<template>
  <div class="tab-wrapper">
    <!-- 主容器：保持边框稳定 -->
    <div class="segmented-control px-panel" role="tablist" aria-label="切换抽取模式">
      
      <!-- 移动滑块 -->
      <div 
        class="tab-indicator" 
        :style="{ transform: `translateX(${tab?.activeTab.value === 'eat' ? '0' : '100%'})` }"
      >
        <div class="indicator-inner"></div>
      </div>

      <!-- 按钮层：移除 Emoji -->
      <button 
        class="tab-btn" 
        role="tab"
        :aria-selected="tab?.activeTab.value === 'eat'"
        :class="{ 'is-active': tab?.activeTab.value === 'eat' }"
        @click="tab?.setActiveTab('eat')"
      >
        <span class="label font-pixel">吃什么</span>
      </button>
      
      <button 
        class="tab-btn" 
        role="tab"
        :aria-selected="tab?.activeTab.value === 'drink'"
        :class="{ 'is-active': tab?.activeTab.value === 'drink' }"
        @click="tab?.setActiveTab('drink')"
      >
        <span class="label font-pixel">喝什么</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.tab-wrapper {
  width: 100%;
  display: flex;
  justify-content: center;
}

.segmented-control {
  position: relative;
  display: flex;
  width: 100%;
  padding: 4px;
  background-color: var(--inner-bg);
  box-shadow: 4px 4px 0 0 var(--shadow);
  border-radius: 0;
  overflow: hidden;
  border: 3px solid var(--border);
}

.tab-indicator {
  position: absolute;
  top: 4px;
  left: 4px;
  bottom: 4px;
  width: calc(50% - 4px);
  z-index: 1;
  transition: transform 0.25s cubic-bezier(0.19, 1, 0.22, 1);
  pointer-events: none;
}

.indicator-inner {
  width: 100%;
  height: 100%;
  background-color: var(--border);
}

.tab-btn {
  position: relative;
  flex: 1;
  padding: 12px 0;
  border: none;
  background: transparent;
  font-family: var(--font-sans);
  font-weight: bold;
  font-size: 0.95rem;
  color: var(--text-sub);
  cursor: pointer;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  transition: color 0.3s ease;
  border-radius: 0;
  outline: none;
}

.tab-btn.is-active {
  color: #FFFFFF;
}

.tab-btn:hover:not(.is-active) {
  color: var(--text-main);
}

.tab-btn:focus-visible {
  outline: 2px solid var(--accent-color);
  outline-offset: -4px;
}
</style>
