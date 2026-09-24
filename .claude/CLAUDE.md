# foreman 仓库

Claude Code 插件 foreman 的源码。和用户交流、写文档都用中文。

## 结构

- `.claude-plugin/`：`plugin.json` 是插件信息，`marketplace.json` 是上架清单（市场名 `404-cyber-store`，插件源就是仓库根目录）
- `skills/setup/`：`/foreman:setup`，搭工程的主流程。`reference/architecture.md` 是整套结构的定义，`reference/audit.md` 是体检清单，`templates/` 是生成文件用的模板
- `skills/audit/`：`/foreman:audit`，只读体检，复用 `setup/reference/` 下的两份文件
- `examples/messy-project/`：虚构的四仓示例项目，故意埋了各种问题，用来实测；`examples/make-demo.sh` 把它生成成 A 或 B 摆法的多 git 仓演示项目

## 约定

- 规则的内容以第 1 期口播稿为准，不自己加新规矩。关于 Claude Code 行为的说法，要能在官方文档 <https://code.claude.com/docs/en/memory> 和 <https://code.claude.com/docs/en/skills> 里找到出处
- `SKILL.md` 不超过 500 行。长内容放进 `reference/` 或 `templates/`，在 SKILL.md 里写明什么时候读
- `examples/messy-project/` 是「改造前」的样子，不要修它里面的问题。要加新的坑，同步更新 README 里的说明
- 改了 skill 以后，先跑 `claude plugin validate .`，再拿示例项目的副本实测（见下）
- 发版时改 `.claude-plugin/plugin.json` 的 `version`，不改的话已安装的用户收不到更新

## 实测

用 `examples/make-demo.sh` 在仓库外面生成演示项目（四个子仓各自是 git 仓），再用 `--plugin-dir` 加载本地插件：

```bash
bash examples/make-demo.sh /tmp/demo-a --hub-git
cd /tmp/demo-a && claude --plugin-dir <本仓库的绝对路径>

bash examples/make-demo.sh /tmp/demo-b --flat
cd /tmp/demo-b/hub && claude --plugin-dir <本仓库的绝对路径> --add-dir ../app ../backend ../admin ../web
```

然后运行 `/foreman:audit` 或 `/foreman:setup`。A、B 两种摆法改了相关逻辑都要各跑一遍。
