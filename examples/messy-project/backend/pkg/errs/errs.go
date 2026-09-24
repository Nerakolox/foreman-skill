package errs

type Error struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (e *Error) Error() string { return e.Message }

var (
	ErrBadRequest   = &Error{40001, "参数错误"}
	ErrUnauthorized = &Error{40101, "未登录或登录已过期"}
	ErrForbidden    = &Error{40301, "没有权限"}
	ErrNotFound     = &Error{40401, "资源不存在"}
	ErrPostTooLong  = &Error{40002, "帖子内容超过 5000 字"}
	ErrInternal     = &Error{50001, "服务器错误"}
)
