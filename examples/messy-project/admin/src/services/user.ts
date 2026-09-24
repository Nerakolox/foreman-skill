import { request } from '@umijs/max'

export interface AdminUser {
  id: number
  user_name: string
  avatar: string
  created_at: string
  banned: boolean
}

export function listUsers(params: { page: number; page_size: number; keyword?: string }) {
  return request<{ list: AdminUser[]; total: number }>('/api/v1/admin/users', { params })
}

export function banUser(id: number) {
  return request(`/api/v1/admin/users/${id}/ban`, { method: 'POST' })
}
