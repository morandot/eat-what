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

## 搜索引擎收录（Bing / IndexNow）

仓库已包含 Bing 收录所需的全部文件：

- `public/robots.txt`：允许所有爬虫，并声明 sitemap 地址
- `public/sitemap.xml`：站点 URL 列表
- `public/<key>.txt`：IndexNow 密钥文件，从站点根目录对外提供
- `index.html`：canonical、robots meta、Open Graph / Twitter Card，以及 WebApplication + ItemList 结构化数据

### 向 IndexNow 提交 URL

IndexNow 会把变更的 URL 立即推送给 Bing、Yandex、Seznam 和 Naver，无需等待下次抓取。

```bash
npm run indexnow              # 提交 public/sitemap.xml 中的全部 <loc>
npm run indexnow -- <url>...  # 只提交指定 URL
```

脚本会先校验密钥文件（需返回 HTTP 200 且内容与文件名一致），再提交到 `https://api.indexnow.org/indexnow`。每次内容变更部署后运行一次即可。

这一步已由 `.github/workflows/indexnow.yml` 自动完成：它监听 Vercel 的 `deployment_status: success`，确保 URL 真正上线后才推送。也可以在 Actions 面板手动触发。

轮换密钥：新增 `public/<新密钥>.txt`（内容为密钥本身），删除旧文件，部署后重新执行 `npm run indexnow`。

### Bing 网站管理员工具一次性配置

1. 在 <https://www.bing.com/webmasters> 添加站点，可直接复用 Google Search Console 验证或使用 DNS / meta 标签验证。
2. 进入 **网站地图**，提交 `https://eatwhat.nopress.net/sitemap.xml`。
3. 进入 **IndexNow** 并选择启用。之后提交记录会出现在「过去 10 几小时内提交的 URL」中，来源显示为 `Self`。
4. 如需单独收录某个 URL，可使用 **URL 检查** 发起索引请求。

## 开源协议

[MIT License](./LICENSE) 