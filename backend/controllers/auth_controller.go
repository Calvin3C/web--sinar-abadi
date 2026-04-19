package controllers

import (
	"net/http"
	"time"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/middleware"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// RegisterInput represents the request body for customer registration.
type RegisterInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Name     string `json:"name" binding:"required"`
}

// LoginInput represents the request body for user login.
type LoginInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Role     string `json:"role" binding:"required"` // customer | admin | owner
}

// Register creates a new customer account.
// POST /api/register
func Register(c *gin.Context) {
	var input RegisterInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Lengkapi semua field (username, password, name)"})
		return
	}

	// Check if username already exists
	var existing models.User
	if result := config.DB.Where("username = ?", input.Username).First(&existing); result.RowsAffected > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Username sudah terdaftar"})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
		return
	}

	user := models.User{
		Username:  input.Username,
		Password:  string(hashedPassword),
		Role:      "customer", // Registration is always for customers
		Name:      input.Name,
		IsBlocked: false,
	}

	if result := config.DB.Create(&user); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat akun"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Akun berhasil terdaftar",
		"user": gin.H{
			"username":  user.Username,
			"role":      user.Role,
			"name":      user.Name,
			"isBlocked": user.IsBlocked,
		},
	})
}

// Login authenticates a user and returns a JWT token.
// POST /api/login
func Login(c *gin.Context) {
	var input LoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Lengkapi semua field (username, password, role)"})
		return
	}

	// Find user by username and role
	var user models.User
	if result := config.DB.Where("username = ? AND role = ?", input.Username, input.Role).First(&user); result.Error != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kredensial tidak valid"})
		return
	}

	// Check if account is blocked
	if user.IsBlocked {
		c.JSON(http.StatusForbidden, gin.H{"error": "Akun Anda telah diblokir oleh Admin"})
		return
	}

	// Verify password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Kredensial tidak valid"})
		return
	}

	// Generate JWT token
	claims := &middleware.Claims{
		UserID:   user.ID,
		Username: user.Username,
		Role:     user.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(middleware.GetJWTSecret())
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": tokenString,
		"user": gin.H{
			"id":        user.ID,
			"username":  user.Username,
			"role":      user.Role,
			"name":      user.Name,
			"isBlocked": user.IsBlocked,
		},
	})
}
