#!/usr/bin/env bash

# Stagedの差分を取得
DIFF=$(git diff --cached)

# 差分がない場合は終了
if [ -z "$DIFF" ]; then
  echo "Staged changes not found. Please stage files before running AI commit."
  exit 1
fi

echo "Generating commit message with AI..."

# OSを判定してAIツールを切り替え
if [ "$(uname -s)" = "Darwin" ]; then
  # Macの場合は agy を使用 (-p で非対話的に実行)
  agy -p "Generate a concise Git commit message based on the following diff. Output ONLY the message, no markdown code blocks or explanations.

$DIFF" > .git/COMMIT_EDITMSG
else
  # WSL (Linux) の場合は github-copilot-cli を使用
  github-copilot-cli git-assist "Generate a concise Git commit message based on this diff: $DIFF" > .git/COMMIT_EDITMSG
fi

# メッセージが生成されていればエディタで開いてコミット
if [ -f .git/COMMIT_EDITMSG ]; then
  git commit -e -F .git/COMMIT_EDITMSG
fi
