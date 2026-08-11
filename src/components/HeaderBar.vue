<script setup lang="ts">
import { inject, computed } from 'vue'
import type { SoundService } from '../types'

const sound = inject<SoundService>('sound')

const soundLabel = computed((): string => {
  return sound?.soundEnabled.value ? '静音' : '音效'
})

const toggleSound = (): void => {
  if (sound) {
    sound.soundEnabled.value = !sound.soundEnabled.value
  }
}
</script>

<template>
  <header class="header-bar">
    <div class="brand">
      <span class="brand-name font-pixel">EATWHAT</span>
    </div>
    
    <div class="actions">
      <button 
        @click="toggleSound" 
        class="icon-btn" 
        :class="{ 'is-active': sound?.soundEnabled.value }"
        :title="soundLabel"
        :aria-label="soundLabel"
      >
        <svg v-if="sound?.soundEnabled.value" width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
          <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>
        </svg>
        <svg v-else width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
          <path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"/>
        </svg>
      </button>
    </div>
  </header>
</template>

<style scoped>
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 0;
  width: 100%;
}

.brand-name {
  font-size: 1.1rem;
  font-weight: 900;
  color: var(--text-main);
  letter-spacing: 0.1em;
}

.actions {
  display: flex;
}

.icon-btn {
  background: var(--inner-bg);
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--text-main);
  transition: all 0.1s steps(2);
  border-radius: 0;
  /* 默认态：静音态边框 */
  border: 2px solid var(--text-weak);
  box-shadow: none;
}

/* 非静音状态 (Active) */
.icon-btn.is-active {
  border: 3px solid var(--border);
  background: var(--panel-bg);
  box-shadow: 2px 2px 0 0 var(--border);
}

/* Hover 状态反馈（仅精确指针设备生效，避免触屏点击后粘住） */
@media (hover: hover) and (pointer: fine) {
  .icon-btn:hover {
    background: var(--panel-bg);
    transform: translate(-2px, -2px);
    border-color: var(--border);
    box-shadow: 2px 2px 0 0 var(--border);
  }

  .icon-btn.is-active:hover {
    box-shadow: 4px 4px 0 0 var(--border);
    transform: translate(-3px, -3px);
  }
}

/* Active 点击状态 */
.icon-btn:active {
  transform: translate(0, 0) !important;
  box-shadow: 0 0 0 0 var(--border) !important;
}

/* Focus-visible 状态 */
.icon-btn:focus-visible {
  outline: 2px solid var(--accent-color);
  outline-offset: 2px;
  border-color: var(--border);
}
</style>
