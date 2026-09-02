<script setup lang="ts">
import { computed } from 'vue'
import { getIcon } from '../data/foods'
import type { TabType } from '../types'

interface Props {
  isRolling: boolean;
  currentResult: string | null;
  activeTab: TabType;
}

const props = defineProps<Props>()

const iconContent = computed(() => {
  return getIcon(props.currentResult, props.activeTab)
})
</script>

<template>
  <div class="result-display px-panel">
    <div class="inner-screen">
      <div class="state-container">
        <!-- 抽取中/结果态内容 -->
        <div v-if="currentResult || isRolling" class="content-box" :class="{ 'rolling-anim': isRolling }">
          <div class="result-emoji-box">
            <div v-html="iconContent" class="svg-container"></div>
          </div>
          <div class="result-info">
            <h2 class="result-name font-pixel">{{ currentResult || '匹配中' }}</h2>
            <div v-if="!isRolling" class="result-hint-box">
              <p class="result-hint">看起来是个不错的选择！</p>
            </div>
            <p v-else class="result-hint">正在匹配美食信号...</p>
          </div>
        </div>

        <!-- 初始态内容：文字与光标同行 -->
        <div v-else class="content-box">
          <div class="initial-status">
            <h2 class="result-name font-pixel inline-text">等待抽取中</h2>
            <span class="cursor-pixel inline-cursor"></span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.result-display {
  width: 100%;
  height: 280px;
  padding: 16px;
  margin-bottom: 24px;
}

.inner-screen {
  width: 100%;
  height: 100%;
  background-color: var(--result-screen-bg);
  border: 2px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.state-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
}

.content-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  width: 100%;
}

.initial-status {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.inline-text {
  margin-bottom: 0 !important;
}

/* 像素光标：更细的版本 */
.cursor-pixel {
  display: inline-block;
  width: 6px;
  height: 2.4rem;
  background-color: var(--border);
  animation: cursor-blink 1s infinite steps(2);
  vertical-align: middle;
  flex-shrink: 0;
}

.inline-cursor {
  margin-left: 4px;
}

@keyframes cursor-blink {
  0%, 49% { opacity: 1; }
  50%, 100% { opacity: 0; }
}

.result-emoji-box {
  width: 124px;
  height: 100px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.svg-container {
  width: 96px;
  height: 96px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 确保内部 SVG 填充容器且不被修改样式 */
.svg-container :deep(svg) {
  width: 100%;
  height: 100%;
  display: block;
}

.result-info {
  margin-top: 12px;
  min-height: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.result-name {
  font-size: 2.4rem;
  color: #171512;
  margin-bottom: 6px;
  line-height: 1.2;
}

.result-hint {
  font-size: 0.95rem;
  color: #3f3a34;
}

.rolling-anim {
  animation: vertical-roll 0.1s infinite steps(1);
}

@keyframes vertical-roll {
  0% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
  100% { transform: translateY(0); }
}
</style>
