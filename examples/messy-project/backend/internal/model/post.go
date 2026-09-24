package model

import "time"

type Post struct {
	ID        int64     `json:"id"`
	Title     string    `json:"title"`
	Content   string    `json:"content"`
	AuthorID  int64     `json:"author_id"`
	LikeCount int64     `json:"like_count"`
	CreatedAt time.Time `json:"created_at"`
}
