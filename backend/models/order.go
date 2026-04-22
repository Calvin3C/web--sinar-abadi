package models

import "time"

// Order represents a customer purchase transaction.
type Order struct {
	ID             string      `gorm:"primaryKey;size:30" json:"id"` // e.g. "ORD-260401-081"
	Date           string      `gorm:"size:20;not null" json:"date"` // "YYYY-MM-DD"
	CustomerID     uint        `gorm:"not null" json:"customerId"`
	Customer       User        `gorm:"foreignKey:CustomerID" json:"-"`
	CustomerName   string      `gorm:"size:200" json:"customer"`     // denormalized username for quick lookups
	Phone          string      `gorm:"size:30" json:"phone"`
	Address        string      `gorm:"type:text" json:"address"`
	ShippingMethod string      `gorm:"size:100" json:"shippingMethod"`
	Total          int64       `gorm:"not null" json:"total"`
	Status         string      `gorm:"size:20;not null;default:'pending'" json:"status"`          // pending | success | refund | cancelled
	ShippingStatus string      `gorm:"size:100;not null;default:'Menunggu Validasi'" json:"shippingStatus"`
	ProofUploaded  bool        `gorm:"default:false" json:"proofUploaded"`
	Items          []OrderItem `gorm:"foreignKey:OrderID" json:"items"`
	Shipping       *Shipping   `gorm:"foreignKey:OrderID" json:"shipping"`
	Payment        *Payment    `gorm:"foreignKey:OrderID" json:"payment"`
	CreatedAt      time.Time   `json:"createdAt"`
	UpdatedAt      time.Time   `json:"updatedAt"`
}

// OrderItem represents a single line item within an order.
type OrderItem struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	OrderID   string `gorm:"size:30;not null;index" json:"orderId"`
	ProductID string `gorm:"size:20" json:"productId"`
	Name      string `gorm:"size:300;not null" json:"name"`  // snapshot of product name at purchase time
	Qty       int    `gorm:"not null" json:"qty"`
	Price     int64  `gorm:"not null" json:"price"`           // price per unit at time of purchase
}
