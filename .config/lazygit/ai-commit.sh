#!/usr/bin/env bash

# Stagedの差分を取得
DIFF=$(git diff --cached)

# 差分がない場合は終了
if [ -z "$DIFF" ]; then
  echo "Staged changes not found. Please stage files before running AI commit."
  exit 1
fi

# 設定ファイルの探索
CONF_PATHS=(
  "$HOME/.config/lazygit/ai.conf"
  "$HOME/Library/Application Support/lazygit/ai.conf"
  "$(cd "$(dirname "$0")" && pwd)/ai.conf"
)

AI_PROVIDER=""
AI_MODEL=""

for conf in "${CONF_PATHS[@]}"; do
  if [ -f "$conf" ]; then
    first_val=$(grep -v '^[[:space:]]*#' "$conf" | grep -v '^[[:space:]]*$' | head -n 1 | tr -d ' \r\n')
    if [[ "$first_val" == *"="* ]]; then
      eval "$(grep -E '^(AI_PROVIDER|AI_MODEL)=' "$conf")"
    elif [ -n "$first_val" ]; then
      AI_PROVIDER="$first_val"
    fi
    [ -n "$AI_PROVIDER" ] && break
  fi
done

# git config からの取得 (未設定時)
if [ -z "$AI_PROVIDER" ]; then
  AI_PROVIDER=$(git config --get ai.provider 2>/dev/null)
fi

# 環境変数での上書き (指定があれば最優先)
AI_PROVIDER="${LAZYGIT_AI:-$AI_PROVIDER}"

# 未設定時のデフォルト (自動判定)
if [ -z "$AI_PROVIDER" ]; then
  if command -v agy &>/dev/null; then
    AI_PROVIDER="agy"
  else
    AI_PROVIDER="copilot"
  fi
fi

echo "Generating commit message with AI [$AI_PROVIDER]..."

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

# 指定されたツールでメッセージ生成
case "$AI_PROVIDER" in
  agy)
    if [ -n "$AI_MODEL" ]; then
      agy --model "$AI_MODEL" -p "$PROMPT" > .git/COMMIT_EDITMSG
    else
      # デフォルトモデルで実行 (最速・安定)
      agy -p "$PROMPT" > .git/COMMIT_EDITMSG
    fi
    ;;
  copilot|github-copilot-cli)
    if command -v github-copilot-cli &>/dev/null; then
      github-copilot-cli git-assist "$PROMPT" > .git/COMMIT_EDITMSG
    elif command -v gh &>/dev/null; then
      gh copilot -p "$PROMPT" > .git/COMMIT_EDITMSG
    else
      echo "Error: github-copilot-cli or gh copilot not found." >&2
      exit 1
    fi
    ;;
  gh|gh-copilot)
    if command -v gh &>/dev/null; then
      gh copilot -p "$PROMPT" > .git/COMMIT_EDITMSG
    else
      echo "Error: gh command not found." >&2
      exit 1
    fi
    ;;
  *)
    echo "Error: Unknown AI provider '$AI_PROVIDER'. Supported: agy, copilot, gh" >&2
    exit 1
    ;;
esac

# クリップボードにコピー
if command -v pbcopy &>/dev/null; then
  cat .git/COMMIT_EDITMSG | pbcopy
elif command -v wl-copy &>/dev/null; then
  cat .git/COMMIT_EDITMSG | wl-copy
elif command -v xclip &>/dev/null; then
  cat .git/COMMIT_EDITMSG | xclip -selection clipboard
elif command -v clip.exe &>/dev/null; then
  cat .git/COMMIT_EDITMSG | clip.exe
fi

# 生成されたメッセージを表示
if [ -f .git/COMMIT_EDITMSG ]; then
  cat .git/COMMIT_EDITMSG
fi
