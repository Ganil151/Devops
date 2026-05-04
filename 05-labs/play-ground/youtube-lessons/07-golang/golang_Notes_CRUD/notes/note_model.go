// notes/note_model.go
package notes

import (
	"time"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Note struct {
	ID        primitive.ObjectID `bson:"_id,omitempty" json:"id"`
	Title     string             `bson:"title" json:"title" binding:"required"`
	Content   string             `bson:"content" json:"content" binding:"required"`
	Pinned    bool               `bson:"pinned" json:"pinned"`
	CreatedAt time.Time          `bson:"created_at" json:"createdAt"`
	UpdatedAt time.Time          `bson:"updated_at" json:"updatedAt"`
}

type CreateNoteRequest struct {
	Title   string `json:"title" binding:"required"`
	Content string `json:"content" binding:"required"`
	Pinned  bool   `json:"pinned"`
}

type UpdateNoteRequest struct {
	Title   *string `json:"title"`   // Pointer = optional
	Content *string `json:"content"` // Pointer = optional
	Pinned  *bool   `json:"pinned"`  // Pointer = optional
}