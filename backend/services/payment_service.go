package services

import (
	"fmt"
	"math/rand"
	"strings"
	"time"
)

type PaymentService struct{}

func NewPaymentService() *PaymentService {
	return &PaymentService{}
}

// InitiatePayment simulates initiating a payment process with a provider.
func (s *PaymentService) InitiatePayment(orderID string, method string, amount int64) (string, error) {
	// Dummy logic for generating Virtual Account or Payment Token
	methodLower := strings.ToLower(method)
	
	if strings.Contains(methodLower, "virtual account") || strings.Contains(methodLower, "va") {
		// Generate random VA number using new random generator
		rng := rand.New(rand.NewSource(time.Now().UnixNano()))
		vaNumber := fmt.Sprintf("88000%d", rng.Intn(90000000)+10000000)
		return vaNumber, nil
	}

	if strings.Contains(methodLower, "credit") {
		// Token or redirect URL for credit card
		return "CC-TOKEN-MOCK-FOR-" + orderID, nil
	}

	return "", fmt.Errorf("metode pembayaran %s belum didukung", method)
}
