#!/usr/bin/env bash
# 把 messy-project 复制成一个能跑 /foreman:setup 的演示项目：四个子仓各自是独立 git 仓，和真实的多仓项目一样。
#
# 用法：
#   bash make-demo.sh <目标目录>              A 摆法：总管包住子仓，总管目录不是 git 仓
#   bash make-demo.sh <目标目录> --hub-git    A 摆法：总管目录也是 git 仓（故意不写 .gitignore，考 setup 会不会补）
#   bash make-demo.sh <目标目录> --flat       B 摆法：总管在 <目标目录>/hub/，子仓和它平级
#
# 然后：
#   A：cd <目标目录> && claude，运行 /foreman:setup
#   B：cd <目标目录>/hub && claude --add-dir ../app ../backend ../admin ../web，运行 /foreman:setup
set -euo pipefail

usage() { sed -n '4,7p' "$0" | sed 's/^# //'; exit 1; }

[ $# -ge 1 ] || usage
target=$1
mode=${2:-}
case "$mode" in ""|--hub-git|--flat) ;; *) usage ;; esac

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

if [ "$mode" = "--flat" ]; then
  hub="$target/hub"
  mkdir -p "$hub"
  for f in "$src"/* "$src"/.[!.]*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    [ "$name" = ".DS_Store" ] && continue
    case " $subs " in
      *" $name "*) cp -R "$f" "$target/$name" ;;
      *) cp -R "$f" "$hub/$name" ;;
    esac
  done
  commit_all "$hub" .
else
  cp -R "$src"/. "$target"/
  rm -f "$target/.DS_Store"
fi

for s in $subs; do
  commit_all "$target/$s" .
done

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

echo "演示项目已生成：$target"
