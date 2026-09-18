# My IELTS - LazyCat App

[My IELTS](https://github.com/hefengxian/my-ielts)（雅思备考资料：词汇真经、语法、听力 179、阅读 538、同义替换）的懒猫微服（LazyCat）打包。

## 模式

- **静态 Web 应用，纯 CI 打包**：上游 480MB 素材（词汇音频等）**不入 git 仓库**；`build.sh`（lzc-build.yml buildscript）在 GitHub Actions 中 clone 上游 → `pnpm install && pnpm build` → 生成 `content/` → 打包进 LPK。
- **自动跟上游**：`sync-upstream.yml` 每日检查上游 `hefengxian/my-ielts` master HEAD（上游无 tag/release，以 commit SHA 为准）；有变化时记录 `.upstream-sha` 基线、`package.yml` 版本 patch +1、打 `v*` tag 触发发布。构建时 `build.sh` 会固定到该 SHA。
- **喵喵商店发布**：仅私有商店，`lazycat.yml` 由 tag 推送 / 定时 / 手动触发。

## 结构

| 文件 | 说明 |
| --- | --- |
| `package.yml` | 包元数据（`community.lazycat.app.my-ielts`） |
| `lzc-manifest.yml` | 静态路由：`/` → `file:///lzcapp/pkg/content/` |
| `lzc-build.yml` | 构建配置（buildscript + `contentdir: ./content`） |
| `build.sh` | CI 构建脚本：上游 clone + pnpm 构建 + 生成 content |
| `.upstream-sha` | 上游已同步基线 SHA |
| `icon.png` | 图标（上游 favicon） |
| `.github/lazycat-action.yml` | [lazycat-github-action](https://github.com/ca-x/lazycat-github-action) 配置 |
| `.github/workflows/sync-upstream.yml` | 上游同步 + 发版 |
| `.github/workflows/lazycat.yml` | 构建 + 发布喵喵商店 |

## 更新流程（全自动）

每日 `sync-upstream.yml`（约北京时间 14:13）自动执行；也可手动 Run workflow 立即检查：

1. 对比上游 master HEAD SHA 与 `.upstream-sha`，无变化则跳过；
2. 有变化 → 记录 SHA + 版本 patch +1 → 打 `v*` tag；
3. tag 触发 `lazycat.yml`：`build.sh` 拉取上游构建内容 → 打包 LPK → 发布喵喵商店。

## 注意

- LPK 约 480MB（上游词汇音频），首次发布耗时较长属正常。
- 上游无 LICENSE 文件，素材为第三方版权内容，请控制传播范围。

## 所需 Secrets

| Secret | 说明 |
| --- | --- |
| `APPSTORE_URL` / `APPSTORE_TOKEN` | 喵喵商店 API 地址与发布令牌 |
| `APP_ID` | 可选 |
| `PRIVATE_STORE_GROUP_CODES` | 可选，私有分组码 |
