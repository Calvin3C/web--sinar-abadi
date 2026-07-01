<script setup>
import { Link, usePage, router } from '@inertiajs/vue3';
import { computed, watch, ref } from 'vue';

const page = usePage();
const auth = computed(() => page.props.auth);
const cartCount = computed(() => page.props.cartCount);
const flash = computed(() => page.props.flash);
const currentRouteName = computed(() => page.props.currentRouteName);

const logoHref = computed(() => {
    if (auth.value.role === 'admin') return '/admin/dashboard';
    if (auth.value.role === 'owner') return '/owner/dashboard';
    return '/';
});

// Toast Notifications System
const toasts = ref([]);

const showToast = (type, title, message) => {
    const id = Date.now() + Math.random();
    toasts.value.push({ id, type, title, message, fading: false });
    
    setTimeout(() => {
        const toast = toasts.value.find(t => t.id === id);
        if (toast) toast.fading = true;
        
        setTimeout(() => {
            removeToast(id);
        }, 500);
    }, 4000);
};

const removeToast = (id) => {
    toasts.value = toasts.value.filter(t => t.id !== id);
};

// Watch for flash notifications from Laravel
watch(() => flash.value.success, (msg) => {
    if (msg) showToast('success', 'Berhasil', msg);
}, { immediate: true });

watch(() => flash.value.error, (msg) => {
    if (msg) showToast('warning', 'Gagal', msg);
}, { immediate: true });

const handleLogout = () => {
    router.post('/logout');
};
</script>

<template>
    <div>
        <!-- Toast Container -->
        <div class="toast-container" id="toast-container">
            <div 
                v-for="toast in toasts" 
                :key="toast.id" 
                class="toast" 
                :class="[toast.type, { fading: toast.fading }]"
                :style="toast.fading ? { animation: 'fadeOut 0.5s forwards' } : {}"
            >
                <svg class="toast-icon" viewBox="0 0 24 24">
                    <path v-if="toast.type === 'success'" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                    <path v-else d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>
                </svg>
                <div>
                    <div class="toast-title">{{ toast.title }}</div>
                    <div class="toast-msg">{{ toast.message }}</div>
                </div>
            </div>
        </div>

        <!-- Header -->
        <header class="header">
            <div class="container header-inner">
                <Link :href="logoHref" class="logo">
                    <svg viewBox="0 0 100 100" width="36" height="36">
                        <polygon points="50,2 61,38 98,38 68,60 79,96 50,74 21,96 32,60 2,38 39,38" fill="none" stroke="currentColor" stroke-width="5" stroke-linejoin="round"/>
                        <text x="50" y="60" text-anchor="middle" font-size="24" font-weight="800" fill="currentColor" font-family="'Plus Jakarta Sans', sans-serif">SA</text>
                    </svg>
                    SINAR<span>ABADI</span>
                </Link>

                <nav class="nav-menu" id="main-nav">
                    <!-- Guest & Customer Navigation -->
                    <template v-if="auth.role !== 'admin' && auth.role !== 'owner'">
                        <Link href="/" class="nav-link" :class="{ active: currentRouteName === 'home' }">Beranda</Link>
                        <Link href="/katalog" class="nav-link" :class="{ active: currentRouteName === 'katalog' }">Semua Katalog</Link>
                    </template>

                    <!-- Authenticated Menu -->
                    <template v-if="!auth.token">
                        <Link href="/login" class="nav-link" :class="{ active: currentRouteName === 'login' }">Masuk / Daftar</Link>
                    </template>
                    <template v-else>
                        <!-- Customer -->
                        <template v-if="auth.role === 'customer'">
                            <Link href="/customer/dashboard" class="nav-link" :class="{ active: currentRouteName && currentRouteName.startsWith('customer.') }">Dashboard Saya</Link>
                            <Link href="/cart" class="cart-trigger">
                                <svg viewBox="0 0 24 24" width="20" height="20">
                                    <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z" fill="currentColor"/>
                                </svg>
                                Keranjang
                                <span class="cart-badge" id="cart-counter" v-if="cartCount > 0">{{ cartCount }}</span>
                            </Link>
                        </template>

                        <!-- Admin -->
                        <template v-else-if="auth.role === 'admin'">
                            <Link href="/admin/dashboard" class="nav-link" :class="{ active: currentRouteName && currentRouteName.startsWith('admin.') }">Panel Admin</Link>
                        </template>

                        <!-- Owner -->
                        <template v-else-if="auth.role === 'owner'">
                            <Link href="/owner/dashboard" class="nav-link" :class="{ active: currentRouteName && currentRouteName.startsWith('owner.') }">Laporan Owner</Link>
                        </template>

                        <!-- Logout Button -->
                        <button @click="handleLogout" class="btn btn-outline" style="padding: 8px 16px; margin-left: 8px;">
                            Keluar ({{ auth.username }})
                        </button>
                    </template>
                </nav>
            </div>
        </header>

        <!-- Main Content -->
        <main>
            <slot />
        </main>

        <!-- Chatbot Floating Button -->
        <div v-if="auth.role !== 'admin' && auth.role !== 'owner'" class="chatbot-fab-container" style="position: fixed; bottom: 30px; right: 30px; z-index: 50; display: flex; align-items: center;">
            <div class="chatbot-tooltip" style="margin-right: 16px; background: white; color: #0f172a; padding: 10px 16px; border-radius: 12px; font-size: 14px; font-weight: 600; box-shadow: 0 10px 25px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; white-space: nowrap; pointer-events: none; opacity: 0; transform: translateX(10px); transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);">Tanya AI untuk rekomendasi bahan bangunan</div>
            <Link :href="auth.token ? '/customer/dashboard?menu=chatbot' : '/login'" class="chatbot-fab" style="display: flex; align-items: center; justify-content: center; width: 60px; height: 60px; background: #e11d48; color: white; border-radius: 50%; box-shadow: 0 4px 12px rgba(225, 29, 72, 0.4); text-decoration: none; transition: transform 0.2s cubic-bezier(0.4, 0, 0.2, 1); position: relative; z-index: 2;">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                </svg>
            </Link>
        </div>

        <!-- Footer -->
        <footer class="footer">
            <div class="container">
                <div class="footer-grid">
                    <div class="footer-brand">
                        <div class="logo">
                            <svg viewBox="0 0 100 100" width="36" height="36">
                                <polygon points="50,2 61,38 98,38 68,60 79,96 50,74 21,96 32,60 2,38 39,38" fill="none" stroke="#dc2626" stroke-width="5" stroke-linejoin="round"/>
                                <text x="50" y="60" text-anchor="middle" font-size="24" font-weight="800" fill="#dc2626" font-family="'Plus Jakarta Sans', sans-serif">SA</text>
                            </svg>
                            SINAR<span>ABADI</span>
                        </div>
                        <p>Toko material bangunan terlengkap di Dampit, Malang. Melayani penjualan material berkualitas tinggi untuk kebutuhan konstruksi Anda.</p>
                    </div>

                    <div v-if="auth.role !== 'admin' && auth.role !== 'owner'">
                        <h4>Navigasi</h4>
                        <ul class="footer-links">
                            <li><Link href="/">Beranda</Link></li>
                            <li><Link href="/katalog">Katalog Produk</Link></li>
                            <li><Link href="/login">Masuk / Daftar</Link></li>
                        </ul>
                    </div>
                    <div v-else>
                        <h4>Panel</h4>
                        <ul class="footer-links">
                            <li v-if="auth.role === 'admin'"><Link href="/admin/dashboard">Dashboard Admin</Link></li>
                            <li v-if="auth.role === 'owner'"><Link href="/owner/dashboard">Dashboard Owner</Link></li>
                        </ul>
                    </div>

                    <div v-if="auth.role !== 'admin' && auth.role !== 'owner'">
                        <h4>Kategori</h4>
                        <ul class="footer-links">
                            <li><Link href="/katalog?category=Semen">Semen</Link></li>
                            <li><Link href="/katalog?category=Perpipaan">Perpipaan</Link></li>
                            <li><Link href="/katalog?category=Cat Tembok">Cat Tembok</Link></li>
                            <li><Link href="/katalog?category=Perkakas">Perkakas</Link></li>
                        </ul>
                    </div>
                    <div v-else>
                        <!-- Spacer for admins/owner -->
                        <div></div>
                    </div>

                    <div>
                        <h4>Hubungi Kami</h4>
                        <a href="https://maps.app.goo.gl/3G151C2dQdjtMmBv8" target="_blank" rel="noopener noreferrer" class="contact-item" style="text-decoration: none; color: inherit; display: flex; align-items: flex-start; gap: 12px; cursor: pointer; transition: opacity 0.2s;" onmouseover="this.style.opacity='0.8'" onmouseout="this.style.opacity='1'">
                            <svg viewBox="0 0 24 24" width="32" height="32" fill="#dc2626" style="flex-shrink: 0; min-width: 32px; margin-top: 2px;">
                                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                            </svg>
                            <span style="line-height: 1.5;">Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181</span>
                        </a>
                        <div class="contact-item">
                            <svg viewBox="0 0 24 24" width="28" height="28" fill="#dc2626">
                                <path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56-.35-.12-.74-.03-1.01.24l-1.57 1.97c-2.83-1.35-5.48-3.9-6.89-6.83l1.95-1.66c.27-.28.35-.67.24-1.02-.37-1.11-.56-2.3-.56-3.53 0-.54-.45-.99-.99-.99H4.19C3.65 3 3 3.24 3 3.99 3 13.28 10.73 21 20.01 21c.71 0 .99-.63.99-1.18v-3.45c0-.54-.45-.99-.99-.99z"/>
                            </svg>
                            <span>+62 819-4512-2202</span>
                        </div>
                        <a href="https://wa.me/6281945122202" target="_blank" rel="noopener noreferrer" class="contact-item" style="text-decoration: none; color: inherit; margin-top: 12px; display: flex; align-items: center; gap: 12px; cursor: pointer;">
                            <svg viewBox="0 0 24 24" width="28" height="28" fill="#25D366">
                                <path d="M12.031 0C5.386 0 0 5.387 0 12.033c0 2.127.551 4.204 1.597 6.03L.044 24l6.105-1.602a11.957 11.957 0 005.882 1.536h.005c6.645 0 12.032-5.387 12.032-12.034C24.068 5.387 18.676 0 12.031 0zm0 21.968a9.98 9.98 0 01-5.093-1.385l-.365-.217-3.784.992.997-3.69-.238-.378A9.984 9.984 0 012.04 12.033c0-5.508 4.484-9.992 9.991-9.992 5.507 0 9.992 4.484 9.992 9.992s-4.485 9.935-9.992 9.935zm5.48-7.48c-.3-.15-1.776-.877-2.052-.977-.276-.1-.476-.15-.676.15-.2.301-.776.977-.952 1.177-.175.2-.35.226-.65.076-1.328-.66-2.5-1.428-3.486-2.65-.239-.297-.477-.615-.716-.94-.175-.25-.018-.387.132-.536.134-.134.3-.35.45-.526.15-.176.2-.301.3-.501.1-.2.05-.376-.025-.526-.075-.15-.676-1.628-.926-2.228-.244-.587-.492-.507-.676-.517-.176-.009-.376-.009-.576-.009s-.526.075-.801.376c-.276.3-1.052 1.027-1.052 2.504 0 1.477 1.077 2.904 1.227 3.104.15.2 2.115 3.23 5.122 4.528 2.054.887 2.827.973 3.824.818.825-.129 2.502-1.022 2.852-2.01.35-.989.35-1.836.25-2.01-.1-.176-.35-.277-.65-.427z"/>
                            </svg>
                            <span>WhatsApp Sinar Abadi</span>
                        </a>
                    </div>
                </div>
                <div class="footer-bottom">
                    &copy; 2026 Sinar Abadi. All rights reserved. | Built with Laravel, Vue & Go
                </div>
            </div>
        </footer>
    </div>
</template>

<style scoped>
.chatbot-fab-container:hover .chatbot-tooltip {
    opacity: 1 !important;
    transform: translateX(0) !important;
}
.chatbot-fab-container:hover .chatbot-fab {
    transform: scale(1.1) !important;
}
</style>
