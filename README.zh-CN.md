# EatWhat

[English](./README.md)

一个像素风的随机抽取器，用来快速决定「吃什么 / 喝什么」。

## 功能

- 支持「吃什么」和「喝什么」两种抽取模式
- 内置像素风 SVG 图标，抽取结果按名称一一对应显示
- 自动保存抽取记录到本地，刷新后仍保留，数据不会上传
- 点击历史记录可快速回显结果
- 一键清空抽取记录
- 可开关的提示音效

## 技术栈

- Vue 3
- Vite
- TypeScript
- 原生 CSS

## 快速开始

```bash
npm install
npm run dev
```

## 构建

```bash
npm run build
```

构建产物输出到 `dist/`。

## 自定义

食物、饮品列表及对应的像素 SVG 数据位于 `src/data/foods.ts`。当前实现使用「名称 → SVG 像素数据」的直接映射，不依赖 emoji，也不依赖模糊分类图标。

## 统计分析（可选）

如需在自己的部署中启用统计，设置以下环境变量（如在 Vercel 中配置）：

- `VITE_SELINE_TOKEN`
- `VITE_GA_ID`

参考 `.env.example`。仅当变量存在时，统计脚本才会加载。

## 开源协议

[MIT License](./LICENSE) 