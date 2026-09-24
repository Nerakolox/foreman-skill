import camelcaseKeys from 'camelcase-keys'

export const BASE_URL = 'https://api.example.com/api/v1'

let token: string | null = null

export function setToken(value: string | null) {
  token = value
}

export async function request<T>(path: string, init: RequestInit = {}): Promise<T> {
  const res = await fetch(BASE_URL + path, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...init.headers,
    },
  })
  const body = await res.json()
  // 后端返回 snake_case，这里统一转成 camelCase。请求体不转，调用方自己按后端字段写
  const { code, message, data } = camelcaseKeys(body, { deep: true })
  if (code !== 0) {
    throw new ApiError(code, message)
  }
  return data as T
}

export class ApiError extends Error {
  constructor(public code: number, message: string) {
    super(message)
  }
}
