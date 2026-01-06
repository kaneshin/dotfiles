---
description: Create a boilerplate for a new project using Cloudflare Workers + Remix + D1 + Prisma
---

# Create Cloudflare Fullstack App

新規フルスタックアプリケーションのボイラープレートを作成するコマンドです。

## Context

このコマンドは以下の技術スタックを使用した新規プロジェクトを生成します：

- **Frontend**: Remix on Cloudflare Pages
- **Backend API**: Hono on Cloudflare Workers
- **Database**: D1 (SQLite) + Prisma ORM
- **UI**: shadcn/ui + Tailwind CSS
- **Monorepo**: Turborepo + pnpm workspaces
- **Authentication**: Google OAuth + JWT (オプション)

## Process

### 1. プロジェクト情報の確認

まず、ユーザーに以下の情報を質問してください：

**必須項目**:
- プロジェクト名（例: `my-app`, `inventory-system`）
- プロジェクトディレクトリ（例: `~/projects/my-app`）

**オプション項目**:
- 認証機能の有無（Google OAuth + JWT）
- 初期エンティティ（例: Users, Products, Orders）

### 2. ディレクトリ構造の作成

以下のディレクトリ構造を作成します：

```
{project-name}/
├── apps/
│   ├── api/                    # Hono (Cloudflare Workers)
│   │   ├── src/
│   │   │   ├── index.ts        # エントリーポイント
│   │   │   ├── routes/         # API routes
│   │   │   ├── middleware/     # 認証・エラーハンドリング
│   │   │   └── lib/            # ユーティリティ
│   │   ├── wrangler.toml       # Cloudflare Workers設定
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── web/                    # Remix (Cloudflare Pages)
│       ├── app/
│       │   ├── routes/         # ページルート
│       │   ├── components/     # UI components
│       │   ├── lib/            # API client, utilities
│       │   └── root.tsx        # ルートレイアウト
│       ├── public/
│       ├── package.json
│       ├── remix.config.js
│       ├── tsconfig.json
│       └── tailwind.config.ts
├── packages/
│   ├── database/               # Prisma
│   │   ├── prisma/
│   │   │   └── schema.prisma   # データベーススキーマ
│   │   ├── migrations/         # D1 migrations
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── shared/                 # 共有型・定数
│   │   ├── src/
│   │   │   ├── constants/
│   │   │   ├── schemas/        # Zod schemas
│   │   │   └── index.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   └── ui/                     # shadcn/ui components
│       ├── src/
│       ├── package.json
│       └── tsconfig.json
├── docs/
│   ├── specs/
│   │   ├── features/
│   │   └── backlog/
│   └── implementation/
├── .gitignore
├── package.json                # Root package.json
├── pnpm-workspace.yaml         # pnpm workspaces
├── turbo.json                  # Turborepo config
├── PLAN.md                     # プロジェクト計画
├── README.md
└── CLAUDE.md                   # Claude Code用ガイド
```

### 3. Root設定ファイルの生成

#### 3.1 package.json (Root)

```json
{
  "name": "{project-name}",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "typecheck": "turbo typecheck",
    "db:generate": "turbo db:generate",
    "db:migrate": "cd packages/database && npm run migrate"
  },
  "devDependencies": {
    "turbo": "^2.3.3",
    "typescript": "^5.7.2"
  },
  "packageManager": "pnpm@9.15.0",
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=9.0.0"
  }
}
```

#### 3.2 pnpm-workspace.yaml

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

#### 3.3 turbo.json

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**", ".remix/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "typecheck": {
      "dependsOn": ["^build"]
    },
    "db:generate": {
      "cache": false
    }
  }
}
```

#### 3.4 .gitignore

```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Build outputs
dist/
.next/
.remix/
.wrangler/
.vercel/

# Environment
.env
.env.local
.dev.vars

# Database
*.db
*.db-journal
.wrangler/state/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*

# Turbo
.turbo/
```

### 4. Backend API (Hono) の生成

#### 4.1 apps/api/package.json

```json
{
  "name": "@{project-name}/api",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "wrangler dev",
    "build": "wrangler deploy --dry-run --outdir=dist",
    "typecheck": "tsc --noEmit",
    "deploy": "wrangler deploy",
    "migrate": "wrangler d1 migrations apply {project-name}-db --local",
    "migrate:prod": "wrangler d1 migrations apply {project-name}-db --remote"
  },
  "dependencies": {
    "hono": "^4.6.15",
    "@{project-name}/shared": "workspace:*",
    "@{project-name}/database": "workspace:*"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.20241218.0",
    "wrangler": "^3.97.0",
    "typescript": "^5.7.2"
  }
}
```

#### 4.2 apps/api/wrangler.toml

```toml
name = "{project-name}-api"
main = "src/index.ts"
compatibility_date = "2024-12-01"

[[d1_databases]]
binding = "DB"
database_name = "{project-name}-db"
database_id = ""  # 後でwrangler d1 createで設定

[observability]
enabled = true
```

#### 4.3 apps/api/src/index.ts

```typescript
import { Hono } from "hono";
import { cors } from "hono/cors";

type Bindings = {
  DB: D1Database;
};

const app = new Hono<{ Bindings: Bindings }>();

// CORS設定
app.use("*", cors());

// ヘルスチェック
app.get("/health", (c) => {
  return c.json({ status: "ok", timestamp: new Date().toISOString() });
});

// API routes
app.get("/api", (c) => {
  return c.json({ message: "Welcome to {project-name} API" });
});

export default app;
```

### 5. Frontend (Remix) の生成

#### 5.1 apps/web/package.json

```json
{
  "name": "@{project-name}/web",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "remix vite:dev",
    "build": "remix vite:build",
    "typecheck": "tsc --noEmit",
    "deploy": "npm run build && wrangler pages deploy ./build/client"
  },
  "dependencies": {
    "@remix-run/cloudflare": "^2.15.3",
    "@remix-run/cloudflare-pages": "^2.15.3",
    "@remix-run/react": "^2.15.3",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "@{project-name}/shared": "workspace:*"
  },
  "devDependencies": {
    "@remix-run/dev": "^2.15.3",
    "@types/react": "^18.3.18",
    "@types/react-dom": "^18.3.5",
    "typescript": "^5.7.2",
    "vite": "^6.0.7",
    "tailwindcss": "^3.4.17",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.49"
  }
}
```

#### 5.2 apps/web/app/root.tsx

```typescript
import {
  Links,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
} from "@remix-run/react";
import type { LinksFunction } from "@remix-run/cloudflare";
import "./tailwind.css";

export const links: LinksFunction = () => [];

export default function App() {
  return (
    <html lang="ja">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
        <Outlet />
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  );
}
```

#### 5.3 apps/web/app/routes/_index.tsx

```typescript
import type { MetaFunction } from "@remix-run/cloudflare";

export const meta: MetaFunction = () => {
  return [
    { title: "{Project Name}" },
    { name: "description", content: "Welcome to {Project Name}!" },
  ];
};

export default function Index() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <div className="text-center">
        <h1 className="text-4xl font-bold mb-4">{Project Name}</h1>
        <p className="text-gray-600">
          Cloudflare Workers + Remix + D1 + Prisma
        </p>
      </div>
    </div>
  );
}
```

### 6. Database (Prisma) の生成

#### 6.1 packages/database/package.json

```json
{
  "name": "@{project-name}/database",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "db:generate": "prisma generate",
    "migrate": "wrangler d1 migrations apply {project-name}-db --local"
  },
  "dependencies": {
    "@prisma/adapter-d1": "^5.23.0",
    "@prisma/client": "^5.23.0"
  },
  "devDependencies": {
    "prisma": "^5.23.0",
    "wrangler": "^3.97.0"
  }
}
```

#### 6.2 packages/database/prisma/schema.prisma

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["driverAdapters"]
}

datasource db {
  provider = "sqlite"
  url      = "file:./dev.db"
}

// Example: Users table
model User {
  id        String   @id
  email     String   @unique
  name      String
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt @map("updated_at")

  @@map("users")
}
```

### 7. Shared package の生成

#### 7.1 packages/shared/package.json

```json
{
  "name": "@{project-name}/shared",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "zod": "^3.24.1"
  },
  "devDependencies": {
    "typescript": "^5.7.2"
  }
}
```

#### 7.2 packages/shared/src/index.ts

```typescript
export * from "./constants/index.js";
export * from "./schemas/index.js";
```

#### 7.3 packages/shared/src/constants/index.ts

```typescript
// Project constants
export const APP_NAME = "{Project Name}";
export const APP_VERSION = "0.1.0";
```

### 8. ドキュメントの生成

#### 8.1 README.md

```markdown
# {Project Name}

{Project description}

## Tech Stack

- **Frontend**: Remix on Cloudflare Pages
- **Backend API**: Hono on Cloudflare Workers
- **Database**: D1 (SQLite) + Prisma ORM
- **UI**: shadcn/ui + Tailwind CSS
- **Monorepo**: Turborepo + pnpm workspaces

## Getting Started

### Prerequisites

- Node.js >= 20.0.0
- pnpm >= 9.0.0

### Installation

\`\`\`bash
# Install dependencies
pnpm install

# Generate Prisma client
pnpm db:generate

# Run development servers
pnpm dev
\`\`\`

## Project Structure

See [CLAUDE.md](./CLAUDE.md) for detailed project structure and development guidelines.

## Documentation

- [PLAN.md](./PLAN.md) - Project planning and roadmap
- [CLAUDE.md](./CLAUDE.md) - Development guide for Claude Code

## License

Private
```

#### 8.2 PLAN.md

```markdown
# PLAN

## Project Overview

**Project Name**: {Project Name}
**Description**: {Project description}

## Tech Stack

- **Frontend**: Remix on Cloudflare Pages
- **Backend API**: Hono on Cloudflare Workers
- **Database**: D1 (SQLite) + Prisma ORM
- **UI**: shadcn/ui + Tailwind CSS
- **Monorepo**: Turborepo + pnpm workspaces

## Implementation Status

### ✅ 実装済み機能

- プロジェクト基盤セットアップ
- 基本的なAPI/Webアプリ構造

### 📋 バックログ

- 認証機能 (Google OAuth + JWT)
- データベースマイグレーション
- UI コンポーネントライブラリ

## Development Principles

- **KISS原則**: シンプルで保守しやすいコードを優先
- **YAGNI原則**: 必要最小限の機能から開始し、段階的に拡張
- **API ファースト**: モバイルアプリ対応を前提とした設計
```

#### 8.3 CLAUDE.md

```markdown
# {Project Name} - Claude Code Guide

This document provides guidance for Claude Code instances working in this repository.

## Project Overview

**{Project Name}** is a {description} built as a modern web application:

- **Stack**: Cloudflare Workers (Hono) + Cloudflare Pages (Remix) + D1 (SQLite)
- **Architecture**: Monorepo using Turborepo + pnpm workspaces
- **Database ORM**: Prisma with D1 adapter

## Common Commands

### Development Setup

\`\`\`bash
# Install dependencies
pnpm install

# Build all packages
pnpm build

# Generate Prisma client
pnpm db:generate

# Apply migrations locally
pnpm db:migrate

# Start development servers
pnpm dev
\`\`\`

### Build & Type Checking

\`\`\`bash
# Build entire monorepo
pnpm build

# Type check all packages
pnpm turbo run typecheck
\`\`\`

### Database Migrations

\`\`\`bash
cd ./packages/database

# Create migration file
wrangler d1 migrations create {project-name}-db <migration_name>

# Generate SQL diff
prisma migrate diff \\
  --from-local-d1 \\
  --to-schema-datamodel ./prisma/schema.prisma \\
  --script \\
  --output ./migrations/<number>_<migration_name>.sql

# Apply migration locally
npm run migrate
\`\`\`

## References

- Project plan: `PLAN.md`
- Installation: `README.md`
- Turborepo config: `turbo.json`
- Database schema: `packages/database/prisma/schema.prisma`
```

### 9. セットアップコマンドの実行

すべてのファイルを生成した後、以下のコマンドを実行します：

```bash
# プロジェクトディレクトリに移動
cd {project-directory}

# 依存関係のインストール
pnpm install

# Prisma クライアント生成
pnpm db:generate

# ビルド確認
pnpm build

# 型チェック
pnpm turbo run typecheck
```

### 10. 次のステップの提示

セットアップ完了後、ユーザーに以下の次のステップを提示します：

1. **D1データベースの作成**:
   ```bash
   cd apps/api
   wrangler d1 create {project-name}-db
   # 出力されたdatabase_idをwrangler.tomlに設定
   ```

2. **開発サーバーの起動**:
   ```bash
   pnpm dev
   ```

3. **追加機能の実装**（オプション）:
   - Google OAuth認証
   - shadcn/ui セットアップ
   - 初期エンティティの作成

## Arguments

- `$ARGUMENTS` - オプション引数
  - 引数なし: 基本的なボイラープレートのみ生成
  - `--with-auth`: Google OAuth認証機能を追加
  - `--entity <name>`: 初期エンティティを追加（例: `--entity Product`）

## Examples

```bash
# 基本的なボイラープレート生成
/create-cloudflare-fullstack

# 認証機能付きで生成
/create-cloudflare-fullstack --with-auth

# 認証+初期エンティティ（Product）
/create-cloudflare-fullstack --with-auth --entity Product
```

## Notes

### 重要事項

1. **Node.js バージョン**: Node.js 20.0.0 以降が必要
2. **pnpm 必須**: npm/yarn ではなく pnpm を使用
3. **Cloudflare アカウント**: デプロイにはCloudflareアカウントが必要
4. **D1 データベース**: 初回セットアップ時に手動で作成が必要

### 生成されるファイル

**必須ファイル** (常に生成):
- ✅ Root設定 (package.json, pnpm-workspace.yaml, turbo.json, .gitignore)
- ✅ Backend API (Hono + TypeScript)
- ✅ Frontend (Remix + TypeScript)
- ✅ Database (Prisma schema)
- ✅ Shared package (Constants, Types)
- ✅ Documentation (README.md, PLAN.md, CLAUDE.md)

**オプション機能** (引数で指定):
- ⚙️ Google OAuth認証 (`--with-auth`)
- ⚙️ 初期エンティティ (`--entity <name>`)
- ⚙️ shadcn/ui セットアップ (`--with-ui`)

### トラブルシューティング

**pnpm install が失敗する**:
```bash
# pnpm のバージョンを確認
pnpm --version

# 必要に応じてアップデート
npm install -g pnpm@latest
```

**Prisma が生成できない**:
```bash
# packages/database で直接実行
cd packages/database
npx prisma generate
```

**TypeScript エラー**:
```bash
# 全パッケージをビルド
pnpm build

# shared パッケージを先にビルド
cd packages/shared
pnpm build
```

### カスタマイズ

このボイラープレートは出発点として使用してください。プロジェクトの要件に応じて以下をカスタマイズできます：

- データベーススキーマ（`packages/database/prisma/schema.prisma`）
- API routes（`apps/api/src/routes/`）
- UI components（`apps/web/app/components/`）
- 定数・型定義（`packages/shared/src/`）

### Brewday プロジェクトとの違い

このボイラープレートはBrewdayプロジェクトをベースにしていますが、以下の点で異なります：

- ✅ シンプルな構成（最小限の機能のみ）
- ✅ ドメイン固有のロジックを含まない
- ✅ カスタマイズしやすいテンプレート構造
- ✅ 段階的な機能追加が可能

### 参考資料

- [Cloudflare Workers ドキュメント](https://developers.cloudflare.com/workers/)
- [Remix ドキュメント](https://remix.run/docs)
- [Hono ドキュメント](https://hono.dev/)
- [Prisma ドキュメント](https://www.prisma.io/docs)
