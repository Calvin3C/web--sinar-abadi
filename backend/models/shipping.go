package models

import "time"

// Shipping represents the logistics details for an order.
type Shipping struct {
	ID                 uint      `gorm:"primaryKey" json:"id"`
	OrderID            string    `gorm:"size:30;not null;uniqueIndex" json:"orderId"`
	ShippingMethodID   uint      `json:"shippingMethodId"`
	ShippingMethodName string    `gorm:"size:100;not null" json:"shippingMethodName"` // Ambil di Toko, Kurir Toko Sinar Abadi, Ekspedisi JNE
	TrackingNumber     string    `gorm:"size:30" json:"trackingNumber"`               // Used for WhatsApp number
	ShippingCost       int64     `gorm:"not null;default:0" json:"shippingCost"`
	DestinationAddress string    `gorm:"type:text;not null" json:"destinationAddress"`
	CreatedAt          time.Time `json:"createdAt"`
	UpdatedAt          time.Time `json:"updatedAt"`
}
