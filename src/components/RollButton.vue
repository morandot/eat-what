<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'

interface Props {
  isRolling: boolean;
}

const props = defineProps<Props>()

const dots = ref<string>('')
let timer: ReturnType<typeof setInterval> | null = null

onMounted(() => {
  timer = setInterval(() => {
    if (props.isRolling) {
      dots.value = dots.value.length >= 3 ? '' : dots.value + '.'
    } else {
      dots.value = ''
    }
  }, 300)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

const buttonText = computed((): string => {
  if (props.isRolling) return `抽取中${dots.value}`
  return '开始抽取'
})
</script>

<template>
  <div class="button-wrapper">
    <button 
      class="main-roll-btn px-button bg-accent" 
      :class="{ 'rolling': isRolling }"
      :disabled="isRolling"
      :aria-label="isRolling ? '抽取中' : '开始抽取'"
    >
      <span class="btn-content">{{ buttonText }}</span>
    </button>
  </div>
</template>

<style scoped>
.button-wrapper {
  width: 100%;
  margin-bottom: 40px;
}

.main-roll-btn {
  width: 100%;
  padding: 20px 0;
  font-size: 1.5rem;
  font-weight: 900;
  box-shadow: 0 8px 0 0 var(--shadow);
  transform: translateY(-8px);
  position: relative;
  letter-spacing: 4px;
  transition: transform 0.1s steps(2), box-shadow 0.1s steps(2), background-color 0.1s steps(2);
}

.bg-accent {
  background-color: var(--accent-color);
  color: var(--text-on-accent);
}

/* hover 仅在精确指针设备（鼠标）生效，避免触屏点击后粘住 */
@media (hover: hover) and (pointer: fine) {
  .main-roll-btn:hover:not(:disabled) {
    transform: translateY(-10px);
    box-shadow: 0 10px 0 0 var(--shadow);
  }
}

.main-roll-btn:active:not(:disabled),
.main-roll-btn.rolling {
  transform: translateY(0);
  box-shadow: 0 0 0 0 var(--shadow);
  background-color: var(--accent-active);
}

.rolling {
  cursor: wait;
}
</style>
