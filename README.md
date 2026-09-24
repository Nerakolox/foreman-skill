# foreman 包工头

<p align="center"><img src="foreman-logo.png" width="320" alt="foreman"></p>

给多仓项目搭一套让 AI 守规矩的工程。来自抖音「404赛博小卖部」第 1 期《工程里怎么用 Claude Code》。

你给 AI 写了一千行规矩，它照样乱来：字段瞎编，别的仓乱改，根目录一堆垃圾文档。问题通常不在模型，在于没给它搭好工程。foreman 把视频里那套打法做成了 Claude Code 插件：

- **spec**：各仓共用的契约，唯一真理源。别处只引章节号，不复制原文
- **总管 CLAUDE.md 当包工头**：只派活、守契约、管目录、答疑，不写代码
- **子仓 CLAUDE.md 先划边界**：本仓只做什么，spec 里没有的一个都不许引进来
- **细则拆进 `.agents/rules/`**：不占开局上下文，在 CLAUDE.md 里用一张「主题 / 路径 / 什么时候读」的表指过去，路径一律写相对路径
- **plan 任务台账**：单仓的、跨仓的任务都登记在 `plan/tasks.md`，只有台账里的状态算数
- **joint-tasks 联调任务单**：跨仓的活走任务单，做完就归档
- **目录戒律**：总管目录不许新增顶层文档

## 安装

在 Claude Code 里运行：

```text
/plugin marketplace add Nerakolox/foreman
/plugin install foreman@404-cyber-store
```

或者克隆下来，启动时指定插件目录：

```bash
git clone https://github.com/Nerakolox/foreman
claude --plugin-dir ./foreman
```

## 两种摆法

总管（spec、台账、任务单、包工头 CLAUDE.md 所在的地方）和各个子仓有两种摆法，setup 会问你选哪种。

**A. 总管包住子仓（默认，推荐）**

```text
my-project/          总管，可以是 git 仓
├── CLAUDE.md
├── spec/  plan/  joint-tasks/
├── app/             子仓，可以各自是独立 git 仓
└── backend/
```

子仓会话自动读到总管的规则，不用记任何参数。外层和子仓都是 git 仓时，外层 `.gitignore` 要写上每个子仓目录，setup 会帮你加。

**B. 总管和子仓平级**

```text
workspace/
├── my-project-hub/  总管 git 仓
├── app/             子仓
└── backend/
```

适合子仓是上游 fork、要独立发布、或者权限分开的情况。代价是子仓会话必须这样启动：

```bash
CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../my-project-hub
```

两样缺一不可。只加 `--add-dir` 读不到总管的 CLAUDE.md，而且不报错，AI 会当 spec 不存在。setup 会把这条命令写进每个子仓的 CLAUDE.md，再加一条自检。

## 用法

在总管目录启动 Claude Code（B 方案要带上 `--add-dir ../<子仓>`，否则读不到子仓）：

| 命令 | 做什么 |
| --- | --- |
| `/foreman:audit` | 只读体检，出一份报告，不改任何文件 |
| `/foreman:setup` | 搭工程。已有项目：体检 → 问你几个问题 → 列方案 → 你确认后才动手；新项目：问清摆法和有哪几个仓，直接搭骨架 |

foreman 只动工程文件（各级 CLAUDE.md、`.agents/rules/`、`spec/`、`plan/`、`joint-tasks/`、`_archive/`，以及 A 方案外层的 `.gitignore`），不改业务代码，不删文件，不提交。发现代码和契约对不上，会开一张任务单交给你。

开始前请先提交或备份。改完不满意，在每个仓里 `git checkout . && git clean -fd` 就能回到改造前（会丢掉所有未提交的改动，所以前面那步不能省）。

搭好以后这样用：在总管目录开一个 Claude Code 当包工头，只拆需求、派活、登记台账；在每个子仓目录各开一个，负责写代码，做完改台账。

## 费用

setup 要通读所有 CLAUDE.md、规则文件和前后端的模型、路由代码。示例项目（四个小仓）上实测：audit 约 1.5 美元，setup 两轮约 4.5～5.5 美元。真实项目按代码量往上涨。

## 先拿示例试试

`examples/messy-project/` 是一个虚构的四仓项目（app、backend、admin、web），故意埋了视频里讲的那些坑：208 行的根 CLAUDE.md、用 `@` 整份引进来的规范、前后端对不上的字段和错误码、根目录的调研笔记和过时的接口草稿，还有一份因为根目录有 CLAUDE.md 而根本不会被读取的 AGENTS.md。

把它复制到别处，在里面运行 `/foreman:setup`，就能看到完整流程。四个子仓在真实项目里通常各自是 git 仓，用 `examples/make-demo.sh` 生成演示项目更接近实际：

```bash
bash examples/make-demo.sh ~/demo-a --hub-git   # A 方案，总管也是 git 仓
bash examples/make-demo.sh ~/demo-b --flat      # B 方案，总管在 ~/demo-b/hub/，子仓和它平级
```

A 方案在 `~/demo-a` 里直接 `claude`；B 方案在 `~/demo-b/hub` 里 `claude --add-dir ../app ../backend ../admin ../web`。然后运行 `/foreman:setup`。

## 许可

MIT
