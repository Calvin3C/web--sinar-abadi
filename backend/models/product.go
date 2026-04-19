package models

import "time"

// Product represents a building material item in the catalog.
type Product struct {
	ID        string    `gorm:"primaryKey;size:20" json:"id"`   // e.g. "P-001"
	Category  string    `gorm:"size:100;not null" json:"category"`
	Name      string    `gorm:"size:300;not null" json:"name"`
	Price     int64     `gorm:"not null" json:"price"`          // in Rupiah (integer, no floating point)
	Stock     int       `gorm:"not null;default:0" json:"stock"`
	Sold      int       `gorm:"not null;default:0" json:"sold"` // popularity counter
	IsLarge   bool      `gorm:"default:false" json:"isLarge"`   // true = heavy/bulky → shipping restriction
	ImageURL  string    `gorm:"size:500" json:"img"`            // JSON key "img" matches frontend
	CreatedAt time.Time `json:"createdAt"`
	UpdatedAt time.Time `json:"updatedAt"`
}
