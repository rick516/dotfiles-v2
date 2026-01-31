# Remotion Plugin

Remotionでプログラマティックにビデオを作成するためのClaude Codeプラグイン。

## Features

### MCP Integration

Remotion Documentation MCPサーバーを統合。Claude CodeがRemotionのドキュメントにアクセスし、正確なAPIリファレンスと例を提供できる。

### Skills

- **remotion-dev**: Remotion開発の包括的なガイド。useCurrentFrame, interpolate, spring, Composition, Sequenceなどの基本概念をカバー。

## Installation

### Global Installation

```bash
# Link to Claude global plugins
ln -s /path/to/this/plugin ~/.claude/plugins/remotion
```

Or add to your dotfiles and symlink.

### Per-Project Installation

プロジェクトの `.claude/plugins/` ディレクトリにコピーまたはシンボリックリンク。

## MCP Server

このプラグインは `@remotion/mcp` サーバーを含む。インストール後、Claude Codeは自動的にRemotionドキュメントにアクセスできる。

```json
{
  "remotion-documentation": {
    "command": "npx",
    "args": ["@remotion/mcp@latest"]
  }
}
```

## Usage

Remotion関連の質問や開発依頼で自動的にスキルがトリガーされる:

- "Remotionでビデオを作成して"
- "アニメーションを追加したい"
- "useCurrentFrameの使い方"
- "springアニメーションの実装"

## Quick Start

```bash
# 新規プロジェクト作成
npx create-video@latest

# プレビュー
npx remotion studio

# レンダリング
npx remotion render src/index.ts MyVideo out/video.mp4
```

## Contents

```
remotion/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json              # Remotion MCP server config
├── README.md
└── skills/
    └── remotion-dev/
        ├── SKILL.md       # Core development guide
        └── examples/
            ├── fade-in.tsx
            ├── spring-scale.tsx
            └── sequence-timeline.tsx
```
