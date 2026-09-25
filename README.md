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

`/foreman:setup` 和 `/foreman:audit` 要在 Claude Code 里跑。搭出来的工程别的 AI 工具也能用：规则写在 CLAUDE.md，每个 CLAUDE.md 旁边放一份 AGENTS.md，用 `@CLAUDE.md` 指过去，Codex、Cursor、Gemini CLI 读 AGENTS.md 就能找到规则。Claude Code 有 CLAUDE.md 时不读 AGENTS.md，所以这份文件不占它的上下文。自动加载上层目录的规则、B 方案的启动命令，是 Claude Code 才有的行为；别的工具靠 AGENTS.md 里那句「先读总管的 CLAUDE.md」。

在 Claude Code 里分两次运行，先加插件市场，再装插件：

```text
/plugin marketplace add Nerakolox/foreman-skill
```

```text
/plugin install foreman
```

你装过的别的市场里也有叫 foreman 的插件时，第二条改成 `/plugin install foreman@nerakolox`，指明从哪个市场装。

或者克隆下来，启动时指定插件目录：

```bash
git clone https://github.com/Nerakolox/foreman-skill
claude --plugin-dir ./foreman-skill
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

## 其他项目结构

| 你的项目 | setup 怎么处理 |
| --- | --- |
| monorepo（pnpm / npm / yarn workspaces、go.work、Cargo workspace、Nx、Turborepo） | 算 A，仓根就是总管。按 workspace 配置找子仓，不限层级；应用包算子仓，库算共享包，问你谁能改、共享类型包是不是契约源 |
| 一个 git 仓，前后端分在 `web/`、`server/` 这类子目录 | 算 A，每个子目录是一个子仓 |
| 只有一个端 | 单仓精简版：一份 CLAUDE.md、spec（有接口或数据模型才建）、台账、细则，没有包工头和联调任务单。以后多出第二个端，再跑一次 setup 升级 |
| 全局规则和 spec 写在某个业务仓里（比如 backend），别的仓在旁边 | 不支持。这个仓的每个会话都会读到管全局的规则，包工头和干活的角色打架。setup 会建议另建总管：父目录当总管（A），或者旁边新建一个（B）。你坚持不建的话，只按单仓精简版改这一个仓 |
| 仓散在不同目录 | B，路径按实际相对位置写，所有人按同样的相对位置克隆 |

## 用法

在总管目录启动 Claude Code（B 方案要带上 `--add-dir ../<子仓>`，否则读不到子仓）：

| 命令 | 做什么 |
| --- | --- |
| `/foreman:audit` | 只读体检，出一份报告，不改任何文件 |
| `/foreman:setup` | 搭工程。已有项目：体检 → 问你几个问题 → 列方案 → 你确认后才动手；新项目：问清摆法和有哪几个仓，直接搭骨架 |

foreman 只动工程文件（各级 CLAUDE.md 和 AGENTS.md、`.agents/rules/`、`spec/`、`plan/`、`joint-tasks/`、`_archive/`，以及 A 方案外层的 `.gitignore`），不改业务代码，不删文件，不提交。发现代码和契约对不上，会开一张任务单交给你。

开始前请先提交或备份。改完不满意，在每个仓里 `git checkout . && git clean -fd` 就能回到改造前（会丢掉所有未提交的改动，所以前面那步不能省）。

搭好以后这样用：在总管目录开一个 Claude Code 当包工头，只拆需求、派活、登记台账；在每个子仓目录各开一个，负责写代码，做完改台账。

## 费用

setup 要通读所有 CLAUDE.md、规则文件和前后端的模型、路由代码。示例项目（四个小仓）上实测：audit 约 1.5 美元，setup 两轮约 4.5～5.5 美元；monorepo 版约 3.5 美元，单仓版约 3.7 美元。真实项目按代码量往上涨。

## 先拿示例试试

`examples/messy-project/` 是一个虚构的四仓项目（app、backend、admin、web），故意埋了视频里讲的那些坑：208 行的根 CLAUDE.md、用 `@` 整份引进来的规范、前后端对不上的字段和错误码、根目录的调研笔记和过时的接口草稿，还有一份因为根目录有 CLAUDE.md 而根本不会被读取的 AGENTS.md。

把它复制到别处，在里面运行 `/foreman:setup`，就能看到完整流程。四个子仓在真实项目里通常各自是 git 仓，用 `examples/make-demo.sh` 生成演示项目更接近实际：

```bash
bash examples/make-demo.sh ~/demo-a --hub-git   # A 方案，总管也是 git 仓
bash examples/make-demo.sh ~/demo-b --flat      # B 方案，总管在 ~/demo-b/hub/，子仓和它平级
bash examples/make-demo.sh ~/demo-m --monorepo  # monorepo：apps/*、services/backend、packages/shared，一个 git 仓
bash examples/make-demo.sh ~/demo-s --single    # 单仓：只有 backend
bash examples/make-demo.sh ~/demo-r --in-repo   # 全局规则写在 backend 仓里，app、admin、web 在旁边
```

A 方案、monorepo、单仓在生成的目录里直接 `claude`；B 方案在 `~/demo-b/hub` 里 `claude --add-dir ../app ../backend ../admin ../web`；`--in-repo` 在 `~/demo-r/backend` 里 `claude --add-dir ../app ../admin ../web`。然后运行 `/foreman:setup`。单仓演示的笔记里提到了 app，setup 会先问你是不是还有别的端，回答「只有这一个」它就按单仓精简版往下做；`--in-repo` 的正确结果是停下来，建议你另建总管。

## 许可

MIT
