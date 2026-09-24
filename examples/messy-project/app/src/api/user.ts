import { request } from './client'

export interface User {
  id: number
  userName: string
  avatar: string
  bio: string
  createdAt: string
}

export function getMe() {
  return request<User>('/users/me')
}

export function updateProfile(input: { userName: string; avatar: string; bio: string }) {
  return request<User>('/user/update', {
    method: 'POST',
    body: JSON.stringify(input),
  })
}
