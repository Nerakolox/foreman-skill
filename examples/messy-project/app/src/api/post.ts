import { request } from './client'

export interface Post {
  id: number
  title: string
  content: string
  authorId: number
  likeCount: number
  createdAt: string
}

export function listPosts(page = 1, pageSize = 20) {
  return request<{ list: Post[]; total: number }>(`/posts?page=${page}&page_size=${pageSize}`)
}

export function createPost(input: { title: string; content: string }) {
  return request<Post>('/posts', {
    method: 'POST',
    body: JSON.stringify(input),
  })
}
