package controllers

import (
	"net/http"

	"sinar-abadi-backend/config"
	"sinar-abadi-backend/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

// GetCustomers returns a list of all customer users. Admin/Owner only.
// GET /api/users
func GetCustomers(c *gin.Context) {
	var users []models.User
	if result := config.DB.Where("role = ?", "customer").Find(&users); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data customer"})
		return
	}

	// Build safe response (without password hashes)
	type UserResponse struct {
		ID        uint   `json:"id"`
		Username  string `json:"username"`
		Name      string `json:"name"`
		Role      string `json:"role"`
		IsBlocked bool   `json:"isBlocked"`
	}

	var response []UserResponse
	for _, u := range users {
		response = append(response, UserResponse{
			ID:        u.ID,
			Username:  u.Username,
			Name:      u.Name,
			Role:      u.Role,
			IsBlocked: u.IsBlocked,
		})
	}

	c.JSON(http.StatusOK, response)
}

// ToggleBlockUser toggles the isBlocked status for a customer. Admin only.
// PUT /api/users/:username/block
func ToggleBlockUser(c *gin.Context) {
	username := c.Param("username")

	var user models.User
	if result := config.DB.Where("username = ? AND role = ?", username, "customer").First(&user); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Customer tidak ditemukan"})
		return
	}

	newStatus := !user.IsBlocked
	config.DB.Model(&user).Update("is_blocked", newStatus)

	statusText := "diblokir"
	if !newStatus {
		statusText = "dibuka kembali"
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "Akses akun " + username + " telah " + statusText,
		"username":  user.Username,
		"isBlocked": newStatus,
	})
}

// GetAdmins returns a list of all admin users. Owner only.
// GET /api/users/admins
func GetAdmins(c *gin.Context) {
	var users []models.User
	if result := config.DB.Where("role = ?", "admin").Find(&users); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data admin"})
		return
	}

	type AdminResponse struct {
		ID       uint   `json:"id"`
		Username string `json:"username"`
		Name     string `json:"name"`
	}

	var response []AdminResponse
	for _, u := range users {
		response = append(response, AdminResponse{
			ID:       u.ID,
			Username: u.Username,
			Name:     u.Name,
		})
	}

	c.JSON(http.StatusOK, response)
}

// DeleteAdmin removes an admin account. Owner only.
// DELETE /api/users/admins/:username
func DeleteAdmin(c *gin.Context) {
	username := c.Param("username")

	var user models.User
	if result := config.DB.Where("username = ? AND role = ?", username, "admin").First(&user); result.Error != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Admin tidak ditemukan"})
		return
	}

	config.DB.Delete(&user)

	c.JSON(http.StatusOK, gin.H{
		"message": "Akun admin " + username + " telah dihapus",
	})
}

// CreateAdminInput represents the request body for creating a new admin.
type CreateAdminInput struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Name     string `json:"name" binding:"required"`
}

// CreateAdmin creates a new admin account. Owner only.
// POST /api/users/admins
func CreateAdmin(c *gin.Context) {
	var input CreateAdminInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Lengkapi semua field"})
		return
	}

	// Check duplicate username
	var existing models.User
	if result := config.DB.Where("username = ?", input.Username).First(&existing); result.RowsAffected > 0 {
		c.JSON(http.StatusConflict, gin.H{"error": "Username sudah digunakan"})
		return
	}

	// Hash password with bcrypt
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
		return
	}

	user := models.User{
		Username:  input.Username,
		Password:  string(hashedPassword),
		Role:      "admin",
		Name:      input.Name,
		IsBlocked: false,
	}

	if result := config.DB.Create(&user); result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat akun admin"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message":  "Akun admin berhasil dibuat",
		"username": user.Username,
		"name":     user.Name,
	})
}
