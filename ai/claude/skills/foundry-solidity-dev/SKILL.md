---
name: foundry-solidity-dev
description: Use when developing Solidity smart contracts with Foundry, setting up forge projects, writing OpenZeppelin-based contracts, running forge tests, or deploying to EVM chains (Polygon, Ethereum). Triggers on keywords like Solidity, Foundry, forge, smart contract, EIP-3009, OpenZeppelin.
---

# Foundry Solidity Development

## Overview

Foundry（forge/cast/anvil）+ OpenZeppelin でスマートコントラクトを開発するためのリファレンス。プロジェクトセットアップからテスト・デプロイまでをカバー。

## When to Use

- Solidity コントラクトの新規作成
- Foundry プロジェクトのセットアップ
- OpenZeppelin セキュリティモジュールの選定
- forge テスト・fuzz テストの作成
- EVM チェーン（Polygon, Ethereum）へのデプロイ

## Project Setup

```bash
# 既存リポジトリ内にコントラクトディレクトリを作成
mkdir contracts && cd contracts
forge init --no-git .
forge install OpenZeppelin/openzeppelin-contracts --no-git

# デフォルトテンプレート削除
rm src/Counter.sol test/Counter.t.sol script/Counter.s.sol
```

### foundry.toml テンプレート

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.24"
optimizer = true
optimizer_runs = 200

remappings = [
  "@openzeppelin/=lib/openzeppelin-contracts/",
  "forge-std/=lib/forge-std/src/",
]

[profile.default.fuzz]
runs = 256
```

## OpenZeppelin モジュール選定

| モジュール | 用途 | いつ使う |
|---|---|---|
| `Ownable` | 管理者限定操作 | admin 関数がある場合は必須 |
| `Pausable` | 緊急停止 | 資金を扱うコントラクトでは必須 |
| `ReentrancyGuard` | 再入攻撃防止 | 外部コントラクト呼び出し + 状態変更がある場合は必須 |
| `SafeERC20` | 安全な ERC20 操作 | ERC20 トークンを transfer/transferFrom する場合は必須 |

```solidity
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
```

## Common Patterns

### Operator パターン（ホワイトリスト実行制限）

特定のアドレスのみが関数を呼べるようにする。Gas payer の制限に使う。

```solidity
mapping(address => bool) public operators;
error NotOperator();

modifier onlyOperator() {
    if (!operators[msg.sender]) revert NotOperator();
    _;
}

function setOperator(address operator, bool active) external onlyOwner {
    if (operator == address(0)) revert ZeroAddress();
    operators[operator] = active;
}
```

### Immutable 宛先パターン（改ざん防止）

デプロイ時に固定し、二度と変更できない宛先アドレス。

```solidity
address public immutable platformWallet;

constructor(address _platformWallet) {
    if (_platformWallet == address(0)) revert ZeroAddress();
    platformWallet = _platformWallet;
}
```

### EIP-3009 インターフェース（JPYC/USDC ガスレス送金）

```solidity
interface IEIP3009 {
    function transferWithAuthorization(
        address from, address to, uint256 value,
        uint256 validAfter, uint256 validBefore,
        bytes32 nonce, uint8 v, bytes32 r, bytes32 s
    ) external;
}
```

### Custom Errors（ガス効率的なエラー）

```solidity
// require() より安い。revert 時にセレクタ（4 bytes）のみ返す
error ZeroAddress();
error FeeTooHigh(uint256 fee, uint256 total);
error AmountZero();
```

## Testing with Forge

### テストファイル構造

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MyContract} from "../src/MyContract.sol";

contract MyContractTest is Test {
    MyContract public target;
    address public owner = makeAddr("owner");
    address public operator = makeAddr("operator");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(owner);
        target = new MyContract(owner);
        target.setOperator(operator, true);
        vm.stopPrank();
    }

    // Happy path
    function test_HappyPath() public { ... }

    // Access control
    function test_RevertWhen_NonOperatorCalls() public {
        vm.prank(attacker);
        vm.expectRevert(MyContract.NotOperator.selector);
        target.restrictedFunction();
    }

    // Fuzz testing
    function testFuzz_ArbitraryAmounts(uint256 amount, uint256 fee) public {
        amount = bound(amount, 1, 1e18);
        fee = bound(fee, 0, amount / 2);
        // ... test with random values
    }
}
```

### よく使う Cheatcodes

| Cheatcode | 用途 |
|---|---|
| `vm.prank(addr)` | 次の1コールを addr として実行 |
| `vm.startPrank(addr)` | 以降のコールを addr として実行 |
| `vm.expectRevert(selector)` | 次のコールが revert することを期待 |
| `vm.expectEmit(true, true, false, true)` | イベント発火を検証 |
| `makeAddr("label")` | テスト用アドレス生成 |
| `deal(token, addr, amount)` | ERC20 残高を強制セット |
| `bound(val, min, max)` | fuzz 入力を範囲制限 |

### テスト実行

```bash
cd contracts
forge build          # コンパイル
forge test           # 全テスト実行
forge test -vvvv     # 詳細トレース付き
forge test --match-test test_HappyPath  # 特定テスト
```

## Deploy Script

```solidity
import {Script, console} from "forge-std/Script.sol";
import {MyContract} from "../src/MyContract.sol";

contract DeployScript is Script {
    function run() external {
        address owner = vm.envAddress("OWNER_ADDRESS");
        address operator = vm.envAddress("OPERATOR_ADDRESS");

        vm.startBroadcast();
        MyContract c = new MyContract(owner);
        c.setOperator(operator, true);
        vm.stopBroadcast();

        console.log("Deployed at", address(c));
    }
}
```

```bash
# Testnet deploy
forge script script/Deploy.s.sol \
  --rpc-url $POLYGON_AMOY_RPC \
  --broadcast \
  --verify

# Dry run (no broadcast)
forge script script/Deploy.s.sol --rpc-url $RPC_URL
```

## Common Mistakes

| 間違い | 正しい方法 |
|---|---|
| `forge init --no-commit` | `--no-commit` は存在しない。`--no-git` を使う |
| `emit log_named_address()` | Script では使えない。`console.log()` を使う |
| プロジェクトルートで `forge test` | `cd contracts` してから実行 |
| `transfer()` を直接呼ぶ | `SafeERC20` の `safeTransfer()` を使う |
| `require()` でエラー処理 | Custom errors (`error X(); revert X();`) の方がガス効率的 |

## Subagent: Forge Test Runner

コントラクトのビルド・テスト実行を委任するサブエージェントプロンプト:

```
You are a Solidity test runner. Your task:
1. cd into the contracts/ directory
2. Run `forge build` and fix any compilation errors
3. Run `forge test -vvvv` and report results
4. If any test fails, analyze the trace and suggest fixes
5. Report: total tests, passed, failed, gas usage for key functions
```
