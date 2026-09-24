#!/usr/bin/env bash
# 把 messy-project 复制成一个能跑 /foreman:setup 的演示项目。默认四个子仓各自是独立 git 仓，和真实的多仓项目一样。
#
# 用法：
#   bash make-demo.sh <目标目录>              A 摆法：总管包住子仓，总管目录不是 git 仓
#   bash make-demo.sh <目标目录> --hub-git    A 摆法：总管目录也是 git 仓（故意不写 .gitignore，考 setup 会不会补）
#   bash make-demo.sh <目标目录> --flat       B 摆法：总管在 <目标目录>/hub/，子仓和它平级
#   bash make-demo.sh <目标目录> --monorepo   monorepo：一个 git 仓，apps/app、apps/admin、apps/web、services/backend，外加没人用的 packages/shared
#   bash make-demo.sh <目标目录> --single     单仓：只有 backend 一个端，根目录照样堆着笔记
#   bash make-demo.sh <目标目录> --in-repo    规则放在业务仓里：根 CLAUDE.md 和笔记都在 backend 仓，app、admin、web 在旁边
#
# 然后：
#   A、monorepo、单仓：cd <目标目录> && claude，运行 /foreman:setup
#   B：cd <目标目录>/hub && claude --add-dir ../app ../backend ../admin ../web，运行 /foreman:setup
#   规则放在业务仓里：cd <目标目录>/backend && claude --add-dir ../app ../admin ../web，运行 /foreman:setup
set -euo pipefail

usage() { sed -n '4,10p' "$0" | sed 's/^# //'; exit 1; }

[ $# -ge 1 ] || usage
target=$1
mode=${2:-}
case "$mode" in ""|--hub-git|--flat|--monorepo|--single|--in-repo) ;; *) usage ;; esac

src="$(cd "$(dirname "$0")" && pwd)/messy-project"
subs="app backend admin web"

if [ -e "$target" ] && [ -n "$(ls -A "$target" 2>/dev/null)" ]; then
  echo "目标目录不是空的：$target" >&2
  exit 1
fi
mkdir -p "$target"
target="$(cd "$target" && pwd)"

commit_all() {
  git -C "$1" init -q
  git -C "$1" -c core.autocrlf=false add -A -- "${@:2}"
  git -C "$1" -c user.name=demo -c user.email=demo@example.com commit -q -m "初始版本"
}

# 把总管的文件（不是子仓的）复制到 $1
copy_hub_files() {
  for f in "$src"/* "$src"/.[!.]*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    [ "$name" = ".DS_Store" ] && continue
    case " $subs " in *" $name "*) continue ;; esac
    cp -R "$f" "$1/$name"
  done
}

case "$mode" in
  --flat|--in-repo)
    for s in $subs; do cp -R "$src/$s" "$target/$s"; done
    if [ "$mode" = "--flat" ]; then
      mkdir -p "$target/hub"
      copy_hub_files "$target/hub"
      commit_all "$target/hub" .
    else
      copy_hub_files "$target/backend"
    fi
    for s in $subs; do commit_all "$target/$s" .; done
    ;;

  --monorepo)
    mkdir -p "$target/apps" "$target/services" "$target/packages/shared/src"
    for s in app admin web; do cp -R "$src/$s" "$target/apps/$s"; done
    cp -R "$src/backend" "$target/services/backend"
    copy_hub_files "$target"
    sed -i 's#^@app/docs/#@apps/app/docs/#' "$target/CLAUDE.md"
    cat > "$target/pnpm-workspace.yaml" <<'EOF'
packages:
  - apps/*
  - packages/*
EOF
    cat > "$target/go.work" <<'EOF'
go 1.22

use ./services/backend
EOF
    cat > "$target/package.json" <<'EOF'
{
  "name": "demo-monorepo",
  "private": true,
  "scripts": {
    "app": "pnpm --filter app start",
    "admin": "pnpm --filter admin dev",
    "lint": "pnpm -r lint"
  },
  "packageManager": "pnpm@9.12.0"
}
EOF
    cat > "$target/packages/shared/package.json" <<'EOF'
{
  "name": "@demo/shared",
  "version": "0.1.0",
  "private": true,
  "main": "src/index.ts"
}
EOF
    cat > "$target/packages/shared/src/index.ts" <<'EOF'
// 各端共用的类型。还没有端引用这里。

export interface User {
  id: number
  username: string
  avatar: string
  bio: string
  createdAt: string
}

export interface Post {
  id: number
  title: string
  content: string
  authorId: number
  likeCount: number
  createdAt: string
}
EOF
    commit_all "$target" .
    ;;

  --single)
    cp -R "$src/backend"/. "$target"/
    for f in notes.md api-draft.md investigation-login-kickout.md; do cp "$src/$f" "$target/$f"; done
    {
      printf '# 项目说明\n\n示例社区的后端服务。请遵守下面的所有规则。\n\n@docs/deploy.md\n\n'
      awk '
        /^## / { keep = ($0 ~ /^## (通用规则|backend 规则|接口说明|Git 规范|部署|其他)$/) }
        keep
      ' "$src/CLAUDE.md"
    } > "$target/CLAUDE.md"
    commit_all "$target" .
    ;;

  *)
    cp -R "$src"/. "$target"/
    rm -f "$target/.DS_Store"
    for s in $subs; do commit_all "$target/$s" .; done
    if [ "$mode" = "--hub-git" ]; then
      # 只提交总管自己的文件；子仓不加进来，外层 git status 里会看到它们没被忽略
      hub_files=()
      for f in "$target"/* "$target"/.[!.]*; do
        [ -e "$f" ] || continue
        name=$(basename "$f")
        case " $subs .git " in *" $name "*) continue ;; esac
        hub_files+=("$name")
      done
      commit_all "$target" "${hub_files[@]}"
    fi
    ;;
esac

echo "演示项目已生成：$target"
