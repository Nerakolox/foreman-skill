# 项目说明

这是我们的项目，包含 app、backend、admin、web 四个部分。请遵守下面的所有规则。

@app/docs/code-style.md

## 技术栈

- app：React Native + TypeScript
- backend：Go 1.22 + Gin + PostgreSQL
- admin：React + TypeScript + Ant Design
- web：纯静态页面

## 通用规则

- 回答用中文
- 修改代码前先理解上下文
- 不要引入新的依赖，除非必要
- 保持代码整洁
- 写完代码要自测
- 遇到不确定的地方要问
- 不要删除别人的代码
- 注释用中文
- 变量名要有意义
- 函数不要太长
- 提交前跑一遍 lint
- 不要提交 console.log
- 不要提交调试代码
- 不要硬编码密钥

## app 规则

- 组件用函数组件，不用 class 组件
- 状态管理用 zustand
- 样式用 StyleSheet.create，不要写内联样式
- 列表用 FlatList，不要用 ScrollView 包 map
- 图片用 FastImage
- 网络请求统一走 src/api/client.ts
- 页面文件放在 src/screens，组件放在 src/components
- 一个组件文件不超过 300 行
- props 要写类型
- 不要用 any
- 颜色统一从 src/theme/colors.ts 取
- 字号统一从 src/theme/typography.ts 取
- 导航用 react-navigation v6
- 页面组件名以 Screen 结尾
- hooks 放在 src/hooks，以 use 开头
- 表单用 react-hook-form
- 日期用 dayjs
- 不要在组件里直接调 fetch
- 错误提示统一用 Toast
- 加载状态统一用 Loading 组件
- 空状态统一用 Empty 组件
- 安卓返回键要处理
- 适配刘海屏用 SafeAreaView
- 键盘遮挡用 KeyboardAvoidingView
- 长列表要做分页
- 下拉刷新用 RefreshControl
- 图片要有占位图
- 按钮要防重复点击
- 输入框要限制长度
- 金额展示保留两位小数

## backend 规则

- 分层：handler → service → repository
- handler 只做参数校验和返回
- 业务逻辑写在 service
- 数据库操作写在 repository
- 错误统一用 pkg/errs 包装
- 日志用 zap
- 配置用 viper，放在 config/
- 数据库迁移用 golang-migrate，放在 migrations/
- 所有接口都要有鉴权，白名单除外
- 分页参数统一 page、page_size
- 时间统一用 UTC 存储
- 金额用分存储，int64
- 软删除用 deleted_at
- 不要在循环里查数据库
- 事务写在 service 层
- 单元测试覆盖 service 层
- 接口响应统一格式 {code, message, data}
- 敏感字段不要打日志
- 密码用 bcrypt
- JWT 过期时间 2 小时
- refresh token 过期时间 7 天
- 上传文件限制 10MB
- 限流用 redis

## admin 规则

- 用 Ant Design 的组件，不要自己造轮子
- 表格用 ProTable
- 表单用 ProForm
- 权限控制用 access.ts
- 路由配置在 config/routes.ts
- 请求用 umi-request
- 列表页要有搜索、分页、导出

## web 规则

- 纯静态，不要引入框架
- 图片要压缩
- 要做 SEO
- 要适配移动端

## 接口说明

### 通用

- 基础路径：/api/v1
- 请求头：Authorization: Bearer <token>
- 响应格式：

```json
{ "code": 0, "message": "ok", "data": {} }
```

### 错误码

| code | 含义 |
| --- | --- |
| 0 | 成功 |
| 40001 | 参数错误 |
| 40101 | 未登录或 token 过期 |
| 40301 | 没有权限 |
| 40401 | 资源不存在 |
| 50001 | 服务器错误 |

### 用户

#### 获取当前用户

GET /api/v1/users/me

返回：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int | 用户 ID |
| username | string | 用户名 |
| avatar | string | 头像 URL |
| bio | string | 简介 |
| created_at | string | 注册时间 |

#### 修改用户资料

PATCH /api/v1/users/:id

参数：username、avatar、bio

### 帖子

#### 帖子列表

GET /api/v1/posts?page=1&page_size=20

返回：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int | 帖子 ID |
| title | string | 标题 |
| content | string | 内容 |
| author_id | int | 作者 ID |
| like_count | int | 点赞数 |
| created_at | string | 发布时间 |

#### 发帖

POST /api/v1/posts

参数：title、content

#### 删除帖子

DELETE /api/v1/posts/:id

## Git 规范

- 分支：main、develop、feature/*、fix/*
- 提交信息格式：type(scope): subject
- type 有 feat、fix、docs、style、refactor、test、chore
- 一个提交只做一件事
- 合并用 squash
- 不要直接推 main
- PR 要有描述
- PR 要至少一人 review

## 部署

部署流程见 docs/deploy.md。

- 测试环境：推 develop 自动部署
- 生产环境：打 tag 手动部署
- 部署前要跑完整测试
- 数据库迁移要先在测试环境跑
- 部署后要看监控

## 其他

- 调研记录写在根目录的 notes.md
- 排查问题的记录写在根目录，文件名 investigation-xxx.md
- 接口草稿写在 api-draft.md
- 有问题先看 notes.md
- 不确定的需求问产品
- 不确定的设计问设计
- 不确定的接口问后端
