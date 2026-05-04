package notes

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type Handler struct{
	repo *Repo
}

func NewHandler(repo *Repo) *Handler {
	return &Handler{
		repo: repo,
	}
}

func (h *Handler) CreateNote(c *gin.Context) {
	var req CreateNoteRequest
	if err := c.ShouldBindBodyWithJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body: " + err.Error()})
		return
	}
	// Time Note Created
	now := time.Now().UTC()

	// Take the note from the request
	note := Note{
		ID: primitive.NewObjectID(),
		Title: req.Title,
		Content: req.Content,
		Pinned: req.Pinned,
		CreatedAt: now,
		UpdatedAt: now,
	}

	created, err := h.repo.Create(c.Request.Context(), &note)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create note: " + err.Error()})
		return
	}
	c.JSON(http.StatusCreated, created)
}

// ListNotes handles the HTTP request to list all notes --> then pass through note_routes
func (h *Handler) ListNotes(c *gin.Context) {
	notes, err := h.repo.ListNotes(c.Request.Context())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to list notes: " + err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"notes": notes})
}

// notes/note_handler.go (relevant sections)
func (h *Handler) GetNoteByID(c *gin.Context) {
	idStr := c.Param("id")  // ✅ No spaces
	
	objID, err := primitive.ObjectIDFromHex(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid note ID format",
			"hint":  "ID must be 24 hex characters",
		})
		return
	}
	
	note, err := h.repo.GetByID(c.Request.Context(), objID)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "note not found"})
			return
		}
		// 📝 Log the actual error for debugging
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to retrieve note",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"note": note})
}

func (h *Handler) UpdateNoteByID(c *gin.Context) {
	idStr := c.Param("id")  // ✅ No spaces
	
	objID, err := primitive.ObjectIDFromHex(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid note ID format",
			"hint":  "ID must be 24 hex characters",
		})
		return
	}
	
	var req UpdateNoteRequest
	if err := c.ShouldBindJSON(&req); err != nil {  // ✅ ShouldBindJSON is simpler than ShouldBindBodyWithJSON
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid request payload",
			"details": err.Error(),
		})
		return
	}
	
	updated, err := h.repo.UpdateByID(c.Request.Context(), objID, req)
	if err != nil {
		if err == mongo.ErrNoDocuments {
			c.JSON(http.StatusNotFound, gin.H{"error": "note not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to update note",
		})
		return
	}
	c.JSON(http.StatusOK, gin.H{"note": updated})
}