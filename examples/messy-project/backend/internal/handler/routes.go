package handler

import (
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine, h *Handler) {
	v1 := r.Group("/api/v1")

	v1.POST("/auth/login", h.Login)

	auth := v1.Group("", h.RequireAuth)
	auth.GET("/users/me", h.GetMe)
	auth.PATCH("/users/:id", h.UpdateProfile)

	auth.GET("/posts", h.ListPosts)
	auth.POST("/posts", h.CreatePost)
	auth.DELETE("/posts/:id", h.DeletePost)
	auth.POST("/posts/:id/like", h.LikePost)
	auth.DELETE("/posts/:id/like", h.UnlikePost)

	admin := auth.Group("/admin", h.RequireAdmin)
	admin.GET("/users", h.AdminListUsers)
	admin.POST("/users/:id/ban", h.AdminBanUser)
}
