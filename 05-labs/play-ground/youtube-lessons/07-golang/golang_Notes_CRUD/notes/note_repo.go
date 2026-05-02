// Repo is the data access layer
package notes

import (
	"context"
	"fmt"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
)


type Repo struct{
	call *mongo.Collection
}

func NewRepo(db *mongo.Database) *Repo {
	return &Repo{
		call: db.Collection("notes"),
	}
}

// C.R.U.D Functions
func (r *Repo) Create(ctx context.Context, note *Note) (Note, error){
	opCtx, cancel := context.WithTimeout(ctx, 5 *time.Second)
	defer cancel()
	
	_, err := r.call.InsertOne(opCtx, note)
	if err != nil {
		return Note{}, fmt.Errorf("Insert note failed: %w", err)
	}
	return *note, nil
}