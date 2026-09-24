---
name: audit
description: 给项目的 AI 工程做只读体检：CLAUDE.md 是否超过 200 行，有没有用 @ 把细则整份引进来，子仓有没有划边界，前后端的字段、接口、错误码对不对得上，有没有任务台账，子仓会话读不读得到总管规则，根目录有没有堆杂文档，CLAUDE.md 里的路径有没有失效。用户想检查 CLAUDE.md、AGENTS.md、规则文件写得好不好，或者想知道 AI 为什么总是瞎编字段、越界改仓时使用。
argument-hint: "[总管目录，不填就是当前目录]"
allowed-tools: Read Grep Glob Bash(git status *) Bash(git ls-files *) Bash(git -C * status *) Bash(git -C * ls-files *)
---

# foreman：体检

项目的总管目录：$ARGUMENTS（为空就用当前工作目录）。

这是只读体检：不新建、不修改、不移动任何文件，报告也只在对话里输出，不写成文件。

1. 读 `${CLAUDE_SKILL_DIR}/../setup/reference/architecture.md`，这是评判标准。
2. 按 `${CLAUDE_SKILL_DIR}/../setup/reference/audit.md` 逐项检查，按里面的格式出报告。总管和子仓平级（B 方案）时，子仓在工作目录外面，读不到就停下来，让用户用 `claude --add-dir ../<子仓> ../<子仓>` 重启再查，不要只查总管就出报告。查别的仓的 git 状态用 `git -C <仓> status --short`，一个仓单独调用一次，不要用 `cd`、`&&`、`;`、`for` 循环串起来，串起来的命令要用户逐条批准。
3. 报告末尾告诉用户：要按报告改造，运行 `/foreman:setup`。
