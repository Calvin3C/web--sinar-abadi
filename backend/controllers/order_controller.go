package controllers

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
)

// ---- Request DTOs ----

// CheckoutItemInput represents a single item in the checkout request.
type CheckoutItemInput struct {
	ProductID string `json:"productId" binding:"required"`
	Name      string `json:"name" binding:"required"`
	Qty       int    `json:"qty" binding:"required"`
	Price     int64  `json:"price" binding:"required"`
}

// CheckoutInput represents the full checkout request body.
type CheckoutInput struct {
	Phone          string              `json:"phone" binding:"required"`
	Address        string              `json:"address" binding:"required"`
	ShippingMethod string              `json:"shippingMethod" binding:"required"`
	Items          []CheckoutItemInput `json:"items" binding:"required,min=1"`
	Total          int64               `json:"total" binding:"required"`
}

// StatusUpdateInput represents the request body for updating order status.
type StatusUpdateInput struct {
	Status         string `json:"status"`         // pending | success | refund | cancelled
	ShippingStatus string `json:"shippingStatus"` // shipping status label
}

// ProofUploadInput represents the request body for marking proof as uploaded.
type ProofUploadInput struct {
	ProofUploaded bool `json:"proofUploaded"`
}

// ---- Helpers ----

// generateOrderID creates an order ID in the format ORD-YYMMDD-XXX.
func generateOrderID() string {
	now := time.Now()
	return fmt.Sprintf("ORD-%s%s%s-%03d",
		fmt.Sprintf("%02d", now.Year()%100),
		fmt.Sprintf("%02d", int(now.Month())),
		fmt.Sprintf("%02d", now.Day()),
		rand.Intn(900)+100,
	)
}

// ---- Handlers ----

// CreateOrder handles customer checkout.
// POST /api/orders
func CreateOrder(c *gin.Context) {
	var input CheckoutInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data checkout tidak lengkap: " + err.Error()})
		return
	}

	// Get the authenticated user ID and username from JWT context
	userID, _ := c.Get("userId")
	username, _ := c.Get("username")

	// Validate stock availability and decrement
	tx := config.DB.Begin()
	for _, item := range input.Items {
		var product models.Product
		if result := tx.Where("id = ?", item.ProductID).First(&product); result.Error != nil {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Produk %s tidak ditemukan", item.ProductID)})
			return
		}
		if product.Stock < item.Qty {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Stok %s tidak mencukupi (tersisa %d)", product.Name, product.Stock)})
			return
		}
		// Decrease stock and increase sold count
		tx.Model(&product).Updates(map[string]interface{}{
			"stock": product.Stock - item.Qty,
			"sold":  product.Sold + item.Qty,
		})
	}

	// Build order items
	var orderItems []models.OrderItem
	for _, item := range input.Items {
		orderItems = append(orderItems, models.OrderItem{
			ProductID: item.ProductID,
			Name:      item.Name,
			Qty:       item.Qty,
			Price:     item.Price,
		})
	}

	order := models.Order{
		ID:             generateOrderID(),
		Date:           time.Now().Format("2006-01-02"),
		CustomerID:     userID.(uint),
		CustomerName:   username.(string),
		Phone:          input.Phone,
		Address:        input.Address,
		ShippingMethod: input.ShippingMethod,
		Total:          input.Total,
		Status:         "pending",
		ShippingStatus: "Menunggu Validasi",
		ProofUploaded:  false,
		Items:          orderItems,
	}

	if result := tx.Create(&order); result.Error != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat pesanan"})
		return
	}

	tx.Commit()

	// Reload with items for response
	config.DB.Preload("Items").First(&order, "id = ?", order.ID)

	c.JSON(http.StatusCreated, order)
}

// GetOrders returns orders based on the user's role.
// - Customer: only their own orders
// - Admin/Owner: all orders (with optional status filter)
// GET /api/orders?status=pending|success|refund|cancelled
func GetOrders(c *gin.Context) {
	role, _ := c.Get("role")
	userID, _ := c.Get("userId")

	var orders []models.Order
	query := config.DB.Preload("Items").Order("created_at DESC")

	// Customers only see their own orders
	if role.(string) == "customer" {
		query = query.Where("customer_id = ?", userID.(uint))
	}

	// Optional status filter (for Admin/Owner dashboard)
	if statusFilter := c.Query("status"); statusFilter != "" && statusFilter != "all" {
		query = query.Where("status = ?", statusFilter)
	}

	if result := query.Find(&orders); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pesanan"})
		return
	}

	c.JSON(http.StatusOK, orders)
}

// GetOrderByID retrieves a single order by its ID for tracking.
// GET /api/orders/:id
func GetOrderByID(c *gin.Context) {
	orderID := c.Param("id")

	var order models.Order
	if result := config.DB.Preload("Items").Where("id = ?", orderID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	// If the requester is a customer, ensure they can only view their own orders
	role, _ := c.Get("role")
	userID, _ := c.Get("userId")
	if role.(string) == "customer" && order.CustomerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki akses ke pesanan ini"})
		return
	}

	c.JSON(http.StatusOK, order)
}

// UpdateOrderStatus handles payment validation (Admin) and shipping status updates (Owner).
// PUT /api/orders/:id/status
func UpdateOrderStatus(c *gin.Context) {
	orderID := c.Param("id")

	var input StatusUpdateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Data status tidak valid"})
		return
	}

	var order models.Order
	if result := config.DB.Where("id = ?", orderID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	updates := map[string]interface{}{}
	if input.Status != "" {
		updates["status"] = input.Status
	}
	if input.ShippingStatus != "" {
		updates["shipping_status"] = input.ShippingStatus
	}

	if len(updates) == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak ada perubahan yang dikirim"})
		return
	}

	config.DB.Model(&order).Updates(updates)

	// Reload for response
	config.DB.Preload("Items").First(&order, "id = ?", order.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "Status pesanan berhasil diperbarui",
		"order":   order,
	})
}

// UploadProof marks the proof of payment as uploaded.
// PUT /api/orders/:id/proof
func UploadProof(c *gin.Context) {
	orderID := c.Param("id")

	var order models.Order
	if result := config.DB.Where("id = ?", orderID).First(&order); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pesanan tidak ditemukan"})
		return
	}

	// Verify ownership if customer
	role, _ := c.Get("role")
	userID, _ := c.Get("userId")
	if role.(string) == "customer" && order.CustomerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Anda tidak memiliki akses ke pesanan ini"})
		return
	}

	config.DB.Model(&order).Update("proof_uploaded", true)

	c.JSON(http.StatusOK, gin.H{
		"message": "Bukti pembayaran berhasil diunggah",
	})
}
