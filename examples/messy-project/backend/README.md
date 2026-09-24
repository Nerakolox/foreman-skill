# backend

示例社区的后端服务，Go 1.22 + Gin，接口前缀 `/api/v1`。

## 本地运行

```bash
go run ./cmd/server
```

## 测试

```bash
go test ./...
```

## 目录

- `internal/handler/`：路由和参数校验
- `internal/model/`：数据模型
- `pkg/errs/`：错误码

部署见 `docs/deploy.md`。
