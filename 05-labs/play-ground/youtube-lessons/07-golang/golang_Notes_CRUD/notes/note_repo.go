// notes/note_repo.go
package notes

import (
	"context"
	"fmt"
	"time"
	
	"go.mongodb.org/mongo-driver/bson"          // ✅ Use v1 bson (not v2)
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Repo struct {
	collection *mongo.Collection  // Renamed from "call" for clarity
}

func NewRepo(db *mongo.Database) *Repo {
	return &Repo{
		collection: db.Collection("notes"),
	}
}

func (r *Repo) Create(ctx context.Context, note *Note) (Note, error) {
	opCtx, cancel := context.WithTimeout(ctx, 5*time.Second)  // ✅ Added *
	defer cancel()
	
	_, err := r.collection.InsertOne(opCtx, note)
	if err != nil {
		return Note{}, fmt.Errorf("insert note failed: %w", err)
	}
	return *note, nil
}

func (r *Repo) ListNotes(ctx context.Context) ([]Note, error) {
	opCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	
	filter := bson.M{}  // ✅ No spaces
	cursor, err := r.collection.Find(opCtx, filter)
	if err != nil {
		return nil, fmt.Errorf("find notes failed: %w", err)
	}
	defer cursor.Close(opCtx)
	
	var notes []Note
	if err = cursor.All(opCtx, &notes); err != nil {
		return nil, fmt.Errorf("decode notes failed: %w", err)
	}
	return notes, nil
}

func (r *Repo) GetByID(ctx context.Context, id primitive.ObjectID) (Note, error) {
	opCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	
	filter := bson.M{"_id": id}  // ✅ No spaces
	var note Note
	err := r.collection.FindOne(opCtx, filter).Decode(&note)
	if err != nil {
		return Note{}, fmt.Errorf("find note failed: %w", err)
	}
	return note, nil
}

func (r *Repo) UpdateByID(ctx context.Context, id primitive.ObjectID, req UpdateNoteRequest) (Note, error) {
	opCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	
	// ✅ Build update document with NO SPACES in keys
	update := bson.M{}
	setOps := bson.M{}
	
	if req.Title != nil {
		setOps["title"] = *req.Title
	}
	if req.Content != nil {
		setOps["content"] = *req.Content
	}
	if req.Pinned != nil {
		setOps["pinned"] = *req.Pinned
	}
	setOps["updated_at"] = time.Now().UTC()
	
	if len(setOps) > 0 {
		update["$set"] = setOps
	}
	
	opts := options.FindOneAndUpdate().SetReturnDocument(options.After)
	
	var updated Note
	err := r.collection.FindOneAndUpdate(
		opCtx,
		bson.M{"_id": id},  // ✅ No spaces
		update,
		opts,
	).Decode(&updated)
	
	if err != nil {
		return Note{}, fmt.Errorf("update note failed: %w", err)
	}
	return updated, nil
}