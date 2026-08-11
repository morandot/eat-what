<script setup lang="ts">
import { ref, provide, onMounted, watch } from 'vue'
import type { TabType, HistoryItem, SoundService, TabContext } from './types'
import { useSound } from './composables/useSound'
import { useRoll } from './composables/useRoll'
import { FOODS, DRINKS } from './data/foods'
import { initAnalytics } from './utils/analytics'

import HeaderBar from './components/HeaderBar.vue'
import TabBar from './components/TabBar.vue'
import ResultDisplay from './components/ResultDisplay.vue'
import RollButton from './components/RollButton.vue'
import HistoryList from './components/HistoryList.vue'

// 1. 核心状态
const soundState = useSound()
const activeTab = ref<TabType>('eat')
const history = ref<HistoryItem[]>([])

// 2. 状态分发
provide<SoundService>('sound', soundState)
provide<TabContext>('tab', {
  activeTab,
  setActiveTab: (tab: TabType) => {
    if (activeTab.value === tab) return
    soundState.playClick()
    activeTab.value = tab
    currentResult.value = null
  }
})

// 3. 抽取逻辑
const { isRolling, currentResult, roll } = useRoll(soundState.playTick, soundState.playResult)

const handleRoll = (): void => {
  soundState.playClick()
  const pool = activeTab.value === 'eat' ? FOODS : DRINKS
  roll(pool, (result: string) => {
    const now = new Date()
    // 完整日期格式：MM-DD HH:mm
    const dateStr = `${(now.getMonth() + 1).toString().padStart(2, '0')}-${now.getDate().toString().padStart(2, '0')}`
    const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
    const fullTime = `${dateStr} ${timeStr}`
    
    history.value.unshift({
      name: result,
      time: fullTime,
      type: activeTab.value
    })
    
    if (history.value.length > 50) history.value.pop()
  })
}

const handleSelectHistory = (name: string): void => {
  if (isRolling.value) return
  soundState.playClick()
  currentResult.value = name
}

const handleClearHistory = (): void => {
  soundState.playClick()
  history.value = []
}

// 4. 持久化逻辑（带类型检查）
const loadHistory = (): void => {
  try {
    const saved = localStorage.getItem('eatwhat-history')
    if (!saved) return
    
    const parsed = JSON.parse(saved)
    if (Array.isArray(parsed)) {
      // 简单类型守卫：确保是有效的 HistoryItem 数组
      const validItems = parsed.filter((item: any): item is HistoryItem => 
        item && typeof item.name === 'string' && typeof item.time === 'string' && (item.type === 'eat' || item.type === 'drink')
      )
      history.value = validItems
    }
  } catch (e) {
    console.error('Failed to load history', e)
  }
}

onMounted(() => {
  loadHistory()
  initAnalytics()
})

watch(history, (newHistory) => {
  try {
    localStorage.setItem('eatwhat-history', JSON.stringify(newHistory))
  } catch (e) {
    console.error('Failed to persist history', e)
  }
}, { deep: true })

const isLoaded = ref<boolean>(false)
onMounted(() => {
  setTimeout(() => { isLoaded.value = true }, 50)
})
</script>

<template>
  <div class="app-root">
    <div class="main-wrapper" v-if="isLoaded">
      <HeaderBar />
      
      <main class="content-area">
        <section class="hero-section">
          <h1 class="hero-subtitle">今天吃什么？随机抽取帮你决定</h1>
        </section>

        <TabBar class="mode-switcher" />

        <div class="center-panel">
          <ResultDisplay 
            :isRolling="isRolling" 
            :currentResult="currentResult" 
            :activeTab="activeTab"
          />
          
          <RollButton 
            :isRolling="isRolling"
            @click="handleRoll"
          />
        </div>
        
        <HistoryList 
          :history="history" 
          :activeTab="activeTab"
          @select="handleSelectHistory"
          @clear="handleClearHistory"
        />
      </main>

      <footer class="app-footer">
        <p class="font-pixel">
          © 2026 <a href="https://www.nopress.net" target="_blank" class="footer-link">NoPress</a>
        </p>
      </footer>
    </div>
  </div>
</template>

<style>
@import './styles/global.css';

.app-root {
  min-height: 100vh;
  min-height: 100dvh; /* 移动端：避免地址栏伸缩导致布局跳动 */
}

.content-area {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.hero-section {
  text-align: center;
  margin-bottom: 32px;
}

.hero-subtitle {
  font-size: 1.15rem;
  color: var(--text-sub);
  font-weight: 700;
}

.mode-switcher {
  margin-bottom: 24px;
}

.center-panel {
  display: flex;
  flex-direction: column;
  width: 100%;
}

.app-footer {
  padding: 40px 0 60px;
  text-align: center;
  color: #5C5C5C;
  font-size: 0.75rem;
  border-top: 1px solid var(--inner-bg);
}

.footer-link {
  color: #5C5C5C;
  text-decoration: underline; /* 保持下划线 */
  transition: opacity 0.2s ease;
}

/* hover 仅在精确指针设备（鼠标）生效，避免触屏点击后粘住 */
@media (hover: hover) and (pointer: fine) {
  .footer-link:hover {
    opacity: 0.8;
  }
}

@media (max-width: 640px) {
  .hero-section { margin-bottom: 24px; }
  .center-panel { margin-bottom: 32px; }
}
</style>
