<script setup lang="ts">
import type { FunctionalIconName } from '../../types'

const props = defineProps<{
  name: FunctionalIconName
  size?: number
}>()

const svgContent = (): string => {
  const content: Record<FunctionalIconName, string> = {
    'px-speaker-on': `
      <rect x="3" y="5" width="3" height="6" fill="currentColor"/>
      <rect x="6" y="6" width="2" height="4" fill="currentColor"/>
      <rect x="8" y="4" width="1" height="8" fill="currentColor"/>
      <rect x="9" y="6" width="1" height="4" fill="currentColor"/>`,

    'px-speaker-off': `
      <rect x="3" y="5" width="3" height="6" fill="currentColor"/>
      <rect x="6" y="6" width="2" height="4" fill="currentColor"/>`,

    'px-trash': `
      <rect x="4" y="2" width="8" height="1" fill="currentColor"/>
      <rect x="5" y="1" width="1" height="1" fill="currentColor"/>
      <rect x="10" y="1" width="1" height="1" fill="currentColor"/>
      <rect x="3" y="3" width="10" height="9" fill="currentColor"/>
      <rect x="5" y="5" width="1" height="4" fill="#FFFFFF"/>
      <rect x="8" y="5" width="1" height="4" fill="#FFFFFF"/>
      <rect x="11" y="5" width="1" height="4" fill="#FFFFFF"/>`,

    'px-history': `
      <rect x="3" y="3" width="10" height="10" fill="none" stroke="currentColor" stroke-width="1.5"/>
      <rect x="5" y="6" width="1" height="1" fill="currentColor"/>
      <rect x="5" y="5" width="2" height="1" fill="currentColor"/>
      <rect x="10" y="5" width="1" height="1" fill="currentColor"/>
      <rect x="10" y="6" width="1" height="2" fill="currentColor"/>
      <rect x="10" y="10" width="1" height="1" fill="currentColor"/>
      <rect x="9" y="11" width="1" height="1" fill="currentColor"/>
      <rect x="5" y="11" width="1" height="1" fill="currentColor"/>
      <rect x="4" y="10" width="1" height="1" fill="currentColor"/>
      <rect x="4" y="6" width="1" height="2" fill="currentColor"/>
      <rect x="7" y="7" width="1" height="4" fill="currentColor"/>
      <rect x="8" y="6" width="3" height="1" fill="currentColor"/>`,
  }

  return content[props.name] ?? ''
}
</script>

<template>
  <span class="icon-px" :aria-hidden="true">
    <svg
      :width="size ?? 18"
      :height="size ?? 18"
      viewBox="0 0 16 16"
      shape-rendering="crispEdges"
      v-html="svgContent()"
    ></svg>
  </span>
</template>

<style scoped>
.icon-px {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 0;
  flex-shrink: 0;
}

.icon-px :deep(svg) {
  display: block;
}
</style>
