<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { router, useForm } from '@inertiajs/vue3';
import { ref, computed } from 'vue';

const props = defineProps({
    orders: {
        type: Array,
        default: () => [],
    },
    customers: {
        type: Array,
        default: () => [],
    },
    fleet: {
        type: Array,
        default: () => [],
    },
    deliveryLocations: {
        type: Array,
        default: () => [],
    },
    username: {
        type: String,
        required: true,
    },
    stats: {
        type: Object,
        default: () => ({ totalOrders: 0, pendingOrders: 0, verifiedOrders: 0, totalCustomers: 0 }),
    },
    profile: {
        type: Object,
        default: () => ({}),
    },
});

const activeTab = ref('dashboard'); // 'dashboard', 'orders', 'customers', 'delivery', or 'profile'

const isShippingModalOpen = ref(false);
const selectedOrderId = ref('');
const shippingCode = ref('');

// Delivery vehicle assignment modal
const isVehicleModalOpen = ref(false);
const vehicleOrderId = ref('');
const selectedVehicleId = ref(null);

// Order detail modal
const isOrderDetailModalOpen = ref(false);
const selectedOrderDetail = ref(null);

const openOrderDetail = (order) => {
    selectedOrderDetail.value = order;
    isOrderDetailModalOpen.value = true;
};

const customerSearchQuery = ref('');
const filteredCustomers = computed(() => {
    if (!customerSearchQuery.value) return props.customers || [];
    const q = customerSearchQuery.value.toLowerCase();
    return (props.customers || []).filter(c => 
        (c.name || '').toLowerCase().includes(q) ||
        (c.username || '').toLowerCase().includes(q) ||
        (c.email || '').toLowerCase().includes(q) ||
        (c.phone || '').toLowerCase().includes(q)
    );
});

const profileForm = useForm({
    name: props.profile?.name || '',
    username: props.profile?.username || '',
    email: props.profile?.email || '',
    phone: props.profile?.phone || '',
    password: '',
});

const saveProfile = () => {
    profileForm.put('/admin/profile', {
        preserveScroll: true,
        onSuccess: () => {
            profileForm.password = '';
        }
    });
};

const orderSearchQuery = ref('');
const orderDateFilter = ref('');
const orderStatusFilter = ref('Semua');

const filteredOrders = computed(() => {
    let ordersToFilter = props.orders || [];
    
    if (orderSearchQuery.value) {
        const q = orderSearchQuery.value.toLowerCase();
        ordersToFilter = ordersToFilter.filter(o => 
            o.id.toLowerCase().includes(q) || 
            (o.items && o.items.some(item => item.name.toLowerCase().includes(q)))
        );
    }
    
    if (orderDateFilter.value) {
        ordersToFilter = ordersToFilter.filter(o => {
            if (!o.createdAt) return false;
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

const resetOrderFilters = () => {
    orderSearchQuery.value = '';
    orderDateFilter.value = '';
    orderStatusFilter.value = 'Semua';
};

// Helper to classify shipping method type
const getShippingType = (method) => {
    if (!method) return 'kurir';
    const m = method.toLowerCase();
    if (m.includes('ambil di toko') || m.includes('ambil')) return 'ambil';
    if (m.includes('kurir toko') || m.includes('kurir sinar') || m.includes('sinar abadi')) return 'kurir_toko';
    return 'kurir'; // JNE, JNT, etc.
};

const handleMarkCompleted = (orderId) => {
    router.put(`/admin/orders/${orderId}/shipping`, {
        shippingCode: 'Diambil di toko',
        status: 'COMPLETED',
    }, {
        preserveScroll: true,
    });
};

const handleKurirStatusChange = (orderId, newStatus) => {
    if (newStatus === 'completed') {
        router.put(`/admin/orders/${orderId}/shipping`, {
            shippingCode: 'Kurir Toko',
            status: 'COMPLETED',
        }, { preserveScroll: true });
    } else if (newStatus === 'shipping') {
        router.put(`/admin/orders/${orderId}/shipping`, {
            shippingCode: 'Kurir Toko - Dalam Pengiriman',
            status: 'SHIPPING',
        }, { preserveScroll: true });
    }
};

const handleMarkShipping = (orderId) => {
    router.put(`/admin/orders/${orderId}/shipping`, {
        status: 'SHIPPING',
    }, { preserveScroll: true });
};

const openShippingModal = (orderId) => {
    selectedOrderId.value = orderId;
    shippingCode.value = '';
    isShippingModalOpen.value = true;
};

const handleUpdateShipping = () => {
    router.put(`/admin/orders/${selectedOrderId.value}/shipping`, {
        shippingCode: shippingCode.value,
    }, {
        onSuccess: () => {
            isShippingModalOpen.value = false;
        },
        preserveScroll: true,
    });
};

// ===============================
// DELIVERY TAB (Kurir Toko Sinar Abadi)
// ===============================

const kurirTokoOrders = computed(() => {
    return (props.orders || []).filter(o => {
        const m = (o.shippingMethod || '').toLowerCase();
        return m.includes('kurir toko') || m.includes('kurir sinar') || m.includes('sinar abadi');
    }).filter(o => {
        // Only show orders that have been paid (not pending/cancelled)
        const s = o.status?.toLowerCase();
        return s !== 'pending' && s !== 'cancelled';
    });
});

const deliverySearchQuery = ref('');
const deliveryStatusFilter = ref('Semua');
const deliveryDateFilter = ref('');

const filteredDeliveryOrders = computed(() => {
    let orders = kurirTokoOrders.value;
    
    if (deliverySearchQuery.value) {
        const q = deliverySearchQuery.value.toLowerCase();
        orders = orders.filter(o => 
            o.id.toLowerCase().includes(q) ||
            (o.customer || '').toLowerCase().includes(q) ||
            (o.shipping?.destinationAddress || '').toLowerCase().includes(q)
        );
    }

    if (deliveryStatusFilter.value && deliveryStatusFilter.value !== 'Semua') {
        orders = orders.filter(o => {
            return (o.shipping?.deliveryStatus || 'Menunggu') === deliveryStatusFilter.value;
        });
    }

    if (deliveryDateFilter.value) {
        orders = orders.filter(o => o.createdAt && o.createdAt.startsWith(deliveryDateFilter.value));
    }

    return orders;
});

const getDeliveryStatusColor = (status) => {
    switch (status) {
        case 'Menunggu': return { bg: '#fef3c7', color: '#92400e', border: '#f59e0b' };
        case 'Diproses': return { bg: '#dbeafe', color: '#1e40af', border: '#3b82f6' };
        case 'Dikirim': return { bg: '#fce7f3', color: '#9d174d', border: '#ec4899' };
        case 'Selesai': return { bg: '#dcfce7', color: '#166534', border: '#22c55e' };
        default: return { bg: '#f1f5f9', color: '#475569', border: '#94a3b8' };
    }
};

const getNextDeliveryStatus = (currentStatus) => {
    switch (currentStatus) {
        case 'Menunggu': return 'Diproses';
        case 'Diproses': return 'Dikirim';
        case 'Dikirim': return 'Selesai';
        default: return null;
    }
};

const getNextStatusLabel = (currentStatus) => {
    switch (currentStatus) {
        case 'Menunggu': return '▶ Proses';
        case 'Diproses': return '🚚 Kirim';
        case 'Dikirim': return '✅ Selesai';
        default: return null;
    }
};

const handleDeliveryStatusChange = (orderId, newStatus) => {
    if (newStatus === 'Dikirim') {
        // Open vehicle selection modal
        vehicleOrderId.value = orderId;
        selectedVehicleId.value = null;
        isVehicleModalOpen.value = true;
        return;
    }

    router.put(`/admin/orders/${orderId}/delivery-status`, {
        deliveryStatus: newStatus,
    }, { preserveScroll: true });
};

const confirmVehicleAssignment = () => {
    if (!selectedVehicleId.value) {
        alert('Silakan pilih mobil untuk pengiriman.');
        return;
    }
    
    router.put(`/admin/orders/${vehicleOrderId.value}/delivery-status`, {
        deliveryStatus: 'Dikirim',
        fleetVehicleId: selectedVehicleId.value,
    }, {
        preserveScroll: true,
        onSuccess: () => {
            isVehicleModalOpen.value = false;
        },
    });
};

const availableVehicles = computed(() => {
    return (props.fleet || []).filter(v => v.status === 'Tersedia');
});

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
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container">
                <div style="display: grid; grid-template-columns: 280px 1fr; gap: 32px; align-items: start;">
                    
                    <!-- Sidebar -->
                    <div style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                        <!-- Profile -->
                        <!-- Profile -->
                        <div 
                            class="d-flex align-center gap-4 mb-4" 
                            @click="activeTab = 'profile'" 
                            style="cursor: pointer; padding: 12px; border-radius: 8px; transition: background 0.2s; margin: -12px -12px 16px -12px;"
                            :style="activeTab === 'profile' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent; hover: background: #f8fafc;'"
                        >
                            <div style="width: 48px; height: 48px; background: #e11d48; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 800; box-shadow: 0 4px 10px rgba(225, 29, 72, 0.4);">
                                {{ username ? username.charAt(0).toUpperCase() : 'A' }}
                            </div>
                            <div>
                                <h3 style="font-size: 16px; font-weight: 800; margin: 0; color: #0f172a;">{{ username }}</h3>
                                <div style="font-size: 13px; color: #64748b;">Administrator</div>
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
                                <span :style="activeTab === 'dashboard' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Dashboard Admin</span>
                                <div v-if="activeTab === 'dashboard'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>

                            <div 
                                @click="activeTab = 'orders'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'orders' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'orders' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Update Status Order</span>
                                <div v-if="activeTab === 'orders'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>

                            <div 
                                @click="activeTab = 'delivery'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'delivery' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'delivery' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Pengiriman Kurir Toko</span>
                                <div v-if="activeTab === 'delivery'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <div 
                                @click="activeTab = 'customers'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeTab === 'customers' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeTab === 'customers' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Daftar Customer</span>
                                <div v-if="activeTab === 'customers'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
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
                        <!-- Tab 0: Dashboard -->
                        <div v-if="activeTab === 'dashboard'">
                            <div class="stats-grid mb-6">
                                <div class="stat-card">
                                    <span class="stat-title">Total Pesanan</span>
                                    <span class="stat-value">{{ stats.totalOrders }}</span>
                                </div>
                                <div class="stat-card">
                                    <span class="stat-title" style="color: var(--color-warning);">Menunggu Status Order</span>
                                    <span class="stat-value" style="color: var(--color-warning);">{{ stats.pendingOrders }}</span>
                                </div>
                                <div class="stat-card">
                                    <span class="stat-title">Total Pelanggan</span>
                                    <span class="stat-value">{{ stats.totalCustomers }}</span>
                                </div>
                            </div>

                            <div class="table-card">
                                <div class="table-header">
                                    <h3 style="font-size:18px;">Daftar Pelanggan Terbaru</h3>
                                </div>
                                <div class="table-responsive">
                                    <table class="data-table">
                                        <thead>
                                            <tr>
                                                <th>Nama Lengkap</th>
                                                <th>Username</th>
                                                <th>Email</th>
                                                <th>No Telepon</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="cust in customers.slice(0, 10)" :key="cust.username">
                                                <td style="font-weight: 700;">{{ cust.name }}</td>
                                                <td>{{ cust.username }}</td>
                                                <td>{{ cust.email || '-' }}</td>
                                                <td>{{ cust.phone || '-' }}</td>
                                            </tr>
                                            <tr v-if="customers.length === 0">
                                                <td colspan="4" class="text-center text-muted" style="padding: 40px 0;">
                                                    Belum ada data customer terdaftar.
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                                <div v-if="customers.length > 10" style="padding: 16px; text-align: center; border-top: 1px solid #e2e8f0;">
                                    <button @click="activeTab = 'customers'" style="color: #e11d48; font-weight: 600; font-size: 14px; background: none; border: none; cursor: pointer;">
                                        Lihat Semua Pelanggan →
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Tab 1: Orders -->
                <div v-if="activeTab === 'orders'" class="table-card">
                    <div class="table-header" style="flex-direction: column; gap: 16px;">
                        <h3 style="font-size:18px; align-self: flex-start; margin: 0;">Daftar Transaksi</h3>
                        
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
                                    <th>ID Order</th>
                                    <th>Tanggal</th>
                                    <th>Metode Pengiriman</th>
                                    <th>Alamat Pengiriman</th>
                                    <th>Status</th>
                                    <th>Kode Resi (Shipping)</th>
                                    <th class="text-center">Aksi Logistik</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="order in filteredOrders" :key="order.id" @click="openOrderDetail(order)" style="cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                                    <td 
                                        style="font-weight: 800; font-family: monospace; color: #0f172a;"
                                    >
                                        {{ order.id }}
                                    </td>
                                    <td>{{ formatDate(order.createdAt) }}</td>
                                    <td style="font-weight: 600; color: #0f172a;">
                                        {{ order.shippingMethod || 'JNE' }}
                                    </td>
                                    <td style="max-width: 250px; white-space: normal; font-size: 13px;">
                                        {{ order.shipping?.destinationAddress || '-' }}
                                    </td>
                                    <td>
                                        <span class="status-pill" :class="getStatusClass(order.status)">
                                            {{ getStatusLabel(order.status) }}
                                        </span>
                                    </td>
                                    
                                    <!-- Kode Resi: Show only for Jasa Kurir (JNE/JNT/etc) -->
                                    <td style="font-weight: 700; font-family: monospace; color: #0f172a;">
                                        <template v-if="getShippingType(order.shippingMethod) === 'kurir'">
                                            {{ order.shipping?.waybillId || '-' }}
                                        </template>
                                        <template v-else>
                                            <span style="color: #94a3b8;">-</span>
                                        </template>
                                    </td>

                                    <!-- Aksi Logistik -->
                                    <td class="text-center">
                                        <template v-if="order.status?.toUpperCase() !== 'PENDING' && order.status?.toUpperCase() !== 'CANCELLED'">
                                            <!-- Jasa Kurir (JNE, JNT, dll): Admin can mark as shipped -->
                                            <template v-if="getShippingType(order.shippingMethod) === 'kurir'">
                                                <button 
                                                    v-if="order.status?.toUpperCase() === 'SUCCESS' || order.status?.toUpperCase() === 'VERIFIED'"
                                                    @click.stop="handleMarkShipping(order.id)"
                                                    style="padding: 6px 18px; font-size: 12px; font-weight: 700; color: white; background: #e11d48; border: none; border-radius: 6px; cursor: pointer;"
                                                >
                                                    Proses Pesanan & Kirim
                                                </button>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                            </template>

                                            <!-- Ambil Di Toko: Show Selesai button -->
                                            <template v-else-if="getShippingType(order.shippingMethod) === 'ambil'">
                                                <button 
                                                    v-if="order.status?.toUpperCase() === 'SUCCESS' || order.status?.toUpperCase() === 'VERIFIED'"
                                                    @click.stop="handleMarkCompleted(order.id)"
                                                    style="padding: 6px 18px; font-size: 12px; font-weight: 700; color: white; background: #2563eb; border: none; border-radius: 6px; cursor: pointer;"
                                                >
                                                    Selesai
                                                </button>
                                                <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                            </template>

                                            <!-- Kurir Sinar Abadi: Redirect to delivery tab -->
                                            <template v-else-if="getShippingType(order.shippingMethod) === 'kurir_toko'">
                                                <button 
                                                    @click.stop="activeTab = 'delivery'"
                                                    style="padding: 6px 18px; font-size: 12px; font-weight: 600; color: #e11d48; background: #fff1f2; border: 1px solid #fecdd3; border-radius: 6px; cursor: pointer;"
                                                >
                                                    Kelola di Tab Pengiriman →
                                                </button>
                                            </template>
                                        </template>
                                        <span v-else style="color: #94a3b8; font-size: 12px;">-</span>
                                    </td>
                                </tr>
                                <tr v-if="filteredOrders.length === 0">
                                    <td colspan="7" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada order yang sesuai.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Tab: Pengiriman Kurir Toko -->
                <div v-if="activeTab === 'delivery'">
                    <!-- Fleet Monitoring Panel -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-bottom: 24px;">
                        <div 
                            v-for="vehicle in fleet" 
                            :key="vehicle.id"
                            style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 20px; border-left: 4px solid;"
                            :style="{ borderLeftColor: vehicle.status === 'Tersedia' ? '#22c55e' : '#f59e0b' }"
                        >
                            <div class="d-flex align-center justify-between mb-3">
                                <div class="d-flex align-center gap-3">
                                    <div 
                                        style="width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 22px;"
                                        :style="vehicle.status === 'Tersedia' ? 'background: #dcfce7;' : 'background: #fef3c7;'"
                                    >
                                        🚛
                                    </div>
                                    <div>
                                        <div style="font-size: 16px; font-weight: 800; color: #0f172a;">{{ vehicle.name }}</div>
                                        <div v-if="vehicle.plate" style="font-size: 12px; color: #94a3b8;">{{ vehicle.plate }}</div>
                                    </div>
                                </div>
                                <span 
                                    style="padding: 4px 12px; border-radius: 16px; font-size: 12px; font-weight: 700;"
                                    :style="vehicle.status === 'Tersedia' 
                                        ? 'background: #dcfce7; color: #166534;' 
                                        : 'background: #fef3c7; color: #92400e;'"
                                >
                                    {{ vehicle.status }}
                                </span>
                            </div>
                            <div v-if="vehicle.status === 'Sedang Mengantar' && vehicle.currentOrder" style="background: #fffbeb; border: 1px solid #fde68a; border-radius: 8px; padding: 12px; margin-top: 8px;">
                                <div style="font-size: 12px; font-weight: 700; color: #92400e; margin-bottom: 4px;">Sedang Mengantar:</div>
                                <div style="font-size: 13px; font-weight: 600; color: #0f172a;">{{ vehicle.currentOrderId }}</div>
                                <div style="font-size: 12px; color: #64748b; margin-top: 2px;">{{ vehicle.currentOrder?.shipping?.destinationAddress || '-' }}</div>
                            </div>
                            <div v-else-if="vehicle.status === 'Tersedia'" style="font-size: 13px; color: #64748b; margin-top: 4px;">
                                Siap untuk ditugaskan pengiriman.
                            </div>
                        </div>
                    </div>

                    <!-- Delivery Orders Table -->
                    <div class="table-card">
                        <div class="table-header" style="flex-direction: column; gap: 16px;">
                            <h3 style="font-size: 18px; align-self: flex-start; margin: 0;">Pengiriman Kurir Toko Sinar Abadi</h3>
                            
                            <div class="d-flex align-center gap-4 flex-wrap w-100" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                <div style="position: relative; flex: 1; min-width: 250px;">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                    <input v-model="deliverySearchQuery" type="text" placeholder="Cari ID / Pelanggan / Alamat" style="width: 100%; padding: 8px 12px 8px 36px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px;">
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <input v-model="deliveryDateFilter" type="date" style="padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; color: #475569;">
                                    <button v-if="deliveryDateFilter" @click="deliveryDateFilter = ''" style="background: none; border: none; color: #e11d48; cursor: pointer; font-size: 12px; font-weight: 700;">Reset</button>
                                </div>
                            </div>

                            <div class="d-flex align-center gap-2 flex-wrap w-100">
                                <span style="font-size: 13px; font-weight: 700; color: #64748b; margin-right: 8px;">Status:</span>
                                <template v-for="status in ['Semua', 'Menunggu', 'Diproses', 'Dikirim', 'Selesai']" :key="status">
                                    <button
                                        @click="deliveryStatusFilter = status"
                                        style="padding: 4px 12px; font-size: 12px; border-radius: 16px; cursor: pointer; transition: all 0.2s; border: 1px solid;"
                                        :style="deliveryStatusFilter === status 
                                            ? `background: ${getDeliveryStatusColor(status === 'Semua' ? 'Menunggu' : status).bg}; color: ${getDeliveryStatusColor(status === 'Semua' ? 'Menunggu' : status).color}; border-color: ${getDeliveryStatusColor(status === 'Semua' ? 'Menunggu' : status).border}; font-weight: 600;` 
                                            : 'background: white; color: #64748b; border-color: #cbd5e1;'"
                                    >
                                        {{ status }}
                                    </button>
                                </template>
                            </div>
                        </div>

                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID Order</th>
                                        <th>Tanggal</th>
                                        <th>Pelanggan</th>
                                        <th>Tujuan</th>
                                        <th>Ongkir</th>
                                        <th>Status Pengiriman</th>
                                        <th class="text-center">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr v-for="order in filteredDeliveryOrders" :key="order.id" @click="openOrderDetail(order)" style="cursor: pointer; transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
                                        <td 
                                            style="font-weight: 800; font-family: monospace; color: #0f172a;"
                                        >
                                            {{ order.id }}
                                        </td>
                                        <td>{{ formatDate(order.createdAt) }}</td>
                                        <td style="font-weight: 600;">{{ order.customer || '-' }}</td>
                                        <td style="max-width: 200px; white-space: normal; font-size: 13px;">
                                            {{ order.shipping?.destinationAddress || '-' }}
                                        </td>
                                        <td style="font-weight: 700; color: #0f172a;">
                                            {{ order.shipping?.shippingCost > 0 ? formatPrice(order.shipping.shippingCost) : 'Gratis' }}
                                        </td>
                                        <td>
                                            <span 
                                                style="padding: 4px 12px; border-radius: 16px; font-size: 12px; font-weight: 700; border: 1px solid;"
                                                :style="{
                                                    background: getDeliveryStatusColor(order.shipping?.deliveryStatus || 'Menunggu').bg,
                                                    color: getDeliveryStatusColor(order.shipping?.deliveryStatus || 'Menunggu').color,
                                                    borderColor: getDeliveryStatusColor(order.shipping?.deliveryStatus || 'Menunggu').border,
                                                }"
                                            >
                                                {{ order.shipping?.deliveryStatus || 'Menunggu' }}
                                            </span>
                                        </td>
                                        <td class="text-center">
                                            <template v-if="getNextDeliveryStatus(order.shipping?.deliveryStatus || 'Menunggu')">
                                                <button 
                                                    @click.stop="handleDeliveryStatusChange(order.id, getNextDeliveryStatus(order.shipping?.deliveryStatus || 'Menunggu'))"
                                                    style="padding: 6px 16px; font-size: 12px; font-weight: 700; color: white; border: none; border-radius: 6px; cursor: pointer; transition: all 0.2s;"
                                                    :style="{
                                                        background: getNextDeliveryStatus(order.shipping?.deliveryStatus || 'Menunggu') === 'Selesai' ? '#22c55e' 
                                                            : getNextDeliveryStatus(order.shipping?.deliveryStatus || 'Menunggu') === 'Dikirim' ? '#e11d48' 
                                                            : '#3b82f6'
                                                    }"
                                                >
                                                    {{ getNextStatusLabel(order.shipping?.deliveryStatus || 'Menunggu') }}
                                                </button>
                                            </template>
                                            <span v-else style="color: #22c55e; font-size: 12px; font-weight: 700;">✓ Selesai</span>
                                        </td>
                                    </tr>
                                    <tr v-if="filteredDeliveryOrders.length === 0">
                                        <td colspan="7" class="text-center text-muted" style="padding: 40px 0;">
                                            Belum ada pengiriman Kurir Toko.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Tab 2: Customers -->
                <div v-if="activeTab === 'customers'" class="table-card">
                    <div class="table-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <h3 style="font-size:18px;">Manajemen Pelanggan</h3>
                        <div style="display: flex; align-items: center; background: white; border: 1px solid #e2e8f0; border-radius: 8px; padding: 4px 12px;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                            <input 
                                type="text" 
                                v-model="customerSearchQuery" 
                                placeholder="Cari nama, email..." 
                                style="border: none; outline: none; padding: 8px; font-size: 14px; width: 200px;"
                            >
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Nama Lengkap</th>
                                    <th>Username</th>
                                    <th>Email</th>
                                    <th>No Telepon</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="cust in filteredCustomers" :key="cust.username">
                                    <td style="font-weight: 700;">{{ cust.name }}</td>
                                    <td>{{ cust.username }}</td>
                                    <td>{{ cust.email || '-' }}</td>
                                    <td>{{ cust.phone || '-' }}</td>
                                </tr>
                                <tr v-if="filteredCustomers.length === 0">
                                    <td colspan="4" class="text-center text-muted" style="padding: 40px 0;">
                                        Belum ada data customer atau tidak ditemukan.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                </template>
                </div> <!-- End Main Content -->
            </div> <!-- End Grid Layout -->
        </div>
    </section>

        <!-- Shipping Code Modal -->
        <div v-if="isShippingModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:400px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Input Kode Resi Pengiriman</h3>
                <form @submit.prevent="handleUpdateShipping">
                    <div class="form-group mb-6">
                        <label class="form-label">Nomor Resi / Bukti Jalan</label>
                        <input 
                            type="text" 
                            class="form-input" 
                            placeholder="Contoh: JT-12345678"
                            v-model="shippingCode" 
                            required
                        >
                    </div>
                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isShippingModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100">Kirim Barang</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Order Detail Modal -->
        <div v-if="isOrderDetailModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:600px; background: white; border-radius: 12px; overflow: hidden; animation: slideUp 0.3s forwards; display: flex; flex-direction: column; max-height: 90vh;">
                <!-- Header -->
                <div class="d-flex justify-between align-center" style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0;">Detail Transaksi ({{ selectedOrderDetail?.id }})</h3>
                    <button @click="isOrderDetailModalOpen = false" style="background: none; border: none; cursor: pointer;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                
                <div style="padding: 24px; overflow-y: auto;">
                    <!-- Section 1: Customer Info -->
                    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; padding: 16px; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 16px; background: #f8fafc;">
                        <div>
                            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 4px;">Nama Pelanggan</div>
                            <div style="font-size: 14px; font-weight: 700; color: #0f172a;">{{ selectedOrderDetail?.customer || '-' }}</div>
                        </div>
                        <div>
                            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 4px;">No HP / WhatsApp</div>
                            <div style="font-size: 14px; font-weight: 700; color: #0f172a;">{{ selectedOrderDetail?.phone || '-' }}</div>
                        </div>
                        <div>
                            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 4px;">Tanggal</div>
                            <div style="font-size: 14px; font-weight: 700; color: #0f172a;">{{ selectedOrderDetail?.date ? formatDate(selectedOrderDetail.date) : '-' }}</div>
                        </div>
                        <div>
                            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 4px;">Status</div>
                            <span class="status-pill" :class="getStatusClass(selectedOrderDetail?.status)">{{ getStatusLabel(selectedOrderDetail?.status) }}</span>
                        </div>
                    </div>

                    <!-- Section 2: Shipping Info -->
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; padding: 16px; border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 24px;">
                        <div>
                            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 4px;">Alamat Pengiriman</div>
                            <div style="font-size: 14px; font-weight: 700; color: #0f172a;">{{ selectedOrderDetail?.address || '-' }}</div>
                        </div>
                        <div>
                            <div style="font-size: 12px; color: #94a3b8; margin-bottom: 4px;">Metode Pengiriman</div>
                            <div style="font-size: 14px; font-weight: 700; color: #0f172a; margin-bottom: 4px;">{{ selectedOrderDetail?.shippingMethod || '-' }}</div>
                            <div style="font-size: 12px; color: #0f172a;" v-if="selectedOrderDetail?.shipping?.waybillId">
                                <strong>Resi:</strong> {{ selectedOrderDetail?.shipping?.waybillId }}
                            </div>
                        </div>
                    </div>

                    <!-- Section 3: Items -->
                    <h4 style="font-size: 16px; font-weight: 700; color: #0f172a; margin-bottom: 12px;">Daftar Item Dibeli</h4>
                    <div style="border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;">
                        <table style="width: 100%; border-collapse: collapse;">
                            <thead style="background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                                <tr>
                                    <th style="padding: 12px 16px; text-align: left; font-size: 12px; color: #64748b; font-weight: 700;">PRODUK</th>
                                    <th style="padding: 12px 16px; text-align: left; font-size: 12px; color: #64748b; font-weight: 700;">VARIAN</th>
                                    <th style="padding: 12px 16px; text-align: center; font-size: 12px; color: #64748b; font-weight: 700;">QTY</th>
                                    <th style="padding: 12px 16px; text-align: right; font-size: 12px; color: #64748b; font-weight: 700;">SUBTOTAL</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-if="!selectedOrderDetail?.items || selectedOrderDetail.items.length === 0">
                                    <td colspan="4" style="font-size: 14px; color: #94a3b8; text-align: center; padding: 20px;">
                                        Data produk tidak tersedia
                                    </td>
                                </tr>
                                <tr v-for="item in selectedOrderDetail?.items" :key="item.id" style="border-bottom: 1px solid #e2e8f0;">
                                    <td style="padding: 16px; font-size: 14px; font-weight: 600; color: #0f172a;">{{ item.name }}</td>
                                    <td style="padding: 16px; font-size: 14px; color: #64748b;">{{ item.color || '-' }}</td>
                                    <td style="padding: 16px; font-size: 14px; font-weight: 700; color: #0f172a; text-align: center;">{{ item.qty }}</td>
                                    <td style="padding: 16px; font-size: 14px; font-weight: 600; color: #0f172a; text-align: right;">{{ formatPrice(item.price * item.qty) }}</td>
                                </tr>
                                <tr style="border-bottom: 1px solid #e2e8f0; background: #fafafa;">
                                    <td colspan="3" style="padding: 16px; text-align: right; font-size: 14px; font-weight: 700; color: #0f172a;">Ongkos Kirim:</td>
                                    <td style="padding: 16px; text-align: right; font-size: 14px; font-weight: 600; color: #64748b;">{{ formatPrice(selectedOrderDetail?.shipping?.shippingCost || 0) }}</td>
                                </tr>
                                <tr style="background: #fafafa;">
                                    <td colspan="3" style="padding: 16px; text-align: right; font-size: 14px; font-weight: 800; color: #0f172a;">Total Tagihan:</td>
                                    <td style="padding: 16px; text-align: right; font-size: 16px; font-weight: 800; color: #dc2626;">{{ formatPrice(selectedOrderDetail?.total || 0) }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div v-if="selectedOrderDetail?.status?.toUpperCase() === 'SUCCESS' || selectedOrderDetail?.status?.toUpperCase() === 'VERIFIED'" style="padding: 16px 24px; border-top: 1px solid #e2e8f0; text-align: right; background: #f8fafc;">
                    <template v-if="getShippingType(selectedOrderDetail?.shippingMethod) === 'kurir'">
                        <button 
                            @click="handleMarkShipping(selectedOrderDetail.id); isOrderDetailModalOpen = false"
                            style="background: #e11d48; color: white; padding: 8px 24px; border-radius: 6px; font-weight: 600; border: none; cursor: pointer;"
                        >
                            Proses Pesanan & Kirim
                        </button>
                    </template>
                    <template v-else-if="getShippingType(selectedOrderDetail?.shippingMethod) === 'ambil'">
                        <button 
                            @click="handleMarkCompleted(selectedOrderDetail.id); isOrderDetailModalOpen = false"
                            style="background: #2563eb; color: white; padding: 8px 24px; border-radius: 6px; font-weight: 600; border: none; cursor: pointer;"
                        >
                            Selesai
                        </button>
                    </template>
                    <template v-else-if="getShippingType(selectedOrderDetail?.shippingMethod) === 'toko'">
                        <button 
                            @click="activeTab = 'delivery'; isOrderDetailModalOpen = false"
                            style="background: #ea580c; color: white; padding: 8px 24px; border-radius: 6px; font-weight: 600; border: none; cursor: pointer;"
                        >
                            Atur Pengiriman
                        </button>
                    </template>
                </div>
            </div>
        </div>

        <!-- Vehicle Assignment Modal -->
        <div v-if="isVehicleModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:450px; background: white; border-radius: 16px; overflow: hidden; animation: slideUp 0.3s forwards; box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);">
                <div style="padding: 24px 24px 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 16px;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0;">🚚 Pilih Mobil Pengiriman</h3>
                    <p style="font-size: 13px; color: #64748b; margin: 8px 0 0;">Pesanan <strong>{{ vehicleOrderId }}</strong> — Pilih mobil yang akan digunakan untuk mengantar.</p>
                </div>
                
                <div style="padding: 24px;">
                    <div v-if="availableVehicles.length === 0" style="text-align: center; padding: 24px; background: #fef2f2; border-radius: 8px; color: #b91c1c; font-weight: 600; font-size: 14px;">
                        Semua mobil sedang dalam pengiriman. Tunggu salah satu selesai.
                    </div>
                    <div v-else style="display: flex; flex-direction: column; gap: 12px;">
                        <div 
                            v-for="vehicle in fleet" 
                            :key="vehicle.id"
                            @click="vehicle.status === 'Tersedia' ? (selectedVehicleId = vehicle.id) : null"
                            style="display: flex; align-items: center; gap: 16px; padding: 16px; border: 2px solid; border-radius: 12px; cursor: pointer; transition: all 0.2s;"
                            :style="selectedVehicleId === vehicle.id 
                                ? 'border-color: #e11d48; background: #fff1f2;' 
                                : vehicle.status !== 'Tersedia' 
                                    ? 'border-color: #e2e8f0; background: #f8fafc; cursor: not-allowed; opacity: 0.6;' 
                                    : 'border-color: #e2e8f0; background: white;'"
                        >
                            <div 
                                style="width: 20px; height: 20px; border-radius: 50%; border: 2px solid; display: flex; align-items: center; justify-content: center; flex-shrink: 0;"
                                :style="selectedVehicleId === vehicle.id ? 'border-color: #e11d48;' : 'border-color: #cbd5e1;'"
                            >
                                <div v-if="selectedVehicleId === vehicle.id" style="width: 10px; height: 10px; border-radius: 50%; background: #e11d48;"></div>
                            </div>
                            <div style="font-size: 24px;">🚛</div>
                            <div style="flex: 1;">
                                <div style="font-size: 15px; font-weight: 700; color: #0f172a;">{{ vehicle.name }}</div>
                                <div style="font-size: 12px; color: #64748b; margin-top: 2px;">
                                    <template v-if="vehicle.status === 'Tersedia'">✅ Tersedia</template>
                                    <template v-else>⚠️ Sedang Mengantar ({{ vehicle.currentOrderId }})</template>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div style="padding: 16px 24px 24px; display: flex; gap: 12px;">
                    <button 
                        @click="isVehicleModalOpen = false" 
                        style="flex: 1; padding: 12px; background: white; color: #64748b; border: 1px solid #cbd5e1; border-radius: 8px; font-weight: 700; cursor: pointer; font-size: 14px;"
                    >
                        Batal
                    </button>
                    <button 
                        @click="confirmVehicleAssignment"
                        :disabled="!selectedVehicleId"
                        style="flex: 1; padding: 12px; background: #e11d48; color: white; border: none; border-radius: 8px; font-weight: 700; cursor: pointer; font-size: 14px; transition: opacity 0.2s;"
                        :style="!selectedVehicleId ? 'opacity: 0.5; cursor: not-allowed;' : ''"
                    >
                        Kirim Sekarang
                    </button>
                </div>
            </div>
        </div>
    </AppLayout>
</template>
