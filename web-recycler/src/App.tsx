import React, { useState, useEffect } from 'react';
import {
  Inbox,
  Send,
  Truck,
  Building2,
  History,
  CheckCircle2,
  MapPin,
  Scale,
  ShieldCheck,
  FileCheck,
  RefreshCw,
  Eye,
  IndianRupee
} from 'lucide-react';

interface Material {
  id: string;
  category: string;
  subCategory?: string;
  description?: string;
  imageUrl: string;
  approxWeightKg: number;
  condition: string;
  estimatedValueMinInr: number;
  estimatedValueMaxInr: number;
  dataMaturity: string;
}

interface Transaction {
  id: string;
  collectorId: string;
  collectorName?: string;
  collectorPhone?: string;
  material: Material;
  weightKg: number;
  quotedPriceInr: number;
  finalPriceInr?: number;
  recyclerId?: string;
  recyclerName?: string;
  collectionArea?: string;
  handoverArea?: string;
  dateTime: string;
  paymentStatus: string;
  paymentMethod?: string;
  transactionStatus: string;
  dataMaturity: string;
  traceability?: {
    handoverReferenceNumber: string;
    recyclerConfirmation: boolean;
    timeline: Array<{ stage: string; timestamp: string; note?: string; actorRole?: string }>;
  };
}

interface RecyclerProfile {
  id: string;
  name: string;
  address: string;
  phone: string;
  email?: string;
  authorizationDetails: string;
  authorizationStatus: string;
  materialsAccepted: string[];
  offeredRatesInrPerKg: Record<string, number>;
  pickupAvailable: boolean;
  serviceAreaRadiusKm: number;
}

export default function App() {
  const [activeTab, setActiveTab] = useState<'incoming' | 'offers' | 'handovers' | 'profile' | 'history'>('incoming');
  const [lots, setLots] = useState<Transaction[]>([]);
  const [profile, setProfile] = useState<RecyclerProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedLot, setSelectedLot] = useState<Transaction | null>(null);
  const [quotePriceInput, setQuotePriceInput] = useState<string>('');
  const [quoteModalLot, setQuoteModalLot] = useState<Transaction | null>(null);
  const [statusMessage, setStatusMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  const RECYCLER_ID = 'rec-001'; // EcoMetals Green Yard default demo

  const fetchAllData = async () => {
    try {
      setLoading(true);
      const [lotsRes, profileRes] = await Promise.all([
        fetch('http://localhost:5000/api/lots'),
        fetch(`http://localhost:5000/api/recyclers/${RECYCLER_ID}`)
      ]);

      if (lotsRes.ok) {
        const lotsData = await lotsRes.json();
        setLots(lotsData);
      }
      if (profileRes.ok) {
        const profileData = await profileRes.json();
        setProfile(profileData);
      }
    } catch (err) {
      console.error('Error fetching recycler data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAllData();
  }, []);

  const handleSendQuote = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!quoteModalLot || !quotePriceInput) return;

    try {
      const res = await fetch(`http://localhost:5000/api/transactions/${quoteModalLot.id}/offer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          finalPriceInr: parseFloat(quotePriceInput),
          quotedPriceInr: parseFloat(quotePriceInput),
          recyclerId: RECYCLER_ID
        })
      });

      if (res.ok) {
        setStatusMessage({ text: `Offer sent for Lot ${quoteModalLot.id} at ₹${quotePriceInput}`, type: 'success' });
        setQuoteModalLot(null);
        setQuotePriceInput('');
        fetchAllData();
      }
    } catch (err) {
      setStatusMessage({ text: 'Failed to submit quote.', type: 'error' });
    }
  };

  const handleConfirmHandover = async (lotId: string) => {
    try {
      const res = await fetch(`http://localhost:5000/api/transactions/${lotId}/confirm`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
      });

      if (res.ok) {
        setStatusMessage({ text: `Handover verified and certified for Lot ${lotId}!`, type: 'success' });
        fetchAllData();
      }
    } catch (err) {
      setStatusMessage({ text: 'Failed to confirm handover.', type: 'error' });
    }
  };

  const handleCompletePayment = async (lotId: string, amount: number) => {
    try {
      const res = await fetch(`http://localhost:5000/api/transactions/${lotId}/pay`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          paymentMethod: 'digital',
          finalPriceInr: amount
        })
      });

      if (res.ok) {
        setStatusMessage({ text: `Payment of ₹${amount} marked completed for Lot ${lotId}!`, type: 'success' });
        fetchAllData();
      }
    } catch (err) {
      setStatusMessage({ text: 'Failed to complete payment.', type: 'error' });
    }
  };

  // Filtered lists
  const incomingLots = lots.filter((l) => ['draft', 'matched'].includes(l.transactionStatus));
  const myOffers = lots.filter((l) => ['offer_sent', 'offer_accepted'].includes(l.transactionStatus));
  const handovers = lots.filter((l) => ['handed_over', 'recycler_confirmed'].includes(l.transactionStatus));
  const completedHistory = lots.filter((l) => l.transactionStatus === 'paid');

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans">
      {/* Top Header */}
      <header className="bg-slate-900 border-b border-slate-800 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-teal-700 to-teal-500 flex items-center justify-center shadow-lg shadow-teal-900/30">
                <Building2 className="w-6 h-6 text-white" />
              </div>
              <div>
                <div className="flex items-center space-x-2">
                  <span className="font-extrabold text-xl tracking-tight text-white">DHATU</span>
                  <span className="text-xs bg-teal-500/20 text-teal-300 font-semibold px-2 py-0.5 rounded-full border border-teal-500/30">
                    AUTHORIZED RECYCLER
                  </span>
                </div>
                <p className="text-xs text-slate-400">
                  {profile ? profile.name : 'EcoMetals Green Yard Pvt Ltd'} · Mumbai MPCB Licensed
                </p>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <span className="inline-flex items-center text-xs px-2.5 py-1 rounded-md bg-amber-500/10 text-amber-300 border border-amber-500/20 font-mono">
                dataMaturity: demo
              </span>
              <button
                onClick={fetchAllData}
                className="p-2 text-slate-400 hover:text-white rounded-lg hover:bg-slate-800 transition-colors"
                title="Refresh"
              >
                <RefreshCw className={`w-5 h-5 ${loading ? 'animate-spin' : ''}`} />
              </button>
            </div>
          </div>

          {/* Navigation Tabs */}
          <div className="flex space-x-1 border-t border-slate-800/80 -mb-px overflow-x-auto custom-scrollbar">
            <button
              onClick={() => setActiveTab('incoming')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'incoming'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Inbox className="w-4 h-4" />
              <span>Incoming Lots</span>
              {incomingLots.length > 0 && (
                <span className="ml-1.5 px-2 py-0.5 text-xs bg-teal-500 text-slate-950 font-bold rounded-full">
                  {incomingLots.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('offers')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'offers'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Send className="w-4 h-4" />
              <span>My Offers</span>
              {myOffers.length > 0 && (
                <span className="ml-1.5 px-2 py-0.5 text-xs bg-amber-500 text-slate-950 font-bold rounded-full">
                  {myOffers.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('handovers')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'handovers'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Truck className="w-4 h-4" />
              <span>Handovers</span>
              {handovers.length > 0 && (
                <span className="ml-1.5 px-2 py-0.5 text-xs bg-blue-500 text-white font-bold rounded-full">
                  {handovers.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('profile')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'profile'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Building2 className="w-4 h-4" />
              <span>Profile & Rates</span>
            </button>

            <button
              onClick={() => setActiveTab('history')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'history'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <History className="w-4 h-4" />
              <span>Transaction History</span>
            </button>
          </div>
        </div>
      </header>

      {/* Status banner alert */}
      {statusMessage && (
        <div
          className={`px-4 py-2.5 text-sm flex items-center justify-between transition-all ${
            statusMessage.type === 'success'
              ? 'bg-teal-900/60 border-b border-teal-700 text-teal-200'
              : 'bg-red-900/60 border-b border-red-700 text-red-200'
          }`}
        >
          <div className="max-w-7xl mx-auto flex items-center space-x-2">
            <CheckCircle2 className="w-4 h-4 text-teal-400" />
            <span>{statusMessage.text}</span>
          </div>
          <button onClick={() => setStatusMessage(null)} className="text-xs opacity-75 hover:opacity-100">
            Dismiss
          </button>
        </div>
      )}

      {/* Main Content Area */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full">
        {/* TAB 1: Incoming Lots */}
        {activeTab === 'incoming' && (
          <div className="space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <h1 className="text-2xl font-bold text-white tracking-tight">Incoming Material Lots</h1>
                <p className="text-slate-400 text-sm">
                  Review digital lots created by informal collectors matching your accepted materials.
                </p>
              </div>
            </div>

            {incomingLots.length === 0 ? (
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-12 text-center">
                <Inbox className="w-12 h-12 text-slate-600 mx-auto mb-3" />
                <h3 className="text-lg font-semibold text-slate-300">No Pending Incoming Lots</h3>
                <p className="text-slate-500 text-sm mt-1">
                  New collector pickups will appear here as soon as they are registered or matched.
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {incomingLots.map((lot) => (
                  <div
                    key={lot.id}
                    className="bg-slate-900 border border-slate-800 rounded-2xl p-5 hover:border-teal-500/50 transition-all flex flex-col justify-between shadow-lg shadow-black/20"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-3">
                        <span className="font-mono text-xs font-bold text-teal-400 bg-teal-950/60 px-2.5 py-1 rounded-md border border-teal-800/60">
                          {lot.id}
                        </span>
                        <span className="text-xs px-2.5 py-0.5 rounded-full bg-slate-800 text-slate-300 capitalize">
                          {lot.transactionStatus.replace('_', ' ')}
                        </span>
                      </div>

                      <div className="flex items-start space-x-3 mb-4">
                        <div className="w-16 h-16 rounded-xl bg-slate-800 border border-slate-700 flex items-center justify-center overflow-hidden flex-shrink-0">
                          <span className="text-2xl font-bold text-teal-300">{lot.material.category[0]}</span>
                        </div>
                        <div>
                          <h3 className="font-bold text-white text-base">{lot.material.category}</h3>
                          <p className="text-xs text-slate-400 line-clamp-1">{lot.material.subCategory || 'Standard Grade'}</p>
                          <div className="flex items-center space-x-3 mt-1.5 text-xs text-slate-300">
                            <span className="flex items-center font-semibold text-amber-400">
                              <Scale className="w-3.5 h-3.5 mr-1" />
                              {lot.weightKg} kg
                            </span>
                            <span className="flex items-center text-slate-400">
                              <MapPin className="w-3.5 h-3.5 mr-1" />
                              {lot.collectionArea || 'Mumbai'}
                            </span>
                          </div>
                        </div>
                      </div>

                      <div className="bg-slate-950/60 rounded-xl p-3 border border-slate-800/80 mb-4 space-y-1 text-xs">
                        <div className="flex justify-between text-slate-400">
                          <span>Est. Valuation Range:</span>
                          <span className="font-medium text-slate-200">
                            ₹{lot.material.estimatedValueMinInr} – ₹{lot.material.estimatedValueMaxInr}
                          </span>
                        </div>
                        <div className="flex justify-between text-slate-400">
                          <span>Collector:</span>
                          <span className="font-medium text-slate-200">{lot.collectorName || 'Ramesh'}</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center space-x-2 pt-2 border-t border-slate-800">
                      <button
                        onClick={() => setSelectedLot(lot)}
                        className="flex-1 py-2 px-3 text-xs font-semibold rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 transition-colors flex items-center justify-center space-x-1"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span>Inspect</span>
                      </button>
                      <button
                        onClick={() => {
                          setQuoteModalLot(lot);
                          setQuotePriceInput(
                            Math.round(
                              (lot.material.estimatedValueMinInr + lot.material.estimatedValueMaxInr) / 2
                            ).toString()
                          );
                        }}
                        className="flex-1 py-2 px-3 text-xs font-semibold rounded-xl bg-teal-600 hover:bg-teal-500 text-white transition-colors flex items-center justify-center space-x-1 shadow-md shadow-teal-950/50"
                      >
                        <Send className="w-3.5 h-3.5" />
                        <span>Send Quote</span>
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* TAB 2: My Offers */}
        {activeTab === 'offers' && (
          <div className="space-y-6">
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">Active Offers & Commitments</h1>
              <p className="text-slate-400 text-sm">Track quotes submitted to collectors awaiting pickup or handover.</p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
              <table className="w-full text-left text-sm text-slate-300">
                <thead className="bg-slate-950 text-xs uppercase text-slate-400 border-b border-slate-800">
                  <tr>
                    <th className="px-6 py-4 font-semibold">Lot ID</th>
                    <th className="px-6 py-4 font-semibold">Material</th>
                    <th className="px-6 py-4 font-semibold">Weight</th>
                    <th className="px-6 py-4 font-semibold">Offered Amount</th>
                    <th className="px-6 py-4 font-semibold">Status</th>
                    <th className="px-6 py-4 font-semibold text-right">Actions</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800">
                  {myOffers.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="px-6 py-8 text-center text-slate-500">
                        No active offers currently pending.
                      </td>
                    </tr>
                  ) : (
                    myOffers.map((lot) => (
                      <tr key={lot.id} className="hover:bg-slate-800/40">
                        <td className="px-6 py-4 font-mono font-bold text-teal-400">{lot.id}</td>
                        <td className="px-6 py-4">
                          <div className="font-semibold text-white">{lot.material.category}</div>
                          <div className="text-xs text-slate-400">{lot.material.subCategory || 'Standard'}</div>
                        </td>
                        <td className="px-6 py-4 font-medium">{lot.weightKg} kg</td>
                        <td className="px-6 py-4 font-bold text-amber-400">
                          ₹{lot.finalPriceInr || lot.quotedPriceInr}
                        </td>
                        <td className="px-6 py-4">
                          <span
                            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                              lot.transactionStatus === 'offer_accepted'
                                ? 'bg-teal-500/20 text-teal-300 border border-teal-500/30'
                                : 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                            }`}
                          >
                            {lot.transactionStatus === 'offer_accepted' ? 'Accepted by Collector' : 'Quote Sent'}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-right">
                          <button
                            onClick={() => setSelectedLot(lot)}
                            className="text-xs text-teal-400 hover:text-teal-300 font-semibold"
                          >
                            View Timeline
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* TAB 3: Handovers */}
        {activeTab === 'handovers' && (
          <div className="space-y-6">
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">Physical Handover Verification</h1>
              <p className="text-slate-400 text-sm">
                Verify physical delivery, certify scale weight, and complete digital sign-off.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {handovers.length === 0 ? (
                <div className="col-span-2 bg-slate-900 border border-slate-800 rounded-2xl p-12 text-center">
                  <Truck className="w-12 h-12 text-slate-600 mx-auto mb-3" />
                  <h3 className="text-lg font-semibold text-slate-300">No Pending Handovers</h3>
                  <p className="text-slate-500 text-sm mt-1">
                    Lots marked as physically handed over by collectors will appear here for verification.
                  </p>
                </div>
              ) : (
                handovers.map((lot) => (
                  <div
                    key={lot.id}
                    className="bg-slate-900 border border-slate-800 rounded-2xl p-6 flex flex-col justify-between"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-4">
                        <span className="font-mono text-sm font-bold text-teal-400 bg-teal-950 px-3 py-1 rounded-lg border border-teal-800">
                          {lot.id}
                        </span>
                        <span
                          className={`text-xs px-3 py-1 rounded-full font-semibold ${
                            lot.transactionStatus === 'recycler_confirmed'
                              ? 'bg-teal-500/20 text-teal-300'
                              : 'bg-blue-500/20 text-blue-300'
                          }`}
                        >
                          {lot.transactionStatus === 'recycler_confirmed'
                            ? 'Verified & Certified'
                            : 'Awaiting Recycler Verification'}
                        </span>
                      </div>

                      <div className="grid grid-cols-2 gap-4 bg-slate-950/70 p-4 rounded-xl border border-slate-800/80 mb-4 text-xs">
                        <div>
                          <span className="text-slate-400">Material Category:</span>
                          <p className="font-bold text-white text-sm mt-0.5">{lot.material.category}</p>
                        </div>
                        <div>
                          <span className="text-slate-400">Logged Scale Weight:</span>
                          <p className="font-bold text-amber-400 text-sm mt-0.5">{lot.weightKg} kg</p>
                        </div>
                        <div>
                          <span className="text-slate-400">Handover Ref ID:</span>
                          <p className="font-mono text-slate-200 mt-0.5">
                            {lot.traceability?.handoverReferenceNumber || `REF-${lot.id}`}
                          </p>
                        </div>
                        <div>
                          <span className="text-slate-400">Agreed Settlement:</span>
                          <p className="font-bold text-teal-300 text-sm mt-0.5">
                            ₹{lot.finalPriceInr || lot.quotedPriceInr}
                          </p>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-2 pt-2">
                      {lot.transactionStatus === 'handed_over' && (
                        <button
                          onClick={() => handleConfirmHandover(lot.id)}
                          className="w-full py-2.5 px-4 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs flex items-center justify-center space-x-2 shadow-lg shadow-teal-950/50"
                        >
                          <ShieldCheck className="w-4 h-4" />
                          <span>Certify Weight & Confirm Handover</span>
                        </button>
                      )}

                      {lot.transactionStatus === 'recycler_confirmed' && (
                        <button
                          onClick={() =>
                            handleCompletePayment(lot.id, lot.finalPriceInr || lot.quotedPriceInr)
                          }
                          className="w-full py-2.5 px-4 rounded-xl bg-amber-600 hover:bg-amber-500 text-slate-950 font-bold text-xs flex items-center justify-center space-x-2 shadow-lg shadow-amber-950/50"
                        >
                          <IndianRupee className="w-4 h-4" />
                          <span>Disburse Payment (₹{lot.finalPriceInr || lot.quotedPriceInr})</span>
                        </button>
                      )}

                      <button
                        onClick={() => setSelectedLot(lot)}
                        className="w-full py-2 px-3 text-xs text-slate-400 hover:text-white"
                      >
                        Inspect Traceability Timeline
                      </button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        )}

        {/* TAB 4: Profile & Rates */}
        {activeTab === 'profile' && profile && (
          <div className="space-y-6 max-w-4xl">
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">Facility Profile & Rate Card</h1>
              <p className="text-slate-400 text-sm">
                Manage your government authorization details, accepted materials, and buying price sheet.
              </p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-6">
              <div className="flex items-center space-x-4 border-b border-slate-800 pb-6">
                <div className="w-16 h-16 rounded-2xl bg-teal-900/60 border border-teal-700/60 flex items-center justify-center text-teal-300">
                  <Building2 className="w-8 h-8" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-white">{profile.name}</h2>
                  <p className="text-xs text-slate-400">{profile.address}</p>
                  <div className="flex items-center space-x-3 mt-2">
                    <span className="text-xs bg-teal-500/20 text-teal-300 border border-teal-500/30 px-2.5 py-0.5 rounded-full flex items-center font-semibold">
                      <ShieldCheck className="w-3.5 h-3.5 mr-1" />
                      {profile.authorizationStatus.toUpperCase()}
                    </span>
                    <span className="text-xs text-slate-400">{profile.authorizationDetails}</span>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-base font-bold text-white mb-3">Live Offered Rates (₹ per kg)</h3>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                  {Object.entries(profile.offeredRatesInrPerKg || {}).map(([category, rate]) => (
                    <div
                      key={category}
                      className="bg-slate-950 p-4 rounded-xl border border-slate-800 flex justify-between items-center"
                    >
                      <div>
                        <span className="text-xs text-slate-400 font-medium">{category}</span>
                        <div className="text-lg font-extrabold text-amber-400 mt-0.5">₹{rate} /kg</div>
                      </div>
                      <span className="w-2 h-2 rounded-full bg-teal-400"></span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="border-t border-slate-800 pt-6 grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                <div className="bg-slate-950 p-4 rounded-xl border border-slate-800">
                  <span className="text-slate-400">Pickup Logistics:</span>
                  <p className="font-bold text-white text-sm mt-1">
                    {profile.pickupAvailable ? 'Active (Pickup Vehicles Dispatched)' : 'Drop-off Only'}
                  </p>
                </div>
                <div className="bg-slate-950 p-4 rounded-xl border border-slate-800">
                  <span className="text-slate-400">Service Area Radius:</span>
                  <p className="font-bold text-white text-sm mt-1">{profile.serviceAreaRadiusKm} km</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* TAB 5: Transaction History */}
        {activeTab === 'history' && (
          <div className="space-y-6">
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">Settled Transaction Ledger</h1>
              <p className="text-slate-400 text-sm">
                Audited digital transfer records with immutable timestamped traceability logs.
              </p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
              <table className="w-full text-left text-sm text-slate-300">
                <thead className="bg-slate-950 text-xs uppercase text-slate-400 border-b border-slate-800">
                  <tr>
                    <th className="px-6 py-4 font-semibold">Lot ID</th>
                    <th className="px-6 py-4 font-semibold">Category</th>
                    <th className="px-6 py-4 font-semibold">Weight</th>
                    <th className="px-6 py-4 font-semibold">Paid Amount</th>
                    <th className="px-6 py-4 font-semibold">Method</th>
                    <th className="px-6 py-4 font-semibold">Handover Ref</th>
                    <th className="px-6 py-4 font-semibold text-right">Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800">
                  {completedHistory.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="px-6 py-8 text-center text-slate-500">
                        No completed transactions recorded yet.
                      </td>
                    </tr>
                  ) : (
                    completedHistory.map((lot) => (
                      <tr key={lot.id} className="hover:bg-slate-800/40">
                        <td className="px-6 py-4 font-mono font-bold text-teal-400">{lot.id}</td>
                        <td className="px-6 py-4 font-semibold text-white">{lot.material.category}</td>
                        <td className="px-6 py-4 font-medium">{lot.weightKg} kg</td>
                        <td className="px-6 py-4 font-bold text-teal-400">₹{lot.finalPriceInr}</td>
                        <td className="px-6 py-4 capitalize">{lot.paymentMethod || 'digital'}</td>
                        <td className="px-6 py-4 font-mono text-xs text-slate-400">
                          {lot.traceability?.handoverReferenceNumber || `REF-${lot.id}`}
                        </td>
                        <td className="px-6 py-4 text-right">
                          <button
                            onClick={() => setSelectedLot(lot)}
                            className="text-xs text-teal-400 hover:text-teal-300 font-semibold"
                          >
                            Traceability Receipt
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </main>

      {/* Modal 1: Send Quote Dialog */}
      {quoteModalLot && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-700 rounded-3xl max-w-md w-full p-6 shadow-2xl space-y-5">
            <div className="flex justify-between items-center">
              <h3 className="text-lg font-bold text-white">Submit Rate Quote</h3>
              <span className="font-mono text-xs text-teal-400">{quoteModalLot.id}</span>
            </div>

            <div className="bg-slate-950 p-4 rounded-xl border border-slate-800 text-xs space-y-1">
              <div className="flex justify-between text-slate-400">
                <span>Material & Weight:</span>
                <span className="text-white font-bold">
                  {quoteModalLot.material.category} · {quoteModalLot.weightKg} kg
                </span>
              </div>
              <div className="flex justify-between text-slate-400">
                <span>Collector AI Estimate:</span>
                <span className="text-amber-400 font-bold">
                  ₹{quoteModalLot.material.estimatedValueMinInr} – ₹{quoteModalLot.material.estimatedValueMaxInr}
                </span>
              </div>
            </div>

            <form onSubmit={handleSendQuote} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1.5">
                  Total Offered Price (₹ INR)
                </label>
                <input
                  type="number"
                  value={quotePriceInput}
                  onChange={(e) => setQuotePriceInput(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-700 rounded-xl px-4 py-3 text-lg font-bold text-white focus:outline-none focus:border-teal-500 font-mono"
                  placeholder="e.g. 2100"
                  required
                />
              </div>

              <div className="flex space-x-3 pt-2">
                <button
                  type="button"
                  onClick={() => setQuoteModalLot(null)}
                  className="flex-1 py-3 text-xs font-semibold rounded-xl bg-slate-800 text-slate-300 hover:bg-slate-700"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-3 text-xs font-bold rounded-xl bg-teal-600 hover:bg-teal-500 text-white shadow-lg shadow-teal-950/50"
                >
                  Send to Collector
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal 2: Inspect Lot Traceability Timeline */}
      {selectedLot && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-700 rounded-3xl max-w-2xl w-full p-6 shadow-2xl space-y-6 max-h-[90vh] overflow-y-auto custom-scrollbar">
            <div className="flex justify-between items-center border-b border-slate-800 pb-4">
              <div>
                <span className="font-mono text-xs font-bold text-teal-400 bg-teal-950 px-2.5 py-1 rounded-md border border-teal-800">
                  {selectedLot.id}
                </span>
                <h3 className="text-xl font-bold text-white mt-1">Material Lot & Traceability Record</h3>
              </div>
              <button
                onClick={() => setSelectedLot(null)}
                className="text-slate-400 hover:text-white p-2 rounded-lg bg-slate-800"
              >
                ✕
              </button>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs bg-slate-950 p-4 rounded-2xl border border-slate-800">
              <div>
                <span className="text-slate-500">Category:</span>
                <p className="font-bold text-white mt-0.5">{selectedLot.material.category}</p>
              </div>
              <div>
                <span className="text-slate-500">Weight:</span>
                <p className="font-bold text-amber-400 mt-0.5">{selectedLot.weightKg} kg</p>
              </div>
              <div>
                <span className="text-slate-500">Final Price:</span>
                <p className="font-bold text-teal-300 mt-0.5">
                  ₹{selectedLot.finalPriceInr || selectedLot.quotedPriceInr}
                </p>
              </div>
              <div>
                <span className="text-slate-500">Data Maturity:</span>
                <p className="font-mono text-amber-300 mt-0.5">{selectedLot.dataMaturity}</p>
              </div>
            </div>

            {/* Traceability Timeline */}
            <div>
              <h4 className="text-sm font-bold text-white mb-4 flex items-center space-x-2">
                <FileCheck className="w-4 h-4 text-teal-400" />
                <span>Verified Traceability Timeline</span>
              </h4>

              <div className="space-y-4 relative before:absolute before:inset-0 before:left-3.5 before:w-0.5 before:bg-slate-800">
                {(selectedLot.traceability?.timeline || []).map((event, idx) => (
                  <div key={idx} className="relative flex items-start space-x-4 pl-2">
                    <div className="w-4 h-4 rounded-full bg-teal-500 border-2 border-slate-900 z-10 flex-shrink-0 mt-1"></div>
                    <div className="bg-slate-950 p-3.5 rounded-xl border border-slate-800/80 flex-1 text-xs">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-teal-300">{event.stage}</span>
                        <span className="text-slate-500 font-mono text-[10px]">
                          {new Date(event.timestamp).toLocaleString('en-IN', {
                            dateStyle: 'short',
                            timeStyle: 'short'
                          })}
                        </span>
                      </div>
                      <p className="text-slate-400 mt-1">{event.note}</p>
                      {event.actorRole && (
                        <span className="inline-block mt-1 text-[10px] text-slate-500 uppercase font-semibold">
                          Actor: {event.actorRole}
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
