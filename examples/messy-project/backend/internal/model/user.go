package model

import "time"

type User struct {
	ID        int64      `json:"id"`
	Username  string     `json:"username"`
	Avatar    string     `json:"avatar"`
	Bio       string     `json:"bio"`
	Password  string     `json:"-"`
	CreatedAt time.Time  `json:"created_at"`
	DeletedAt *time.Time `json:"-"`
}

type UpdateProfileInput struct {
	Username *string `json:"username" binding:"omitempty,min=2,max=20"`
	Avatar   *string `json:"avatar" binding:"omitempty,url"`
	Bio      *string `json:"bio" binding:"omitempty,max=200"`
}
