# 接口草稿（v0）

> 早期草稿，部分已经改了，以后端实现为准。

## 修改用户资料

POST /api/v1/user/update

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| userName | string | 用户名 |
| avatar | string | 头像 |
| bio | string | 简介 |

## 帖子列表

GET /api/v1/posts

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | int | 帖子 ID |
| title | string | 标题 |
| content | string | 内容 |
| authorId | int | 作者 |
| likes | int | 点赞数 |
