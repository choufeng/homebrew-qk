---
name: homebrew-bump
description: 自动更新 Homebrew Formula - 检查版本、计算 SHA256、提交更新、创建 PR
---

# Homebrew Bump Skill

用于自动更新 Homebrew tap 仓库中的 formula。完整流程：检查版本 → 下载计算 SHA256 → 更新 formula → commit → 创建 PR。

## 使用场景

当用户请求以下任何操作时使用此 skill：
- "更新 qk 到最新版本"
- "更新某个 formula"
- "检查有新版本吗"
- "bump homebrew"
- "更新 homebrew formula"

## 完整操作流程

### Step 1: 确定项目信息

首先确定以下信息：
- **formula 名称**：从用户的请求中获取（如 `qk`、`my-app` 等）
- **GitHub 仓库 URL**：从 formula 文件的 `homepage` 或 `url` 字段推断
  - 从 `homepage "https://github.com/owner/repo"` 提取 owner/repo
  - 或从 `url "https://github.com/owner/repo/archive/..."` 提取
- **Formula 文件路径**：通常是 `Formula/<name>.rb`

### Step 2: 检查当前版本

1. 读取 formula 文件，找到当前版本：
   ```bash
   grep -oP 'v\K[0-9.]+' Formula/qk.rb
   # 或
   grep "url " Formula/qk.rb | grep -oP 'v\K[0-9.]+'
   ```

2. 调用 GitHub API 获取最新 release：
   ```bash
   curl -sL "https://api.github.com/repos/{owner}/{repo}/releases/latest"
   ```
   
   解析 JSON 响应（使用 grep/sed 提取 tag_name）：
   ```bash
   response=$(curl -sL "https://api.github.com/repos/{owner}/{repo}/releases/latest")
   version=$(echo "$response" | grep -oP '"tag_name":\s*"\K[^"]+')
   # 或手动解析：version=$(echo "$response" | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
   ```

3. 比较版本：
   - 如果最新版本 == 当前版本：告知用户已是最新的
   - 如果最新版本 > 当前版本：继续执行更新

### Step 3: 下载并计算 SHA256

1. 构建 tarball URL：
   ```
   https://github.com/{owner}/{repo}/archive/refs/tags/v{version}.tar.gz
   ```

2. 下载并计算 SHA256：
   ```bash
   curl -sL "https://github.com/{owner}/{repo}/archive/refs/tags/v{version}.tar.gz" | sha256sum
   ```

3. 记录完整的 SHA256 字符串（64 个字符的十六进制）

### Step 4: 更新 Formula 文件

读取 formula 文件，使用 edit 工具进行以下替换：

1. **更新 url**：
   - 查找：`url "https://github.com/{owner}/{repo}/archive/refs/tags/v{旧版本}.tar.gz"`
   - 替换为：`url "https://github.com/{owner}/{repo}/archive/refs/tags/v{新版本}.tar.gz"`

2. **更新 sha256**：
   - 查找：`sha256 "{旧sha256}"`
   - 替换为：`sha256 "{新sha256}"`

### Step 5: Git 操作

1. 创建新分支：
   ```bash
   git checkout -b bump-{formula}-{版本}
   ```

2. 添加更改：
   ```bash
   git add Formula/{formula}.rb
   ```

3. 提交：
   ```bash
   git commit -m "Bump {formula} to v{版本}"
   ```

### Step 6: 创建 PR

使用 gh CLI 创建 Pull Request：
```bash
gh pr create \
  --title "Update {formula} to v{版本}" \
  --body "Auto-generated update

## Changes
- Updated {formula} to version v{版本}
- Computed new SHA256 checksum

This PR was created automatically by homebrew-bump skill."
  --base main
```

或者先推送到远程：
```bash
git push -u origin bump-{formula}-{版本}
```
然后让用户手动创建 PR（如果 gh pr create 失败或需要用户确认）。

## 常见问题处理

### Q: 如何确定 GitHub 仓库？
A: 从 formula 文件中查找：
- `homepage "https://github.com/owner/repo"` → owner/repo
- `url "https://github.com/owner/repo/archive/..."` → owner/repo

### Q: SHA256 计算结果不对？
A: 确保使用 `curl -sL` 下载 tarball，不要使用 redirect 的 URL，要用原始的 tarball URL。

### Q: gh pr create 失败？
A: 可能需要先 `git push`。可以分步执行：
1. `git push -u origin branch-name`
2. 提示用户手动创建 PR，或让用户确认后再执行

### Q: 版本号格式不一致？
A: 有些仓库用 `v1.0.0`，有些用 `1.0.0`。从 API 返回的 `tag_name` 中提取，如果有 `v` 前缀，去掉后再比较。

## 示例

用户说 "更新 qk"：

1. 读取 Formula/qk.rb，找到当前版本 v1.7.1
2. curl API 获取最新版本 → v1.7.2
3. v1.7.2 > v1.7.1，需要更新
4. 下载 v1.7.2 tarball，计算 SHA256
5. 更新 Formula/qk.rb 中的 url 和 sha256
6. git checkout -b bump-qk-1.7.2
7. git add, git commit, git push
8. gh pr create

## 注意事项

- 此 skill 需要系统安装：curl, sha256sum, git, gh CLI
- 始终先检查版本再执行更新，避免无用功
- 创建 PR 前确保分支已推送到远程
- 如果用户只想先看信息，可以只执行到 Step 3，不做实际更新
