package seed

import (
	"log"

	"sinar-abadi-backend/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// RunSeeder populates the database with initial data if tables are empty.
func RunSeeder(db *gorm.DB) {
	seedUsers(db)
	seedProducts(db)
	seedOrders(db)
}

// ---- USERS ----
func seedUsers(db *gorm.DB) {
	var count int64
	db.Model(&models.User{}).Count(&count)
	if count > 0 {
		log.Println("⏭️  Users table already seeded, skipping...")
		return
	}

	hashPw := func(pw string) string {
		h, _ := bcrypt.GenerateFromPassword([]byte(pw), bcrypt.DefaultCost)
		return string(h)
	}

	users := []models.User{
		{Username: "budi", Password: hashPw("123"), Role: "customer", Name: "Budi Santoso", IsBlocked: false},
		{Username: "admin", Password: hashPw("admin123"), Role: "admin", Name: "Admin Operasional", IsBlocked: false},
		{Username: "owner", Password: hashPw("owner123"), Role: "owner", Name: "Dewan Direksi", IsBlocked: false},
	}

	for _, u := range users {
		db.Create(&u)
	}
	log.Println("✅ Seeded 3 default users")
}

// ---- PRODUCTS ----
func seedProducts(db *gorm.DB) {
	var count int64
	db.Model(&models.Product{}).Count(&count)
	if count > 0 {
		log.Println("⏭️  Products table already seeded, skipping...")
		return
	}

	products := []models.Product{
		// =====================================================================
		// SEMEN (IsLarge = true)
		// =====================================================================
		{ID: "P-001", Category: "Semen", Name: "Semen Gresik 40 kg", Price: 59000, Stock: 100, Sold: 850, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Gresik"},
		{ID: "P-002", Category: "Semen", Name: "Semen Merah Putih 40 kg", Price: 47000, Stock: 120, Sold: 720, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Merah+Putih"},
		{ID: "P-003", Category: "Semen", Name: "Semen Singa Merah 40 kg", Price: 45000, Stock: 100, Sold: 650, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Singa+Merah"},
		{ID: "P-004", Category: "Semen", Name: "Semen Putih Tiga Roda 40 kg", Price: 120000, Stock: 60, Sold: 320, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Tiga+Roda"},
		{ID: "P-005", Category: "Semen", Name: "Semen Putih Panda 40 kg", Price: 65000, Stock: 80, Sold: 410, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Panda"},
		{ID: "P-006", Category: "Semen", Name: "Semen Sika Perekat Granit 20 kg", Price: 110000, Stock: 50, Sold: 280, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Semen+Sika"},
		{ID: "P-007", Category: "Semen", Name: "Semen Perekat Bata Ringan Drymix 20 kg", Price: 75000, Stock: 70, Sold: 350, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Drymix"},
		{ID: "P-008", Category: "Semen", Name: "Semen Perekat Bata Ringan Eco 20 kg", Price: 65000, Stock: 70, Sold: 300, IsLarge: true, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Eco+Bata"},

		// =====================================================================
		// PLUMBING — Maspion AW (IsLarge = false)
		// =====================================================================
		{ID: "P-009", Category: "Plumbing", Name: "Pipa Maspion 1/2 AW", Price: 35000, Stock: 200, Sold: 1200, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1/2+AW"},
		{ID: "P-010", Category: "Plumbing", Name: "Pipa Maspion 3/4 AW", Price: 42000, Stock: 200, Sold: 1100, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+3/4+AW"},
		{ID: "P-011", Category: "Plumbing", Name: "Pipa Maspion 1 AW", Price: 56000, Stock: 150, Sold: 900, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+AW"},
		{ID: "P-012", Category: "Plumbing", Name: "Pipa Maspion 1 1/4 AW", Price: 74000, Stock: 100, Sold: 600, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/4+AW"},
		{ID: "P-013", Category: "Plumbing", Name: "Pipa Maspion 1 1/2 AW", Price: 98000, Stock: 100, Sold: 500, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/2+AW"},
		{ID: "P-014", Category: "Plumbing", Name: "Pipa Maspion 2 AW", Price: 138000, Stock: 80, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+2+AW"},
		{ID: "P-015", Category: "Plumbing", Name: "Pipa Maspion 2 1/2 AW", Price: 185000, Stock: 60, Sold: 250, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+2+1/2+AW"},
		{ID: "P-016", Category: "Plumbing", Name: "Pipa Maspion 3 AW", Price: 255000, Stock: 50, Sold: 200, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+3+AW"},
		{ID: "P-017", Category: "Plumbing", Name: "Pipa Maspion 4 AW", Price: 385000, Stock: 40, Sold: 150, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+4+AW"},
		{ID: "P-018", Category: "Plumbing", Name: "Pipa Maspion 5 AW", Price: 575000, Stock: 30, Sold: 80, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+5+AW"},
		{ID: "P-019", Category: "Plumbing", Name: "Pipa Maspion 6 AW", Price: 765000, Stock: 20, Sold: 50, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+6+AW"},
		{ID: "P-020", Category: "Plumbing", Name: "Pipa Maspion 8 AW", Price: 1275000, Stock: 15, Sold: 30, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+8+AW"},

		// Maspion C
		{ID: "P-021", Category: "Plumbing", Name: "Pipa Maspion 5/8 C", Price: 9000, Stock: 300, Sold: 1500, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+5/8+C"},
		{ID: "P-022", Category: "Plumbing", Name: "Pipa Maspion 3/4 C", Price: 16000, Stock: 250, Sold: 1300, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+3/4+C"},
		{ID: "P-023", Category: "Plumbing", Name: "Pipa Maspion 1 C", Price: 26000, Stock: 200, Sold: 1000, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+C"},
		{ID: "P-024", Category: "Plumbing", Name: "Pipa Maspion 1 1/4 C", Price: 31000, Stock: 150, Sold: 700, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/4+C"},
		{ID: "P-025", Category: "Plumbing", Name: "Pipa Maspion 1 1/2 C", Price: 37000, Stock: 150, Sold: 600, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/2+C"},
		{ID: "P-026", Category: "Plumbing", Name: "Pipa Maspion 2 C", Price: 58000, Stock: 100, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+2+C"},
		{ID: "P-027", Category: "Plumbing", Name: "Pipa Maspion 2 1/2 C", Price: 69000, Stock: 80, Sold: 300, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+2+1/2+C"},
		{ID: "P-028", Category: "Plumbing", Name: "Pipa Maspion 3 C", Price: 79000, Stock: 60, Sold: 200, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+3+C"},
		{ID: "P-029", Category: "Plumbing", Name: "Pipa Maspion 4 C", Price: 102000, Stock: 50, Sold: 150, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+4+C"},

		// Maspion D
		{ID: "P-030", Category: "Plumbing", Name: "Pipa Maspion 1 1/4 D", Price: 45000, Stock: 100, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/4+D"},
		{ID: "P-031", Category: "Plumbing", Name: "Pipa Maspion 1 1/2 D", Price: 55000, Stock: 100, Sold: 350, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+1+1/2+D"},
		{ID: "P-032", Category: "Plumbing", Name: "Pipa Maspion 2 D", Price: 68000, Stock: 80, Sold: 300, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+2+D"},
		{ID: "P-033", Category: "Plumbing", Name: "Pipa Maspion 2 1/2 D", Price: 98000, Stock: 60, Sold: 200, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+2+1/2+D"},
		{ID: "P-034", Category: "Plumbing", Name: "Pipa Maspion 3 D", Price: 137000, Stock: 50, Sold: 150, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+3+D"},
		{ID: "P-035", Category: "Plumbing", Name: "Pipa Maspion 4 D", Price: 189000, Stock: 40, Sold: 100, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+4+D"},
		{ID: "P-036", Category: "Plumbing", Name: "Pipa Maspion 5 D", Price: 320000, Stock: 30, Sold: 60, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+5+D"},
		{ID: "P-037", Category: "Plumbing", Name: "Pipa Maspion 6 D", Price: 410000, Stock: 20, Sold: 40, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+6+D"},
		{ID: "P-038", Category: "Plumbing", Name: "Pipa Maspion 8 D", Price: 730000, Stock: 15, Sold: 25, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Maspion+8+D"},

		// Rucika AW
		{ID: "P-039", Category: "Plumbing", Name: "Pipa Rucika 1/2 AW", Price: 32000, Stock: 200, Sold: 1100, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+1/2+AW"},
		{ID: "P-040", Category: "Plumbing", Name: "Pipa Rucika 3/4 AW", Price: 42000, Stock: 200, Sold: 1000, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+3/4+AW"},
		{ID: "P-041", Category: "Plumbing", Name: "Pipa Rucika 1 AW", Price: 55000, Stock: 150, Sold: 800, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+1+AW"},
		{ID: "P-042", Category: "Plumbing", Name: "Pipa Rucika 1 1/4 AW", Price: 74000, Stock: 100, Sold: 500, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+1+1/4+AW"},
		{ID: "P-043", Category: "Plumbing", Name: "Pipa Rucika 1 1/2 AW", Price: 92000, Stock: 100, Sold: 450, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+1+1/2+AW"},
		{ID: "P-044", Category: "Plumbing", Name: "Pipa Rucika 2 AW", Price: 128000, Stock: 80, Sold: 350, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+2+AW"},
		{ID: "P-045", Category: "Plumbing", Name: "Pipa Rucika 2 1/2 AW", Price: 175000, Stock: 60, Sold: 200, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+2+1/2+AW"},
		{ID: "P-046", Category: "Plumbing", Name: "Pipa Rucika 3 AW", Price: 255000, Stock: 50, Sold: 150, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+3+AW"},
		{ID: "P-047", Category: "Plumbing", Name: "Pipa Rucika 4 AW", Price: 385000, Stock: 40, Sold: 100, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+4+AW"},
		{ID: "P-048", Category: "Plumbing", Name: "Pipa Rucika 5 AW", Price: 595000, Stock: 25, Sold: 60, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+5+AW"},
		{ID: "P-049", Category: "Plumbing", Name: "Pipa Rucika 6 AW", Price: 775000, Stock: 20, Sold: 40, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+6+AW"},
		{ID: "P-050", Category: "Plumbing", Name: "Pipa Rucika 8 AW", Price: 1325000, Stock: 10, Sold: 20, IsLarge: false, ImageURL: "https://placehold.co/400x300/0284c7/white?text=Rucika+8+AW"},

		// =====================================================================
		// CAT TEMBOK / PAINT (IsLarge = false)
		// =====================================================================
		{ID: "P-051", Category: "Cat Tembok", Name: "Decolith 5 kg", Price: 145000, Stock: 100, Sold: 900, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Decolith+5kg"},
		{ID: "P-052", Category: "Cat Tembok", Name: "Decolith 25 kg", Price: 725000, Stock: 40, Sold: 300, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Decolith+25kg"},
		{ID: "P-053", Category: "Cat Tembok", Name: "Avitex 5 kg", Price: 155000, Stock: 100, Sold: 850, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Avitex+5kg"},
		{ID: "P-054", Category: "Cat Tembok", Name: "Avitex 25 kg", Price: 775000, Stock: 35, Sold: 250, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Avitex+25kg"},
		{ID: "P-055", Category: "Cat Tembok", Name: "No. Drop 4 kg", Price: 245000, Stock: 60, Sold: 500, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=No+Drop+4kg"},
		{ID: "P-056", Category: "Cat Tembok", Name: "No. Drop 20 kg", Price: 1225000, Stock: 20, Sold: 150, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=No+Drop+20kg"},
		{ID: "P-057", Category: "Cat Tembok", Name: "Aquaproof 4 kg", Price: 265000, Stock: 50, Sold: 450, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Aquaproof+4kg"},
		{ID: "P-058", Category: "Cat Tembok", Name: "Aquaproof 20 kg", Price: 1275000, Stock: 15, Sold: 100, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Aquaproof+20kg"},
		{ID: "P-059", Category: "Cat Tembok", Name: "Aries 5 kg", Price: 70000, Stock: 120, Sold: 700, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Aries+5kg"},
		{ID: "P-060", Category: "Cat Tembok", Name: "Aries 20 kg", Price: 280000, Stock: 40, Sold: 250, IsLarge: false, ImageURL: "https://placehold.co/400x300/dc2626/white?text=Aries+20kg"},

		// =====================================================================
		// CAT KAYU (IsLarge = false)
		// =====================================================================
		{ID: "P-061", Category: "Cat Kayu", Name: "Emco Warna Standart 1 kg", Price: 85000, Stock: 80, Sold: 600, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Emco+Std+1kg"},
		{ID: "P-062", Category: "Cat Kayu", Name: "Emco Warna Standart 0.5 kg", Price: 47500, Stock: 100, Sold: 700, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Emco+Std+0.5kg"},
		{ID: "P-063", Category: "Cat Kayu", Name: "Emco Warna Gunung 1 kg", Price: 95000, Stock: 60, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Emco+Gunung+1kg"},
		{ID: "P-064", Category: "Cat Kayu", Name: "Emco Warna Gunung 0.5 kg", Price: 55000, Stock: 80, Sold: 500, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Emco+Gunung+0.5kg"},
		{ID: "P-065", Category: "Cat Kayu", Name: "Emco Warna Bintang 1 kg", Price: 102000, Stock: 50, Sold: 300, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Emco+Bintang+1kg"},
		{ID: "P-066", Category: "Cat Kayu", Name: "Emco Warna Bintang 0.5 kg", Price: 60000, Stock: 70, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Emco+Bintang+0.5kg"},
		{ID: "P-067", Category: "Cat Kayu", Name: "Avian 1 kg", Price: 85000, Stock: 80, Sold: 550, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Avian+1kg"},
		{ID: "P-068", Category: "Cat Kayu", Name: "Avian 0.5 kg", Price: 47500, Stock: 100, Sold: 650, IsLarge: false, ImageURL: "https://placehold.co/400x300/b91c1c/white?text=Avian+0.5kg"},

		// =====================================================================
		// BESI BETON (IsLarge = true)
		// =====================================================================
		{ID: "P-069", Category: "Besi Beton", Name: "Besi Beton 6 SNI", Price: 28000, Stock: 200, Sold: 1500, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+6+SNI"},
		{ID: "P-070", Category: "Besi Beton", Name: "Besi Beton 8 SNI", Price: 46000, Stock: 150, Sold: 1200, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+8+SNI"},
		{ID: "P-071", Category: "Besi Beton", Name: "Besi Beton 10 SNI", Price: 71000, Stock: 120, Sold: 900, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+10+SNI"},
		{ID: "P-072", Category: "Besi Beton", Name: "Besi Beton 12 SNI", Price: 105000, Stock: 100, Sold: 700, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+12+SNI"},
		{ID: "P-073", Category: "Besi Beton", Name: "Besi Beton 14 SNI", Price: 134000, Stock: 80, Sold: 500, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+14+SNI"},
		{ID: "P-074", Category: "Besi Beton", Name: "Besi Beton 16 SNI", Price: 195000, Stock: 60, Sold: 350, IsLarge: true, ImageURL: "https://placehold.co/400x300/374151/white?text=Besi+16+SNI"},

		// =====================================================================
		// KLOSET (IsLarge = true)
		// =====================================================================
		{ID: "P-075", Category: "Kloset", Name: "Kloset Jongkok INA", Price: 210000, Stock: 30, Sold: 200, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Kloset+INA"},
		{ID: "P-076", Category: "Kloset", Name: "Kloset Jongkok Triliun", Price: 205000, Stock: 30, Sold: 180, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Kloset+Triliun"},
		{ID: "P-077", Category: "Kloset", Name: "Kloset Jongkok Duty", Price: 145000, Stock: 40, Sold: 250, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Kloset+Duty"},
		{ID: "P-078", Category: "Kloset", Name: "Monoblok INA", Price: 1550000, Stock: 10, Sold: 50, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Monoblok+INA"},
		{ID: "P-079", Category: "Kloset", Name: "Monoblok Triliun", Price: 1525000, Stock: 10, Sold: 45, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Monoblok+Triliun"},
		{ID: "P-080", Category: "Kloset", Name: "Monoblok Volk", Price: 1250000, Stock: 12, Sold: 60, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Monoblok+Volk"},

		// =====================================================================
		// TOOLS AND MACHINERY (IsLarge = false)
		// =====================================================================
		{ID: "P-081", Category: "Tools", Name: "Mesin Pasrah Modern M2900", Price: 495000, Stock: 15, Sold: 120, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Pasrah+M2900"},
		{ID: "P-082", Category: "Tools", Name: "Mesin Pasrah Modern M2950", Price: 475000, Stock: 15, Sold: 100, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Pasrah+M2950"},
		{ID: "P-083", Category: "Tools", Name: "Mesin Bor Modern M2100", Price: 295000, Stock: 20, Sold: 200, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Bor+M2100"},
		{ID: "P-084", Category: "Tools", Name: "Mesin Bor Modern M2130", Price: 395000, Stock: 15, Sold: 150, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Bor+M2130"},
		{ID: "P-085", Category: "Tools", Name: "Mesin Gerinda Modern M2350", Price: 325000, Stock: 18, Sold: 180, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Gerinda+M2350"},
		{ID: "P-086", Category: "Tools", Name: "Mesin Profil Modern M2700", Price: 425000, Stock: 12, Sold: 90, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Profil+M2700"},
		{ID: "P-087", Category: "Tools", Name: "Mesin Gergaji Modern M2600", Price: 625000, Stock: 10, Sold: 70, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Gergaji+M2600"},
		{ID: "P-088", Category: "Tools", Name: "Meteran Tukang 3 m", Price: 25000, Stock: 200, Sold: 1500, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Meteran+3m"},
		{ID: "P-089", Category: "Tools", Name: "Meteran Tukang 5 m", Price: 35000, Stock: 200, Sold: 1400, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Meteran+5m"},
		{ID: "P-090", Category: "Tools", Name: "Meteran Tukang 7.5 m", Price: 55000, Stock: 150, Sold: 1000, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Meteran+7.5m"},
		{ID: "P-091", Category: "Tools", Name: "Meteran Tukang 10 m", Price: 55000, Stock: 150, Sold: 900, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Meteran+10m"},
		{ID: "P-092", Category: "Tools", Name: "Palu Tukang Supit 8 oz", Price: 35000, Stock: 100, Sold: 800, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+8oz"},
		{ID: "P-093", Category: "Tools", Name: "Palu Tukang Supit 12 oz", Price: 45000, Stock: 100, Sold: 700, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+12oz"},
		{ID: "P-094", Category: "Tools", Name: "Palu Tukang Kotak 200 gram", Price: 35000, Stock: 100, Sold: 600, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+200g"},
		{ID: "P-095", Category: "Tools", Name: "Palu Tukang Kotak 300 gram", Price: 45000, Stock: 100, Sold: 550, IsLarge: false, ImageURL: "https://placehold.co/400x300/059669/white?text=Palu+300g"},

		// =====================================================================
		// ELECTRICAL (IsLarge = false)
		// =====================================================================
		{ID: "P-096", Category: "Electrical", Name: "Lampu Philips LED 5 Watt", Price: 25000, Stock: 300, Sold: 3000, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+5W"},
		{ID: "P-097", Category: "Electrical", Name: "Lampu Philips LED 7 Watt", Price: 29000, Stock: 300, Sold: 2800, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+7W"},
		{ID: "P-098", Category: "Electrical", Name: "Lampu Philips LED 9 Watt", Price: 35000, Stock: 250, Sold: 2500, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+9W"},
		{ID: "P-099", Category: "Electrical", Name: "Lampu Philips LED 11 Watt", Price: 42500, Stock: 200, Sold: 2000, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+11W"},
		{ID: "P-100", Category: "Electrical", Name: "Lampu Philips LED 13 Watt", Price: 49500, Stock: 200, Sold: 1800, IsLarge: false, ImageURL: "https://placehold.co/400x300/d97706/white?text=Philips+13W"},

		// =====================================================================
		// KUAS CAT (IsLarge = false)
		// =====================================================================
		{ID: "P-101", Category: "Kuas Cat", Name: "Kuas Eterna 1 Inch", Price: 7000, Stock: 300, Sold: 2000, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+1in"},
		{ID: "P-102", Category: "Kuas Cat", Name: "Kuas Eterna 1.5 Inch", Price: 10000, Stock: 300, Sold: 1800, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+1.5in"},
		{ID: "P-103", Category: "Kuas Cat", Name: "Kuas Eterna 2 Inch", Price: 12000, Stock: 250, Sold: 1600, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+2in"},
		{ID: "P-104", Category: "Kuas Cat", Name: "Kuas Eterna 2.5 Inch", Price: 15000, Stock: 250, Sold: 1400, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+2.5in"},
		{ID: "P-105", Category: "Kuas Cat", Name: "Kuas Eterna 3 Inch", Price: 18000, Stock: 200, Sold: 1200, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+3in"},
		{ID: "P-106", Category: "Kuas Cat", Name: "Kuas Eterna 4 Inch", Price: 25000, Stock: 200, Sold: 1000, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+4in"},
		{ID: "P-107", Category: "Kuas Cat", Name: "Kuas Eterna 5 Inch", Price: 30000, Stock: 150, Sold: 800, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+5in"},
		{ID: "P-108", Category: "Kuas Cat", Name: "Kuas Eterna 6 Inch", Price: 35000, Stock: 150, Sold: 700, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Kuas+6in"},
		{ID: "P-109", Category: "Kuas Cat", Name: "Kuas Roll Eterna 9 Inch", Price: 30000, Stock: 100, Sold: 900, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+Eterna+9in"},
		{ID: "P-110", Category: "Kuas Cat", Name: "Kuas Roll 4 Inch", Price: 15000, Stock: 150, Sold: 800, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+4in"},
		{ID: "P-111", Category: "Kuas Cat", Name: "Kuas Roll Imundex 9 Inch", Price: 30000, Stock: 100, Sold: 600, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+Imundex+9in"},
		{ID: "P-112", Category: "Kuas Cat", Name: "Kuas Roll Imundex 7 Inch", Price: 25000, Stock: 120, Sold: 650, IsLarge: false, ImageURL: "https://placehold.co/400x300/e11d48/white?text=Roll+Imundex+7in"},

		// =====================================================================
		// KUNCI PINTU (IsLarge = false)
		// =====================================================================
		{ID: "P-113", Category: "Kunci Pintu", Name: "Kunci Pintu Zeona Besar", Price: 175000, Stock: 50, Sold: 350, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Zeona+Besar"},
		{ID: "P-114", Category: "Kunci Pintu", Name: "Kunci Pintu Zeona Tanggung", Price: 110000, Stock: 60, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Zeona+Tanggung"},
		{ID: "P-115", Category: "Kunci Pintu", Name: "Kunci Pintu WanLi Kecil", Price: 75000, Stock: 80, Sold: 500, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=WanLi+Kecil"},
		{ID: "P-116", Category: "Kunci Pintu", Name: "Kunci Pintu Muller Besar", Price: 325000, Stock: 30, Sold: 200, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Muller+Besar"},
		{ID: "P-117", Category: "Kunci Pintu", Name: "Kunci Pintu Muller Tanggung", Price: 245000, Stock: 40, Sold: 250, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Muller+Tanggung"},
		{ID: "P-118", Category: "Kunci Pintu", Name: "Kunci Pintu Kuda Besar", Price: 125000, Stock: 60, Sold: 350, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Kuda+Besar"},
		{ID: "P-119", Category: "Kunci Pintu", Name: "Kunci Pintu Kuda Kecil", Price: 95000, Stock: 70, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/1e293b/white?text=Kuda+Kecil"},

		// =====================================================================
		// ENGSEL (IsLarge = false)
		// =====================================================================
		{ID: "P-120", Category: "Engsel", Name: "Engsel Pintu Muller 5 Inch", Price: 95000, Stock: 100, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Muller+5in"},
		{ID: "P-121", Category: "Engsel", Name: "Engsel Pintu Muller 4 Inch", Price: 75000, Stock: 100, Sold: 450, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Muller+4in"},
		{ID: "P-122", Category: "Engsel", Name: "Engsel Pintu Muller 3 Inch", Price: 45000, Stock: 120, Sold: 500, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Muller+3in"},
		{ID: "P-123", Category: "Engsel", Name: "Engsel Pintu Nishio 5 Inch", Price: 45000, Stock: 100, Sold: 350, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+5in"},
		{ID: "P-124", Category: "Engsel", Name: "Engsel Pintu Nishio 4 Inch", Price: 35000, Stock: 120, Sold: 400, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+4in"},
		{ID: "P-125", Category: "Engsel", Name: "Engsel Pintu Nishio 3 Inch", Price: 20000, Stock: 150, Sold: 600, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Nishio+3in"},
		{ID: "P-126", Category: "Engsel", Name: "Engsel Lemari Tipis 3 Inch", Price: 10000, Stock: 200, Sold: 800, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Lemari+3in"},
		{ID: "P-127", Category: "Engsel", Name: "Engsel Lemari Tipis 2.5 Inch", Price: 8000, Stock: 200, Sold: 750, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Lemari+2.5in"},
		{ID: "P-128", Category: "Engsel", Name: "Engsel Lemari Tipis 2 Inch", Price: 7000, Stock: 250, Sold: 900, IsLarge: false, ImageURL: "https://placehold.co/400x300/64748b/white?text=Engsel+Lemari+2in"},

		// =====================================================================
		// KERAMIK & GRANITE (IsLarge = true)
		// =====================================================================
		{ID: "P-129", Category: "Keramik & Granite", Name: "Keramik Lantai 40x40 cm", Price: 55000, Stock: 200, Sold: 1200, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+40x40"},
		{ID: "P-130", Category: "Keramik & Granite", Name: "Keramik Lantai 50x50 cm", Price: 65000, Stock: 180, Sold: 1000, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+50x50"},
		{ID: "P-131", Category: "Keramik & Granite", Name: "Keramik Lantai 60x60 cm", Price: 135000, Stock: 100, Sold: 600, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+60x60"},
		{ID: "P-132", Category: "Keramik & Granite", Name: "Keramik Dinding 25x40 cm", Price: 65000, Stock: 150, Sold: 800, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+25x40"},
		{ID: "P-133", Category: "Keramik & Granite", Name: "Keramik Dinding 25x50 cm", Price: 75000, Stock: 130, Sold: 700, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+25x50"},
		{ID: "P-134", Category: "Keramik & Granite", Name: "Keramik Dinding 30x60 cm", Price: 90000, Stock: 100, Sold: 500, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Keramik+30x60"},
		{ID: "P-135", Category: "Keramik & Granite", Name: "Granite Polos 60x60 cm", Price: 145000, Stock: 80, Sold: 400, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Granite+Polos"},
		{ID: "P-136", Category: "Keramik & Granite", Name: "Granite Motif 60x60 cm", Price: 165000, Stock: 70, Sold: 350, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Granite+Motif"},
		{ID: "P-137", Category: "Keramik & Granite", Name: "Granite Warna Gelap 60x60 cm", Price: 255000, Stock: 50, Sold: 200, IsLarge: true, ImageURL: "https://placehold.co/400x300/0f172a/white?text=Granite+Gelap"},
	}

	for _, p := range products {
		db.Create(&p)
	}
	log.Printf("✅ Seeded %d products\n", len(products))
}

// ---- ORDERS ----
func seedOrders(db *gorm.DB) {
	var count int64
	db.Model(&models.Order{}).Count(&count)
	if count > 0 {
		log.Println("⏭️  Orders table already seeded, skipping...")
		return
	}

	// Get budi's user ID
	var budi models.User
	if result := db.Where("username = ?", "budi").First(&budi); result.Error != nil {
		log.Println("⚠️  Could not find user 'budi' for order seeding")
		return
	}

	orders := []models.Order{
		{
			ID:             "ORD-260401-081",
			Date:           "2026-04-01",
			CustomerID:     budi.ID,
			CustomerName:   "budi",
			Phone:          "081234567890",
			Address:        "Jl. Merdeka, Malang",
			ShippingMethod: "Kurir Toko Sinar Abadi",
			Total:          854700,
			Status:         "success",
			ShippingStatus: "Selesai",
			ProofUploaded:  true,
			Items: []models.OrderItem{
				{ProductID: "P-096", Name: "Lampu Philips LED 5 Watt", Qty: 2, Price: 385000},
			},
		},
		{
			ID:             "ORD-260402-309",
			Date:           "2026-04-02",
			CustomerID:     budi.ID,
			CustomerName:   "budi",
			Phone:          "081234567890",
			Address:        "Toko Sinar Abadi",
			ShippingMethod: "Ambil di Toko",
			Total:          721500,
			Status:         "pending",
			ShippingStatus: "Menunggu Validasi",
			ProofUploaded:  true,
			Items: []models.OrderItem{
				{ProductID: "P-001", Name: "Semen Gresik 40 kg", Qty: 10, Price: 59000},
			},
		},
	}

	for _, o := range orders {
		db.Create(&o)
	}
	log.Println("✅ Seeded 2 sample orders")
}
