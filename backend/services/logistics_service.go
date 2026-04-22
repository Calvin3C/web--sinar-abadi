package services

import (
	"errors"
	"strings"

	"sinar-abadi-backend/models"
)

// LogisticsService handles shipping logic
type LogisticsService struct{}

func NewLogisticsService() *LogisticsService {
	return &LogisticsService{}
}

// CalculateShippingCost calculates the shipping cost based on the method, destination, and items.
func (s *LogisticsService) CalculateShippingCost(method string, destination string, items []models.OrderItem) (int64, error) {
	methodLower := strings.ToLower(method)

	// 1. Ambil di Toko
	if strings.Contains(methodLower, "ambil di toko") {
		return 0, nil
	}

	// 2. Kurir Toko Sinar Abadi (Khusus area Malang)
	if strings.Contains(methodLower, "kurir toko") {
		if !strings.Contains(strings.ToLower(destination), "malang") {
			return 0, errors.New("pengiriman kurir toko hanya berlaku untuk area Malang")
		}
		// Based on business logic, let's return a flat rate for Malang or 0.
		// Set default flat rate for Kurir Toko: Rp 50.000
		return 50000, nil
	}

	// 3. Ekspedisi JNE (Khusus Hardware/Plumbing, usually implies lightweight)
	if strings.Contains(methodLower, "jne") {
		// In a real application, you might check product models to ensure category matches.
		// For this example, we assume items have been verified or we set a flat rate for JNE per item/kg.
		// Flat rate JNE simulation: Rp 20.000 + (Rp 5.000 * Total Qty)
		totalQty := 0
		for _, item := range items {
			totalQty += item.Qty
		}
		cost := int64(20000 + (totalQty * 5000))
		return cost, nil
	}

	return 0, errors.New("metode pengiriman tidak valid")
}
