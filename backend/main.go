package main

import (
	"log"
	"os"
	"time"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/controllers"
	"sinar-abadi-backend/middleware"
	"sinar-abadi-backend/models"
	"sinar-abadi-backend/seed"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables
	_ = godotenv.Load()

	// Connect to PostgreSQL
	config.ConnectDatabase()

	// Auto-migrate all models
	if err := config.DB.AutoMigrate(
		&models.User{},
		&models.Product{},
		&models.Order{},
		&models.OrderItem{},
	); err != nil {
		log.Fatalf("❌ Auto-migration failed: %v", err)
	}
	log.Println("✅ Database migration completed")

	// Run seeder (only seeds if tables are empty)
	seed.RunSeeder(config.DB)

	// Initialize Gin router
	r := gin.Default()

	// CORS configuration — allow all origins for development
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}))

	// ==================================================================
	// API Routes
	// ==================================================================
	api := r.Group("/api")

	// --- Auth (Public) ---
	api.POST("/register", controllers.Register)
	api.POST("/login", controllers.Login)

	// --- Products ---
	api.GET("/products", controllers.GetProducts) // Public: list with search, filter, sort

	// Protected product routes
	productAuth := api.Group("/products")
	productAuth.Use(middleware.AuthRequired())
	{
		productAuth.POST("", middleware.RoleRequired("admin", "owner"), controllers.CreateProduct)
		productAuth.PUT("/:id/stock", middleware.RoleRequired("owner"), controllers.UpdateStock)
	}

	// --- Orders (All require auth) ---
	orderRoutes := api.Group("/orders")
	orderRoutes.Use(middleware.AuthRequired())
	{
		orderRoutes.POST("", middleware.RoleRequired("customer"), controllers.CreateOrder)
		orderRoutes.GET("", controllers.GetOrders) // role-based filtering inside handler
		orderRoutes.GET("/:id", controllers.GetOrderByID)
		orderRoutes.PUT("/:id/status", middleware.RoleRequired("admin", "owner"), controllers.UpdateOrderStatus)
		orderRoutes.PUT("/:id/proof", middleware.RoleRequired("customer"), controllers.UploadProof)
	}

	// --- Users (Admin/Owner) ---
	userRoutes := api.Group("/users")
	userRoutes.Use(middleware.AuthRequired())
	{
		userRoutes.GET("", middleware.RoleRequired("admin", "owner"), controllers.GetCustomers)
		userRoutes.PUT("/:username/block", middleware.RoleRequired("admin"), controllers.ToggleBlockUser)

		// Admin management (Owner only)
		userRoutes.GET("/admins", middleware.RoleRequired("owner"), controllers.GetAdmins)
		userRoutes.POST("/admins", middleware.RoleRequired("owner"), controllers.CreateAdmin)
		userRoutes.DELETE("/admins/:username", middleware.RoleRequired("owner"), controllers.DeleteAdmin)
	}

	// ==================================================================
	// Health check
	// ==================================================================
	api.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"service": "Sinar Abadi Backend API",
			"version": "1.0.0",
		})
	})

	// Start server
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("🚀 Sinar Abadi API Server running on http://localhost:%s", port)
	log.Printf("📋 API Base URL: http://localhost:%s/api", port)

	if err := r.Run(":" + port); err != nil {
		log.Fatalf("❌ Failed to start server: %v", err)
	}
}
