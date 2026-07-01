<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router, useForm, Link } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    products: {
        type: Array,
        default: () => [],
    },
    orders: {
        type: Array,
        default: () => [],
    },
    admins: {
        type: Array,
        default: () => [],
    },
    warehouses: { // [WAREHOUSING]
        type: Array,
        default: () => [],
    },
    inbounds: {
        type: Array,
        default: () => [],
    },
    stockTransfers: {
        type: Array,
        default: () => [],
    },
    username: {
        type: String,
        required: true,
    },
    stats: {
        type: Object,
        default: () => ({ totalRevenueKotor: 0, totalRevenueBersih: 0, salesCount: 0, stockIssuesCount: 0, totalAdmins: 0 }),
    },
    profile: {
        type: Object,
        default: () => ({}),
    },
});

const activeTab = ref('dashboard'); // 'dashboard', 'products', 'validasi', 'histori', 'admins', or 'profile'
const omzetType = ref('kotor'); // 'kotor' or 'bersih'
const productFilter = ref('aktif'); // 'aktif' or 'habis'
const searchQuery = ref('');
const categoryFilter = ref('');

const getFilteredProducts = (warehouseId) => {
    if (!warehouseId) return props.products;
    
    const warehouse = props.warehouses.find(w => w.id === warehouseId);
    if (!warehouse) return props.products;
    
    const name = warehouse.name.toLowerCase();
    
    if (name.includes('gudang y')) {
        return props.products.filter(p => ['besi beton', 'semen'].includes((p.category || '').toLowerCase()));
    } else if (name.includes('gudang m')) {
        const allowed = ['perpipaan', 'kunci pintu', 'perkakas', 'engsel', 'cat kayu', 'cat tembok', 'kuas cat'];
        return props.products.filter(p => allowed.includes((p.category || '').toLowerCase()));
    } else if (name.includes('toko')) {
        return props.products;
    }
    
    return props.products;
};

const expandedOrders = ref([]);
const toggleOrderDetails = (orderId) => {
    const index = expandedOrders.value.indexOf(orderId);
    if (index === -1) {
        expandedOrders.value.push(orderId);
    } else {
        expandedOrders.value.splice(index, 1);
    }
};

// Modals State
const isStockModalOpen = ref(false);
const selectedProductId = ref('');
const stockAmount = ref(0);

// Variant Modal State
const isVariantModalOpen = ref(false);
const selectedProductVariants = ref([]);
const newVariantForm = useForm({
    name: '',
    price: 0,
    stock: 0,
});


const isCreateAdminModalOpen = ref(false);
const newAdminForm = useForm({
    name: '',
    username: '',
    email: '',
    phone: '',
    password: '',
});

const profileForm = useForm({
    name: props.profile?.name || '',
    username: props.profile?.username || '',
    email: props.profile?.email || '',
    phone: props.profile?.phone || '',
    password: '',
});

const saveProfile = () => {
    profileForm.put('/owner/profile', {
        preserveScroll: true,
        onSuccess: () => {
            profileForm.password = '';
        }
    });
};

const formatPrice = (price) => {
    return new Intl.NumberFormat('id-ID', {
        style: 'currency',
        currency: 'IDR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
    }).format(price).replace('Rp', 'Rp ');
};

const formatDate = (dateStr) => {
    if (!dateStr) return '-';
    try {
        const date = new Date(dateStr);
        return date.toLocaleDateString('id-ID', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
        });
    } catch (e) {
        return dateStr;
    }
};

const getStatusClass = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'pending';
        case 'success': return 'warning';
        case 'verified': return 'warning';
        case 'shipping': return 'pending';
        case 'completed': return 'success';
        case 'cancelled': return 'cancelled';
        default: return 'pending';
    }
};

const getStatusLabel = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'Menunggu Konfirmasi';
        case 'success': return 'Diproses';
        case 'verified': return 'Diproses';
        case 'shipping': return 'Dikirim';
        case 'completed': return 'Selesai';
        case 'cancelled': return 'Dibatalkan';
        default: return status;
    }
};

const getProductUnit = (productId) => {
    const product = props.products.find(p => p.id === productId);
    return product ? product.unit : '-';
};

const getActualStock = (productId, warehouseId, variantId) => {
    const product = props.products.find(p => p.id === productId);
    if (!product) return 0;
    
    if (!warehouseId) return product.stock || 0;
    
    if (variantId) {
        const variant = product.variants?.find(v => v.id === variantId);
        if (variant) {
            const wh = variant.warehouseStocks?.find(w => w.warehouseId === warehouseId);
            return wh ? wh.stock : 0;
        }
        return 0;
    } else {
        const wh = product.warehouseStocks?.find(w => w.warehouseId === warehouseId && (!w.variantId || w.variantId === null));
        return wh ? wh.stock : 0;
    }
};

const getAllocatedStock = (productId, warehouseId, variantId) => {
    let allocated = 0;
    props.orders.forEach(order => {
        if (['pending', 'verified', 'success'].includes(order.status?.toLowerCase())) {
            order.items?.forEach(item => {
                if (item.productId === productId && (item.warehouseId === warehouseId || !warehouseId)) {
                    if ((!variantId && !item.variantId) || (variantId && item.variantId === variantId)) {
                        allocated += item.qty;
                    }
                }
            });
        }
    });
    return allocated;
};

const getOrderWarehouses = (order) => {
    if (!order.items || order.items.length === 0) return 'Toko';
    const whSet = new Set();
    order.items.forEach(item => {
        const product = props.products.find(p => p.id === item.productId);
        if (product && product.warehouseStocks && product.warehouseStocks.length > 0) {
            product.warehouseStocks.forEach(ws => {
                if (ws.stock > 0) {
                    const wh = props.warehouses.find(w => w.id === ws.warehouseId);
                    if (wh) whSet.add(wh.name);
                }
            });
        }
    });
    if (whSet.size === 0) return 'Toko';
    return Array.from(whSet).join(', ');
};

const getProductWarehouses = (product) => {
    if (!product.warehouseStocks || product.warehouseStocks.length === 0) return '-';
    const names = [];
    product.warehouseStocks.forEach(ws => {
        if (ws.stock > 0) {
            const wh = props.warehouses.find(w => w.id === ws.warehouseId);
            if (wh && !names.includes(wh.name)) {
                names.push(wh.name);
            }
        }
    });
    return names.length > 0 ? names.join(', ') : '-';
};

// Actions
const openStockModal = (productId, currentStock, variants = []) => {
    selectedProductId.value = productId;
    stockAmount.value = ''; // Reset form for delta input
    stockUpdateForm.warehouseId = props.warehouses[0]?.id || '';
    stockUpdateForm.variantId = '';
    selectedProductVariants.value = variants;
    isStockModalOpen.value = true;
};

const handleUpdateStock = () => {
    router.put(`/owner/products/${selectedProductId.value}/stock`, {
        amount: stockAmount.value, // Delta
        warehouseId: stockUpdateForm.warehouseId,
        variantId: stockUpdateForm.variantId || null,
    }, {
        onSuccess: () => {
            isStockModalOpen.value = false;
            stockAmount.value = '';
        },
        preserveScroll: true,
    });
};

const openStockForVariant = (variantId) => {
    isVariantModalOpen.value = false;
    const product = props.products.find(p => p.id === selectedProductId.value);
    if (product) {
        openStockModal(product.id, product.stock, product.variants || []);
        stockUpdateForm.variantId = variantId;
    }
};

const getVariantTotalStock = (variant) => {
    if (!variant.warehouseStocks) return 0;
    return variant.warehouseStocks.reduce((sum, w) => sum + w.stock, 0);
};

const getVariantStockByWarehouse = (variant, warehouseId) => {
    if (!variant.warehouseStocks) return 0;
    const ws = variant.warehouseStocks.find(w => w.warehouseId === warehouseId);
    return ws ? ws.stock : 0;
};

// [WAREHOUSING]
const stockUpdateForm = useForm({
    warehouseId: '',
    variantId: '',
});


const isCreateWarehouseModalOpen = ref(false);
const warehouseForm = useForm({
    name: '',
    description: '',
});

const handleCreateWarehouse = () => {
    warehouseForm.post('/owner/warehouses', {
        onSuccess: () => {
            isCreateWarehouseModalOpen.value = false;
            warehouseForm.reset();
        },
        preserveScroll: true,
    });
};

const isEditWarehouseModalOpen = ref(false);
const editWarehouseForm = useForm({
    id: '',
    name: '',
    description: '',
    isActive: true,
});

const openEditWarehouseModal = (warehouse) => {
    editWarehouseForm.id = warehouse.id;
    editWarehouseForm.name = warehouse.name;
    editWarehouseForm.description = warehouse.description || '';
    editWarehouseForm.isActive = warehouse.isActive;
    isEditWarehouseModalOpen.value = true;
};

const handleUpdateWarehouse = () => {
    editWarehouseForm.put(`/owner/warehouses/${editWarehouseForm.id}`, {
        onSuccess: () => {
            isEditWarehouseModalOpen.value = false;
            editWarehouseForm.reset();
        },
        preserveScroll: true,
    });
};

const openVariantModal = (product) => {
    selectedProductId.value = product.id;
    selectedProductVariants.value = product.variants || [];
    newVariantForm.reset();
    isVariantModalOpen.value = true;
};

const handleAddVariant = () => {
    newVariantForm.post(`/owner/products/${selectedProductId.value}/variants`, {
        preserveScroll: true,
        onSuccess: (page) => {
            // Update variants array from props if possible, or just let page reload handle it
            const prod = page.props.products.find(p => p.id === selectedProductId.value);
            if (prod) {
                selectedProductVariants.value = prod.variants || [];
            }
            newVariantForm.reset();
        }
    });
};

const handleRemoveVariant = (variantId) => {
    if (confirm('Yakin ingin menghapus varian ini?')) {
        router.delete(`/owner/products/${selectedProductId.value}/variants/${variantId}`, {
            preserveScroll: true,
            onSuccess: (page) => {
                const prod = page.props.products.find(p => p.id === selectedProductId.value);
                if (prod) {
                    selectedProductVariants.value = prod.variants || [];
                }
            }
        });
    }
};

// ==========================================
// INBOUND (Logistik Masuk) STATE
// ==========================================
const warehouseTab = ref('list'); // 'list', 'inbound', 'outbound'
const isInboundModalOpen = ref(false);
const isInboundDetailModalOpen = ref(false);
const selectedInbound = ref(null);

const isOrderDetailModalOpen = ref(false);
const selectedOrder = ref(null);

const openOrderDetailModal = (order) => {
    selectedOrder.value = order;
    isOrderDetailModalOpen.value = true;
};

const openInboundDetailModal = (po) => {
    selectedInbound.value = po;
    isInboundDetailModalOpen.value = true;
};
const inboundForm = useForm({
    supplierName: '',
    expectedDate: '',
    items: [],
});

const openInboundModal = () => {
    inboundForm.reset();
    inboundForm.items = [{ productId: '', variantId: '', warehouseId: props.warehouses[0]?.id || '', qty: 1, unitCost: 0 }];
    isInboundModalOpen.value = true;
};

const addInboundItem = () => {
    inboundForm.items.push({ productId: '', variantId: '', warehouseId: props.warehouses[0]?.id || '', qty: 1, unitCost: 0 });
};

const removeInboundItem = (index) => {
    inboundForm.items.splice(index, 1);
};

const submitInbound = () => {
    inboundForm.post('/owner/inbounds', {
        onSuccess: () => {
            isInboundModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

const markInboundReceived = (id) => {
    if (confirm('Yakin ingin menandai pesanan ini sebagai DITERIMA? Stok gudang akan otomatis bertambah.')) {
        router.put(`/owner/inbounds/${id}/status`, { status: 'received' }, { preserveScroll: true });
    }
};

const markInboundCancelled = (id) => {
    if (confirm('Yakin ingin membatalkan pesanan kulakan ini?')) {
        router.put(`/owner/inbounds/${id}/status`, { status: 'cancelled' }, { preserveScroll: true });
    }
};

// ==========================================
// OUTBOUND (Logistik Keluar) STATE
// ==========================================
const outboundTab = ref('orders'); // 'orders' or 'transfers'
const outboundSearchQuery = ref('');
const outboundDateFilter = ref('');
const outboundWarehouseFilter = ref('Semua');

const filteredStockTransfers = computed(() => {
    return props.stockTransfers.filter(st => {
        let match = true;
        if (outboundWarehouseFilter.value && outboundWarehouseFilter.value !== 'Semua') {
            const fw = props.warehouses.find(w => w.id === st.fromWarehouseId);
            const tw = props.warehouses.find(w => w.id === st.toWarehouseId);
            match = (fw && fw.name === outboundWarehouseFilter.value) || (tw && tw.name === outboundWarehouseFilter.value);
        }
        return match;
    });
});

const warehouseFilterOptions = computed(() => {
    return ['Semua', ...props.warehouses.map(w => w.name), 'Toko'];
});

const filteredOutbounds = computed(() => {
    let result = (props.orders || []).filter(o => ['shipping', 'completed'].includes(o.status?.toLowerCase()));
    
    if (outboundSearchQuery.value) {
        const q = outboundSearchQuery.value.toLowerCase();
        result = result.filter(order => 
            order.id.toLowerCase().includes(q) || 
            (order.shippingMethod || '').toLowerCase().includes(q) ||
            (order.shipping?.waybillId || '').toLowerCase().includes(q)
        );
    }
    if (outboundDateFilter.value) {
        result = result.filter(order => {
            if (!order.date) return false;
            return order.date.startsWith(outboundDateFilter.value);
        });
    }
    if (outboundWarehouseFilter.value && outboundWarehouseFilter.value !== 'Semua') {
        result = result.filter(order => {
            const orderWarehouses = getOrderWarehouses(order);
            return orderWarehouses.includes(outboundWarehouseFilter.value);
        });
    }
    return result;
});

// INBOUND FILTERS
const inboundSearchQuery = ref('');
const inboundDateFilter = ref('');
const inboundWarehouseFilter = ref('Semua');

const filteredInbounds = computed(() => {
    let result = props.inbounds || [];
    if (inboundSearchQuery.value) {
        const q = inboundSearchQuery.value.toLowerCase();
        result = result.filter(po => 
            `po-${po.id}`.toLowerCase().includes(q) || 
            (po.supplierName || '').toLowerCase().includes(q)
        );
    }
    if (inboundDateFilter.value) {
        result = result.filter(po => {
            if (!po.expectedDate) return false;
            return po.expectedDate.startsWith(inboundDateFilter.value);
        });
    }
    if (inboundWarehouseFilter.value && inboundWarehouseFilter.value !== 'Semua') {
        result = result.filter(po => {
            let whName = 'Toko';
            if (po.items && po.items.length > 0) {
                const wId = po.items[0].warehouseId;
                const wh = props.warehouses.find(w => w.id === wId);
                if (wh) whName = wh.name;
            }
            return whName === inboundWarehouseFilter.value;
        });
    }
    return result;
});

const printLabel = (orderId) => {
    alert("Fitur Proses Pesanan & Kirim akan segera hadir!"); // Placeholder for actual printing
};

// Filtered products based on search and stock filter
const filteredProducts = computed(() => {
    let list = props.products || [];
    
    // Search filter
    if (searchQuery.value.trim()) {
        const q = searchQuery.value.toLowerCase();
        list = list.filter(p => 
            p.name?.toLowerCase().includes(q) || 
            p.id?.toLowerCase().includes(q) ||
            p.category?.toLowerCase().includes(q)
        );
    }
    
    // Category filter
    if (categoryFilter.value) {
        list = list.filter(p => p.category === categoryFilter.value);
    }
    
    // Stock tab filter
    if (productFilter.value === 'habis') {
        list = list.filter(p => (p.stock ?? 0) <= 0);
    } else {
        list = list.filter(p => (p.stock ?? 0) > 0);
    }
    
    return list;
});

const uniqueCategories = computed(() => {
    if (!props.products) return [];
    const categories = new Set(props.products.map(p => p.category).filter(Boolean));
    return Array.from(categories).sort();
});

const orderSearchQuery = ref('');
const orderDateFilter = ref('');
const orderStatusFilter = ref('Semua');

const filteredOrders = computed(() => {
    let ordersToFilter = props.orders || [];
    
    if (orderSearchQuery.value) {
        const q = orderSearchQuery.value.toLowerCase();
        ordersToFilter = ordersToFilter.filter(o => 
            o.id.toLowerCase().includes(q) || 
            (o.items && o.items.some(item => item.name.toLowerCase().includes(q))) ||
            (o.customer && o.customer.toLowerCase().includes(q))
        );
    }
    
    if (orderDateFilter.value) {
        ordersToFilter = ordersToFilter.filter(o => {
            if (!o.createdAt) return false;
            // Handle ISO date format YYYY-MM-DD
            return o.createdAt.startsWith(orderDateFilter.value);
        });
    }

    if (orderStatusFilter.value && orderStatusFilter.value !== 'Semua') {
        ordersToFilter = ordersToFilter.filter(o => {
            const s = o.status?.toLowerCase();
            const filterMap = {
                'Menunggu Konfirmasi': ['pending'],
                'Diproses': ['success'],
                'Dikirim': ['shipping'],
                'Dibatalkan': ['cancelled'],
                'Selesai': ['completed']
            };
            const expectedStatuses = filterMap[orderStatusFilter.value] || [];
            return expectedStatuses.includes(s);
        });
    }
    
    return ordersToFilter;
});

const historyOrders = computed(() => {
    return filteredOrders.value.filter(o => o.status?.toLowerCase() === 'completed');
});

const resetOrderFilters = () => {
    orderSearchQuery.value = '';
    orderDateFilter.value = '';
    orderStatusFilter.value = 'Semua';
};



const updateOrderStatus = (orderId, nextStatus) => {
    if (nextStatus === 'cancelled') {
        if (!confirm('Apakah Anda yakin ingin membatalkan pesanan ini?')) {
            return;
        }
    }
    
    router.put(`/owner/orders/${orderId}/status`, { status: nextStatus }, {
        preserveScroll: true,
    });
};


const handleCreateAdmin = () => {
    newAdminForm.post('/owner/admins', {
        onSuccess: () => {
            newAdminForm.reset();
            isCreateAdminModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

const isEditAdminModalOpen = ref(false);
const editAdminForm = useForm({
    username: '',
    name: '',
    phone: '',
    email: '',
    password: '',
});

const openEditAdminModal = (admin) => {
    editAdminForm.username = admin.username;
    editAdminForm.name = admin.name;
    editAdminForm.phone = admin.phone || '';
    editAdminForm.email = admin.email || '';
    editAdminForm.password = '';
    isEditAdminModalOpen.value = true;
};

const handleUpdateAdmin = () => {
    editAdminForm.put(`/owner/admins/${editAdminForm.username}`, {
        onSuccess: () => {
            isEditAdminModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

const handleDeleteAdmin = (adminUsername) => {
    if (confirm(`Apakah Anda yakin ingin menghapus staf admin "${adminUsername}"?`)) {
        router.delete(`/owner/admins/${adminUsername}`, {
            preserveScroll: true,
        });
    }
};
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container">
                <div style="display: grid; grid-template-columns: 280px 1fr; gap: 32px; align-items: start;">
                    
                    <!-- Sidebar -->
                    <div style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                        <!-- Profile -->
                        <div 
                            class="d-flex align-center gap-4 mb-4" 
                            @click="activeTab = 'profile'" 
                            style="cursor: pointer; padding: 12px; border-radius: 8px; transition: background 0.2s; margin: -12px -12px 16px -12px;"
                            :style="activeTab === 'profile' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent; hover: background: #f8fafc;'"
                        >
                            <div style="width: 48px; height: 48px; background: #e11d48; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 800; box-shadow: 0 4px 10px rgba(225, 29, 72, 0.4);">
                                {{ username ? username.charAt(0).toUpperCase() : 'O' }}
                            </div>
                            <div>
                                <h3 style="font-size: 16px; font-weight: 800; margin: 0; color: #0f172a;">{{ username }}</h3>
                                <div style="font-size: 13px; color: #64748b;">Sistem Kontrol Utama</div>
                            </div>
                        </div>
                        
                        <div style="height: 1px; background: #e2e8f0; margin: 16px 0;"></div>
                        
                        <!-- Menu -->
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <div 
                                @click="activeTab = 'dashboard'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'dashboard' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'dashboard' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Dashboard Owner</span>
                                <div v-if="activeTab === 'dashboard'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>

                            <div 
                                @click="activeTab = 'products'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'products' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'products' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Stok Produk</span>
                                <div v-if="activeTab === 'products'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'warehouses'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'warehouses' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'warehouses' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Manajemen Gudang</span>
                                <div v-if="activeTab === 'warehouses'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'validasi'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'validasi' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'validasi' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Validasi Pembayaran</span>
                                <div v-if="activeTab === 'validasi'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'histori'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'histori' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'histori' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Histori Transaksi</span>
                                <div v-if="activeTab === 'histori'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'admins'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'admins' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'admins' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Kelola Staf Admin</span>
                                <div v-if="activeTab === 'admins'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Main Content -->
                    <div>
                        <!-- Tab Profil Saya -->
                        <div v-if="activeTab === 'profile'" style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                            <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin-top: 0; margin-bottom: 24px;">Profil Saya</h3>
                            
                            <form @submit.prevent="saveProfile">
                                <div v-if="$page.props.flash.success" style="background: #ecfdf5; color: #065f46; padding: 12px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #10b981; font-weight: 600; font-size: 14px;">
                                    {{ $page.props.flash.success }}
                                </div>
                                <div v-if="$page.props.flash.error" style="background: #fef2f2; color: #b91c1c; padding: 12px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #ef4444; font-weight: 600; font-size: 14px;">
                                    {{ $page.props.flash.error }}
                                </div>
                                <div v-if="profileForm.errors.username" style="background: #fef2f2; color: #b91c1c; padding: 12px; border-radius: 8px; margin-bottom: 24px; border: 1px solid #ef4444; font-weight: 600; font-size: 14px;">
                                    {{ profileForm.errors.username }}
                                </div>
                                
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Nama Lengkap</label>
                                    <input type="text" v-model="profileForm.name" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;" required>
                                </div>
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Username</label>
                                    <input type="text" v-model="profileForm.username" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;" required>
                                </div>
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Email</label>
                                    <input type="email" v-model="profileForm.email" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                                </div>
                                <div class="form-group mb-4">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Nomor HP</label>
                                    <input type="text" v-model="profileForm.phone" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                                </div>
                                <div class="form-group mb-6">
                                    <label class="form-label" style="font-size: 14px; font-weight: 600; color: #475569; margin-bottom: 8px; display: block;">Password Baru <span style="font-weight: 400; color: #94a3b8;">(Kosongkan jika tidak ingin mengubah)</span></label>
                                    <input type="password" v-model="profileForm.password" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;" placeholder="Min. 3 karakter">
                                </div>
                                
                                <button type="submit" style="padding: 12px 24px; background: #e11d48; color: white; border-radius: 8px; font-weight: 700; border: none; cursor: pointer;" :disabled="profileForm.processing">Simpan Perubahan</button>
                            </form>
                        </div>
                        
                        <template v-else>
                        <!-- Tab 0: Dashboard Owner (Stats Only) -->
                        <div v-if="activeTab === 'dashboard'" class="stats-grid mb-6">
                            <div class="stat-card" style="position: relative;">
                                <div class="d-flex justify-between align-center mb-2">
                                    <span class="stat-title" style="margin: 0; text-transform: uppercase;">Omzet Hari Ini</span>
                                    <select v-model="omzetType" style="padding: 2px 8px; font-size: 11px; border-radius: 4px; border: 1px solid #cbd5e1; outline: none; background: #f8fafc; cursor: pointer;">
                                        <option value="kotor">Kotor</option>
                                        <option value="bersih">Bersih</option>
                                    </select>
                                </div>
                                <span class="stat-value" style="color:var(--color-primary)">
                                    {{ formatPrice(omzetType === 'kotor' ? stats.totalRevenueKotor : stats.totalRevenueBersih) }}
                                </span>
                                <div style="font-size: 11px; color: #64748b; margin-top: 4px; font-weight: 500;">
                                    {{ omzetType === 'kotor' ? 'Termasuk ongkir & PPN' : 'Harga barang saja' }}
                                </div>
                            </div>
                            <div class="stat-card">
                                <span class="stat-title">Transaksi Selesai</span>
                                <span class="stat-value">{{ stats.salesCount }}</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-title" style="color: var(--color-warning);">Butuh Restock</span>
                                <span class="stat-value" style="color: var(--color-warning);">{{ stats.stockIssuesCount }}</span>
                            </div>
                            <div class="stat-card">
                                <span class="stat-title">Staf Administrator</span>
                                <span class="stat-value">{{ stats.totalAdmins }}</span>
                            </div>
                        </div>

                        <!-- Tab 1: Products - Manajemen Stok Barang -->
                <div v-if="activeTab === 'products'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <div class="d-flex justify-between align-center w-100">
                            <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Manajemen Stok Barang</h3>
                        </div>

                        <!-- Search + Filter + Add Button Row -->
                        <div class="d-flex justify-between align-center w-100" style="gap: 12px; flex-wrap: wrap;">
                            <div class="d-flex" style="gap: 10px; flex-direction: column;">
                                <div class="d-flex align-center" style="gap: 10px;">
                                    <!-- Search Bar -->
                                    <div style="position: relative;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 50%; transform: translateY(-50%);">
                                            <circle cx="11" cy="11" r="8"></circle>
                                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                        </svg>
                                        <input 
                                            v-model="searchQuery"
                                            type="text" 
                                            placeholder="Cari Nama Produk" 
                                            style="padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; width: 220px; outline: none; background: white;"
                                        >
                                    </div>
                                    <!-- Filter Button -->
                                    <button style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; background: white; cursor: pointer; display: flex; align-items: center; justify-content: center;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <line x1="4" y1="6" x2="20" y2="6"></line>
                                            <line x1="6" y1="12" x2="18" y2="12"></line>
                                            <line x1="8" y1="18" x2="16" y2="18"></line>
                                        </svg>
                                    </button>
                                </div>
                                
                                <div class="d-flex align-center" style="gap: 12px; flex-wrap: wrap;">
                                    <!-- Category Dropdown Filter -->
                                    <select v-model="categoryFilter" style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 13px; outline: none; background: white; width: fit-content; min-width: 160px;">
                                        <option value="">Semua Kategori</option>
                                        <option v-for="cat in uniqueCategories" :key="cat" :value="cat">{{ cat }}</option>
                                    </select>

                                    <!-- Aktif / Stok Habis Pills -->
                                    <div class="d-flex align-center" style="background: #f1f5f9; padding: 4px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                        <div 
                                            @click="productFilter = 'aktif'"
                                            style="padding: 6px 16px; font-size: 13px; font-weight: 600; cursor: pointer; border-radius: 6px; transition: all 0.2s;"
                                            :style="productFilter === 'aktif' ? 'background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'color: #64748b;'"
                                        >
                                            Stok Tersedia
                                        </div>
                                        <div 
                                            @click="productFilter = 'habis'"
                                            style="padding: 6px 16px; font-size: 13px; font-weight: 600; cursor: pointer; border-radius: 6px; transition: all 0.2s;"
                                            :style="productFilter === 'habis' ? 'background: white; color: #dc2626; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'color: #64748b;'"
                                        >
                                            Stok Habis
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- Add Product Button -->
                            <Link 
                                href="/owner/products/create"
                                style="padding: 8px 18px; font-size: 13px; font-weight: 700; color: #0f172a; border: 1px solid #cbd5e1; border-radius: 8px; background: white; cursor: pointer; text-decoration: none; white-space: nowrap; transition: all 0.2s; align-self: flex-start;"
                            >
                                + Tambah Produk Baru
                            </Link>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="width: 80px;">ID</th>
                                    <th>Nama Produk</th>
                                    <th>Kategori</th>
                                    <th>Gudang</th>
                                    <th class="text-center" style="width: 80px;">Stok</th>
                                    <th class="text-center" style="width: 90px;">Terjual</th>
                                    <th class="text-center" style="width: 80px;">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="product in filteredProducts" :key="product.id">
                                    <td style="font-weight: 700; font-family: monospace; font-size: 13px; color: #475569;">{{ product.id }}</td>
                                    <td style="font-weight: 600; color: #0f172a;">{{ product.name }}</td>
                                    <td style="color: #475569;">{{ product.category }}</td>
                                    <td style="color: #475569; font-size: 13px;">
                                        {{ getProductWarehouses(product) }}
                                    </td>
                                    <td class="text-center" style="font-weight: 800;" :style="product.stock <= 5 ? { color: '#06b6d4' } : { color: '#06b6d4' }">
                                        {{ product.stock }}
                                    </td>
                                    <td class="text-center" style="font-weight: 700; color: #06b6d4;">
                                        {{ product.sold || 0 }}
                                    </td>
                                    <td class="text-center">
                                        <div class="d-flex align-center justify-center gap-2">
                                            <button
                                                @click="openVariantModal(product)"
                                                style="padding: 5px 14px; font-size: 12px; font-weight: 600; color: #475569; border: 1px solid #cbd5e1; border-radius: 6px; background: #f8fafc; cursor: pointer; transition: all 0.2s;"
                                            >
                                                Varian
                                            </button>
                                            <Link
                                                :href="`/owner/products/${product.id}/edit`"
                                                style="padding: 5px 14px; font-size: 12px; font-weight: 600; color: #475569; border: 1px solid #cbd5e1; border-radius: 6px; background: #f8fafc; cursor: pointer; text-decoration: none; display: inline-block; transition: all 0.2s;"
                                            >
                                                Atur
                                            </Link>
                                        </div>
                                    </td>
                                </tr>
                                <tr v-if="filteredProducts.length === 0">
                                    <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">
                                        {{ productFilter === 'habis' ? 'Tidak ada produk dengan stok habis.' : 'Tidak ada produk ditemukan.' }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 1.5: Manajemen Gudang -->
                <div v-else-if="activeTab === 'warehouses'" class="table-card">
                    <!-- Inner Tabs for Warehouse Module -->
                    <div class="d-flex align-center gap-2 mb-4" style="background: #f8fafc; padding: 6px; border-radius: 8px; border: 1px solid #e2e8f0; display: inline-flex;">
                        <button @click="warehouseTab = 'list'" :style="warehouseTab === 'list' ? 'background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'background: transparent; color: #64748b;'" style="padding: 8px 16px; border-radius: 6px; font-weight: 600; font-size: 13px; border: none; cursor: pointer; transition: all 0.2s;">
                            Daftar Gudang
                        </button>
                        <button @click="warehouseTab = 'inbound'" :style="warehouseTab === 'inbound' ? 'background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'background: transparent; color: #64748b;'" style="padding: 8px 16px; border-radius: 6px; font-weight: 600; font-size: 13px; border: none; cursor: pointer; transition: all 0.2s;">
                            Logistik Masuk (Inbound)
                        </button>
                        <button @click="warehouseTab = 'outbound'" :style="warehouseTab === 'outbound' ? 'background: white; color: #0f172a; box-shadow: 0 1px 3px rgba(0,0,0,0.1);' : 'background: transparent; color: #64748b;'" style="padding: 8px 16px; border-radius: 6px; font-weight: 600; font-size: 13px; border: none; cursor: pointer; transition: all 0.2s;">
                            Logistik Keluar (Outbound)
                        </button>
                    </div>

                    <!-- Warehouse List -->
                    <div v-if="warehouseTab === 'list'">
                        <div class="table-header" style="flex-direction: column; gap: 16px;">
                            <div class="d-flex justify-between align-center w-100">
                                <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Manajemen Gudang</h3>
                            </div>
                            <div class="d-flex justify-between align-center w-100" style="gap: 12px; flex-wrap: wrap;">
                                <div class="d-flex gap-2">
                                    <button @click="isCreateWarehouseModalOpen = true" class="btn btn-primary">+ Tambah Gudang</button>
                                </div>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th style="width: 50px;" class="text-center">No.</th>
                                        <th style="width: 80px;">ID</th>
                                        <th>Nama Gudang</th>
                                        <th>Deskripsi</th>
                                        <th class="text-center" style="width: 120px;">Status</th>
                                        <th class="text-center" style="width: 120px;">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="(w, index) in warehouses" :key="w.id">
                                        <td class="text-center" style="font-weight: 600; color: #64748b;">{{ index + 1 }}</td>
                                        <td style="font-weight: 700; font-family: monospace; font-size: 13px; color: #475569;">{{ w.id }}</td>
                                        <td style="font-weight: 600; color: #0f172a;">{{ w.name }}</td>
                                        <td style="color: #475569;">{{ w.description || '-' }}</td>
                                        <td class="text-center">
                                            <span class="status-pill" :class="w.isActive ? 'success' : 'cancelled'">
                                                {{ w.isActive ? 'Aktif' : 'Non-Aktif' }}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <button @click="openEditWarehouseModal(w)" class="btn btn-outline" style="padding: 4px 10px; font-size: 11px;">Edit</button>
                                        </td>
                                    </tr>
                                    <tr v-if="warehouses.length === 0">
                                        <td colspan="5" class="text-center text-muted" style="padding: 40px 0;">Belum ada data gudang.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Inbound Module -->
                    <div v-else-if="warehouseTab === 'inbound'">
                        <div class="table-header" style="flex-direction: column; gap: 16px;">
                            <div class="d-flex justify-between align-center w-100">
                                <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Logistik Masuk (Inbound Kulakan)</h3>
                            </div>
                            <div class="d-flex justify-between align-center w-100" style="gap: 12px; flex-wrap: wrap;">
                                <div class="d-flex gap-4 flex-wrap" style="flex: 1;">
                                    <div style="position: relative; flex: 1; min-width: 200px;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                        <input v-model="inboundSearchQuery" type="text" placeholder="Cari ID PO atau Supplier" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                                    </div>
                                    <div style="position: relative; flex: 1; min-width: 150px;">
                                        <input v-model="inboundDateFilter" type="date" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                                    </div>
                                    <div style="position: relative; flex: 1; min-width: 150px;">
                                        <select v-model="inboundWarehouseFilter" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569; background: white; cursor: pointer;">
                                            <option v-for="opt in warehouseFilterOptions" :key="opt" :value="opt">{{ opt === 'Semua' ? 'Semua Gudang' : opt }}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="d-flex gap-2">
                                    <button @click="openInboundModal" class="btn btn-primary">+ Tambah Kulakan Baru</button>
                                </div>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th style="width: 50px;" class="text-center">No.</th>
                                        <th style="width: 80px;">ID PO</th>
                                        <th>Supplier</th>
                                        <th>Gudang</th>
                                        <th>Tgl. Estimasi</th>
                                        <th class="text-right">Total Biaya</th>
                                        <th class="text-center">Status</th>
                                        <th class="text-center" style="width: 140px;">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="(po, index) in filteredInbounds" :key="po.id" @click="openInboundDetailModal(po)" style="cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                                        <td class="text-center" style="font-weight: 600; color: #64748b;">{{ index + 1 }}</td>
                                        <td style="font-weight: 700; font-family: monospace; font-size: 13px; color: #475569;">PO-{{ po.id }}</td>
                                        <td style="font-weight: 600; color: #0f172a;">{{ po.supplierName }}</td>
                                        <td style="color: #475569;">{{ po.items && po.items.length > 0 ? (warehouses.find(w => w.id === po.items[0].warehouseId)?.name || '-') : '-' }}</td>
                                        <td style="color: #475569;">{{ formatDate(po.expectedDate) }}</td>
                                        <td class="text-right" style="font-weight: 600; color: #dc2626;">{{ formatPrice(po.totalCost) }}</td>
                                        <td class="text-center">
                                            <span class="status-pill" :class="po.status === 'received' ? 'success' : (po.status === 'cancelled' ? 'cancelled' : 'pending')">
                                                {{ po.status === 'received' ? 'Diterima' : (po.status === 'cancelled' ? 'Dibatalkan' : 'Menunggu') }}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <div v-if="po.status === 'pending'" class="d-flex gap-2 justify-center">
                                                <button @click.stop="markInboundReceived(po.id)" class="btn btn-primary" style="padding: 4px 10px; font-size: 11px;">Diterima</button>
                                                <button @click.stop="markInboundCancelled(po.id)" class="btn btn-outline" style="padding: 4px 10px; font-size: 11px; color: #dc2626; border-color: #dc2626;">Batal</button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr v-if="!filteredInbounds || filteredInbounds.length === 0">
                                        <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">Tidak ada pesanan kulakan yang sesuai dengan pencarian Anda.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Outbound Module -->
                    <div v-else-if="warehouseTab === 'outbound'">
                        <div style="display: flex; gap: 12px; margin-bottom: 24px; border-bottom: 1px solid #e2e8f0;">
                            <button @click="outboundTab = 'orders'" :style="outboundTab === 'orders' ? 'border-bottom: 2px solid #3b82f6; color: #3b82f6;' : 'color: #64748b;'" style="padding: 10px 16px; font-weight: 600; font-size: 14px; border: none; border-bottom: 2px solid transparent; background: transparent; cursor: pointer;">Pesanan Pelanggan (Ekspedisi)</button>
                            <button @click="outboundTab = 'transfers'" :style="outboundTab === 'transfers' ? 'border-bottom: 2px solid #3b82f6; color: #3b82f6;' : 'color: #64748b;'" style="padding: 10px 16px; font-weight: 600; font-size: 14px; border: none; border-bottom: 2px solid transparent; background: transparent; cursor: pointer;">Riwayat Transfer Stok</button>
                        </div>
                        
                        <div v-if="outboundTab === 'orders'">
                            <div class="table-header" style="flex-direction: column; gap: 16px;">
                            <div class="d-flex justify-between align-center w-100">
                                <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Logistik Keluar (Pemantauan Ekspedisi)</h3>
                            </div>
                            <div class="d-flex justify-between align-center w-100" style="gap: 12px; flex-wrap: wrap;">
                                <div class="d-flex gap-4 flex-wrap" style="flex: 1;">
                                    <div style="position: relative; flex: 1; min-width: 200px;">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                        <input v-model="outboundSearchQuery" type="text" placeholder="Cari ID Order atau Metode Pengiriman" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                                    </div>
                                    <div style="position: relative; flex: 1; min-width: 150px;">
                                        <input v-model="outboundDateFilter" type="date" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                                    </div>
                                    <div style="position: relative; flex: 1; min-width: 150px;">
                                        <select v-model="outboundWarehouseFilter" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569; background: white; cursor: pointer;">
                                            <option v-for="opt in warehouseFilterOptions" :key="opt" :value="opt">{{ opt === 'Semua' ? 'Semua Gudang' : opt }}</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th style="width: 80px;">ID Order</th>
                                        <th>Tanggal</th>
                                        <th>Gudang</th>
                                        <th>Metode Pengiriman</th>
                                        <th>Kurir & Resi (Biteship)</th>
                                        <th class="text-center">Status Transaksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <template v-for="order in filteredOutbounds" :key="order.id">
                                        <tr @click="toggleOrderDetails(order.id)" style="border-bottom: none; cursor: pointer; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor='#f8fafc'" onmouseout="this.style.backgroundColor='transparent'">
                                            <td style="font-weight: 700; font-family: monospace; font-size: 13px; color: #475569;">
                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <svg :style="{ transform: expandedOrders.includes(order.id) ? 'rotate(90deg)' : 'rotate(0)' }" style="transition: transform 0.2s; color: #94a3b8;" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                                                    {{ order.id }}
                                                </div>
                                            </td>
                                            <td style="color: #475569;">{{ formatDate(order.createdAt) }}</td>
                                            <td style="color: #475569;">{{ getOrderWarehouses(order) }}</td>
                                            <td style="font-weight: 600; color: #0f172a;">{{ order.shippingMethod || '-' }}</td>
                                            <td style="color: #475569;">
                                                <div v-if="order.shipping && order.shipping.waybillId">
                                                    <div style="font-weight: 700; color: #0f172a; margin-bottom: 2px;">{{ order.shipping.courierCompany || order.shipping.courierCode || '-' }}</div>
                                                    <span style="font-weight: 600;">Resi:</span> {{ order.shipping.waybillId }}
                                                </div>
                                                <div v-else class="text-muted">-</div>
                                            </td>
                                            <td class="text-center">
                                                <span class="status-pill" :class="getStatusClass(order.status)">
                                                    {{ getStatusLabel(order.status) }}
                                                </span>
                                            </td>
                                        </tr>
                                        <!-- Row Detail Data Barang & Inventaris -->
                                        <tr v-if="expandedOrders.includes(order.id)">
                                            <td colspan="6" style="padding: 0 16px 16px 16px; border-top: none;">
                                                <div style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0; overflow-x: auto;">
                                                    <div style="font-size: 12px; font-weight: 800; color: #334155; margin-bottom: 12px; text-transform: uppercase; position: sticky; left: 0;">Detail Outbound & Pembaruan Inventaris</div>
                                                    <table style="width: 100%; border-collapse: collapse; min-width: 600px;">
                                                        <thead>
                                                            <tr style="border-bottom: 1px solid #cbd5e1; color: #64748b; font-size: 11px; text-transform: uppercase;">
                                                                <th style="text-align: left; padding-bottom: 8px; font-weight: 700;">Nama Produk / Deskripsi</th>
                                                                <th style="text-align: center; padding-bottom: 8px; font-weight: 700;">Qty Keluar</th>
                                                                <th style="text-align: center; padding-bottom: 8px; font-weight: 700;">UOM</th>
                                                                <th v-for="wh in warehouses" :key="wh.id" style="text-align: center; padding-bottom: 8px; font-weight: 700;">Stok Aktual ({{ wh.name }})</th>
                                                                <th style="text-align: center; padding-bottom: 8px; font-weight: 700;">Stok Alokasi</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <tr v-for="item in order.items" :key="item.id" style="border-bottom: 1px solid #f1f5f9; font-size: 12px;">
                                                                <td style="padding: 10px 0; color: #0f172a; font-weight: 600;">
                                                                    {{ item.name }}
                                                                    <div v-if="item.color" style="font-size: 11px; color: #64748b; font-weight: 400; margin-top: 2px;">Variant: {{ item.color }}</div>
                                                                </td>
                                                                <td style="text-align: center; padding: 10px 0; font-weight: 700; color: #16a34a;">{{ item.qty }}</td>
                                                                <td style="text-align: center; padding: 10px 0; color: #475569;">{{ getProductUnit(item.productId) }}</td>
                                                                <td v-for="wh in warehouses" :key="'data-'+wh.id" style="text-align: center; padding: 10px 0; color: #475569;">{{ getActualStock(item.productId, wh.id, item.variantId) }}</td>
                                                                <td style="text-align: center; padding: 10px 0; color: #ea580c;">{{ getAllocatedStock(item.productId, item.warehouseId, item.variantId) }}</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                    </template>
                                    <tr v-if="filteredOutbounds.length === 0">
                                        <td colspan="4" class="text-center text-muted" style="padding: 40px 0;">Tidak ada pesanan logistik yang sesuai dengan pencarian Anda.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        </div>
                        
                        <div v-if="outboundTab === 'transfers'">
                            <div class="table-header" style="margin-bottom: 16px;">
                                <h3 style="font-size: 20px; font-weight: 800; color: #0f172a; margin: 0;">Riwayat Transfer Stok Internal</h3>
                                <div style="position: relative; width: 200px;">
                                    <select v-model="outboundWarehouseFilter" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569; background: white; cursor: pointer;">
                                        <option v-for="opt in warehouseFilterOptions" :key="opt" :value="opt">{{ opt === 'Semua' ? 'Semua Gudang' : opt }}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="data-table">
                                    <thead>
                                        <tr>
                                            <th>Tanggal</th>
                                            <th>Produk</th>
                                            <th>Dari Gudang</th>
                                            <th>Ke Gudang</th>
                                            <th class="text-center">Jumlah</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="st in filteredStockTransfers" :key="st.id">
                                            <td style="color: #475569; font-size: 13px;">{{ formatDate(st.createdAt) }}</td>
                                            <td style="font-weight: 600; color: #0f172a; font-size: 13px;">{{ st.product ? st.product.name : st.productId }}</td>
                                            <td style="color: #ea580c; font-weight: 600; font-size: 13px;">{{ st.fromWarehouse ? st.fromWarehouse.name : 'ID: ' + st.fromWarehouseId }}</td>
                                            <td style="color: #16a34a; font-weight: 600; font-size: 13px;">{{ st.toWarehouse ? st.toWarehouse.name : 'ID: ' + st.toWarehouseId }}</td>
                                            <td class="text-center" style="font-weight: 700; font-size: 14px;">{{ st.quantity }}</td>
                                        </tr>
                                        <tr v-if="filteredStockTransfers.length === 0">
                                            <td colspan="5" class="text-center text-muted" style="padding: 40px 0;">Tidak ada riwayat transfer stok.</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab 2: Validasi Pembayaran -->
                <div v-else-if="activeTab === 'validasi'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <h3 style="font-size:20px; font-weight: 800; color: #0f172a; margin: 0; align-self: flex-start;">Validasi Pembayaran</h3>
                        
                        <!-- Order Filters -->
                        <div class="d-flex align-center gap-4 flex-wrap w-100" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                            <!-- Search -->
                            <div style="position: relative; flex: 1; min-width: 250px;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                <input v-model="orderSearchQuery" type="text" placeholder="Cari ID Pesanan / Produk" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                            </div>
                            
                            <!-- Date Filter -->
                            <div style="position: relative; min-width: 150px;">
                                <input v-model="orderDateFilter" type="date" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                            </div>
                        </div>

                        <!-- Status Pills -->
                        <div class="d-flex align-center gap-2 flex-wrap w-100">
                            <span style="font-size: 13px; font-weight: 700; color: #64748b; margin-right: 8px;">Status:</span>
                            <template v-for="status in ['Semua', 'Menunggu Konfirmasi', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan']" :key="status">
                                <button
                                    @click="orderStatusFilter = status"
                                    style="padding: 4px 12px; font-size: 12px; border-radius: 16px; cursor: pointer; transition: all 0.2s; border: 1px solid;"
                                    :style="orderStatusFilter === status ? 'background: #eafff2; color: #16a34a; border-color: #16a34a; font-weight: 600;' : 'background: white; color: #64748b; border-color: #cbd5e1;'"
                                >
                                    {{ status }}
                                </button>
                            </template>
                            <span @click="resetOrderFilters" style="font-size: 12px; font-weight: 700; color: #16a34a; cursor: pointer; margin-left: auto;">Reset Filter</span>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">ID Order</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Tanggal</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Metode Pengiriman</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Item Pesanan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nominal Tagihan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Status</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;" class="text-center">Bukti Pembayaran</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;" class="text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in filteredOrders" :key="order.id" @click="openOrderDetailModal(order)" style="cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                                    <!-- ID Order -->
                                    <td style="font-weight: 800; font-family: monospace; color: #0f172a;">
                                        {{ order.id }}
                                    </td>

                                    <!-- Tanggal -->
                                    <td style="color: #475569;">{{ formatDate(order.createdAt) }}</td>

                                    <!-- Metode Pengiriman -->
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.shippingMethod || 'JNE' }}
                                    </td>

                                    <!-- Item Pesanan -->
                                    <td>
                                        <div v-for="item in order.items" :key="item.productId" style="margin-bottom: 8px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
                                            <div style="font-size: 12px; font-weight: 700; color: #0f172a;">{{ item.name }} ({{ item.qty }}x)</div>
                                            <div v-if="item.color" style="font-size: 11px; color: #64748b; margin-top: 2px;">Warna: <span style="font-weight: 600;">{{ item.color }}</span></div>
                                        </div>
                                    </td>

                                    <!-- Nominal Tagihan -->
                                    <td style="font-weight: 800; color: #dc2626;">
                                        {{ formatPrice(order.total || order.totalAmount || 0) }}
                                    </td>

                                    <!-- Status -->
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>

                                    <!-- Bukti Pembayaran -->
                                    <td class="text-center">
                                        <a v-if="order.proofUploaded && order.proofUrl" :href="order.proofUrl" target="_blank" class="d-flex align-center justify-center gap-2" style="color: #0284c7; font-weight: 600; font-size: 12px; text-decoration: none; cursor: pointer;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                                <circle cx="12" cy="12" r="3"></circle>
                                            </svg>
                                            Lihat
                                        </a>
                                        <div v-else-if="order.proofUploaded" style="color: #94a3b8; font-style: italic; font-size: 12px;">
                                            Uploaded
                                        </div>
                                        <div v-else style="color: #94a3b8; font-style: italic; font-size: 12px;">
                                            -
                                        </div>
                                    </td>

                                    <!-- Aksi: Conditional per status & shipping type -->
                                    <td class="text-center">
                                        <!-- Validasi Pembayaran untuk Pending -->
                                        <div v-if="order.status?.toLowerCase() === 'pending'" class="d-flex align-center justify-center gap-2">
                                            <template v-if="order.payment && (order.payment.paymentMethod?.toLowerCase().includes('midtrans') || order.payment.paymentMethod?.toLowerCase().includes('online'))">
                                                <span style="color: #64748b; font-size: 11px; font-style: italic;">Menunggu<br>Sistem Midtrans</span>
                                            </template>
                                            <template v-else>
                                                <button 
                                                    @click="updateOrderStatus(order.id, 'success')"
                                                    class="btn btn-primary"
                                                    style="padding: 4px 10px; font-size:11px; background:#0284c7; border-color:#0284c7; border-radius: 4px;"
                                                >
                                                    Validasi
                                                </button>
                                                <button 
                                                    @click="updateOrderStatus(order.id, 'cancelled')"
                                                    class="btn btn-outline"
                                                    style="padding: 4px 10px; font-size:11px; color: #dc2626; border-color: #dc2626; border-radius: 4px;"
                                                >
                                                    Tolak
                                                </button>
                                            </template>
                                        </div>

                                        <!-- Logistik dipindah ke admin -->
                                        <template v-else>
                                            <div class="d-flex align-center justify-center gap-2">
                                                <button v-if="order.status?.toLowerCase() !== 'cancelled' && order.status?.toLowerCase() !== 'completed'"
                                                    @click="updateOrderStatus(order.id, 'cancelled')"
                                                    class="btn btn-outline"
                                                    style="padding: 4px 10px; font-size:11px; color: #dc2626; border-color: #dc2626; border-radius: 4px;"
                                                    title="Batalkan secara manual jika sudah dibatalkan di Biteship"
                                                >
                                                    Batalkan
                                                </button>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                            </div>
                                        </template>
                                    </td>
                                </tr>
                                <tr v-if="filteredOrders.length === 0">
                                    <td colspan="8" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada rekap order yang sesuai.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 2.5: Histori Transaksi -->
                <div v-else-if="activeTab === 'histori'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <h3 style="font-size:20px; font-weight: 800; color: #0f172a; margin: 0; align-self: flex-start;">Histori Transaksi</h3>
                        
                        <!-- Order Filters -->
                        <div class="d-flex align-center gap-4 flex-wrap w-100" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                            <!-- Search -->
                            <div style="position: relative; flex: 1; min-width: 250px;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                <input v-model="orderSearchQuery" type="text" placeholder="Cari ID Pesanan / Produk" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                            </div>
                            
                            <!-- Date Filter -->
                            <div style="position: relative; min-width: 150px;">
                                <input v-model="orderDateFilter" type="date" style="width: 100%; padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                            </div>
                        </div>

                            <div style="width: 100%; text-align: right; margin-top: 8px;">
                                <span @click="resetOrderFilters" style="font-size: 12px; font-weight: 700; color: #16a34a; cursor: pointer;">Reset Filter</span>
                            </div>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">ID Order</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nama Pelanggan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Tanggal</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Metode Pengiriman</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Item Pesanan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Nominal Tagihan</th>
                                    <th style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700;">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in historyOrders" :key="order.id" @click="openOrderDetailModal(order)" style="cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                                    <td style="font-weight: 800; font-family: monospace; color: #0f172a;">
                                        {{ order.id }}
                                    </td>
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.customer || '-' }}
                                    </td>
                                    <td style="color: #475569;">{{ formatDate(order.createdAt) }}</td>
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.shippingMethod || 'JNE' }}
                                    </td>
                                    <td>
                                        <div v-for="item in order.items" :key="item.productId" style="margin-bottom: 8px; border-bottom: 1px dashed #e2e8f0; padding-bottom: 8px;">
                                            <div style="font-size: 12px; font-weight: 700; color: #0f172a;">{{ item.name }} ({{ item.qty }}x)</div>
                                            <div v-if="item.color" style="font-size: 11px; color: #64748b; margin-top: 2px;">Warna: <span style="font-weight: 600;">{{ item.color }}</span></div>
                                        </div>
                                    </td>
                                    <td style="font-weight: 800; color: #dc2626;">
                                        {{ formatPrice(order.total || order.totalAmount || 0) }}
                                    </td>
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>
                                </tr>
                                <tr v-if="filteredOrders.length === 0">
                                    <td colspan="7" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada histori transaksi.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab 3: Admins Management -->
                <div v-else class="dashboard-layout" style="grid-template-columns: 1fr;">
                    <!-- Admins List -->
                    <div class="table-card">
                        <div class="table-header d-flex justify-between align-center">
                            <h3 style="font-size:18px;">Staf Operator Aktif</h3>
                            <button @click="isCreateAdminModalOpen = true" class="btn btn-primary" style="font-size: 13px; padding: 8px 16px;">
                                + Tambah Admin
                            </button>
                        </div>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">NAMA</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">NO TELEPON</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">EMAIL</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">ROLE</th>
                                        <th style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">TANGGAL DIBUAT</th>
                                        <th class="text-center" style="font-size: 11px; text-transform: uppercase; color: #64748b; letter-spacing: 0.5px;">AKSI</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="admin in admins.filter(a => a.role !== 'Owner')" :key="admin.username">
                                        <td style="font-weight: 700; color: #334155;">{{ admin.name }}</td>
                                        <td style="color: #475569;">{{ admin.phone || '-' }}</td>
                                        <td style="color: #475569;">{{ admin.email || '-' }}</td>
                                        <td>
                                            <span style="padding: 4px 12px; font-size: 11px; border-radius: 12px; font-weight: 600; background: #dbeafe; color: #1e40af;">
                                                {{ admin.role }}
                                            </span>
                                        </td>
                                        <td style="color: #475569;">{{ formatDate(admin.createdAt) }}</td>
                                        <td class="text-center">
                                            <div class="d-flex align-center justify-center gap-3">
                                                <button @click="openEditAdminModal(admin)" style="background: none; border: none; cursor: pointer; color: #eab308; padding: 4px;" title="Edit">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
                                                </button>
                                                <button v-if="admin.role === 'Admin'" @click="handleDeleteAdmin(admin.username)" style="background: none; border: none; cursor: pointer; color: #ef4444; padding: 4px;" title="Hapus">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr v-if="admins.length === 0">
                                        <td colspan="6" class="text-center text-muted" style="padding: 40px 0;">
                                            Belum ada staf administrator.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    </div>
                    </template>
                    </div> <!-- End Main Content -->
                </div> <!-- End Grid Layout -->
            </div>
        </section>

        <!-- Stock Update Modal -->
        <div v-if="isStockModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Update Jumlah Stok</h3>
                <form @submit.prevent="handleUpdateStock">
                    <div class="form-group mb-4">
                        <label class="form-label">Gudang</label>
                        <select v-model="stockUpdateForm.warehouseId" class="form-input" required>
                            <option value="" disabled>Pilih Gudang</option>
                            <option v-for="w in warehouses" :key="w.id" :value="w.id">{{ w.name }}</option>
                        </select>
                    </div>
                    
                    <div class="form-group mb-4" v-if="selectedProductVariants.length > 0">
                        <label class="form-label">Varian (Opsional)</label>
                        <select v-model="stockUpdateForm.variantId" class="form-input">
                            <option value="">(Semua / Non-Varian)</option>
                            <option v-for="v in selectedProductVariants" :key="v.id" :value="v.id">{{ v.name }}</option>
                        </select>
                    </div>

                    <div class="form-group mb-6">
                        <label class="form-label">Jumlah Stok (Ditambah/Dikurang dari saat ini)</label>
                        <input 
                            type="number" 
                            class="form-input" 
                            v-model.number="stockAmount" 
                            placeholder="Cth: 10 untuk tambah 10, atau -5 untuk kurang 5"
                            required
                        >
                        <small style="color:#64748b; font-size:11px; margin-top:4px; display:block;">Isi selisih yang ingin ditambahkan atau dikurangkan.</small>
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isStockModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100">Simpan Stok</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Variant Modal -->
        <div v-if="isVariantModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:500px; padding:32px; animation: slideUp 0.3s forwards;">
                <div class="d-flex justify-between align-center mb-6">
                    <h3 style="margin: 0;">Kelola Varian</h3>
                    <button @click="isVariantModalOpen = false" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #64748b;">&times;</button>
                </div>
                
                <div v-if="selectedProductVariants.length > 0" class="mb-6">
                    <div style="max-height: 350px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 6px;">
                        <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                            <thead style="position: sticky; top: 0; background: white; z-index: 1; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                                <tr style="border-bottom: 2px solid #e2e8f0;">
                                    <th style="text-align: left; padding: 10px; color: #64748b;">Nama Varian</th>
                                    <th style="text-align: right; padding: 10px; color: #64748b;">Harga (Rp)</th>
                                    <th v-for="w in warehouses" :key="w.id" style="text-align: center; padding: 10px; color: #64748b;">Stok {{ w.name }}</th>
                                    <th style="text-align: center; padding: 10px; color: #64748b; width: 100px;">Aksi</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="variant in selectedProductVariants" :key="variant.id" style="border-bottom: 1px solid #f1f5f9;">
                                    <td style="padding: 12px 10px; font-weight: 600; color: #334155;">{{ variant.name }}</td>
                                    <td style="padding: 12px 10px; text-align: right; color: #0f172a;">{{ variant.price > 0 ? formatPrice(variant.price) : 'Default' }}</td>
                                    <td v-for="w in warehouses" :key="w.id" style="padding: 12px 10px; text-align: center; font-weight: 600; color: #0ea5e9;">
                                        {{ getVariantStockByWarehouse(variant, w.id) }}
                                    </td>
                                    <td style="padding: 12px 10px; text-align: center; display: flex; justify-content: center; gap: 12px;">
                                        <button @click="openStockForVariant(variant.id)" style="color: #10b981; background: none; border: none; cursor: pointer; font-size: 13px; font-weight: 600;" title="Atur Stok">Stok</button>
                                        <button @click="handleRemoveVariant(variant.id)" style="color: #ef4444; background: none; border: none; cursor: pointer; font-size: 13px; font-weight: 600;" title="Hapus Varian">Hapus</button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div v-else class="mb-6 text-center" style="padding: 20px; background: #f8fafc; border-radius: 8px; color: #64748b; font-size: 14px;">
                    Belum ada varian untuk produk ini.
                </div>

                <form @submit.prevent="handleAddVariant" style="background: #f1f5f9; padding: 16px; border-radius: 8px;">
                    <h4 class="mb-3" style="font-size: 14px; color: #334155;">Tambah Varian Baru</h4>
                    <div class="d-flex gap-2 mb-3">
                        <div style="flex: 2;">
                            <label style="display: block; font-size: 12px; color: #64748b; margin-bottom: 4px; font-weight: 500;">Nama Varian <span style="color: #ef4444;">*</span></label>
                            <input v-model="newVariantForm.name" type="text" placeholder="Cth: Merah" required class="form-input" style="font-size: 13px;">
                        </div>
                        <div style="flex: 1;">
                            <label style="display: block; font-size: 12px; color: #64748b; margin-bottom: 4px; font-weight: 500;">Harga Tambahan</label>
                            <input v-model.number="newVariantForm.price" type="number" min="0" placeholder="0 = Default" class="form-input" style="font-size: 13px;">
                        </div>
                        <div style="flex: 1;">
                            <label style="display: block; font-size: 12px; color: #64748b; margin-bottom: 4px; font-weight: 500;">Stok Awal</label>
                            <input v-model.number="newVariantForm.stock" type="number" min="0" placeholder="0" class="form-input" style="font-size: 13px;">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary w-100" :disabled="newVariantForm.processing" style="padding: 8px 16px;">
                        {{ newVariantForm.processing ? 'Menambahkan...' : 'Tambah Varian' }}
                    </button>
                </form>
            </div>
        </div>

        <!-- Edit Admin Modal -->
        <div v-if="isEditAdminModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Update Profil Admin</h3>
                <form @submit.prevent="handleUpdateAdmin">
                    <div class="form-group mb-4">
                        <label class="form-label">Nama Lengkap</label>
                        <input type="text" class="form-input" v-model="editAdminForm.name" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Nomor HP</label>
                        <input type="text" class="form-input" v-model="editAdminForm.phone">
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-input" v-model="editAdminForm.email">
                    </div>
                    <div class="form-group mb-6">
                        <label class="form-label">Password Baru <span style="font-weight: 400; color: #94a3b8; font-size: 12px;">(Kosongkan jika tak diubah)</span></label>
                        <input type="password" class="form-input" v-model="editAdminForm.password" placeholder="Min. 3 karakter">
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isEditAdminModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="editAdminForm.processing">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Create Admin Modal -->
        <div v-if="isCreateAdminModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Tambah Staf Admin Baru</h3>
                <form @submit.prevent="handleCreateAdmin">
                    <div class="form-group mb-4">
                        <label class="form-label">Nama Lengkap</label>
                        <input type="text" class="form-input" v-model="newAdminForm.name" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Username</label>
                        <input type="text" class="form-input" v-model="newAdminForm.username" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Nomor HP</label>
                        <input type="text" class="form-input" v-model="newAdminForm.phone">
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-input" v-model="newAdminForm.email">
                    </div>
                    <div class="form-group mb-6">
                        <label class="form-label">Password</label>
                        <input type="password" class="form-input" v-model="newAdminForm.password" placeholder="Min. 3 karakter" required>
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isCreateAdminModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="newAdminForm.processing">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Create Warehouse Modal -->
        <div v-if="isCreateWarehouseModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Tambah Gudang Baru</h3>
                <form @submit.prevent="handleCreateWarehouse">
                    <div class="form-group mb-4">
                        <label class="form-label">Nama Gudang</label>
                        <input type="text" class="form-input" v-model="warehouseForm.name" required>
                    </div>
                    <div class="form-group mb-6">
                        <label class="form-label">Deskripsi</label>
                        <textarea class="form-input" v-model="warehouseForm.description" rows="3"></textarea>
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isCreateWarehouseModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="warehouseForm.processing">Simpan</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Edit Warehouse Modal -->
        <div v-if="isEditWarehouseModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Edit Gudang</h3>
                <form @submit.prevent="handleUpdateWarehouse">
                    <div class="form-group mb-4">
                        <label class="form-label">Nama Gudang</label>
                        <input type="text" class="form-input" v-model="editWarehouseForm.name" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="form-label">Deskripsi</label>
                        <textarea class="form-input" v-model="editWarehouseForm.description" rows="3"></textarea>
                    </div>
                    <div class="form-group mb-6">
                        <label class="d-flex align-center gap-2" style="cursor:pointer;">
                            <input type="checkbox" v-model="editWarehouseForm.isActive" style="width: 16px; height: 16px;">
                            <span style="font-size: 14px; font-weight: 600; color: #475569;">Gudang Aktif</span>
                        </label>
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isEditWarehouseModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="editWarehouseForm.processing">Simpan</button>
                    </div>
                </form>
            </div>
        </div>



        <!-- Inbound Modal -->
        <div v-if="isInboundModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:800px; padding:32px; animation: slideUp 0.3s forwards; max-height: 90vh; overflow-y: auto;">
                <h3 class="mb-4">Buat Purchase Order (Kulakan) Baru</h3>
                <form @submit.prevent="submitInbound">
                    <div class="d-flex gap-4 mb-4">
                        <div class="form-group" style="flex: 1;">
                            <label class="form-label">Nama Supplier</label>
                            <input type="text" class="form-input" v-model="inboundForm.supplierName" required placeholder="PT. Bintang Bangunan / Toko A">
                        </div>
                        <div class="form-group" style="flex: 1;">
                            <label class="form-label">Tgl. Estimasi Sampai</label>
                            <input type="date" class="form-input" v-model="inboundForm.expectedDate" required>
                        </div>
                    </div>

                    <div style="margin-top: 24px; margin-bottom: 12px; font-weight: 700; color: #0f172a;">Daftar Barang</div>
                    <div v-for="(item, index) in inboundForm.items" :key="index" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 12px; position: relative;">
                        <button type="button" v-if="inboundForm.items.length > 1" @click="removeInboundItem(index)" style="position: absolute; top: -10px; right: -10px; background: white; border: 1px solid #e2e8f0; border-radius: 50%; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; cursor: pointer; color: #dc2626; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">✕</button>
                        
                        <div class="d-flex gap-4 flex-wrap">
                            <div class="form-group" style="flex: 1; min-width: 150px;">
                                <label class="form-label">Gudang Penerima</label>
                                <select class="form-input" v-model="item.warehouseId" @change="item.productId = ''; item.variantId = ''" required>
                                    <option value="" disabled>-- Pilih Gudang --</option>
                                    <option v-for="w in warehouses" :key="w.id" :value="w.id">{{ w.name }}</option>
                                </select>
                            </div>

                            <div class="form-group" style="flex: 1; min-width: 200px;" v-if="item.warehouseId">
                                <label class="form-label">Pilih Produk</label>
                                <select class="form-input" v-model="item.productId" @change="item.variantId = ''" required>
                                    <option value="" disabled>-- Pilih Produk --</option>
                                    <option v-for="p in getFilteredProducts(item.warehouseId)" :key="p.id" :value="p.id">{{ p.name }} - {{ p.category }}</option>
                                </select>
                            </div>
                            
                            <div class="form-group" style="flex: 1; min-width: 150px;" v-if="item.productId && getFilteredProducts(item.warehouseId).find(p => p.id === item.productId)?.variants?.length > 0">
                                <label class="form-label">Pilih Varian</label>
                                <select class="form-input" v-model="item.variantId">
                                    <option value="">(Tanpa Varian)</option>
                                    <option v-for="v in getFilteredProducts(item.warehouseId).find(p => p.id === item.productId)?.variants" :key="v.id" :value="v.id">{{ v.name }}</option>
                                </select>
                            </div>
                        </div>

                        <div class="d-flex gap-4 flex-wrap mt-3">
                            <div class="form-group" style="flex: 1; min-width: 150px;">
                                <label class="form-label">Kuantitas (Qty)</label>
                                <input type="number" class="form-input" v-model.number="item.qty" required min="1">
                            </div>
                            <div class="form-group" style="flex: 1; min-width: 150px;">
                                <label class="form-label">Harga Beli Satuan</label>
                                <input type="number" class="form-input" v-model.number="item.unitCost" required min="0" placeholder="Rp ...">
                            </div>
                        </div>
                    </div>
                    
                    <button type="button" @click="addInboundItem" class="btn btn-outline w-100 mb-6" style="border-style: dashed; padding: 12px; color: #475569;">+ Tambah Barang Lain</button>

                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isInboundModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="inboundForm.processing">Simpan Purchase Order</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Inbound Detail Modal -->
        <div v-if="isInboundDetailModalOpen && selectedInbound" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:800px; padding:32px; animation: slideUp 0.3s forwards; max-height: 90vh; overflow-y: auto;">
                <div class="d-flex justify-between align-center mb-4">
                    <h3 style="margin: 0;">Detail Purchase Order (PO-{{ selectedInbound.id }})</h3>
                    <button @click="isInboundDetailModalOpen = false" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #64748b;">✕</button>
                </div>
                
                <div class="d-flex gap-4 mb-6" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <div style="flex: 1;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Supplier</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ selectedInbound.supplierName }}</div>
                    </div>
                    <div style="flex: 1;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Tgl. Estimasi</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ formatDate(selectedInbound.expectedDate) || '-' }}</div>
                    </div>
                    <div style="flex: 1;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Status</div>
                        <span class="status-pill" :class="selectedInbound.status === 'received' ? 'success' : (selectedInbound.status === 'cancelled' ? 'cancelled' : 'pending')" style="display: inline-block;">
                            {{ selectedInbound.status === 'received' ? 'Diterima' : (selectedInbound.status === 'cancelled' ? 'Dibatalkan' : 'Menunggu') }}
                        </span>
                    </div>
                </div>

                <div style="font-weight: 700; color: #0f172a; margin-bottom: 12px;">Daftar Barang Dikulak</div>
                <div class="table-responsive" style="border: 1px solid #e2e8f0; border-radius: 8px;">
                    <table class="data-table" style="margin: 0;">
                        <thead>
                            <tr style="background: #f8fafc;">
                                <th>ID Produk</th>
                                <th>Nama Produk</th>
                                <th>Varian</th>
                                <th>Gudang Tujuan</th>
                                <th class="text-center">Qty</th>
                                <th class="text-right">Harga Satuan</th>
                                <th class="text-right">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="item in selectedInbound.items" :key="item.id">
                                <td style="font-weight: 600; font-family: monospace; color: #475569;">{{ item.productId }}</td>
                                <td style="font-weight: 600; color: #0f172a;">{{ products.find(p => p.id === item.productId)?.name || item.product?.name || '-' }}</td>
                                <td style="color: #475569;">{{ item.variant?.name || '-' }}</td>
                                <td style="color: #475569;">{{ warehouses.find(w => w.id === item.warehouseId)?.name || item.warehouse?.name || 'Gudang Utama' }}</td>
                                <td class="text-center" style="font-weight: 600;">{{ item.qty }}</td>
                                <td class="text-right" style="color: #475569;">{{ formatPrice(item.unitCost) }}</td>
                                <td class="text-right" style="font-weight: 600; color: #0f172a;">{{ formatPrice(item.subtotal) }}</td>
                            </tr>
                            <tr style="background: #f8fafc;">
                                <td colspan="6" class="text-right" style="font-weight: 700; color: #0f172a;">Total Biaya:</td>
                                <td class="text-right" style="font-weight: 800; color: #dc2626; font-size: 16px;">{{ formatPrice(selectedInbound.totalCost) }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Order Detail Modal -->
        <div v-if="isOrderDetailModalOpen && selectedOrder" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:800px; padding:32px; animation: slideUp 0.3s forwards; max-height: 90vh; overflow-y: auto;">
                <div class="d-flex justify-between align-center mb-4">
                    <h3 style="margin: 0;">Detail Transaksi ({{ selectedOrder.id }})</h3>
                    <button @click="isOrderDetailModalOpen = false" style="background: none; border: none; font-size: 20px; cursor: pointer; color: #64748b;">✕</button>
                </div>
                
                <div class="d-flex gap-4 mb-6 flex-wrap" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <div style="flex: 1; min-width: 150px;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Nama Pelanggan</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ selectedOrder.customer || '-' }}</div>
                    </div>
                    <div style="flex: 1; min-width: 150px;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">No HP / WhatsApp</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ selectedOrder.phone || '-' }}</div>
                    </div>
                    <div style="flex: 1; min-width: 150px;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Tanggal</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ formatDate(selectedOrder.createdAt) }}</div>
                    </div>
                    <div style="flex: 1; min-width: 150px;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Status</div>
                        <span class="status-pill" :class="getStatusClass(selectedOrder.status)" style="display: inline-block;">
                            {{ getStatusLabel(selectedOrder.status) }}
                        </span>
                    </div>
                </div>

                <div class="d-flex gap-4 mb-6 flex-wrap" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <div style="flex: 1; min-width: 250px;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Alamat Pengiriman</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ selectedOrder.address || '-' }}</div>
                    </div>
                    <div style="flex: 1; min-width: 200px;">
                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Metode Pengiriman</div>
                        <div style="font-weight: 600; color: #0f172a;">{{ selectedOrder.shippingMethod || '-' }}</div>
                        <div v-if="selectedOrder.shipping?.waybillId" style="font-size: 12px; margin-top: 4px;">
                            <span style="font-weight: 600;">Resi:</span> {{ selectedOrder.shipping.waybillId }}
                        </div>
                    </div>
                </div>

                <div style="font-weight: 700; color: #0f172a; margin-bottom: 12px;">Daftar Item Dibeli</div>
                <div class="table-responsive" style="border: 1px solid #e2e8f0; border-radius: 8px;">
                    <table class="data-table" style="margin: 0;">
                        <thead>
                            <tr style="background: #f8fafc;">
                                <th>Produk</th>
                                <th>Varian</th>
                                <th class="text-center">Qty</th>
                                <th class="text-right">Subtotal</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr v-for="item in selectedOrder.items" :key="item.id || item.productId">
                                <td style="font-weight: 600; color: #0f172a;">{{ item.name }}</td>
                                <td style="color: #475569;">{{ item.color || '-' }}</td>
                                <td class="text-center" style="font-weight: 600;">{{ item.qty }}</td>
                                <td class="text-right" style="font-weight: 600; color: #0f172a;">{{ formatPrice(item.price * item.qty) }}</td>
                            </tr>
                            <tr style="background: #f8fafc;">
                                <td colspan="3" class="text-right" style="font-weight: 700; color: #0f172a;">Ongkos Kirim:</td>
                                <td class="text-right" style="font-weight: 600; color: #475569;">{{ formatPrice(selectedOrder.shipping?.shippingCost || 0) }}</td>
                            </tr>
                            <tr style="background: #f8fafc;">
                                <td colspan="3" class="text-right" style="font-weight: 700; color: #0f172a;">Total Tagihan:</td>
                                <td class="text-right" style="font-weight: 800; color: #dc2626; font-size: 16px;">{{ formatPrice(selectedOrder.total || selectedOrder.totalAmount || 0) }}</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </AppLayout>
</template>
