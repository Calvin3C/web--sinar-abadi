package models

// PaymentMethod represents an available payment option (Virtual Account, Credit Card, etc).
type PaymentMethod struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	Name        string `gorm:"size:100;not null" json:"name"`
	Description string `gorm:"type:text" json:"description"`
}
