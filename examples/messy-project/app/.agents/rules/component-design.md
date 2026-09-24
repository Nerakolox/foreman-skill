# 组件设计

- 页面组件（Screen）只负责组装和取数据，不写复杂 UI
- 超过 150 行的组件要拆
- 拆分顺序：先拆纯展示组件，再拆带状态的
- 纯展示组件不直接读 store，数据全部从 props 进
- 同一段 UI 出现两次以上，抽成组件放到 src/components
- 组件的样式写在同文件底部的 StyleSheet.create
- 列表项组件用 React.memo 包一层
