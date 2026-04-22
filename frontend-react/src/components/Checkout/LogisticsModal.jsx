import React, { useState } from 'react';

const LogisticsModal = ({ isOpen, onClose, onConfirm, cartItems }) => {
  const [whatsapp, setWhatsapp] = useState('');
  const [region, setRegion] = useState('');
  const [shippingMethod, setShippingMethod] = useState('');

  // Define logic constraints
  const hasHardwareOrPlumbing = cartItems?.some(item => 
    item.category === 'Hardware' || item.category === 'Plumbing'
  );

  const isMalang = region.toLowerCase().includes('malang');

  const handleConfirm = () => {
    if (!whatsapp || !region || !shippingMethod) {
      alert("Mohon lengkapi semua data logistik.");
      return;
    }
    onConfirm({ whatsapp, region, shippingMethod });
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 transition-opacity">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-lg p-6 relative overflow-hidden">
        {/* Header */}
        <div className="flex justify-between items-center border-b pb-4 mb-4">
          <h2 className="text-2xl font-bold text-gray-800">Detail Pengiriman & Logistik</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 focus:outline-none rounded-full p-1 hover:bg-gray-100 transition">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Form Body */}
        <div className="space-y-5">
          {/* WhatsApp */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1">Nomor WhatsApp (Aktif)</label>
            <input 
              type="text" 
              placeholder="Contoh: 08123456789" 
              className="w-full border border-gray-300 rounded-lg p-3 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
              value={whatsapp}
              onChange={(e) => setWhatsapp(e.target.value)}
            />
            <p className="text-xs text-gray-500 mt-1">Diperlukan untuk notifikasi resi dan konfirmasi.</p>
          </div>

          {/* Region */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-1">Lokasi Pengiriman Tujuan</label>
            <select 
              className="w-full border border-gray-300 rounded-lg p-3 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition bg-white"
              value={region}
              onChange={(e) => {
                setRegion(e.target.value);
                setShippingMethod(''); // Reset method on region change
              }}
            >
              <option value="" disabled>Pilih Wilayah...</option>
              <option value="Kota Malang">Kota Malang</option>
              <option value="Kabupaten Malang">Kabupaten Malang</option>
              <option value="Surabaya">Surabaya</option>
              <option value="Jakarta">Jakarta</option>
            </select>
          </div>

          {/* Methods */}
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Metode Pengiriman</label>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              
              {/* Ambil di Toko */}
              <label className="border rounded-lg p-4 cursor-pointer hover:border-blue-500 hover:bg-blue-50 transition border-gray-200">
                <div className="flex items-start">
                  <input type="radio" name="shippingMethod" value="Ambil di Toko" 
                    className="mt-1 mr-3 h-4 w-4 text-blue-600 focus:ring-blue-500"
                    onChange={(e) => setShippingMethod(e.target.value)}
                    checked={shippingMethod === "Ambil di Toko"}
                  />
                  <div>
                    <span className="block font-semibold text-gray-800">Ambil di Toko</span>
                    <span className="block text-xs text-gray-500 mt-1">Bebas biaya. Ambil langsung di toko Sinar Abadi.</span>
                  </div>
                </div>
              </label>

              {/* Kurir Toko */}
              <label className={`border rounded-lg p-4 transition ${!isMalang ? 'opacity-50 cursor-not-allowed bg-gray-50 border-gray-200' : 'cursor-pointer hover:border-blue-500 hover:bg-blue-50 border-gray-200'}`}>
                <div className="flex items-start">
                  <input type="radio" name="shippingMethod" value="Kurir Toko Sinar Abadi" 
                    disabled={!isMalang}
                    className="mt-1 mr-3 h-4 w-4 text-blue-600 focus:ring-blue-500"
                    onChange={(e) => setShippingMethod(e.target.value)}
                    checked={shippingMethod === "Kurir Toko Sinar Abadi"}
                  />
                  <div>
                    <span className="block font-semibold text-gray-800">Kurir Toko Sinar Abadi</span>
                    <span className="block text-xs text-gray-500 mt-1">Khusus area Malang. Bebas ukuran/berat barang.</span>
                  </div>
                </div>
              </label>

              {/* Ekspedisi JNE */}
              <label className={`border rounded-lg p-4 transition ${!hasHardwareOrPlumbing ? 'opacity-50 cursor-not-allowed bg-gray-50 border-gray-200' : 'cursor-pointer hover:border-blue-500 hover:bg-blue-50 border-gray-200'} col-span-1 md:col-span-2`}>
                <div className="flex items-start">
                  <input type="radio" name="shippingMethod" value="Ekspedisi JNE" 
                    disabled={!hasHardwareOrPlumbing}
                    className="mt-1 mr-3 h-4 w-4 text-blue-600 focus:ring-blue-500"
                    onChange={(e) => setShippingMethod(e.target.value)}
                    checked={shippingMethod === "Ekspedisi JNE"}
                  />
                  <div>
                    <span className="block font-semibold text-gray-800">Ekspedisi JNE</span>
                    <span className="block text-xs text-gray-500 mt-1">Luar kota. Berlaku hanya untuk barang (Hardware/Plumbing).</span>
                  </div>
                </div>
              </label>

            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-6 flex justify-end space-x-3 bg-gray-50 -mx-6 -mb-6 p-4 border-t">
          <button 
            type="button" 
            onClick={onClose}
            className="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none transition shadow-sm"
          >
            Batal
          </button>
          <button 
            type="button" 
            onClick={handleConfirm}
            className="px-5 py-2.5 text-sm font-medium text-white bg-red-500 rounded-lg hover:bg-red-600 focus:outline-none transition shadow-md"
          >
            Buat Pesanan
          </button>
        </div>
      </div>
    </div>
  );
};

export default LogisticsModal;
