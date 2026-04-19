package models

import "time"

// User represents a system user (customer, admin, or owner).
type User struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Username  string    `gorm:"uniqueIndex;size:100;not null" json:"username"`
	Password  string    `gorm:"not null" json:"-"`                               // never exposed in JSON responses
	Role      string    `gorm:"size:20;not null;default:'customer'" json:"role"` // customer | admin | owner
	Name      string    `gorm:"size:200;not null" json:"name"`
	IsBlocked bool      `gorm:"default:false" json:"isBlocked"`
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
