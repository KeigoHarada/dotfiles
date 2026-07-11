#!/usr/bin/env bash

# Stagedの差分を取得
DIFF=$(git diff --cached)

# 差分がない場合は終了
if [ -z "$DIFF" ]; then
  echo "Staged changes not found. Please stage files before running AI commit."
  exit 1
fi

echo "Generating commit message with AI..."

# プロンプトの定義
PROMPT="Generate a Git commit message based on the following diff.
Follow this EXACT format:
<prefix>: <short english description>
- <日本語での変更点1>
- <日本語での変更点2>
- ...

Rules:
- Prefix must be one of: add, update, feat, fix, chore, docs, style, refactor, perf, test
- The first line must be in English and concise.
- Do NOT leave a blank line after the first line.
- The details must be written in Japanese using a bulleted list (- ).
- Output ONLY the commit message, no markdown code blocks, no intro, no outro.

Diff:
$DIFF"

# OSを判定してAIツールを切り替え
if [ "$(uname -s)" = "Darwin" ]; then
  # Macの場合は agy を使用 (-p で非対話的に実行, 軽量なモデルを指定)
  agy --model gemini-3.5-flash -p "$PROMPT" > .git/COMMIT_EDITMSG
  
  # クリップボードにコピー (Mac)
  if command -v pbcopy &> /dev/null; then
    cat .git/COMMIT_EDITMSG | pbcopy
  fi
else
  # WSL (Linux) の場合は github-copilot-cli を使用
  github-copilot-cli git-assist "$PROMPT" > .git/COMMIT_EDITMSG
  
  # クリップボードにコピー (WSL)
  if command -v clip.exe &> /dev/null; then
    cat .git/COMMIT_EDITMSG | clip.exe
  fi
fi

# 生成されたメッセージを画面に表示
if [ -f .git/COMMIT_EDITMSG ]; then
  cat .git/COMMIT_EDITMSG
fi
