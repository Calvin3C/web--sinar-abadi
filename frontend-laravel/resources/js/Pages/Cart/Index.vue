<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router, Link, useForm } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    cartItems: {
        type: Array,
        default: () => [],
    },
    logistic: {
        type: Object,
        default: () => ({ courier: '', address: '', cost: 0, totalWeight: 0 }),
    },
});

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const subtotal = computed(() => {
    return props.cartItems.reduce((acc, item) => acc + (item.price * item.qty), 0);
});



const shippingCost = computed(() => {
    return props.logistic?.cost || 0;
});

const grandTotal = computed(() => {
    return subtotal.value + shippingCost.value;
});

const updateQty = (id, newQty) => {
    if (newQty < 1) return;
    router.post('/cart/update', { id, qty: newQty }, { preserveScroll: true });
};

const removeItem = (id) => {
    router.delete(`/cart/${id}`, { preserveScroll: true });
};

</script>

<template>
    <AppLayout>
        <section class="section active">
            <div class="container">
                <h2 class="section-title">Keranjang Belanja</h2>

                <div v-if="cartItems.length > 0" class="dashboard-layout" style="grid-template-columns: 1.8fr 1fr;">
                    <!-- Left: Cart Items & Logistics Info -->
                    <div>
                        <!-- Items Card -->
                        <div class="table-card" style="padding: 24px; margin-bottom: 24px;">
                            <h3 class="mb-4" style="font-size:18px;">Daftar Material</h3>
                            <div 
                                v-for="item in cartItems" 
                                :key="item.cartKey || item.id" 
                                class="cart-item"
                            >
                                <img 
                                    :src="item.img || 'https://placehold.co/150/e2e8f0/64748b?text=Material'" 
                                    :alt="item.name" 
                                    class="cart-item-img"
                                >
                                <div class="cart-item-info">
                                    <div class="d-flex justify-between align-start">
                                        <h4 class="cart-item-title">{{ item.name }}</h4>
                                        <button 
                                            @click="removeItem(item.cartKey || item.id)" 
                                            class="btn-ghost" 
                                            style="padding: 4px; color: var(--color-danger); cursor: pointer;"
                                        >
                                            Hapus
                                        </button>
                                    </div>
                                    <div v-if="item.color" style="font-size: 13px; color: #64748b; margin-bottom: 4px;">Warna: <span style="font-weight: 500;">{{ item.color }}</span></div>
                                    <div class="cart-item-price">{{ formatPrice(item.price) }}</div>
                                    <div class="d-flex justify-between align-center mt-2">
                                        <div class="qty-controls">
                                            <button @click="updateQty(item.cartKey || item.id, item.qty - 1)" class="qty-btn" :disabled="item.qty <= (item.minPurchase || 1)">-</button>
                                            <input type="text" :value="item.qty" class="qty-input" readonly>
                                            <button @click="updateQty(item.cartKey || item.id, item.qty + 1)" class="qty-btn">+</button>
                                        </div>
                                        <div style="font-weight: 800; color: var(--color-text-main);">
                                            Total: {{ formatPrice(item.price * item.qty) }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Summary -->
                    <div class="sidebar-card">
                        <h3 class="mb-4" style="font-size:18px;">Ringkasan Belanja</h3>
                        <div class="summary-total">
                            <span>Total</span>
                            <span>{{ formatPrice(subtotal) }}</span>
                        </div>

                        <Link 
                            href="/cart/payment" 
                            class="btn btn-primary w-100" 
                            style="font-size:16px; padding:14px; display: block; text-align: center; font-weight: 700;"
                        >
                            Checkout
                        </Link>
                    </div>
                </div>

                <div v-else class="text-center" style="padding: 80px 20px; color: #64748b;">
                    <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1" style="margin:0 auto 16px;">
                        <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                    </svg>
                    <h3>Keranjang Belanja Kosong</h3>
                    <p>Silakan pilih material konstruksi terlebih dahulu di katalog kami.</p>
                    <Link href="/katalog" class="btn btn-primary mt-6">Belanja Sekarang</Link>
                </div>
            </div>
        </section>

    </AppLayout>
</template>
