import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// 极简配置，确保 Vue 正常运行
export default defineConfig({
  plugins: [
    vue()
  ],
  server: {
    port: 5173,
    host: true
  }
})
