<script setup>
import AppLayout from '@/Layouts/AppLayout.vue';
import { useForm, Link, router } from '@inertiajs/vue3';
import { ref, computed, watch, onMounted } from 'vue';
import { useAddresses } from '@/Composables/useAddresses';

const props = defineProps({
    cartItems: {
        type: Array,
        required: true,
    },
    logistic: {
        type: Object,
        required: true,
    },
    bankAccounts: {
        type: Array,
        required: true,
    },
    user: {
        type: Object,
        default: () => ({}),
    }
});

const { addresses: mockAddresses, addAddress, updateAddress } = useAddresses(props.user?.username);

const isAddressModalOpen = ref(false);
const isEditAddressModalOpen = ref(false);
const activeTab = ref('semua');

const storeAddress = {
    id: 99,
    label: 'Ambil Di Toko',
    isMain: false,
    name: 'Sinar Abadi (Pusat)',
    phone: '+62 8123388670',
    address: 'Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181',
    pinpoint: false
};

const selectedAddress = ref(mockAddresses.value.length > 0 ? mockAddresses.value[0] : storeAddress);

const selectedBank = ref(props.bankAccounts[0]?.name || 'Mandiri');
const selectedPaymentMethod = ref('midtrans_gopay'); // specific midtrans method or 'manual'
const isProcessingMidtrans = ref(false);
const midtransError = ref('');

const midtransMethods = [
    { id: 'midtrans_gopay', name: 'GoPay/QRIS', badge: 'E-Wallet / Instan' },
    { id: 'midtrans_bca_va', name: 'BCA Virtual Account', badge: 'Otomatis' },
    { id: 'midtrans_echannel', name: 'Mandiri Virtual Account', badge: 'Otomatis' },
    { id: 'midtrans_bni_va', name: 'BNI Virtual Account', badge: 'Otomatis' },
    { id: 'midtrans_bri_va', name: 'BRI Virtual Account', badge: 'Otomatis' },
];

const checkoutForm = useForm({
    bank: selectedBank.value,
    address: selectedAddress.value.kota ? `${selectedAddress.value.address}, ${selectedAddress.value.kota}` : selectedAddress.value.address,
    phone: selectedAddress.value.phone,
    courier: selectedAddress.value.id === 99 ? 'Ambil Di Toko' : 'JNE',
    proof: null,
    biteship_area_id: selectedAddress.value.biteshipAreaId || '',
    shipping_cost: 0,
    courier_code: '',
    courier_service_code: '',
    delivery_location_id: null,
    payment_type: 'midtrans_gopay',
});

// Delivery locations for Kurir Toko Sinar Abadi
const deliveryLocations = ref([]);
const selectedDeliveryLocation = ref(null);
const isFetchingLocations = ref(false);

const fetchDeliveryLocations = async () => {
    isFetchingLocations.value = true;
    try {
        const res = await fetch('http://localhost:8080/api/delivery/locations');
        if (res.ok) {
            deliveryLocations.value = await res.json();
            if (activeTab.value === 'kurir') {
                checkDeliveryLocationMatch();
            }
        }
    } catch (e) {
        console.error('Failed to fetch delivery locations', e);
    } finally {
        isFetchingLocations.value = false;
    }
};

const checkDeliveryLocationMatch = () => {
    if (!selectedAddress.value || selectedAddress.value.id === 99 || !deliveryLocations.value.length) return;
    
    const fullAddress = `${selectedAddress.value.address} ${selectedAddress.value.kota || ''}`.toLowerCase();
    
    // Match intelligently, ignoring "Desa" prefixes
    const match = deliveryLocations.value.find(loc => {
        let locName = loc.name.toLowerCase().replace(/^desa\s+/, '');
        return fullAddress.includes(locName);
    });
    
    if (match) {
        selectedDeliveryLocation.value = match;
        checkoutForm.delivery_location_id = match.id;
        checkoutForm.shipping_cost = match.shippingCost;
    } else {
        selectedDeliveryLocation.value = null;
        checkoutForm.delivery_location_id = null;
        checkoutForm.shipping_cost = 0;
    }
};

const isDragging = ref(false);
const proofPreview = ref(null);
const fileInputRef = ref(null);

const handleProofUpload = (e) => {
    const file = e.target.files[0];
    if (file) {
        checkoutForm.proof = file;
        proofPreview.value = URL.createObjectURL(file);
    }
};

const handleDrop = (e) => {
    e.preventDefault();
    isDragging.value = false;
    const file = e.dataTransfer.files[0];
    if (file && file.type.startsWith('image/')) {
        checkoutForm.proof = file;
        proofPreview.value = URL.createObjectURL(file);
    }
};

const handleDragOver = (e) => {
    e.preventDefault();
    isDragging.value = true;
};

const handleDragLeave = () => {
    isDragging.value = false;
};

const triggerFileInput = () => {
    fileInputRef.value?.click();
};

const removeProof = () => {
    checkoutForm.proof = null;
    proofPreview.value = null;
    if (fileInputRef.value) fileInputRef.value.value = '';
};

// Watch for changes in selectedAddress to update checkout form
const availableRates = ref([]);
const isFetchingRates = ref(false);
const selectedRate = ref(null);

const fetchRates = async (addr) => {
    availableRates.value = [];
    selectedRate.value = null;
    
    if (!addr.biteshipAreaId) {
        // Fallback for mock data without biteshipAreaId
        availableRates.value = [
             { id: 1, courier_name: 'JNE', courier_code: 'jne', courier_service_name: 'REG', courier_service_code: 'reg', price: 15000, duration: '2-3 hari' },
             { id: 2, courier_name: 'SiCepat', courier_code: 'sicepat', courier_service_name: 'HALU', courier_service_code: 'halu', price: 12000, duration: '2-4 hari' }
        ];
        return;
    }

    isFetchingRates.value = true;
    try {
        const payload = {
            destinationAreaId: addr.biteshipAreaId,
            couriers: 'jne,sicepat,jnt',
            items: props.cartItems.map(item => ({
                name: item.name,
                value: item.price,
                quantity: item.qty,
                weight: item.weight && item.weight > 0 ? item.weight : 2000,
                length: item.length && item.length > 0 ? item.length : 1,
                width: item.width && item.width > 0 ? item.width : 1,
                height: item.height && item.height > 0 ? item.height : 1
            }))
        };
        const res = await fetch('http://localhost:8080/api/biteship/rates', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        
        if (res.ok) {
            const data = await res.json();
            // Map Biteship response to include courier_code and courier_service_code
            // Biteship returns 'pricing' array with courier_name, courier_code, courier_service_name, courier_service_code
            availableRates.value = (data.pricing || []).map(rate => ({
                ...rate,
                courier_code: rate.courier_code || '',
                courier_service_code: rate.courier_service_code || '',
            }));
        }
    } catch (e) {
        console.error("Failed to fetch rates", e);
    } finally {
        isFetchingRates.value = false;
    }
};

const selectAddress = async (addr) => {
    if (!addr) return;
    
    selectedAddress.value = addr;
    checkoutForm.address = addr.kota ? `${addr.address}, ${addr.kota}` : addr.address;
    checkoutForm.phone = addr.phone;
    checkoutForm.biteship_area_id = addr.biteshipAreaId || '';
    
    if (addr.id === 99) {
        checkoutForm.courier = 'Ambil Di Toko';
        selectedRate.value = null;
        selectedDeliveryLocation.value = null;
        checkoutForm.delivery_location_id = null;
    } else if (activeTab.value === 'kurir') {
        checkoutForm.courier = 'Kurir Toko Sinar Abadi';
        selectedRate.value = null;
        checkDeliveryLocationMatch();
    } else {
        checkoutForm.courier = ''; // Will be set when user picks a rate
        selectedDeliveryLocation.value = null;
        checkoutForm.delivery_location_id = null;
        await fetchRates(addr);
    }
};

const selectCourierRate = (rate) => {
    selectedRate.value = rate;
    checkoutForm.courier = `${rate.courier_name} ${rate.courier_service_name}`;
    checkoutForm.courier_code = rate.courier_code || '';
    checkoutForm.courier_service_code = rate.courier_service_code || '';
};

// Automatically select default address based on tab change
watch(activeTab, (newTab) => {
    if (newTab === 'ambil') {
        selectAddress(storeAddress);
    } else {
        if (selectedAddress.value.id === 99 && mockAddresses.value.length === 0) {
            // Do not try to select mockAddresses[0] if it's empty
            return;
        }
        selectAddress(selectedAddress.value.id === 99 ? mockAddresses.value[0] : selectedAddress.value);
    }
});

onMounted(() => {
    if (selectedAddress.value && selectedAddress.value.id !== 99 && activeTab.value === 'semua') {
        checkoutForm.biteship_area_id = selectedAddress.value.biteshipAreaId || '';
        fetchRates(selectedAddress.value);
    }
    // Prefetch delivery locations for Kurir Toko tab
    fetchDeliveryLocations();
});

// Edit form
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
    biteshipAreaId: '',
    postalCode: '',
});

const areaSearchQuery = ref('');
const isSearchingArea = ref(false);
const areaSearchResults = ref([]);
const isSelectingArea = ref(false);

let searchTimeout;
watch(areaSearchQuery, (newVal) => {
    if (isSelectingArea.value) {
        isSelectingArea.value = false;
        return;
    }

    if (!newVal || newVal.length < 3) {
        areaSearchResults.value = [];
        return;
    }
    
    clearTimeout(searchTimeout);
    isSearchingArea.value = true;
    
    searchTimeout = setTimeout(async () => {
        try {
            const res = await fetch(`http://localhost:8080/api/biteship/maps?input=${encodeURIComponent(newVal)}`);
            if (res.ok) {
                const data = await res.json();
                areaSearchResults.value = data.areas || [];
            }
        } catch (e) {
            console.error("Failed to fetch areas", e);
        } finally {
            isSearchingArea.value = false;
        }
    }, 500);
});

const selectArea = (area) => {
    addressForm.biteshipAreaId = area.id;
    addressForm.kota = area.name;
    addressForm.postalCode = area.postal_code || '';
    
    isSelectingArea.value = true;
    areaSearchQuery.value = `${area.name}, ${area.administrative_division_level_2_name}, ${area.administrative_division_level_1_name} ${area.postal_code}`;
    areaSearchResults.value = [];
};

// Update Address from Payment.vue
const saveEditAddress = async () => {
    try {
        const payload = {
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

        let result = false;
        if (addressForm.id === null) {
            result = await addAddress(payload);
        } else {
            result = await updateAddress(addressForm.id, payload);
        }
        
        if (result === true) {
            isEditAddressModalOpen.value = false;
            if (addressForm.id === null) {
                // Automatically select the newly created address if it's the only one
                if (mockAddresses.value.length === 1) {
                    selectAddress(mockAddresses.value[0]);
                } else {
                    // Otherwise find the one we just added (usually the last one)
                    selectAddress(mockAddresses.value[mockAddresses.value.length - 1]);
                }
            }
            // Refresh selected address if it was the one edited
            if (selectedAddress.value.id === addressForm.id) {
                const updated = mockAddresses.value.find(a => a.id === addressForm.id);
                if (updated) selectAddress(updated);
            }
        } else {
            alert("Gagal menyimpan alamat di server. Pesan error:\n" + result);
        }
    } catch (err) {
        alert("Terjadi kesalahan pada sistem: " + err.message);
        console.error(err);
    }
};

const openAddAddressModal = () => {
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
    addressForm.name = props.user?.name || '';
    addressForm.phone = props.user?.phone || '';
    isEditAddressModalOpen.value = true;
};

const openEditAddress = (addr) => {
    addressForm.id = addr.id;
    addressForm.label = addr.label;
    addressForm.name = addr.name;
    addressForm.phone = addr.phone;
    addressForm.kota = addr.kota || '';
    addressForm.address = addr.address;
    addressForm.catatan = addr.catatan || '';
    addressForm.isMain = addr.isMain || false;
    addressForm.pinpoint = addr.pinpoint || false;
    addressForm.biteshipAreaId = addr.biteshipAreaId || '';
    addressForm.postalCode = addr.postalCode || '';
    areaSearchQuery.value = addr.kota || '';
    isEditAddressModalOpen.value = true;
};

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

// PPN calculation if needed, for now just matching UI
const ppn = computed(() => {
    return subtotal.value * 0.11;
});

const currentShippingCost = computed(() => {
    if (activeTab.value === 'semua' && selectedRate.value) {
        return selectedRate.value.price;
    }
    if (activeTab.value === 'kurir' && selectedDeliveryLocation.value) {
        return selectedDeliveryLocation.value.shippingCost;
    }
    if (activeTab.value === 'ambil') {
        return 0;
    }
    return props.logistic.cost || 0;
});

const grandTotal = computed(() => {
    return subtotal.value + ppn.value + currentShippingCost.value;
});

const isCheckoutDisabled = computed(() => {
    const courierNotReady = activeTab.value === 'semua' && !selectedRate.value;
    const kurirNoLocation = activeTab.value === 'kurir' && !selectedDeliveryLocation.value;
    const processing = checkoutForm.processing || isProcessingMidtrans.value;
    
    if (selectedPaymentMethod.value.startsWith('midtrans')) {
        return processing || courierNotReady || kurirNoLocation;
    }
    // Manual: also need proof
    return processing || !checkoutForm.proof || courierNotReady || kurirNoLocation;
});

const handleCheckout = async () => {
    if (!confirm('Pastikan alamat pengiriman sudah benar dan kurir pengiriman sudah sesuai.')) {
        return;
    }

    checkoutForm.bank = selectedBank.value;
    checkoutForm.shipping_cost = currentShippingCost.value;
    checkoutForm.payment_type = selectedPaymentMethod.value;

    // === MIDTRANS FLOW ===
    if (selectedPaymentMethod.value.startsWith('midtrans')) {
        isProcessingMidtrans.value = true;
        midtransError.value = '';
        
        try {
            const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
            const formData = new FormData();
            formData.append('payment_type', selectedPaymentMethod.value);
            formData.append('address', checkoutForm.address);
            formData.append('phone', checkoutForm.phone);
            formData.append('courier', checkoutForm.courier);
            formData.append('biteship_area_id', checkoutForm.biteship_area_id);
            formData.append('shipping_cost', checkoutForm.shipping_cost);
            formData.append('courier_code', checkoutForm.courier_code);
            formData.append('courier_service_code', checkoutForm.courier_service_code);
            if (checkoutForm.delivery_location_id) {
                formData.append('delivery_location_id', checkoutForm.delivery_location_id);
            }

            const response = await fetch('/checkout', {
                method: 'POST',
                headers: {
                    'X-CSRF-TOKEN': csrfToken,
                    'Accept': 'application/json',
                },
                body: formData,
            });

            const data = await response.json();

            if (!response.ok) {
                midtransError.value = data.error || 'Gagal membuat pesanan.';
                isProcessingMidtrans.value = false;
                return;
            }

            if (data.snapToken) {
                const createdOrderId = data.orderId;
                // Open Midtrans Snap popup
                window.snap.pay(data.snapToken, {
                    onSuccess: async function(result) {
                        // Payment completed — clear cart and redirect
                        await fetch('/cart/clear', {
                            method: 'POST',
                            headers: {
                                'X-CSRF-TOKEN': csrfToken,
                                'Accept': 'application/json',
                            },
                        });
                        router.visit('/customer/dashboard', {
                            method: 'get',
                            data: {},
                            replace: true,
                        });
                    },
                    onPending: async function(result) {
                        // User closed popup after selecting payment method (QRIS/VA shown).
                        // Cancel the order so they can go back and retry.
                        // If user actually paid (e.g. scanned QRIS), the Midtrans webhook
                        // will still process the payment and re-create the order.
                        try {
                            await fetch('/checkout/cancel', {
                                method: 'POST',
                                headers: {
                                    'X-CSRF-TOKEN': csrfToken,
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify({ orderId: createdOrderId }),
                            });
                        } catch (e) {
                            console.error('Failed to cancel order:', e);
                        }
                        isProcessingMidtrans.value = false;
                        // User stays on payment page and can retry
                    },
                    onError: async function(result) {
                        // Payment failed — cancel the order and let user retry
                        try {
                            await fetch('/checkout/cancel', {
                                method: 'POST',
                                headers: {
                                    'X-CSRF-TOKEN': csrfToken,
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify({ orderId: createdOrderId }),
                            });
                        } catch (e) {
                            console.error('Failed to cancel order:', e);
                        }
                        midtransError.value = 'Pembayaran gagal. Silakan coba lagi.';
                        isProcessingMidtrans.value = false;
                    },
                    onClose: async function() {
                        // User pressed the X button — they want to go back.
                        // Cancel the order so stock is restored and user can retry.
                        try {
                            await fetch('/checkout/cancel', {
                                method: 'POST',
                                headers: {
                                    'X-CSRF-TOKEN': csrfToken,
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                },
                                body: JSON.stringify({ orderId: createdOrderId }),
                            });
                        } catch (e) {
                            console.error('Failed to cancel order:', e);
                        }
                        isProcessingMidtrans.value = false;
                        // User stays on payment page and can retry
                    }
                });
            } else {
                midtransError.value = 'Token pembayaran tidak ditemukan.';
                isProcessingMidtrans.value = false;
            }
        } catch (err) {
            console.error('Midtrans checkout error:', err);
            midtransError.value = 'Terjadi kesalahan. Silakan coba lagi.';
            isProcessingMidtrans.value = false;
        }
        return;
    }

    // === MANUAL TRANSFER FLOW ===
    checkoutForm.post('/checkout', {
        forceFormData: true,
    });
};
</script>

<template>
    <AppLayout>
        <section class="section active" style="padding-top: 40px; background: #f8fafc; min-height: 100vh;">
            <div class="container" style="max-width: 1000px;">
                <div class="d-flex align-center justify-between mb-6" style="padding-bottom: 16px; border-bottom: 2px solid #e2e8f0;">
                    <div class="d-flex align-center gap-4">
                        <h2 style="font-size: 24px; font-weight: 800; color: #dc2626; margin: 0;">SINAR ABADI</h2>
                        <div style="width: 1px; height: 24px; background: #cbd5e1;"></div>
                        <div style="color: #059669; font-weight: 700; font-size: 14px; display: flex; align-items: center; gap: 6px;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            PEMBAYARAN AMAN
                        </div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1.8fr 1fr; gap: 24px; align-items: start;">
                    <!-- Left Column -->
                    <div class="d-flex flex-column gap-6">
                        
                        <!-- ALAMAT PENGIRIMAN -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 24px;">
                            <h3 style="font-size: 14px; font-weight: 700; color: #64748b; margin-bottom: 16px; text-transform: uppercase;">ALAMAT PENGIRIMAN</h3>
                            
                            <div class="d-flex justify-between align-start">
                                <div>
                                    <div class="d-flex align-center gap-2 mb-2">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                            <circle cx="12" cy="10" r="3"></circle>
                                        </svg>
                                        <template v-if="checkoutForm.courier === 'Ambil Di Toko'">
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">Ambil Di Toko</span>
                                        </template>
                                        <template v-else-if="checkoutForm.courier === 'Kurir Toko Sinar Abadi'">
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">Kurir Sinar Abadi - {{ selectedAddress.name }}</span>
                                        </template>
                                        <template v-else>
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ selectedAddress.label }}</span>
                                            <span style="color: #64748b; font-size: 14px;">•</span>
                                            <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ selectedAddress.name }}</span>
                                        </template>
                                    </div>
                                    <div style="color: #334155; font-size: 14px; line-height: 1.5; max-width: 90%;">
                                        {{ selectedAddress.address }}
                                    </div>
                                </div>
                                <button @click="isAddressModalOpen = true" class="btn btn-outline" style="padding: 6px 16px; font-size: 13px; border-radius: 8px;">
                                    Ganti
                                </button>
                            </div>
                        </div>

                        <!-- KURIR PENGIRIMAN -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 24px;">
                            <h3 style="font-size: 14px; font-weight: 700; color: #64748b; margin-bottom: 16px; text-transform: uppercase;">KURIR PENGIRIMAN</h3>
                            
                            <template v-if="checkoutForm.courier === 'Ambil Di Toko'">
                                <div style="font-weight: 700; font-size: 14px; color: #0f172a;">Ambil Di Toko</div>
                                <div style="font-size: 13px; color: #64748b; margin-top: 4px;">Barang diambil sendiri di toko Sinar Abadi. (Gratis)</div>
                            </template>
                            <template v-else-if="checkoutForm.courier === 'Kurir Toko Sinar Abadi'">
                                <div style="font-weight: 700; font-size: 14px; color: #0f172a;">Kurir Toko Sinar Abadi</div>
                                <div style="font-size: 13px; color: #64748b; margin-top: 4px;">Dikirim oleh armada toko kami ke desa tujuan.</div>
                                
                                <div style="margin-top: 16px;">
                                    <div v-if="isFetchingLocations" style="font-size: 13px; color: #64748b; padding: 12px; text-align: center;">
                                        Memuat data lokasi...
                                    </div>
                                    <div v-else-if="selectedDeliveryLocation" style="padding: 10px 14px; background: #f0fdf4; border: 1px solid #86efac; border-radius: 6px;">
                                        <div style="font-size: 12px; color: #166534; font-weight: 600;">Tujuan dikenali: <strong>{{ selectedDeliveryLocation.name }}</strong></div>
                                        <div style="font-size: 13px; color: #166534; font-weight: 800; margin-top: 2px;">
                                            Ongkir: {{ selectedDeliveryLocation.shippingCost === 0 ? 'GRATIS' : formatPrice(selectedDeliveryLocation.shippingCost) }}
                                        </div>
                                    </div>
                                    <div v-else style="padding: 10px 14px; background: #fef2f2; border: 1px solid #fca5a5; border-radius: 6px;">
                                        <div style="font-size: 13px; color: #dc2626; font-weight: 600;">
                                            Untuk lokasi Anda saat ini belum bisa dikirim oleh kurir sinar abadi, mohon pilih metode pengiriman yang lain.
                                        </div>
                                    </div>

                                    <!-- Supported Delivery Areas Info -->
                                    <div style="margin-top: 12px; font-size: 12px; color: #64748b; background: #f8fafc; padding: 10px 14px; border: 1px dashed #cbd5e1; border-radius: 6px;">
                                        <strong style="color: #475569; display: block; margin-bottom: 8px;">Area Jangkauan Kurir Toko:</strong>
                                        <ol style="margin: 0; padding-left: 24px; line-height: 1.6; column-count: 2; column-gap: 24px; list-style-type: decimal;">
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Dampit (Jambangan, Ngelak, Rembun)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Tirtoyudo (Kepatihan, Pujiharjo, Lenggoksono)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Wonoagung (Wonokitri)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Tamansari (Blubuk)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Kebonagung (Karangsono)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Gedangan (Sumber Gesing)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Srimulyo (Sumber Arum)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Ampelgading (Sono Wangi, Sono Sekar)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Sumbermanjing Wetan (Tambak Asri, Sido Asri)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Pamotan (Sumber Ayu)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Majangtengah (Lambang Kuning)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Sumberputih (Lambang Sari)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Wajak (Sumber Putih)</li>
                                            <li style="break-inside: avoid; margin-bottom: 6px;">Turen (Kedok, Turen Pusat)</li>
                                        </ol>
                                    </div>
                                </div>
                            </template>
                            <template v-else>
                                <div v-if="isFetchingRates" style="font-size: 13px; color: #64748b; padding: 12px; text-align: center;">
                                    Menghitung ongkos kirim...
                                </div>
                                <div v-else-if="availableRates.length === 0" style="font-size: 13px; color: #dc2626;">
                                    Gagal mendapatkan daftar ongkos kirim untuk alamat ini. Pastikan alamat memiliki kecamatan/kodepos yang valid.
                                </div>
                                <div v-else style="display: flex; flex-direction: column; gap: 8px;">
                                    <div 
                                        v-for="(rate, idx) in availableRates" 
                                        :key="idx"
                                        @click="selectCourierRate(rate)"
                                        style="display: flex; justify-content: space-between; align-items: center; padding: 12px; border: 1px solid #e2e8f0; border-radius: 6px; cursor: pointer;"
                                        :style="selectedRate === rate ? { borderColor: '#e11d48', background: '#fff1f2' } : { background: 'white' }"
                                    >
                                        <div>
                                            <div style="font-weight: 700; font-size: 14px; color: #0f172a;">{{ rate.courier_name }} ({{ rate.courier_service_name }})</div>
                                            <div style="font-size: 12px; color: #64748b; margin-top: 2px;">Estimasi: {{ rate.duration }}</div>
                                        </div>
                                        <div style="font-weight: 800; font-size: 14px; color: #0f172a;">
                                            {{ formatPrice(rate.price) }}
                                        </div>
                                    </div>
                                </div>
                            </template>
                        </div>

                        <!-- METODE PEMBAYARAN -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 24px;">
                            <h3 style="font-size: 14px; font-weight: 700; color: #0f172a; margin-bottom: 16px; text-transform: uppercase; border-bottom: 1px solid #e2e8f0; padding-bottom: 12px;">METODE PEMBAYARAN</h3>
                            
                            <p class="text-muted mb-4" style="font-size:13px;">
                                Silahkan pilih metode pembayaran yang Anda inginkan:
                            </p>

                            <!-- Midtrans Payment Options -->
                            <div 
                                v-for="method in midtransMethods" 
                                :key="method.id" 
                                class="order-card mb-3"
                                :style="selectedPaymentMethod === method.id ? { borderColor: '#0ea5e9', background: '#f0f9ff' } : { cursor: 'pointer' }"
                                @click="selectedPaymentMethod = method.id"
                            >
                                <div class="d-flex align-center gap-3">
                                    <div 
                                        style="width: 18px; height: 18px; border-radius: 50%; border: 2px solid #cbd5e1; display: flex; align-items: center; justify-content: center; background: white;"
                                        :style="selectedPaymentMethod === method.id ? { borderColor: '#0ea5e9' } : {}"
                                    >
                                        <div 
                                            v-if="selectedPaymentMethod === method.id"
                                            style="width: 10px; height: 10px; border-radius: 50%; background: #0ea5e9;"
                                        ></div>
                                    </div>
                                    <div style="flex: 1;">
                                        <span style="font-size: 14px; font-weight: 600; color: #1e293b;">
                                            {{ method.name }}
                                        </span>
                                        <span style="font-size: 11px; font-weight: 700; color: white; background: linear-gradient(135deg, #0ea5e9, #6366f1); padding: 2px 8px; border-radius: 4px; margin-left: 8px;">
                                            {{ method.badge }}
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <!-- Option 2: Transfer Bank Manual -->
                            <div 
                                v-for="bank in bankAccounts" 
                                :key="bank.name" 
                                class="order-card mb-3"
                                :style="selectedPaymentMethod === 'manual' ? { borderColor: '#3b82f6', background: '#eff6ff' } : { cursor: 'pointer' }"
                                @click="selectedPaymentMethod = 'manual'; selectedBank = bank.name"
                            >
                                <div class="d-flex align-center gap-3">
                                    <div 
                                        style="width: 18px; height: 18px; border-radius: 50%; border: 2px solid #cbd5e1; display: flex; align-items: center; justify-content: center; background: white;"
                                        :style="selectedPaymentMethod === 'manual' ? { borderColor: '#3b82f6' } : {}"
                                    >
                                        <div 
                                            v-if="selectedPaymentMethod === 'manual'"
                                            style="width: 10px; height: 10px; border-radius: 50%; background: #3b82f6;"
                                        ></div>
                                    </div>
                                    <span style="font-size: 14px; font-weight: 600; color: #1e293b;">
                                        Transfer Bank ({{ bank.name }}) <span style="font-size: 12px; font-weight: 500; color: #64748b;">(Verifikasi Manual)</span>
                                    </span>
                                </div>

                                <div v-if="selectedPaymentMethod === 'manual'" style="margin-top: 16px; margin-left: 31px; background: white; padding: 16px; border-radius: 6px; border: 1px solid #e2e8f0;">
                                    <div style="font-size: 13px; font-weight: 700; color: #0f172a; margin-bottom: 4px;">Instruksi Pembayaran (Rekening Tujuan)</div>
                                    <div style="font-size: 13px; color: #64748b; margin-bottom: 12px;">Silakan transfer tagihan Anda ke rekening kami berikut:</div>
                                    
                                    <div style="font-size: 16px; font-weight: 800; color: #1e3a8a; margin-bottom: 16px;">
                                        {{ bank.name }} - {{ bank.number }} a.n. {{ bank.owner }}
                                    </div>

                                    <div style="border-top: 1px solid #e2e8f0; margin-bottom: 12px;"></div>

                                    <div style="font-size: 13px; font-weight: 700; color: #0f172a; margin-bottom: 4px;">Alamat Sinar Abadi (Pusat)</div>
                                    <div style="font-size: 13px; color: #64748b; line-height: 1.5;">
                                        Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181 &bull; +62 8123388670
                                    </div>
                                </div>
                            </div>

                            <!-- Upload Bukti Transfer (only for manual) -->
                            <div v-if="selectedPaymentMethod === 'manual'" style="margin-top: 16px; margin-bottom: 16px;">
                                <label style="font-size: 13px; font-weight: 700; color: #0f172a; display: block; margin-bottom: 8px;">Upload Bukti Transfer</label>
                                
                                <input 
                                    ref="fileInputRef"
                                    type="file" 
                                    accept="image/*"
                                    @change="handleProofUpload"
                                    style="display: none;"
                                >

                                <div 
                                    v-if="!proofPreview"
                                    @click="triggerFileInput"
                                    @drop="handleDrop"
                                    @dragover="handleDragOver"
                                    @dragleave="handleDragLeave"
                                    :style="{
                                        border: isDragging ? '2px dashed #3b82f6' : '2px dashed #cbd5e1',
                                        borderRadius: '12px',
                                        padding: '32px 16px',
                                        textAlign: 'center',
                                        cursor: 'pointer',
                                        background: isDragging ? '#eff6ff' : '#f8fafc',
                                        transition: 'all 0.25s ease',
                                    }"
                                >
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="margin: 0 auto 12px; display: block;">
                                        <path d="M16.5 18.5h-9a5 5 0 0 1-.42-9.98A7 7 0 0 1 20 9a4.5 4.5 0 0 1-0.5 8.97"></path>
                                        <polyline points="12 13 12 21"></polyline>
                                        <polyline points="9 16 12 13 15 16"></polyline>
                                    </svg>
                                    <div style="font-size: 14px; font-weight: 600; color: #334155; margin-bottom: 4px;">Klik atau seret file ke sini</div>
                                    <div style="font-size: 12px; color: #94a3b8;">Format: JPG, PNG, JPEG (Maks. 4MB)</div>
                                </div>

                                <div v-else style="position: relative; border: 2px solid #10b981; border-radius: 12px; padding: 12px; background: #f0fdf4; text-align: center;">
                                    <img :src="proofPreview" alt="Preview bukti transfer" style="max-height: 200px; max-width: 100%; border-radius: 8px; object-fit: contain;" />
                                    <div style="margin-top: 8px; font-size: 13px; color: #059669; font-weight: 600;">{{ checkoutForm.proof?.name }}</div>
                                    <button 
                                        @click.prevent="removeProof" 
                                        style="position: absolute; top: 8px; right: 8px; width: 28px; height: 28px; border-radius: 50%; background: #dc2626; border: none; cursor: pointer; display: flex; align-items: center; justify-content: center;"
                                    >
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                    </button>
                                </div>

                                <div style="font-size: 11px; color: #dc2626; margin-top: 4px;" v-if="checkoutForm.errors.proof">
                                    {{ checkoutForm.errors.proof }}
                                </div>
                            </div>
                            
                            <form @submit.prevent="handleCheckout" class="mt-4">
                                <div style="font-size: 13px; color: #dc2626; margin-bottom: 8px;" v-if="checkoutForm.errors.bank">
                                    {{ checkoutForm.errors.bank }}
                                </div>
                                <div style="font-size: 13px; color: #dc2626; margin-bottom: 8px;" v-if="midtransError">
                                    {{ midtransError }}
                                </div>
                                <button 
                                    type="submit" 
                                    class="btn w-100" 
                                    :style="[
                                        { background: selectedPaymentMethod.startsWith('midtrans') ? 'linear-gradient(135deg, #0ea5e9, #6366f1)' : '#0f172a', color: 'white', fontSize: '14px', padding: '16px', fontWeight: '700', borderRadius: '6px', border: 'none', cursor: 'pointer', transition: 'all 0.3s ease' },
                                        isCheckoutDisabled ? { opacity: 0.5, cursor: 'not-allowed' } : {}
                                    ]"
                                    :disabled="isCheckoutDisabled"
                                >
                                    <span v-if="checkoutForm.processing || isProcessingMidtrans">MEMPROSES PESANAN...</span>
                                    <span v-else-if="selectedPaymentMethod.startsWith('midtrans')">&#x1F512; BAYAR OTOMATIS</span>
                                    <span v-else>BAYAR SEKARANG</span>
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Right Column: Summaries -->
                    <div class="d-flex flex-column gap-4">
                        <!-- Ringkasan Pembelian -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 20px;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #0f172a; margin-bottom: 16px;">Ringkasan Pembelian</h3>
                            
                            <div class="d-flex justify-between align-center mb-3" style="font-size: 14px; color: #64748b;">
                                <span>Subtotal Produk</span>
                                <span style="color: #0f172a; font-weight: 500;">{{ formatPrice(subtotal) }}</span>
                            </div>
                            <div class="d-flex justify-between align-center mb-3" style="font-size: 14px; color: #64748b;">
                                <span>PPN (11%)</span>
                                <span style="color: #0f172a; font-weight: 500;">{{ formatPrice(ppn) }}</span>
                            </div>
                            <div class="d-flex justify-between align-center mb-4" style="font-size: 14px; color: #64748b;">
                                <span>Ongkos Kirim</span>
                                <span style="color: #0f172a; font-weight: 500;">
                                    <template v-if="checkoutForm.courier === 'Kurir Toko Sinar Abadi'">
                                        <template v-if="selectedDeliveryLocation">
                                            <span v-if="selectedDeliveryLocation.shippingCost === 0" style="color: #059669; font-weight: 700;">Gratis</span>
                                            <span v-else>{{ formatPrice(selectedDeliveryLocation.shippingCost) }}</span>
                                        </template>
                                        <span v-else style="color: #dc2626; font-style: italic; font-size: 13px;">(tujuan tidak terjangkau)</span>
                                    </template>
                                    <template v-else>
                                        {{ currentShippingCost > 0 ? formatPrice(currentShippingCost) : 'Gratis' }}
                                    </template>
                                </span>
                            </div>

                            <div style="border-top: 1px solid #e2e8f0; padding-top: 16px;" class="d-flex justify-between align-center">
                                <span style="font-size: 15px; font-weight: 700; color: #0f172a;">Grand Total</span>
                                <span style="font-size: 18px; font-weight: 800; color: #dc2626;">{{ formatPrice(grandTotal) }}</span>
                            </div>
                        </div>

                        <!-- Ringkasan Produk -->
                        <div style="background: white; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 20px;">
                            <h3 style="font-size: 15px; font-weight: 700; color: #0f172a; margin-bottom: 16px;">Ringkasan Produk</h3>
                            <div style="max-height: 250px; overflow-y: auto; padding-right: 8px;">
                                <div v-for="item in cartItems" :key="item.id" class="d-flex gap-3 mb-4">
                                    <div style="width: 48px; height: 48px; border-radius: 6px; background: #f1f5f9; flex-shrink: 0;">
                                        <img v-if="item.img" :src="item.img" style="width:100%; height:100%; object-fit:cover; border-radius: 6px;">
                                    </div>
                                    <div>
                                        <div style="font-size: 13px; color: #1e293b; font-weight: 600; line-height: 1.4;">{{ item.name }}</div>
                                        <div v-if="item.color" style="font-size: 12px; color: #64748b; margin-top: 2px;">Warna: <span style="font-weight: 500;">{{ item.color }}</span></div>
                                        <div style="font-size: 12px; color: #64748b; margin-top: 4px;">{{ item.qty }} x {{ formatPrice(item.price) }}</div>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex justify-end mt-2" style="border-top: 1px solid #e2e8f0; padding-top: 12px;">
                                <Link href="/cart" style="font-size: 13px; font-weight: 700; color: #3b82f6; text-decoration: none; display: flex; align-items: center; gap: 6px;">
                                    <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                    Edit
                                </Link>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Modal 1: Daftar Alamat -->
        <div v-if="isAddressModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:650px; background: white; border-radius: 12px; overflow: hidden; animation: slideUp 0.3s forwards; display: flex; flex-direction: column; max-height: 90vh;">
                <!-- Header -->
                <div class="d-flex justify-between align-center" style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0; flex: 1; text-align: center;">Daftar Alamat</h3>
                    <button @click="isAddressModalOpen = false" style="background: none; border: none; cursor: pointer;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                
                <!-- Tabs -->
                <div class="d-flex" style="border-bottom: 1px solid #e2e8f0;">
                    <div 
                        @click="activeTab = 'semua'"
                        style="flex: 1; text-align: center; padding: 12px 0; font-size: 14px; cursor: pointer;"
                        :style="activeTab === 'semua' ? 'font-weight: 700; color: #e11d48; border-bottom: 2px solid #e11d48;' : 'font-weight: 600; color: #64748b;'"
                    >
                        Ekspedisi (JNE, J&T, dan SiCepat)
                    </div>
                    <div 
                        @click="activeTab = 'ambil'"
                        style="flex: 1; text-align: center; padding: 12px 0; font-size: 14px; cursor: pointer;"
                        :style="activeTab === 'ambil' ? 'font-weight: 700; color: #e11d48; border-bottom: 2px solid #e11d48;' : 'font-weight: 600; color: #64748b;'"
                    >
                        Ambil Di Toko
                    </div>
                    <div 
                        @click="activeTab = 'kurir'"
                        style="flex: 1; text-align: center; padding: 12px 0; font-size: 14px; cursor: pointer;"
                        :style="activeTab === 'kurir' ? 'font-weight: 700; color: #e11d48; border-bottom: 2px solid #e11d48;' : 'font-weight: 600; color: #64748b;'"
                    >
                        Kurir Sinar Abadi
                    </div>
                </div>

                <div v-if="activeTab === 'semua' || activeTab === 'kurir'" style="display: flex; flex-direction: column; overflow: hidden;">
                    <!-- Search & Add -->
                    <div style="padding: 20px 24px;">
                        <div style="position: relative; margin-bottom: 16px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; left: 12px; top: 11px;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                            <input type="text" placeholder="Tulis Nama Alamat / Kota / Kecamatan tujuan pengiriman" style="width: 100%; padding: 10px 12px 10px 40px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 14px;">
                        </div>
                        
                        <button @click="openAddAddressModal" style="width: 100%; padding: 12px; border: 1px solid #e11d48; background: white; color: #e11d48; font-weight: 700; border-radius: 8px; font-size: 14px; cursor: pointer;">
                            Tambah Alamat Baru
                        </button>
                    </div>

                    <!-- Address List -->
                    <div style="padding: 0 24px 24px 24px; overflow-y: auto; flex: 1;">
                        <div 
                            v-for="addr in mockAddresses" 
                            :key="addr.id" 
                            @click="selectAddress(addr)"
                            style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 16px; margin-bottom: 16px; cursor: pointer; position: relative;"
                            :style="selectedAddress.id === addr.id ? { borderColor: '#e11d48' } : {}"
                        >
                            <div class="d-flex align-center gap-2 mb-2">
                                <span style="font-weight: 700; color: #0f172a; font-size: 14px;">{{ addr.label }}</span>
                                <span v-if="addr.isMain" style="background: #e11d48; color: white; font-size: 11px; font-weight: 700; padding: 2px 6px; border-radius: 4px;">Utama</span>
                            </div>
                            <div style="font-weight: 700; color: #0f172a; font-size: 15px; margin-bottom: 4px;">{{ addr.name }}</div>
                            <div style="font-size: 13px; color: #64748b; margin-bottom: 4px;">{{ addr.phone }}</div>
                            <div style="font-size: 13px; color: #334155; line-height: 1.5; margin-bottom: 12px; padding-right: 24px;">
                                {{ addr.address }}
                            </div>
                            
                            <div v-if="addr.pinpoint" class="d-flex align-center gap-2 mb-3" style="color: #e11d48; font-size: 13px; font-weight: 600;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                    <circle cx="12" cy="10" r="3"></circle>
                                </svg>
                                Sudah Pinpoint
                            </div>

                            <div class="d-flex align-center gap-4">
                                <span @click.stop="openEditAddress(addr)" style="font-size: 13px; font-weight: 700; color: #e11d48;">Ubah Alamat</span>
                            </div>

                            <!-- Checkmark -->
                            <div v-if="selectedAddress.id === addr.id" style="position: absolute; right: 16px; top: 16px; color: #e11d48;">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            </div>

                        </div>
                    </div>
                </div>

                <div v-else style="padding: 24px; flex: 1;">
                    <div 
                        @click="selectAddress(storeAddress)"
                        style="border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; cursor: pointer; position: relative;"
                        :style="selectedAddress.id === storeAddress.id ? { borderColor: '#e11d48' } : {}"
                    >
                        <div style="font-weight: 700; color: #0f172a; font-size: 15px; margin-bottom: 12px;">Ambil Di Toko</div>
                        <div style="font-size: 13px; color: #334155; line-height: 1.6; max-width: 90%;">
                            Alamat: {{ storeAddress.address }}
                        </div>
                        
                        <!-- Checkmark -->
                        <div v-if="selectedAddress.id === storeAddress.id" style="position: absolute; right: 16px; top: 20px; color: #e11d48;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        </div>
                    </div>
                </div>

                <div style="padding: 16px 24px; border-top: 1px solid #e2e8f0; background: white;">
                    <button 
                        @click="isAddressModalOpen = false" 
                        class="btn btn-primary w-100" 
                        style="background: #e11d48; border-color: #e11d48; padding: 14px; font-weight: 700; border-radius: 8px;"
                    >
                        Pilih Alamat
                    </button>
                </div>
            </div>
        </div>

        <!-- Modal 2: Edit Alamat -->
        <div v-if="isEditAddressModalOpen" class="d-flex" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:10000; align-items:center; justify-content:center; padding:16px;">
            <div style="width:100%; max-width:550px; background: white; border-radius: 12px; overflow: hidden; animation: slideUp 0.3s forwards;">
                <div class="d-flex justify-between align-center" style="padding: 20px 24px; border-bottom: 1px solid #e2e8f0;">
                    <h3 style="font-size: 18px; font-weight: 800; color: #0f172a; margin: 0; flex: 1; text-align: center;">Ubah Alamat</h3>
                    <button @click="isEditAddressModalOpen = false" style="background: none; border: none; cursor: pointer;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
                
                <form @submit.prevent="saveEditAddress" style="padding: 24px; max-height: 70vh; overflow-y: auto;">
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
                    
                    <button type="submit" class="btn btn-primary w-100" style="background: #e11d48; border-color: #e11d48; padding: 14px; font-weight: 700; border-radius: 8px;">
                        Simpan Alamat
                    </button>
                </form>
            </div>
        </div>
    </AppLayout>
</template>
