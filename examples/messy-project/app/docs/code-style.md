# app 代码风格

- 缩进 2 空格，单引号，不写分号
- 组件用函数组件加 hooks
- 文件名：组件用 PascalCase，其他用 camelCase
- import 顺序：react → 第三方 → 项目内绝对路径 → 相对路径
- 类型定义放在同目录的 types.ts，跨模块共用的放 src/types
- 不用 any；实在要用写 // eslint-disable-next-line 并说明原因
- 异步统一 async/await，不用 .then 链
- 常量全大写下划线
- 布尔变量以 is、has、can 开头
- 事件处理函数以 handle 开头，props 里的回调以 on 开头
