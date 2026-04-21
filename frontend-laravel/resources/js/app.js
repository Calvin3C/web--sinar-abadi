/**
 * Sinar Abadi Frontend - JavaScript
 * Handles: Add to cart (AJAX), toast notifications
 */

// CSRF token for AJAX requests
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

/**
 * Add product to cart via AJAX
 */
function addToCart(button) {
    const data = {
        id: button.dataset.id,
        name: button.dataset.name,
        price: parseInt(button.dataset.price),
        img: button.dataset.img || '',
        isLarge: button.dataset.islarge || '0',
        stock: parseInt(button.dataset.stock) || 0,
    };

    button.disabled = true;
    button.innerHTML = '⏳ Menambahkan...';

    fetch('/cart/add', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': csrfToken,
            'Accept': 'application/json',
        },
        body: JSON.stringify(data),
    })
    .then(response => {
        if (response.status === 401) {
            window.location.href = '/login';
            return;
        }
        return response.json();
    })
    .then(result => {
        if (result && result.success) {
            // Update ALL cart badges on the page
            document.querySelectorAll('#cart-counter').forEach(badge => {
                badge.textContent = result.cartCount;
                badge.style.display = result.cartCount > 0 ? 'flex' : 'none';
            });

            showToast('success', 'Ditambahkan!', `${data.name} berhasil ditambahkan ke keranjang.`);
        } else {
            showToast('warning', 'Gagal', result?.message || 'Gagal menambahkan produk.');
        }
    })
    .catch(err => {
        showToast('warning', 'Error', 'Terjadi kesalahan jaringan.');
        console.error(err);
    })
    .finally(() => {
        button.disabled = false;
        button.innerHTML = `<svg viewBox="0 0 24 24" width="18" height="18" fill="white"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg> Tambah ke Keranjang`;
    });
}

/**
 * Show toast notification
 */
function showToast(type, title, message) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const iconPaths = {
        success: '<path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>',
        warning: '<path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>',
    };

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <svg class="toast-icon" viewBox="0 0 24 24">${iconPaths[type] || iconPaths.success}</svg>
        <div>
            <div class="toast-title">${title}</div>
            <div class="toast-msg">${message}</div>
        </div>
    `;

    container.appendChild(toast);

    // Auto-remove after 4 seconds
    setTimeout(() => {
        toast.style.animation = 'fadeOut 0.5s forwards';
        setTimeout(() => toast.remove(), 500);
    }, 4000);
}

// ⚠️ PENTING: Expose ke global scope agar onclick="addToCart(this)" di HTML bisa bekerja
// Vite/ESModule membungkus JS sehingga fungsi tidak otomatis global
window.addToCart = addToCart;
window.showToast = showToast;
