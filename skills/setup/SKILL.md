---
name: setup
description: 给多仓项目搭一套让 AI 守规矩的工程：spec 契约当唯一真理源，总管 CLAUDE.md 当包工头只派活，子仓 CLAUDE.md 先划边界，长规则拆进 .agents/rules 按时机读取，所有任务登记进 plan/tasks.md 台账，跨仓的活走 joint-tasks 任务单，总管目录不堆杂文档。总管可以包住子仓，也可以和子仓平级。已有项目先体检出报告、确认后再改造；新项目直接搭骨架。
argument-hint: "[总管目录，不填就是当前目录]"
disable-model-invocation: true
allowed-tools: Read Grep Glob Bash(git status *) Bash(git log *) Bash(git diff *) Bash(git ls-files *) Bash(git -C * status *) Bash(git -C * log *) Bash(git -C * diff *) Bash(git -C * ls-files *)
---

# foreman：给多仓项目搭工程

总管目录：$ARGUMENTS（为空就用当前工作目录）。

**开头先把下面这些一次读完**，它们是你自己的参考文件，都在 `${CLAUDE_SKILL_DIR}` 下（用绝对路径读，它们不在项目里）：

- `reference/architecture.md`：整套结构的定义，下面生成的每个文件都要符合它
- `reference/audit.md`：体检的 16 项和报告格式
- `templates/` 下全部模板：`root-CLAUDE.md`、`sub-CLAUDE.md`、`rule.md`、`joint-tasks-rule.md`、`plan-rule.md`、`plan-tasks.md`、`spec/INDEX.md`、`spec/chapter.md`、`spec/10-decisions.md`

现在就全读完，别等到第 4 步再回来读。

## 铁律

- **只动工程文件**：各级 `CLAUDE.md`、`AGENTS.md`、`.agents/rules/`、`spec/`、`plan/`、`joint-tasks/`、`_archive/`，以及 A 方案外层的 `.gitignore`（只加子仓目录，别的行不动）。业务代码一行不改。发现代码和契约冲突，记下来，交给之后的任务单。
- **不删文件**。要清理的移进 `_archive/`，在报告里列出来。
- **不编内容**。spec 和规则里写的每一条，都要能在现有代码、文档或用户的回答里找到出处。找不到的写「待补」，或者问用户。
- **先确认再动手**。第 1 到 3 步只读不写；用户确认改造方案以后，才进第 4 步。
- **能回滚**。改造前查每个 git 仓的状态；有未提交的改动，提醒用户先提交。总管目录不是 git 仓的，提醒用户先备份。查别的仓用 `git -C <仓> status --short`，一个仓单独调用一次，不要用 `cd`、`&&`、`;`、`for` 循环串起来，串起来的命令不在免确认的范围里。
- **不提交**。改完交给用户看，由用户自己分仓提交。

## 第 1 步：认项目

1. **认摆法**（两种摆法见 architecture.md）：
   - 当前目录下面有子仓：A，总管包住子仓。
   - 当前目录下面没有子仓，但当前目录是 git 仓、里面有 `spec/`、`plan/`、`joint-tasks/`、CLAUDE.md 这类总管的东西，或者用户说子仓在旁边：B，总管和子仓平级，到 `../` 下找子仓。
   - B 方案的子仓在工作目录外面。读不到就停下来，让用户用 `claude --add-dir ../<子仓> ../<子仓>` 重启再跑，不要只看总管就往下做。
2. **找子仓**：在上面认定的位置列出一级目录。有 `.git`、`package.json`、`go.mod`、`pom.xml`、`build.gradle`、`pubspec.yaml`、`Cargo.toml`、`pyproject.toml`、`*.csproj` 之类的，算一个子仓；没有这些、但明显是一个独立端的（比如只有 `index.html` 的静态官网），也算。`spec/`、`docs/`、`plan/`、`joint-tasks/`、`_archive/` 这类不算。
3. 子仓少于 2 个：告诉用户这套结构是给多仓、多端项目设计的，问要不要继续。
4. 子仓里已经有代码，走「已有项目」（第 2 步起）；都是空目录或者还没建，走「新项目」（第 5 步）。

## 第 2 步：体检（已有项目）

按 [reference/audit.md](reference/audit.md) 逐项检查，按里面的格式出报告。项目大的时候，可以把各子仓分给子代理并行去查，但报告由你汇总。

## 第 3 步：访谈，然后出方案

用户看完报告后，一次问完从代码里推不出来的事。每个问题都附上你的推断，让用户确认或纠正：

- **摆法**：保持现状还是换。推荐 A；子仓是上游 fork、要独立发布、或者权限分开不能放进同一个目录的，选 B。选 B 要讲清楚代价：每个子仓都得带启动参数，忘了带不报错、直接读不到规则。已经是 B 的，默认保持 B，不劝用户挪目录。
- 每个子仓负责什么、不负责什么
- 契约现在以哪里为准（OpenAPI、共享类型、文档，还是只在代码里）
- 有 OpenAPI、Protobuf 这类契约文件的：挪进 `spec/`，还是留在原处、只在 INDEX.md 登记。附上你的判断：手写的还是代码生成的
- 有 `.claude/rules/` 的：告诉用户这些文件开局就全部加载，问是保留、挪进 `.agents/rules/`，还是加上 `paths:`
- 字段命名以哪种为准（camelCase 还是 snake_case），有没有转换层、放在哪一端
- 报告里每一条跨仓冲突，以哪边为准
- 现在在做、还没做完的任务有哪些（登记进台账）
- 总管目录那些零散文件，哪些还有用
- 各仓有没有已经在遵守、但没写下来的规矩

然后列出改造方案，分「新建」「修改」「移动」三组，每个文件一行，写清楚做什么。等用户确认。

## 第 4 步：改造

按这个顺序做，模板都在 `templates/` 下。生成时把模板里的占位全部换成真实内容，按摆法删掉不适用的段落，删掉所有 HTML 注释。

1. **`spec/`**：用 [templates/spec/INDEX.md](templates/spec/INDEX.md) 建索引，用 [templates/spec/chapter.md](templates/spec/chapter.md) 建各主题文件，用 [templates/spec/10-decisions.md](templates/spec/10-decisions.md) 建决策记录。
   - 字段名、类型、接口路径、方法、错误码，能从代码或文档可靠提取的就提取。
   - 冲突按用户的决定写进 spec。每条决定记一节决策记录。
   - 项目大到一次提不完：先把实体清单、接口清单和有冲突的部分写全，其余章节写「待补」。
   - 已有 OpenAPI 之类的契约文件，按第 3 步用户的回答处理：挪进 `spec/`，或者留在原处、在 INDEX.md 登记位置和生成命令。
2. **总管 `CLAUDE.md`**：用 [templates/root-CLAUDE.md](templates/root-CLAUDE.md)。原来已经有的，保留其中有用的内容，按四层归位：属于某个仓的挪去那个仓，属于契约的挪进 spec。
3. **总管 `.agents/rules/`**：`plan.md` 照抄 [templates/plan-rule.md](templates/plan-rule.md)，`joint-tasks.md` 照抄 [templates/joint-tasks-rule.md](templates/joint-tasks-rule.md)，填上真实的子仓名。
4. **每个子仓的 `CLAUDE.md`**：用 [templates/sub-CLAUDE.md](templates/sub-CLAUDE.md)。
   - 原有的规则一条都不丢。短的留在 CLAUDE.md；成段的规范拆进 `.agents/rules/<主题>.md`（格式见 [templates/rule.md](templates/rule.md)），在「细则」表里登记路径和读取时机。
   - 所有仓共用的规范（git、部署这类）放总管的 `.agents/rules/`，登记进总管 CLAUDE.md 的「细则」表，子仓不再抄一份。
   - 已有的 `.claude/rules/` 按第 3 步用户的回答处理。
   - 常用命令只写从 `package.json`、`Makefile` 这类文件里核实过的。
   - 有 `AGENTS.md` 的子仓，按 architecture.md 里「AGENTS.md 会被挤掉」那条处理。
   - `@` 引用细则的，改成「什么时候读」的写法。
5. **`joint-tasks/` 和 `_archive/`**：建目录。已有的任务文档按新规矩改名、补状态；已完成的移进 `_archive/joint-tasks/`。第 3 步里定下来、需要改代码的冲突，开一张状态为 `planning` 的任务单，把冲突写进去。
6. **`plan/tasks.md`**：用 [templates/plan-tasks.md](templates/plan-tasks.md)。第 3 步确认过的在做的任务、上一步开的每张任务单，各登记一行。项目原来有全局任务表的，把还没做完的行搬过来，原文件移进 `_archive/`。
7. **按摆法补齐**：
   - A 方案：外层是 git 仓、子仓也各自有 `.git` 的，外层 `.gitignore` 逐个加上子仓目录。外层已经把子仓存成 gitlink 的，不要自己处理，写进交付说明，告诉用户怎么修（`git rm --cached <子仓>`，再加进 `.gitignore`）。
   - B 方案：每个子仓 CLAUDE.md 保留「启动」一节；总管 `README.md` 加一张版本表（总管提交对应各子仓的版本），没有 README 就新建。
8. **总管目录零散文件**：按用户确认的去向移走。
9. **修路径**：把所有 CLAUDE.md、AGENTS.md、`.agents/rules/` 里的路径逐个核对，失效的改掉，绝对路径一律改成相对路径。B 方案里子仓指向总管的路径是 `../<总管目录>/…`，别写成 `../spec/`。

## 第 5 步：新项目

1. 问用户：用哪种摆法（推荐 A，理由同第 3 步）、有哪几个仓、每个仓负责什么、用什么技术栈（可以不答）、字段命名用哪种、有没有已经定下来的字段和接口。
2. 按第 4 步的顺序建文件。spec 只建 INDEX.md 和用户给出了内容的主题文件；没有内容的主题只在 INDEX.md 里列出来，不建空文件。台账只留表头。
3. 子仓目录不存在就新建，里面只放 CLAUDE.md，不建业务代码的脚手架。A 方案建在总管目录下面，B 方案建在 `../`。
4. 细则只在用户给了规矩时才建。没有的话，子仓 CLAUDE.md 的「细则」表删掉，只留一句：「规则多到 CLAUDE.md 放不下时，拆进 `.agents/rules/<主题>.md`，在这里加一张「主题 / 路径 / 什么时候读」的表。」

## 第 6 步：复查和交付

1. 对照 [reference/audit.md](reference/audit.md) 再查一遍，这次每项都应该是 ✅。没过的修好，修不了的说明原因。
2. 向用户交付：
   - 新建、修改、移动了哪些文件，按仓分组（每个 git 仓要分开提交）
   - 每个 CLAUDE.md 的行数
   - spec 里还有哪些「待补」
   - 台账登记了哪些任务，开了哪些任务单
3. 最后告诉用户怎么用：
   - 在总管目录开一个 Claude Code 当包工头，只拆需求、派活、登记台账、改 spec
   - 在每个子仓目录各开一个，负责写代码，做完改台账
   - 子仓会话的启动命令：
     - A 方案：`claude --add-dir ../spec ../plan ../joint-tasks ../.agents`（不加也能用，只是读写这几个目录会弹权限确认）
     - B 方案：`CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1 claude --add-dir ../<总管目录>`，**两样缺一不可**，只加 `--add-dir` 读不到总管规则，而且不报错
   - 改动还没提交，让用户看过以后按仓分别提交
