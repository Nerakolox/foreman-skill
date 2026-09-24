import { ApiError } from './client'

export const ERR_UNAUTHORIZED = 401001
// 后端实际返回 40101，临时兼容，见根目录 investigation-login-kickout.md
export const ERR_UNAUTHORIZED_COMPAT = 40101

export function isUnauthorized(err: unknown) {
  return (
    err instanceof ApiError &&
    (err.code === ERR_UNAUTHORIZED || err.code === ERR_UNAUTHORIZED_COMPAT)
  )
}
