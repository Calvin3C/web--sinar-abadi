<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { useForm, Link, router } from '@inertiajs/vue3';
import { ref, computed, watch } from 'vue';
import { useAddresses } from '@/Composables/useAddresses';
import { marked } from 'marked';

marked.setOptions({
    breaks: true,
    gfm: true
});

const renderMarkdown = (text) => {
    if (!text) return '';
    return marked.parse(text);
};

const props = defineProps({
    orders: {
        type: Array,
        default: () => [],
    },
    username: {
        type: String,
        required: true,
    },
    user: {
        type: Object,
        default: () => ({}),
    },
    profile: {
        type: Object,
        default: () => ({}),
    }
});

const { addresses: mockAddresses, addAddress, updateAddress, setMainAddress } = useAddresses(props.username);

const isModalOpen = ref(false);
const selectedOrderId = ref('');
const activeMenu = ref('alamat'); // 'alamat', 'pesanan', 'riwayat', 'profile', or 'chatbot'

import { onMounted } from 'vue';

onMounted(() => {
    const params = new URLSearchParams(window.location.search);
    const menuParam = params.get('menu');
    if (menuParam) {
        activeMenu.value = menuParam;
    }
});

const isAddressFormModalOpen = ref(false);
const addressFormMode = ref('add'); // 'add' or 'edit'

const profileForm = useForm({
    name: props.profile?.name || '',
    username: props.profile?.username || '',
    email: props.profile?.email || '',
    phone: props.profile?.phone || '',
    password: '',
});

const saveProfile = () => {
    profileForm.put('/customer/profile', {
        preserveScroll: true,
        onSuccess: () => {
            profileForm.password = '';
        }
    });
};

const addressForm = useForm({
    id: null,
    label: '',
    name: '',
    phone: '',
    kota: '',
    address: '',
    catatan: '',
    isMain: false,
    pinpoint: false,
    biteshipAreaId: '', // Added Biteship Area ID
});

const chatHistory = ref([]);
const chatInput = ref('');
const isChatLoading = ref(false);

const sendChatMessage = async () => {
    if (!chatInput.value.trim() || isChatLoading.value) return;

    const userMessage = chatInput.value.trim();
    chatHistory.value.push({ role: 'user', text: userMessage });
    chatInput.value = '';
    isChatLoading.value = true;

    try {
        const response = await fetch('http://localhost:8080/api/chatbot', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({ history: chatHistory.value })
        });

        if (response.ok) {
            const data = await response.json();
            chatHistory.value.push({ role: 'assistant', text: data.reply });
        } else {
            chatHistory.value.push({ role: 'assistant', text: 'Maaf, saya sedang tidak dapat terhubung dengan server saat ini.' });
        }
    } catch (e) {
        console.error('Chat error:', e);
        chatHistory.value.push({ role: 'assistant', text: 'Terjadi kesalahan jaringan, silakan coba lagi.' });
    } finally {
        isChatLoading.value = false;
        // Scroll to bottom (handled via Vue reactivity in a robust app, but for now simple)
    }
};

// Biteship autocomplete state
const areaSearchQuery = ref('');
const areaSearchResults = ref([]);
const isSearchingArea = ref(false);

// Watch for search query changes and debounce API call
let searchTimeout = null;
watch(areaSearchQuery, (newQuery) => {
    if (searchTimeout) clearTimeout(searchTimeout);
    
    if (newQuery.length < 3) {
        areaSearchResults.value = [];
        return;
    }

    searchTimeout = setTimeout(async () => {
        isSearchingArea.value = true;
        try {
            const res = await fetch(`http://localhost:8080/api/biteship/maps?input=${encodeURIComponent(newQuery)}`);
            if (res.ok) {
                const data = await res.json();
                areaSearchResults.value = data.areas || [];
            } else {
                areaSearchResults.value = [];
            }
        } catch (e) {
            console.error('Failed to search area', e);
            areaSearchResults.value = [];
        } finally {
            isSearchingArea.value = false;
        }
    }, 500); // 500ms debounce
});

const selectArea = (area) => {
    addressForm.kota = `${area.name}, ${area.administrative_division_level_2_name}, ${area.administrative_division_level_1_name}`;
    addressForm.biteshipAreaId = area.id;
    addressForm.postalCode = area.postal_code || '';
    
    // Clear search state but show selected text
    areaSearchQuery.value = addressForm.kota;
    areaSearchResults.value = [];
};

const openAddAddressModal = () => {
    addressFormMode.value = 'add';
    addressForm.id = null;
    addressForm.label = '';
    addressForm.kota = '';
    addressForm.address = '';
    addressForm.catatan = '';
    addressForm.isMain = false;
    addressForm.pinpoint = false;
    addressForm.biteshipAreaId = '';
    addressForm.postalCode = '';
    areaSearchQuery.value = '';
    areaSearchResults.value = [];
    addressForm.name = props.user?.name || '';
    addressForm.phone = props.user?.phone || '';
    isAddressFormModalOpen.value = true;
};

const openEditAddressModal = (addr) => {
    addressFormMode.value = 'edit';
    addressForm.id = addr.id;
    addressForm.label = addr.label;
    addressForm.name = addr.name;
    addressForm.phone = addr.phone;
    addressForm.kota = addr.kota || '';
    addressForm.address = addr.address;
    addressForm.catatan = addr.catatan || '';
    addressForm.isMain = addr.isMain;
    addressForm.pinpoint = addr.pinpoint;
    addressForm.biteshipAreaId = addr.biteshipAreaId || '';
    addressForm.postalCode = addr.postalCode || '';
    areaSearchQuery.value = addr.kota || '';
    areaSearchResults.value = [];
    isAddressFormModalOpen.value = true;
};

const saveAddress = async () => {
    const data = {
        label: addressForm.label,
        name: addressForm.name,
        phone: addressForm.phone,
        kota: addressForm.kota,
        address: addressForm.address,
        catatan: addressForm.catatan,
        isMain: addressForm.isMain,
        pinpoint: addressForm.pinpoint,
        biteshipAreaId: addressForm.biteshipAreaId,
        postalCode: String(addressForm.postalCode),
    };

    let success = false;
    if (addressFormMode.value === 'add') {
        success = await addAddress(data);
    } else {
        success = await updateAddress(addressForm.id, data);
    }
    
    if (success) {
        isAddressFormModalOpen.value = false;
    }
};

// Split orders into active vs completed
const activeOrders = computed(() => {
    return (props.orders || []).filter(o => {
        const s = o.status?.toUpperCase();
        return s !== 'COMPLETED';
    });
});

const completedOrders = computed(() => {
    return (props.orders || []).filter(o => {
        const s = o.status?.toUpperCase();
        return s === 'COMPLETED';
    });
});

const expandedRiwayatOrders = ref([]);
const toggleRiwayatOrder = (orderId) => {
    const index = expandedRiwayatOrders.value.indexOf(orderId);
    if (index === -1) {
        expandedRiwayatOrders.value.push(orderId);
    } else {
        expandedRiwayatOrders.value.splice(index, 1);
    }
};

const orderSearchQuery = ref('');
const orderDateFilter = ref('');
const orderStatusFilter = ref('Semua');

const displayedOrders = computed(() => {
    let ordersToFilter = activeMenu.value === 'riwayat' ? completedOrders.value : activeOrders.value;
    
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

const resetFilters = () => {
    orderSearchQuery.value = '';
    orderDateFilter.value = '';
    orderStatusFilter.value = 'Semua';
};

const proofForm = useForm({
    proofUploaded: true,
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
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        });
    } catch (e) {
        return dateStr;
    }
};

const getStatusClass = (status) => {
    switch (status?.toLowerCase()) {
        case 'pending': return 'pending';
        case 'verified': return 'success';
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

const openUploadModal = (orderId) => {
    selectedOrderId.value = orderId;
    isModalOpen.value = true;
};

const handleUploadProof = () => {
    proofForm.post(`/customer/orders/${selectedOrderId.value}/proof`, {
        onSuccess: () => {
            isModalOpen.value = false;
        },
    });
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
                            @click="activeMenu = 'profile'" 
                            style="cursor: pointer; padding: 12px; border-radius: 8px; transition: background 0.2s; margin: -12px -12px 16px -12px;"
                            :style="activeMenu === 'profile' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent; hover: background: #f8fafc;'"
                        >
                            <div style="width: 48px; height: 48px; background: #e11d48; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; font-weight: 800; box-shadow: 0 4px 10px rgba(225, 29, 72, 0.4);">
                                {{ username.charAt(0).toUpperCase() }}
                            </div>
                            <div>
                                <h3 style="font-size: 16px; font-weight: 800; margin: 0; color: #0f172a;">{{ username }}</h3>
                                <div style="font-size: 13px; color: #64748b;">Profil Saya</div>
                            </div>
                        </div>
                        
                        <div style="height: 1px; background: #e2e8f0; margin: 16px 0;"></div>
                        
                        <!-- Menu -->
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <!-- Daftar Alamat -->
                            <div 
                                @click="activeMenu = 'alamat'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeMenu === 'alamat' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeMenu === 'alamat' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Daftar Alamat</span>
                                <div v-if="activeMenu === 'alamat'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <!-- Pesanan & Pengiriman -->
                            <div 
                                @click="activeMenu = 'pesanan'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeMenu === 'pesanan' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeMenu === 'pesanan' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Pesanan & Pengiriman</span>
                                <div v-if="activeMenu === 'pesanan'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                            
                            <!-- Riwayat Selesai -->
                            <div 
                                @click="activeMenu = 'riwayat'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeMenu === 'riwayat' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <span :style="activeMenu === 'riwayat' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Riwayat Selesai</span>
                                <div v-if="activeMenu === 'riwayat'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>

                            
                            <!-- Keranjang Belanja -->
                            <Link href="/cart" style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; text-decoration: none;">
                                <div style="display: flex; align-items: center;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 12px;">
                                        <circle cx="9" cy="21" r="1"></circle>
                                        <circle cx="20" cy="21" r="1"></circle>
                                        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                                    </svg>
                                    <span style="color: #64748b; font-weight: 600; font-size: 14px;">Keranjang Belanja</span>
                                </div>
                                <div v-if="$page.props.cartCount > 0" style="background: #e11d48; color: white; font-size: 11px; font-weight: 800; padding: 2px 8px; border-radius: 12px;">
                                    {{ $page.props.cartCount }}
                                </div>
                            </Link>

                            <!-- Chatbot -->
                            <div 
                                @click="activeMenu = 'chatbot'"
                                style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s;"
                                :style="activeMenu === 'chatbot' ? 'background: #ffe4e6; border-left: 4px solid #e11d48;' : 'border-left: 4px solid transparent;'"
                            >
                                <div style="display: flex; align-items: center;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" :stroke="activeMenu === 'chatbot' ? '#e11d48' : '#64748b'" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 12px;">
                                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                                    </svg>
                                    <span :style="activeMenu === 'chatbot' ? 'color: #e11d48; font-weight: 700; font-size: 14px;' : 'color: #64748b; font-weight: 600; font-size: 14px;'">Chatbot Asisten</span>
                                </div>
                                <div v-if="activeMenu === 'chatbot'" style="width: 14px; height: 14px; background: #e11d48; border-radius: 50%;"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Main Content -->
                    <div>
                        <h3 class="section-title mb-6">{{ activeMenu === 'profile' ? 'Profil Saya' : activeMenu === 'riwayat' ? 'Riwayat Selesai' : activeMenu === 'alamat' ? 'Daftar Alamat' : activeMenu === 'chatbot' ? 'Chatbot Konsultan Sinar Abadi' : 'Pesanan & Pengiriman' }}</h3>

                <!-- Profil Saya Content -->
                <div v-if="activeMenu === 'profile'" style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
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

                <!-- Daftar Alamat Content -->
                <div v-else-if="activeMenu === 'alamat'" style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px;">
                    <!-- Search & Add -->
                    <div class="d-flex justify-between align-center mb-6 gap-4">
                        <div style="position: relative; flex: 1;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                            <input type="text" placeholder="Tulis Nama Alamat / Kota / Kecamatan tujuan pengiriman" style="width: 100%; padding: 10px 12px 10px 40px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                        </div>
                        <button @click="openAddAddressModal" style="padding: 10px 20px; background: #e11d48; color: white; font-weight: 700; border-radius: 8px; font-size: 14px; border: none; cursor: pointer; white-space: nowrap;">
                            + Tambah Alamat Baru
                        </button>
                    </div>

                    <!-- Address List -->
                    <div>
                        <div 
                            v-for="addr in mockAddresses" 
                            :key="addr.id" 
                            style="border: 1px solid #e11d48; background: #ffe4e6; border-radius: 8px; padding: 16px; margin-bottom: 16px; position: relative;"
                        >
                            <div class="d-flex align-center gap-2 mb-2">
                                <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ addr.label }}</span>
                                <span v-if="addr.isMain" style="background: #e11d48; color: white; font-size: 11px; font-weight: 700; padding: 2px 6px; border-radius: 4px;">Utama</span>
                            </div>
                            <div style="font-weight: 700; color: #0f172a; font-size: 15px; margin-bottom: 4px;">{{ addr.name }}</div>
                            <div style="font-size: 13px; color: #0f172a; margin-bottom: 4px;">{{ addr.phone }}</div>
                            <div style="font-size: 13px; color: #0f172a; line-height: 1.5; margin-bottom: 16px; padding-right: 24px;">
                                {{ addr.address }}
                            </div>
                            
                            <div v-if="addr.pinpoint" class="d-flex align-center gap-2 mb-4" style="color: #e11d48; font-size: 13px; font-weight: 700;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                    <circle cx="12" cy="10" r="3"></circle>
                                </svg>
                                Sudah Pinpoint
                            </div>

                            <div class="d-flex align-center gap-4">
                                <span @click="openEditAddressModal(addr)" style="font-size: 14px; font-weight: 700; color: #e11d48; cursor: pointer;">Ubah Alamat</span>
                                <div v-if="!addr.isMain" style="width: 1px; height: 14px; background: #cbd5e1;"></div>
                                <span v-if="!addr.isMain" @click="setMainAddress(addr.id)" style="font-size: 14px; font-weight: 700; color: #e11d48; cursor: pointer;">Jadikan Utama</span>
                            </div>

                            <!-- Checkmark -->
                            <div v-if="addr.isMain" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); color: #e11d48;">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-else-if="activeMenu === 'pesanan' || activeMenu === 'riwayat'">
                    <!-- Filters Section -->
                    <div style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px; margin-bottom: 24px;">
                        <div class="d-flex align-center gap-4 flex-wrap mb-4">
                            <!-- Search -->
                            <div style="position: relative; flex: 1; min-width: 250px;">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                                <input v-model="orderSearchQuery" type="text" placeholder="Cari pesanan atau produk" style="width: 100%; padding: 10px 12px 10px 40px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                            </div>
                            
                            <!-- Date Filter -->
                            <div style="position: relative; min-width: 200px;">
                                <input v-model="orderDateFilter" type="date" style="width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px; color: #475569;">
                            </div>
                        </div>

                        <!-- Status Pills -->
                        <div class="d-flex align-center gap-2 flex-wrap">
                            <template v-if="activeMenu !== 'riwayat'">
                                <span style="font-size: 14px; font-weight: 700; color: #0f172a; margin-right: 8px;">Status</span>
                                <template v-for="status in ['Semua', 'Menunggu Konfirmasi', 'Diproses', 'Dikirim', 'Dibatalkan']" :key="status">
                                    <button @click="orderStatusFilter = status"
                                        style="padding: 6px 16px; font-size: 13px; border-radius: 20px; cursor: pointer; transition: all 0.2s; border: 1px solid;"
                                        :style="orderStatusFilter === status ? 'background: #eafff2; color: #16a34a; border-color: #16a34a; font-weight: 600;' : 'background: white; color: #64748b; border-color: #cbd5e1;'"
                                    >
                                        {{ status }}
                                    </button>
                                </template>
                            </template>
                            <span @click="resetFilters" style="font-size: 13px; font-weight: 700; color: #16a34a; cursor: pointer; margin-left: auto;">Reset Filter</span>
                        </div>
                    </div>

                    <div v-if="displayedOrders.length > 0">
                        <div 
                            v-for="order in displayedOrders" 
                        :key="order.id" 
                        class="order-card"
                    >
                        <div class="order-header" 
                             :style="activeMenu === 'riwayat' ? 'cursor: pointer; transition: background-color 0.2s; padding: 16px; border-radius: 8px;' : ''"
                             @click="activeMenu === 'riwayat' ? toggleRiwayatOrder(order.id) : null"
                             :onmouseover="activeMenu === 'riwayat' ? 'this.style.backgroundColor=\'#f8fafc\'' : ''"
                             :onmouseout="activeMenu === 'riwayat' ? 'this.style.backgroundColor=\'transparent\'' : ''"
                        >
                            <div class="d-flex align-center gap-3">
                                <svg v-if="activeMenu === 'riwayat'" :style="{ transform: expandedRiwayatOrders.includes(order.id) ? 'rotate(90deg)' : 'rotate(0)' }" style="transition: transform 0.2s; color: #94a3b8;" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                                <div>
                                    <div style="font-size:12px; color:var(--color-text-muted);">ID Pesanan</div>
                                    <div style="font-weight: 800; font-size: 16px; color: var(--color-text-main);">
                                        {{ order.id }}
                                    </div>
                                    <div style="font-size: 12px; color: var(--color-text-muted); margin-top:4px;">
                                        Dipesan pada: {{ formatDate(order.createdAt) }}
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex flex-column align-end gap-2">
                                <span class="status-pill" :class="getStatusClass(order.status)" style="padding: 6px 14px; font-size: 12px; font-weight: 700;">
                                    {{ getStatusLabel(order.status) }}
                                </span>
                                <div style="font-size: 12px; font-weight:600; color: #64748b;">
                                    Pembayaran: {{ order.payment?.paymentMethod || '-' }}
                                </div>
                            </div>
                        </div>

                        <!-- Expandable Body -->
                        <div v-if="activeMenu !== 'riwayat' || expandedRiwayatOrders.includes(order.id)">
                            
                            <!-- LAYOUT RIWAYAT SELESAI -->
                            <div v-if="activeMenu === 'riwayat'" style="margin-top: 24px;">
                                <div class="d-flex gap-4 mb-4 flex-wrap" style="background: #f8fafc; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                    <div style="flex: 1; min-width: 120px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">ID Order</div>
                                        <div style="font-weight: 600; color: #0f172a;">{{ order.id }}</div>
                                    </div>
                                    <div style="flex: 1; min-width: 150px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Nama Pelanggan</div>
                                        <div style="font-weight: 600; color: #0f172a;">{{ profile?.name || '-' }}</div>
                                    </div>
                                    <div style="flex: 1; min-width: 150px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">No HP / WhatsApp</div>
                                        <div style="font-weight: 600; color: #0f172a;">{{ profile?.phone || '-' }}</div>
                                    </div>
                                    <div style="flex: 1; min-width: 120px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Tanggal</div>
                                        <div style="font-weight: 600; color: #0f172a;">{{ formatDate(order.createdAt) }}</div>
                                    </div>
                                    <div style="flex: 1; min-width: 100px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Status</div>
                                        <span class="status-pill success" style="display: inline-block; padding: 4px 12px; font-weight: 700; background: #dcfce7; color: #166534; border: none;">Selesai</span>
                                    </div>
                                </div>

                                <div class="d-flex gap-4 mb-6 flex-wrap" style="background: #ffffff; padding: 16px; border-radius: 8px; border: 1px solid #e2e8f0;">
                                    <div style="flex: 1; min-width: 250px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Alamat Pengiriman</div>
                                        <div style="font-weight: 600; color: #0f172a; line-height: 1.5;">{{ order.address || '-' }}</div>
                                    </div>
                                    <div style="flex: 1; min-width: 200px;">
                                        <div style="font-size: 12px; color: #64748b; margin-bottom: 4px;">Metode Pengiriman</div>
                                        <div style="font-weight: 600; color: #0f172a;">{{ order.shippingMethod || '-' }}</div>
                                        <div v-if="order.shipping?.waybillId" style="font-size: 12px; margin-top: 4px; color: #475569;">
                                            <span style="font-weight: 600; color: #0f172a;">Resi:</span> {{ order.shipping.waybillId }}
                                        </div>
                                    </div>
                                </div>

                                <div style="font-weight: 800; color: #0f172a; margin-bottom: 12px; font-size: 16px;">Daftar Item Dibeli</div>
                                <div class="table-responsive" style="border: 1px solid #e2e8f0; border-radius: 8px; margin-bottom: 8px;">
                                    <table class="data-table" style="margin: 0; width: 100%; border-collapse: collapse;">
                                        <thead>
                                            <tr style="background: #ffffff; border-bottom: 1px solid #e2e8f0;">
                                                <th style="padding: 16px; text-align: left; font-size: 12px; font-weight: 800; color: #64748b; text-transform: uppercase;">Produk</th>
                                                <th style="padding: 16px; text-align: left; font-size: 12px; font-weight: 800; color: #64748b; text-transform: uppercase;">Varian</th>
                                                <th style="padding: 16px; text-align: center; font-size: 12px; font-weight: 800; color: #64748b; text-transform: uppercase;">Qty</th>
                                                <th style="padding: 16px; text-align: right; font-size: 12px; font-weight: 800; color: #64748b; text-transform: uppercase;">Subtotal</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr v-for="item in order.items" :key="item.id || item.productId" style="border-bottom: 1px solid #e2e8f0;">
                                                <td style="padding: 16px; font-weight: 600; color: #0f172a;">{{ item.name }}</td>
                                                <td style="padding: 16px; color: #475569;">{{ item.color || '-' }}</td>
                                                <td style="padding: 16px; text-align: center; font-weight: 600; color: #0f172a;">{{ item.qty }}</td>
                                                <td style="padding: 16px; text-align: right; font-weight: 600; color: #0f172a;">{{ formatPrice(item.price * item.qty) }}</td>
                                            </tr>
                                            <tr style="background: #ffffff; border-bottom: 1px solid #e2e8f0;">
                                                <td colspan="3" class="text-right" style="padding: 16px; font-weight: 800; color: #0f172a;">Ongkos Kirim:</td>
                                                <td class="text-right" style="padding: 16px; font-weight: 600; color: #64748b;">
                                                    <span v-if="order.shipping?.shippingCost === 0" style="color: #059669; font-weight: 700;">Gratis</span>
                                                    <span v-else>{{ formatPrice(order.shipping?.shippingCost || 0) }}</span>
                                                </td>
                                            </tr>
                                            <tr style="background: #f8fafc;">
                                                <td colspan="3" class="text-right" style="padding: 16px; font-weight: 800; color: #0f172a;">Total Tagihan:</td>
                                                <td class="text-right" style="padding: 16px; font-weight: 800; color: #dc2626; font-size: 16px;">{{ formatPrice(order.total) }}</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- LAYOUT PESANAN AKTIF -->
                            <div v-else>
                        <!-- Items List -->
                        <div style="margin-top: 16px; border-top: 1px solid #f1f5f9; padding-top: 16px;">
                            <div v-for="(item, idx) in order.items" :key="item.productId" 
                                 class="d-flex justify-between align-center flex-wrap gap-3"
                                 :style="idx !== order.items.length - 1 ? 'border-bottom: 1px dashed #e2e8f0; padding-bottom: 16px; margin-bottom: 16px;' : 'padding-bottom: 16px;'"
                            >
                                <div style="flex: 1; min-width: 200px;">
                                    <div style="font-weight: 700; font-size: 14px; color: #0f172a; margin-bottom: 4px;">{{ item.name }}</div>
                                    <div v-if="item.color" style="font-size: 12px; color: #64748b;">Variant: {{ item.color }}</div>
                                </div>
                                <div style="width: 140px; text-align: right; color: #64748b; font-size: 13px;">
                                    {{ item.qty }} x {{ formatPrice(item.price) }}
                                </div>
                                <div style="width: 140px; text-align: right; font-weight: 800; font-size: 14px; color: #0f172a;">
                                    {{ formatPrice(item.price * item.qty) }}
                                </div>
                            </div>
                        </div>

                        <!-- Order Summary -->
                        <div class="d-flex justify-between align-end flex-wrap gap-4 mt-2" style="border-top:1px dashed #cbd5e1; padding-top:20px;">
                            <div style="flex: 1; min-width: 300px;">
                                <div style="font-size:13px; color:#475569; margin-bottom: 6px;">
                                    Kurir: <strong style="color:#0f172a;">{{ order.shippingMethod || '-' }}</strong> 
                                    (Ongkir: <span v-if="order.shipping?.shippingCost === 0" style="color: #059669; font-weight: 700;">Gratis</span><span v-else>{{ formatPrice(order.shipping?.shippingCost || 0) }}</span>)
                                </div>
                                <div style="font-size:13px; color:#475569; line-height: 1.5;">
                                    Alamat: <span style="color:#0f172a;">{{ order.address || '-' }}</span>
                                </div>
                            </div>
                            <div class="text-right">
                                <div style="font-size:12px; color:#64748b; margin-bottom: 4px;">Total Pembayaran</div>
                                <div style="font-size: 22px; font-weight: 900; color: #dc2626;">
                                    {{ formatPrice(order.total) }}
                                </div>
                            </div>
                        </div>
                            </div>

                        <!-- Lacak Button for Kurir Sinar Abadi & Jasa Kurir (not Ambil Di Toko) -->
                        <div 
                            v-if="order.shippingMethod && !order.shippingMethod.toLowerCase().includes('ambil') && order.status !== 'PENDING' && order.status?.toUpperCase() !== 'COMPLETED'"
                            class="d-flex justify-end mt-4"
                        >
                            <Link 
                                :href="`/customer/tracking?orderId=${order.id}`"
                                style="padding: 10px 24px; font-size: 13px; font-weight: 700; color: white; background: #1e293b; border: none; border-radius: 8px; text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.2s;"
                            >
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="8"></circle>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                </svg>
                                Lacak
                            </Link>
                        </div>

                        <!-- Pending Pay Actions -->
                        <div 
                            v-if="order.status === 'PENDING' && !order.proofUploaded && (!order.payment?.paymentMethod || !order.payment.paymentMethod.toLowerCase().includes('midtrans'))" 
                            class="d-flex justify-between align-center flex-wrap gap-4 mt-6" 
                            style="background: var(--color-bg-subtle); padding:16px; border-radius: var(--radius-sm);"
                        >
                            <div style="font-size: 13px; max-width: 480px;">
                                Silakan transfer ke rekening <strong>{{ order.payment?.paymentMethod }}</strong>. Setelah transfer, segera upload bukti pembayaran.
                            </div>
                            <button 
                                @click="openUploadModal(order.id)" 
                                class="btn btn-primary" 
                                style="padding: 10px 20px; font-size:13px;"
                            >
                                Upload Bukti Bayar
                            </button>
                        </div>
                        <div 
                            v-else-if="order.status === 'PENDING' && order.proofUploaded && (!order.payment?.paymentMethod || !order.payment.paymentMethod.toLowerCase().includes('midtrans'))" 
                            class="d-flex justify-between align-center flex-wrap gap-4 mt-6" 
                            style="background: #ecfdf5; border: 1px solid #10b981; padding:16px; border-radius: var(--radius-sm);"
                        >
                            <div style="font-size: 13px; max-width: 480px; color: #065f46;">
                                <strong style="display:block; margin-bottom: 4px;">Bukti Pembayaran Terkirim</strong>
                                Bukti transfer Anda sudah kami terima dan sedang dalam proses verifikasi oleh Admin. Silakan pantau status pesanan secara berkala.
                            </div>
                            <Link 
                                :href="`/customer/tracking?orderId=${order.id}`" 
                                class="btn" 
                                style="padding: 10px 20px; font-size:13px; background: #059669; color: white; border-radius: 6px; font-weight: 700; text-decoration: none;"
                            >
                                Lacak Pesanan
                            </Link>
                        </div>

                        <!-- Completed order info -->
                        <div 
                            v-if="order.status?.toUpperCase() === 'COMPLETED'" 
                            class="d-flex align-start gap-3 mt-6" 
                            style="background: #f0fdf4; border: 1px solid #bbf7d0; padding:16px; border-radius: 8px;"
                        >
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0; margin-top: 2px;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                            <div style="font-size: 13px; color: #166534;">
                                <strong style="display:block; margin-bottom: 4px; font-size: 14px;">Pesanan Selesai</strong>
                                Pesanan ini telah selesai diproses. Terima kasih telah berbelanja di Sinar Abadi!
                            </div>
                        </div>

                        <!-- Cancelled order info -->
                        <div 
                            v-else-if="order.status?.toUpperCase() === 'CANCELLED'" 
                            class="d-flex justify-between align-center flex-wrap gap-4 mt-6" 
                            style="background: #fef2f2; border: 1px solid #ef4444; padding:16px; border-radius: var(--radius-sm);"
                        >
                            <div style="font-size: 13px; color: #b91c1c;">
                                <strong style="display:block; margin-bottom: 4px;">❌ Pesanan Dibatalkan</strong>
                                Pesanan ini telah dibatalkan. Jika Anda sudah melakukan pembayaran, silakan hubungi CS kami.
                            </div>
                        </div>
                        </div> <!-- End Expandable Body -->
                    </div>
                </div>

                <div v-else class="text-center" style="padding: 60px 20px; color: #64748b;">
                    <svg viewBox="0 0 24 24" width="80" height="80" fill="#cbd5e1" style="margin: 0 auto 16px;">
                        <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zm4.3 14.3L11 12.7V7h1.5v4.9l3.85 2.3-.76 1.1z"/>
                    </svg>
                    <h3>{{ activeMenu === 'riwayat' ? 'Belum Ada Riwayat' : 'Belum Ada Pesanan Aktif' }}</h3>
                    <p>{{ activeMenu === 'riwayat' ? 'Belum ada pesanan yang selesai.' : 'Anda belum melakukan pemesanan material apa pun.' }}</p>
                    <Link v-if="activeMenu !== 'riwayat'" href="/katalog" class="btn btn-primary mt-4">Pesan Sekarang</Link>
                </div>
                </div> <!-- End v-else-if (pesanan/riwayat) -->
                
                <!-- Chatbot Content -->
                <div v-else-if="activeMenu === 'chatbot'" style="background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); padding: 24px; display: flex; flex-direction: column; height: 600px;">
                     <div style="flex: 1; overflow-y: auto; padding-right: 12px; margin-bottom: 16px; display: flex; flex-direction: column; gap: 16px;" id="chatContainer">
                         <div v-if="chatHistory.length === 0" style="text-align: center; color: #94a3b8; margin-top: 40px; margin-bottom: 20px;">
                             <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="margin-bottom: 16px;"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path></svg>
                             <h4 style="font-size: 18px; font-weight: 800; color: #0f172a;">Halo! Saya Konsultan Proyek Sinar Abadi.</h4>
                             <p style="font-size: 14px; max-width: 400px; margin: 0 auto; line-height: 1.5;">Tanyakan kebutuhan material bangunan Anda, dan saya akan merekomendasikan produk serta menghitung kebutuhan Anda.</p>
                         </div>
                         <div v-for="(msg, idx) in chatHistory" :key="idx" :style="{ alignSelf: msg.role === 'user' ? 'flex-end' : 'flex-start', maxWidth: '85%', background: msg.role === 'user' ? '#e11d48' : '#f8fafc', color: msg.role === 'user' ? 'white' : '#0f172a', padding: '14px 18px', borderRadius: '16px', borderBottomRightRadius: msg.role === 'user' ? '4px' : '16px', borderBottomLeftRadius: msg.role === 'assistant' ? '4px' : '16px', border: msg.role === 'assistant' ? '1px solid #e2e8f0' : 'none' }">
                             <div :class="{ 'markdown-body': msg.role === 'assistant' }" :style="{ whiteSpace: msg.role === 'user' ? 'pre-wrap' : 'normal', fontSize: '14px', lineHeight: '1.6' }" v-html="msg.role === 'user' ? msg.text.replace(/\\n/g, '<br>') : renderMarkdown(msg.text)"></div>
                         </div>
                         <div v-if="isChatLoading" style="align-self: flex-start; background: #f8fafc; padding: 14px 18px; border-radius: 16px; border-bottom-left-radius: 4px; border: 1px solid #e2e8f0; color: #64748b; font-size: 14px; font-style: italic;">
                             Sedang mengetik balasan...
                         </div>
                     </div>
                     <form @submit.prevent="sendChatMessage" style="display: flex; gap: 12px; border-top: 1px solid #e2e8f0; padding-top: 16px; margin-top: auto;">
                         <input v-model="chatInput" type="text" placeholder="Tanya sesuatu, misal: butuh berapa sak semen untuk ukuran 4x5 meter?" style="flex: 1; padding: 14px 16px; border: 1px solid #cbd5e1; border-radius: 10px; font-size: 14px; outline: none; transition: border-color 0.2s;" :disabled="isChatLoading" onfocus="this.style.borderColor='#e11d48'" onblur="this.style.borderColor='#cbd5e1'">
                         <button type="submit" style="padding: 14px 28px; background: #e11d48; color: white; font-weight: 700; border-radius: 10px; border: none; cursor: pointer; transition: opacity 0.2s;" :disabled="isChatLoading || !chatInput.trim()" :style="{ opacity: isChatLoading || !chatInput.trim() ? 0.5 : 1 }">
                             Kirim
                         </button>
                     </form>
                </div>
                    </div> <!-- End Main Content -->
                </div> <!-- End Grid Layout -->
            </div>
        </section>

        <!-- Proof Upload Dialog -->
        <div v-if="isModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div class="table-card" style="width:100%; max-width:480px; padding:32px; animation: slideUp 0.3s forwards;">
                <h3 class="mb-4">Upload Bukti Pembayaran</h3>
                <p class="text-muted mb-6" style="font-size:13px;">
                    Upload file foto/struk transfer bank Anda untuk memverifikasi pesanan <strong>{{ selectedOrderId }}</strong>.
                </p>
                <form @submit.prevent="handleUploadProof">
                    <div class="form-group mb-6">
                        <label class="form-label">Pilih File Gambar Bukti Transfer</label>
                        <!-- For mocking, we show a styled input field but submit via our post helper -->
                        <div style="border: 2px dashed var(--color-border); padding: 30px; text-align: center; border-radius: var(--radius-sm); background: #f8fafc;">
                            <svg viewBox="0 0 24 24" width="40" height="40" fill="#94a3b8" style="margin: 0 auto 8px;">
                                <path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM14 13v4h-4v-4H7l5-5 5 5h-3z"/>
                            </svg>
                            <span style="font-size:13px; font-weight:700; color:var(--color-primary); cursor:pointer;">Pilih Foto Struk Transfer</span>
                            <div style="font-size:11px; color:var(--color-text-muted); margin-top:4px;">JPEG, PNG up to 2MB (Simulasi)</div>
                        </div>
                    </div>

                    <div class="d-flex justify-between gap-4">
                        <button type="button" @click="isModalOpen = false" class="btn btn-outline w-100">Batal</button>
                        <button type="submit" class="btn btn-primary w-100" :disabled="proofForm.processing">Kirim Bukti</button>
                    </div>
                </form>
            </div>
        </div>
        <!-- Address Form Modal -->
        <div v-if="isAddressFormModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:10000; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:550px; background: white; border-radius: 12px; overflow: hidden; animation: slideUp 0.3s forwards;">
                <div class="d-flex justify-between align-center" style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0; flex: 1; text-align: center;">{{ addressFormMode === 'add' ? 'Tambah Alamat Baru' : 'Ubah Alamat' }}</h3>
                    <button @click="isAddressFormModalOpen = false" style="background: none; border: none; cursor: pointer;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                
                <form @submit.prevent="saveAddress" style="padding: 24px; max-height: 70vh; overflow-y: auto;">
                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Nama Penerima</label>
                        <input type="text" v-model="addressForm.name" required maxlength="50" class="form-input" style="width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <div style="text-align: right; font-size: 12px; color: #64748b; margin-top: 4px;">{{ addressForm.name.length }}/50</div>
                    </div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Nomor HP</label>
                        <input type="text" v-model="addressForm.phone" required maxlength="15" class="form-input" style="width: 100%; padding: 14px 40px 14px 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1e293b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; right: 14px; top: 14px;"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect></svg>
                        <div style="text-align: right; font-size: 12px; color: #64748b; margin-top: 4px;">{{ addressForm.phone.length }}/15</div>
                    </div>
                    
                    <div style="height: 8px; background: #f1f5f9; margin: 24px -24px;"></div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Label Alamat</label>
                        <input type="text" v-model="addressForm.label" required maxlength="30" class="form-input" style="width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <div style="text-align: right; font-size: 12px; color: #64748b; margin-top: 4px;">{{ addressForm.label.length }}/30</div>
                    </div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Kota & Kecamatan / Kodepos (Cari)</label>
                        <input type="text" v-model="areaSearchQuery" placeholder="Ketik nama kecamatan atau kodepos..." class="form-input" style="width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <div v-if="isSearchingArea" style="position: absolute; right: 12px; top: 16px; font-size: 12px; color: #64748b;">Mencari...</div>
                        
                        <!-- Autocomplete Dropdown -->
                        <div v-if="areaSearchResults.length > 0" style="position: absolute; z-index: 10; width: 100%; background: white; border: 1px solid #cbd5e1; border-radius: 8px; margin-top: 4px; max-height: 200px; overflow-y: auto; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1);">
                            <div v-for="area in areaSearchResults" :key="area.id" @click="selectArea(area)" style="padding: 12px; cursor: pointer; border-bottom: 1px solid #f1f5f9; hover: background: #f8fafc;">
                                <div style="font-weight: 600; font-size: 14px; color: #0f172a;">{{ area.name }}</div>
                                <div style="font-size: 12px; color: #64748b;">{{ area.administrative_division_level_2_name }}, {{ area.administrative_division_level_1_name }} {{ area.postal_code }}</div>
                            </div>
                        </div>
                    </div>

                    <div style="position: relative; margin-bottom: 24px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Alamat Lengkap</label>
                        <textarea v-model="addressForm.address" required maxlength="200" class="form-input" rows="3" style="width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px; resize: vertical;"></textarea>
                        <div style="text-align: right; font-size: 12px; color: #64748b; margin-top: 4px;">{{ addressForm.address.length }}/200</div>
                    </div>

                    <div style="position: relative; margin-bottom: 32px;">
                        <label style="position: absolute; top: -8px; left: 12px; background: white; padding: 0 4px; font-size: 12px; color: #64748b; font-weight: 500;">Catatan Untuk Kurir (Opsional)</label>
                        <input type="text" v-model="addressForm.catatan" maxlength="45" class="form-input" style="width: 100%; padding: 14px; border: 1px solid #cbd5e1; border-radius: 8px;">
                        <div class="d-flex justify-between" style="margin-top: 4px;">
                            <div style="font-size: 12px; color: #64748b;">Warna rumah, patokan, pesan khusus, dll.</div>
                            <div style="font-size: 12px; color: #64748b;">{{ addressForm.catatan.length }}/45</div>
                        </div>
                    </div>

                    <div class="d-flex align-center gap-2 mb-6">
                        <input type="checkbox" id="isMain" v-model="addressForm.isMain" style="width: 16px; height: 16px;">
                        <label for="isMain" style="font-size: 14px; color: #1e293b; cursor: pointer;">Jadikan Alamat Utama</label>
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100" style="background: #e11d48; border-color: #e11d48; padding: 14px; font-weight: 700; border-radius: 8px;">
                        Simpan Alamat
                    </button>
                </form>
            </div>
        </div>
    </AppLayout>
</template>

<style scoped>
:deep(.markdown-body p) {
    margin-bottom: 0.5em;
    margin-top: 0;
}
:deep(.markdown-body p:last-child) {
    margin-bottom: 0;
}
:deep(.markdown-body ul) {
    list-style-type: disc;
    padding-left: 1.5em;
    margin-bottom: 0.5em;
}
:deep(.markdown-body ol) {
    list-style-type: decimal;
    padding-left: 1.5em;
    margin-bottom: 0.5em;
}
:deep(.markdown-body li) {
    margin-bottom: 0.25em;
}
:deep(.markdown-body strong) {
    font-weight: 700;
}
:deep(.markdown-body em) {
    font-style: italic;
}
:deep(.markdown-body h1), :deep(.markdown-body h2), :deep(.markdown-body h3) {
    font-weight: 700;
    margin-top: 1em;
    margin-bottom: 0.5em;
}
:deep(.markdown-body h1:first-child), :deep(.markdown-body h2:first-child), :deep(.markdown-body h3:first-child) {
    margin-top: 0;
}
:deep(.markdown-body a) {
    color: #2563eb;
    text-decoration: underline;
}
</style>
