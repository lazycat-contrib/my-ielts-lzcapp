#!/usr/bin/env bash
# 构建上游静态内容到 content/（在 GitHub Actions / lzc-cli 构建时执行）
# 上游 480MB 素材不进 git，LPK 完全在 CI 中打包。
set -euo pipefail

UPSTREAM_URL="${MY_IELTS_UPSTREAM:-https://github.com/hefengxian/my-ielts}"
ROOT="$(cd "$(dirname "$0")" && pwd)"

rm -rf "${ROOT}/content"
rm -rf /tmp/my-ielts-upstream

git clone --depth=1 "${UPSTREAM_URL}" /tmp/my-ielts-upstream

# 有同步基线时固定到该 commit，保证与 sync-upstream.yml 记录的版本一致
PIN="$(cat "${ROOT}/.upstream-sha" 2>/dev/null || true)"
if [ -n "${PIN}" ] && [ "$(git -C /tmp/my-ielts-upstream rev-parse HEAD)" != "${PIN}" ]; then
  git -C /tmp/my-ielts-upstream fetch --depth=1 origin "${PIN}"
  git -C /tmp/my-ielts-upstream checkout FETCH_HEAD
fi

cd /tmp/my-ielts-upstream
npm install -g pnpm@8.6.0
pnpm i --frozen-lockfile
pnpm build

mkdir -p "${ROOT}/content"
cp -r dist/. "${ROOT}/content/"
echo "content ready: $(du -sh "${ROOT}/content" | cut -f1)"
