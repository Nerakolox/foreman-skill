<!-- foreman 模板：AGENTS.md，放在每个 CLAUDE.md 的同一目录（总管、每个子仓；单仓就是仓根）。给 Codex、Cursor、Gemini CLI 这些读 AGENTS.md 的工具指路，规则本身只写在 CLAUDE.md。<总管 CLAUDE.md> 写子仓到总管 CLAUDE.md 的相对路径（A 方案一般是 `../CLAUDE.md`，monorepo 按层级，B 方案是 `../<总管目录>/CLAUDE.md`）；总管目录和单仓删掉第一条。生成时删掉这条注释。 -->
# AGENTS.md

本目录的规则全文在同目录的 `CLAUDE.md`，以那份为准。开工前先完整读一遍：

@CLAUDE.md

Claude Code 会自动读 CLAUDE.md，用不上这份文件。用其他 AI 工具时注意：

- 先读总管的 `<总管 CLAUDE.md>`，再读本目录的 `CLAUDE.md`。两份冲突时，按 CLAUDE.md「谁说了算」一节判。
- CLAUDE.md「细则」表里的文件不会自动加载，到了表里写的时机再去读。
