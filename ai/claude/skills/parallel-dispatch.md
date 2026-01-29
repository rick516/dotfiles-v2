# Parallel Dispatch Skill

Claude Codeからopencodeを活用した大量並列タスク処理スキル。単純作業を高速に捌く。

## 発動条件

以下のキーワード・状況で自動発動:
- 「大量に」「一括で」「並列で」「まとめて」
- 独立した単純タスクが10個以上
- 各タスクが相互依存しない

## アーキテクチャ

```
Claude Code (オーケストレーター)
    │
    ├── opencode -p "バッチ1" --dir ./path
    │       └── 内部でさらに並列可能
    ├── opencode -p "バッチ2" --dir ./path
    │       └── 内部でさらに並列可能
    └── opencode -p "バッチ3" --dir ./path
            └── 内部でさらに並列可能
```

## 実行パターン

### パターン1: Bashバックグラウンド並列

```bash
parallel_dispatch() {
    local max_parallel=${1:-5}
    local tasks=("${@:2}")
    local pids=()

    for task in "${tasks[@]}"; do
        opencode -p "$task" -q &
        pids+=($!)
        
        if [[ ${#pids[@]} -ge $max_parallel ]]; then
            wait -n
            pids=($(jobs -p))
        fi
    done
    wait
}
```

### パターン2: xargs並列

```bash
echo "タスク1
タスク2
タスク3" | xargs -P 5 -I {} opencode -p "{}" -q
```

### パターン3: GNU parallel

```bash
parallel -j 5 opencode -p {} -q ::: "タスク1" "タスク2" "タスク3"
```

## ユースケース別テンプレート

### GitHub Issue一括処理

```bash
gh issue list --label "" --json number,title --limit 50 | \
jq -r '.[] | "#\(.number) \(.title)"' | \
xargs -P 5 -I {} opencode -p "Issue {}を分析してラベル提案" -q
```

### 複数ファイルリファクタ

```bash
find src -name "*.ts" -type f | \
xargs -P 5 -I {} opencode -p "{}をリファクタ: 未使用import削除、型厳密化" --dir .
```

### テスト一括生成

```bash
find src/components -name "*.tsx" | \
xargs -P 5 -I {} opencode -p "{}のユニットテスト作成" -q
```

## 注意点

### 競合回避
- 同じファイルを複数プロセスで編集しない
- 依存関係のあるタスクは並列化しない
- 読み取り専用タスクは安全に並列化OK

### レート制限対策
```bash
for task in "${tasks[@]}"; do
    opencode -p "$task" -q &
    sleep 0.5  # 間隔を空ける
done
```

### 結果集約
```bash
mkdir -p /tmp/dispatch-results
for i in "${!tasks[@]}"; do
    opencode -p "${tasks[$i]}" -f json > /tmp/dispatch-results/$i.json &
done
wait
cat /tmp/dispatch-results/*.json | jq -s '.'
```

## opencodeへの指示テンプレート

```
あなたはバッチ処理の一部です。

タスク: [具体的な指示]

制約:
- 指定スコープのみ変更
- 完了したら簡潔に報告
- 必要ならさらに並列分割して高速化

```

## 使用例

Claude Codeに対して:
- 「全コンポーネントにテスト追加して、並列で」
- 「未対応issue 50件をトリアージして」
- 「src/以下のTSファイルを一括リファクタ」

→ このスキルが発動、opencodeに並列ディスパッチ
