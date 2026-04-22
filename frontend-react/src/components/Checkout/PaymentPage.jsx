import React, { useState } from 'react';

const PaymentPage = ({ cartItems = [], shippingCost = 0, shippingMethod = "", onPaymentSubmit }) => {
  const [paymentMethod, setPaymentMethod] = useState('');

  // Calculate pricing
  const totalProducts = cartItems.reduce((acc, item) => acc + (item.price * item.qty), 0);
  const grandTotal = totalProducts + shippingCost;

  const formatRupiah = (number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(number);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if(!paymentMethod) {
      alert("Silahkan pilih metode pembayaran");
      return;
    }
    if (onPaymentSubmit) {
      onPaymentSubmit(paymentMethod);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 p-6 md:p-12 font-sans text-gray-800">
      
      {/* Navbar mockup */}
      <header className="flex justify-between items-center mb-8 border-b pb-4 border-gray-200">
        <div className="flex items-center space-x-3">
           <div className="font-extrabold text-2xl text-red-600 tracking-tight">SINAR ABADI</div>
           <span className="text-gray-300">|</span>
           <span className="font-semibold text-gray-600 text-sm flex items-center gap-2">
             <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-green-600" viewBox="0 0 20 20" fill="currentColor">
               <path fillRule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clipRule="evenodd" />
             </svg>
             PEMBAYARAN AMAN
           </span>
        </div>
        <div className="flex items-center space-x-6 text-sm font-medium">
           <span className="text-gray-400">PEMESANAN</span>
           <span className="text-gray-800 border-b-2 border-yellow-400 pb-1">PEMBAYARAN</span>
        </div>
      </header>

      <div className="max-w-6xl mx-auto flex flex-col lg:flex-row gap-8">
        
        {/* Left Column: Payment Methods */}
        <div className="flex-grow bg-white rounded-xl shadow-sm border border-gray-100 p-8">
          <h2 className="text-lg font-bold text-gray-800 mb-6 uppercase tracking-wider border-b pb-4">Metode Pembayaran</h2>
          <p className="text-sm text-gray-600 mb-6 font-medium">Silahkan pilih metode pembayaran yang anda inginkan:</p>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            
            <label className={`block border rounded-lg p-5 cursor-pointer transition ${paymentMethod === 'Virtual Account' ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500' : 'border-gray-200 hover:border-gray-300'}`}>
              <div className="flex items-center">
                <input 
                  type="radio" 
                  name="paymentMethod" 
                  value="Virtual Account"
                  checked={paymentMethod === 'Virtual Account'}
                  onChange={(e) => setPaymentMethod(e.target.value)}
                  className="h-5 w-5 text-blue-600 focus:ring-blue-500 mr-4"
                />
                <span className="font-bold text-gray-800">Virtual Account</span>
              </div>
            </label>

            <label className={`block border rounded-lg p-5 cursor-pointer transition ${paymentMethod === 'Credit Card' ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500' : 'border-gray-200 hover:border-gray-300'}`}>
              <div className="flex items-center">
                <input 
                  type="radio" 
                  name="paymentMethod" 
                  value="Credit Card"
                  checked={paymentMethod === 'Credit Card'}
                  onChange={(e) => setPaymentMethod(e.target.value)}
                  className="h-5 w-5 text-blue-600 focus:ring-blue-500 mr-4"
                />
                <span className="font-bold text-gray-800">Credit - Full Payment</span>
              </div>
            </label>

            <div className="mt-8 text-sm text-gray-600 border-t pt-6 bg-gray-50 rounded-lg p-5 border border-gray-100">
              <strong className="block text-gray-800 mb-2 font-bold">Depo Bangunan Kalimalang Store</strong>
              <p>Jl. Raya Tarum Barat No. 46 Kalimalang - Jakarta Timur Kota Jakarta Timur,</p>
              <p>DKI Jakarta 13440 Indonesia 021-8652888</p>
            </div>

            <div className="mt-8">
               <button 
                  type="submit" 
                  className="w-full md:w-auto bg-black text-white hover:bg-gray-800 font-bold py-3 px-10 rounded shadow-md transition transform hover:-translate-y-0.5"
               >
                 BAYAR SEKARANG
               </button>
            </div>
          </form>
        </div>

        {/* Right Column: Summaries */}
        <div className="w-full lg:w-96 space-y-6 flex-shrink-0">
          
          {/* Order Summary */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h3 className="font-bold text-gray-800 border-b pb-3 mb-4">Ringkasan Pembelian</h3>
            <div className="space-y-3 text-sm text-gray-600">
              <div className="flex justify-between">
                <span>Total Produk</span>
                <span className="font-medium text-gray-800">{formatRupiah(totalProducts)}</span>
              </div>
              <div className="flex justify-between">
                <span>Ongkos Kirim / Ambil</span>
                <span className="font-medium text-gray-800">{shippingCost === 0 ? 'Rp 0' : formatRupiah(shippingCost)}</span>
              </div>
            </div>
            <div className="flex justify-between mt-5 pt-4 border-t border-gray-200">
               <span className="font-bold text-gray-800 text-lg">Total</span>
               <span className="font-bold text-xl text-black">{formatRupiah(grandTotal)}</span>
            </div>
          </div>

          {/* Product Items Summary */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
             <h3 className="font-bold text-gray-800 border-b pb-3 mb-4">Ringkasan Produk</h3>
             <div className="space-y-4 max-h-64 overflow-y-auto pr-2">
                {cartItems.map((item, idx) => (
                   <div key={idx} className="flex gap-4">
                      {/* Image placeholder */}
                      <div className="w-16 h-16 bg-gray-100 rounded flex-shrink-0 flex items-center justify-center border">
                         <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                           <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                         </svg>
                      </div>
                      <div>
                         <p className="text-sm font-semibold text-gray-800 line-clamp-2">{item.name}</p>
                         <p className="text-xs text-gray-500 mt-1">{item.qty} x {formatRupiah(item.price)}</p>
                      </div>
                   </div>
                ))}
                {cartItems.length === 0 && (
                  <p className="text-sm text-gray-500 italic">Pilih produk dulu.</p>
                )}
             </div>
          </div>

          {/* Shipping Selected */}
          <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
             <div className="flex justify-between items-center border-b pb-3 mb-4">
                <h3 className="font-bold text-gray-800">Metode Pengiriman</h3>
                <button className="text-red-500 text-sm hover:underline">Ubah</button>
             </div>
             <p className="text-sm text-gray-600 leading-relaxed">
                {shippingMethod || "Ambil Di Toko 'Sinar Abadi Kalimalang Store'"}
             </p>
          </div>

        </div>
      </div>
    </div>
  );
};

export default PaymentPage;
