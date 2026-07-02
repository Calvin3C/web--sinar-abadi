<script setup>
import { Link, router } from '@inertiajs/vue3';
import { computed, ref } from 'vue';

const props = defineProps({
    product: {
        type: Object,
        required: true,
    },
    authRole: {
        type: String,
        default: null,
    },
});

const quantity = ref(1);

const decreaseQty = () => {
    if (quantity.value > 1) quantity.value--;
};

const increaseQty = () => {
    if (quantity.value < props.product.stock) quantity.value++;
};

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const handleAddToCart = () => {
    router.post('/cart/add', {
        id: props.product.id,
        name: props.product.name,
        price: props.product.price,
        img: props.product.img || '',
        weight: props.product.weight || 0,
        length: props.product.length || 1,
        width: props.product.width || 1,
        height: props.product.height || 1,
        stock: props.product.stock,
        qty: quantity.value,
        minPurchase: props.product.minPurchase || 1,
    }, {
        preserveScroll: true,
        onSuccess: () => {
            quantity.value = 1;
        }
    });
};
</script>

<template>
    <div class="product-card">
        <Link :href="'/katalog/' + product.id" class="product-image-wrap">
            <span v-if="product.stock <= 0" class="product-badge">Habis</span>
            <img 
                :src="product.img || 'https://placehold.co/400x300/e2e8f0/64748b?text=No+Image'" 
                :alt="product.name" 
                class="product-image" 
                loading="lazy"
            >
        </Link>
        <div class="product-content">
            <span class="product-cat-label">{{ product.category }}</span>
            <Link :href="'/katalog/' + product.id" class="product-title-link">
                <h4 class="product-title">{{ product.name }}</h4>
            </Link>
            <div class="product-stats">
                <span>{{ product.sold || 0 }} terjual</span>
                <span>•</span>
                <span>Stok: {{ product.stock || 0 }}</span>
            </div>
            <div class="product-price">{{ formatPrice(product.price) }}</div>


            <button 
                v-if="product.stock <= 0" 
                class="btn w-100" 
                disabled 
                style="background: #e2e8f0; color: #94a3b8; cursor: not-allowed;"
            >
                Stok Habis
            </button>
        </div>
    </div>
</template>

<style scoped>
.quantity-selector {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #f1f5f9;
    border-radius: 8px;
    padding: 4px;
    margin-bottom: 12px;
}
.qty-btn {
    background: transparent;
    border: none;
    color: #475569;
    font-size: 1.2rem;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.2s;
}
.qty-btn:hover:not(:disabled) {
    background: #e2e8f0;
    color: #0f172a;
}
.qty-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
.qty-input {
    width: 40px;
    text-align: center;
    border: none;
    background: transparent;
    font-weight: 600;
    color: #0f172a;
    -moz-appearance: textfield;
}
.qty-input:focus {
    outline: none;
}
.qty-input::-webkit-outer-spin-button,
.qty-input::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
}
.product-title-link {
    text-decoration: none;
    color: inherit;
}
.product-title-link:hover .product-title {
    color: var(--color-primary);
}
</style>
