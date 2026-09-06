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
  IndianRupee,
  Sun,
  Moon,
  Phone,
  Loader2,
  Recycle,
  KeyRound,
  ArrowLeft
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

// ─── Recycler Login Page ─────────────────────────────────────
function RecyclerLoginPage({ theme, onLogin }: { theme: 'dark' | 'light'; onLogin: (token: string, user: any) => void }) {
  const [phone, setPhone] = useState('9876543210');
  const [otp, setOtp] = useState('123456');
  const [step, setStep] = useState<'phone' | 'otp'>('phone');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const isDark = theme === 'dark';

  const quickDemoLogin = async () => {
    setLoading(true);
    setError('');
    try {
      const res = await fetch('http://localhost:5000/api/auth/verify-otp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone: '9876543210', otp: '123456', role: 'recycler' })
      });
      if (res.ok) {
        const data = await res.json();
        localStorage.setItem('dhatu_recycler_token', data.token);
        localStorage.setItem('dhatu_recycler_user', JSON.stringify(data.user));
        onLogin(data.token, data.user);
        return;
      }
    } catch {
      // Offline fallback
    }

    // Graceful demo login
    const demoUser = {
      id: 'demo-rec-001',
      phone: '9876543210',
      name: 'EcoMetals Green Yard Pvt Ltd',
      role: 'recycler',
      recyclerId: 'rec-001',
      language: 'en'
    };
    const demoToken = 'demo_recycler_jwt_token_2026';
    localStorage.setItem('dhatu_recycler_token', demoToken);
    localStorage.setItem('dhatu_recycler_user', JSON.stringify(demoUser));
    onLogin(demoToken, demoUser);
  };

  const sendOtp = async () => {
    if (phone.length < 10) { setError('Enter a valid 10-digit phone number'); return; }
    setLoading(true); setError('');
    try {
      const res = await fetch('http://localhost:5000/api/auth/send-otp', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone })
      });
      if (res.ok) { setStep('otp'); }
      else { setStep('otp'); } // Allow demo continuation
    } catch {
      setStep('otp'); // Offline fallback allows demo step
    }
    setLoading(false);
  };

  const verifyOtp = async () => {
    if (otp.length < 4) { setError('Enter the OTP'); return; }
    setLoading(true); setError('');
    try {
      const res = await fetch('http://localhost:5000/api/auth/verify-otp', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phone, otp, role: 'recycler' })
      });
      if (res.ok) {
        const data = await res.json();
        localStorage.setItem('dhatu_recycler_token', data.token);
        localStorage.setItem('dhatu_recycler_user', JSON.stringify(data.user));
        onLogin(data.token, data.user);
        return;
      }
    } catch {
      // Offline fallback
    }

    if (otp === '123456' || otp === '000000') {
      const demoUser = {
        id: 'demo-rec-001',
        phone,
        name: 'EcoMetals Green Yard Pvt Ltd',
        role: 'recycler',
        recyclerId: 'rec-001',
        language: 'en'
      };
      const demoToken = 'demo_recycler_jwt_token_2026';
      localStorage.setItem('dhatu_recycler_token', demoToken);
      localStorage.setItem('dhatu_recycler_user', JSON.stringify(demoUser));
      onLogin(demoToken, demoUser);
    } else {
      setError('Invalid OTP. For demo use 123456.');
      setLoading(false);
    }
  };

  return (
    <div className={`min-h-screen flex items-center justify-center p-6 ${isDark ? 'bg-navy-950' : 'bg-slate-50'}`}>
      <div className={`w-full max-w-md rounded-3xl border p-8 ${isDark ? 'bg-navy-900 border-navy-700/40' : 'bg-white border-greenblack-900/10'}`}>
        {/* Logo */}
        <div className="flex flex-col items-center mb-6">
          <div className={`w-16 h-16 rounded-2xl flex items-center justify-center mb-3 ${isDark ? 'bg-navy-700' : 'bg-greenblack-900'}`}>
            <Recycle className={`w-9 h-9 ${isDark ? 'text-sky-400' : 'text-white'}`} />
          </div>
          <h1 className={`text-2xl font-black tracking-wide ${isDark ? 'text-slate-100' : 'text-greenblack-900'}`}>
            DHATU · धातु
          </h1>
          <p className={`text-sm font-semibold mt-0.5 ${isDark ? 'text-sky-400' : 'text-emerald-600'}`}>
            Recycler Portal Login
          </p>
          <p className={`text-xs mt-0.5 ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>
            Authorized E-Waste Facility Portal
          </p>
        </div>

        {/* 1-Click Instant Demo Login Banner */}
        <div className={`mb-6 p-4 rounded-2xl border ${isDark ? 'bg-navy-800/80 border-sky-500/30' : 'bg-emerald-50/70 border-emerald-500/20'}`}>
          <div className="flex items-center gap-2 mb-2">
            <span className="text-amber-400 text-base font-bold">⚡</span>
            <span className={`text-xs font-bold uppercase tracking-wider ${isDark ? 'text-sky-400' : 'text-emerald-800'}`}>
              One-Click Demo Access
            </span>
          </div>
          <button
            onClick={quickDemoLogin}
            disabled={loading}
            className={`w-full py-2.5 rounded-xl font-bold text-sm transition-all duration-200 shadow-sm flex items-center justify-center gap-2 ${
              isDark
                ? 'bg-sky-500 hover:bg-sky-400 text-slate-950 disabled:bg-sky-700'
                : 'bg-emerald-600 hover:bg-emerald-700 text-white disabled:bg-emerald-800'
            }`}
          >
            {loading ? <Loader2 className="w-4 h-4 animate-spin" /> : '⚡ Instant Demo Login (EcoMetals)'}
          </button>
        </div>

        <div className="relative flex py-2 items-center mb-5">
          <div className={`flex-grow border-t ${isDark ? 'border-navy-700' : 'border-slate-200'}`} />
          <span className={`flex-shrink mx-3 text-xs uppercase font-semibold ${isDark ? 'text-slate-500' : 'text-slate-400'}`}>
            Or Login with Phone
          </span>
          <div className={`flex-grow border-t ${isDark ? 'border-navy-700' : 'border-slate-200'}`} />
        </div>

        {/* Phone step */}
        {step === 'phone' && (
          <div className="space-y-4">
            <label className={`block text-sm font-bold ${isDark ? 'text-slate-300' : 'text-greenblack-900'}`}>
              Phone Number
            </label>
            <div className={`flex items-center rounded-xl border overflow-hidden ${isDark ? 'bg-navy-700/40 border-navy-600/50' : 'bg-slate-100 border-slate-200'}`}>
              <span className={`px-3 text-sm font-bold ${isDark ? 'text-slate-400' : 'text-greenblack-900'}`}>+91</span>
              <div className={`w-px h-7 ${isDark ? 'bg-navy-600' : 'bg-slate-300'}`} />
              <input
                type="tel" maxLength={10} value={phone}
                onChange={(e) => setPhone(e.target.value.replace(/\D/g, ''))}
                placeholder="9876543210"
                className={`flex-1 px-3 py-3 text-base font-bold tracking-widest bg-transparent outline-none font-mono ${isDark ? 'text-slate-100 placeholder:text-slate-600' : 'text-greenblack-900 placeholder:text-slate-400'}`}
              />
              <Phone className={`w-5 h-5 mr-3 ${isDark ? 'text-slate-500' : 'text-slate-400'}`} />
            </div>
          </div>
        )}

        {/* OTP step */}
        {step === 'otp' && (
          <div className="space-y-4">
            <button onClick={() => { setStep('phone'); setOtp('123456'); setError(''); }}
              className={`flex items-center gap-1 text-xs font-semibold mb-1 ${isDark ? 'text-sky-400 hover:text-sky-300' : 'text-emerald-600 hover:text-emerald-700'}`}>
              <ArrowLeft className="w-3.5 h-3.5" /> Change Number
            </button>
            <div className={`flex items-center gap-2 px-3 py-2 rounded-lg mb-1 ${isDark ? 'bg-navy-700/30' : 'bg-slate-100'}`}>
              <Phone className={`w-4 h-4 ${isDark ? 'text-sky-400' : 'text-emerald-600'}`} />
              <span className={`text-sm font-mono font-bold ${isDark ? 'text-slate-300' : 'text-greenblack-900'}`}>+91 {phone}</span>
            </div>
            <label className={`block text-sm font-bold ${isDark ? 'text-slate-300' : 'text-greenblack-900'}`}>
              Enter OTP
            </label>
            <input
              type="text" maxLength={6} value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
              placeholder="123456"
              className={`w-full text-center text-xl font-black tracking-[0.4em] py-3 rounded-xl border bg-transparent outline-none font-mono ${isDark ? 'text-slate-100 border-navy-600/50 placeholder:text-slate-700 focus:border-sky-500' : 'text-greenblack-900 border-slate-200 placeholder:text-slate-300 focus:border-emerald-500'}`}
            />
            <p className={`text-center text-xs font-mono font-semibold ${isDark ? 'text-sky-400/70' : 'text-emerald-600/70'}`}>
              Demo OTP: 123456
            </p>
          </div>
        )}

        {/* Error */}
        {error && (
          <div className="mt-4 flex items-center gap-2 px-3 py-2 rounded-xl bg-red-500/10 border border-red-500/30">
            <KeyRound className="w-4 h-4 text-red-400 flex-shrink-0" />
            <p className="text-xs text-red-400 font-semibold">{error}</p>
          </div>
        )}

        {/* Submit */}
        <button
          onClick={step === 'phone' ? sendOtp : verifyOtp}
          disabled={loading}
          className={`w-full mt-5 py-3 rounded-xl text-white font-bold text-sm transition-all duration-200 flex items-center justify-center gap-2 ${
            isDark ? 'bg-navy-600 hover:bg-navy-500 disabled:bg-navy-700' : 'bg-greenblack-900 hover:bg-greenblack-800 disabled:bg-greenblack-900/50'
          }`}
        >
          {loading ? <Loader2 className="w-4 h-4 animate-spin" /> :
            step === 'phone' ? <><Phone className="w-4 h-4" /> Send OTP</> :
            <><ShieldCheck className="w-4 h-4" /> Verify & Enter Dashboard</>
          }
        </button>

        <p className={`text-center text-[10px] mt-5 ${isDark ? 'text-slate-600' : 'text-slate-400'}`}>
          Dhatu E-Waste Regularization Platform · SIH 2026
        </p>
      </div>
    </div>
  );
}

// ─── Main Dashboard App ──────────────────────────────────────
export default function App() {
  const [theme, setTheme] = useState<'dark' | 'light'>(() => {
    const saved = localStorage.getItem('dhatu_theme');
    if (saved === 'light' || saved === 'dark') return saved;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  });

  // Auth state
  const [authToken, setAuthToken] = useState<string | null>(() => localStorage.getItem('dhatu_recycler_token'));
  const [, setAuthUser] = useState<any>(() => {
    try { return JSON.parse(localStorage.getItem('dhatu_recycler_user') || 'null'); } catch { return null; }
  });

  // Theme effect needs to be before auth gate
  useEffect(() => {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('dhatu_theme', theme);
  }, [theme]);

  const handleLogin = (token: string, user: any) => {
    setAuthToken(token);
    setAuthUser(user);
  };

  const handleLogout = () => {
    localStorage.removeItem('dhatu_recycler_token');
    localStorage.removeItem('dhatu_recycler_user');
    setAuthToken(null);
    setAuthUser(null);
  };

  // Auth gate: show login if not authenticated
  if (!authToken) {
    return <RecyclerLoginPage theme={theme} onLogin={handleLogin} />;
  }

  const [activeTab, setActiveTab] = useState<'incoming' | 'offers' | 'handovers' | 'profile' | 'history'>('incoming');
  const [lots, setLots] = useState<Transaction[]>([]);
  const [profile, setProfile] = useState<RecyclerProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedLot, setSelectedLot] = useState<Transaction | null>(null);
  const [quotePriceInput, setQuotePriceInput] = useState<string>('');
  const [quoteModalLot, setQuoteModalLot] = useState<Transaction | null>(null);
  const [statusMessage, setStatusMessage] = useState<{ text: string; type: 'success' | 'error' } | null>(null);

  const RECYCLER_ID = 'rec-001'; // EcoMetals Green Yard default demo

  const toggleTheme = () => {
    setTheme(prev => (prev === 'dark' ? 'light' : 'dark'));
  };

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
    <div className="min-h-screen bg-slate-50 dark:bg-navy-950 text-greenblack-900 dark:text-slate-100 flex flex-col font-sans transition-colors duration-200">
      {/* Top Header */}
      <header className="bg-white dark:bg-navy-900 border-b border-slate-200 dark:border-navy-800/80 sticky top-0 z-40 transition-colors shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-xl bg-greenblack-900 dark:bg-navy-700 flex items-center justify-center text-white shadow-md">
                <Building2 className="w-5 h-5 text-emerald-400 dark:text-blue-300" />
              </div>
              <div>
                <div className="flex items-center space-x-2">
                  <span className="font-extrabold text-xl tracking-tight text-greenblack-950 dark:text-white">DHATU</span>
                  <span className="text-xs bg-greenblack-100 text-greenblack-900 dark:bg-navy-800 dark:text-blue-300 font-bold px-2 py-0.5 rounded-full border border-greenblack-900/10 dark:border-blue-700/40">
                    AUTHORIZED RECYCLER
                  </span>
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  {profile ? profile.name : 'EcoMetals Green Yard Pvt Ltd'} · Licensed Facility
                </p>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              {/* Theme Toggle Button */}
              <button
                onClick={toggleTheme}
                aria-label="Toggle Theme"
                className="flex items-center space-x-2 px-3 py-1.5 rounded-xl text-xs font-semibold bg-slate-100 hover:bg-slate-200 dark:bg-navy-800 dark:hover:bg-navy-700 text-greenblack-900 dark:text-slate-200 border border-slate-200 dark:border-navy-700 transition-colors"
                title={`Switch to ${theme === 'dark' ? 'Light Mode (White & Greenish-Black)' : 'Dark Mode (Black & Navy Blue)'}`}
              >
                {theme === 'dark' ? (
                  <>
                    <Sun className="w-4 h-4 text-amber-400" />
                    <span className="hidden sm:inline">Light Mode</span>
                  </>
                ) : (
                  <>
                    <Moon className="w-4 h-4 text-navy-700" />
                    <span className="hidden sm:inline">Dark Mode</span>
                  </>
                )}
              </button>

              <button
                onClick={fetchAllData}
                className="p-2 text-slate-500 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-white rounded-lg hover:bg-slate-100 dark:hover:bg-navy-800 transition-colors"
                title="Refresh"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              </button>
            </div>
          </div>

          {/* Navigation Tabs */}
          <div className="flex space-x-2 border-t border-slate-200 dark:border-navy-800/80 -mb-px overflow-x-auto custom-scrollbar pt-1">
            <button
              onClick={() => setActiveTab('incoming')}
              className={`flex items-center space-x-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all whitespace-nowrap rounded-t-lg ${
                activeTab === 'incoming'
                  ? 'border-greenblack-900 dark:border-blue-500 text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-800/60'
                  : 'border-transparent text-slate-600 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-slate-200'
              }`}
            >
              <Inbox className="w-4 h-4" />
              <span>Incoming Lots</span>
              {incomingLots.length > 0 && (
                <span className="ml-1 px-1.5 py-0.5 text-[10px] bg-greenblack-900 dark:bg-blue-600 text-white font-bold rounded-full">
                  {incomingLots.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('offers')}
              className={`flex items-center space-x-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all whitespace-nowrap rounded-t-lg ${
                activeTab === 'offers'
                  ? 'border-greenblack-900 dark:border-blue-500 text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-800/60'
                  : 'border-transparent text-slate-600 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-slate-200'
              }`}
            >
              <Send className="w-4 h-4" />
              <span>My Offers</span>
              {myOffers.length > 0 && (
                <span className="ml-1 px-1.5 py-0.5 text-[10px] bg-amber-600 dark:bg-amber-500 text-white font-bold rounded-full">
                  {myOffers.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('handovers')}
              className={`flex items-center space-x-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all whitespace-nowrap rounded-t-lg ${
                activeTab === 'handovers'
                  ? 'border-greenblack-900 dark:border-blue-500 text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-800/60'
                  : 'border-transparent text-slate-600 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-slate-200'
              }`}
            >
              <Truck className="w-4 h-4" />
              <span>Handovers</span>
              {handovers.length > 0 && (
                <span className="ml-1 px-1.5 py-0.5 text-[10px] bg-emerald-600 dark:bg-blue-500 text-white font-bold rounded-full">
                  {handovers.length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('profile')}
              className={`flex items-center space-x-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all whitespace-nowrap rounded-t-lg ${
                activeTab === 'profile'
                  ? 'border-greenblack-900 dark:border-blue-500 text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-800/60'
                  : 'border-transparent text-slate-600 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-slate-200'
              }`}
            >
              <Building2 className="w-4 h-4" />
              <span>Profile & Rates</span>
            </button>

            <button
              onClick={() => setActiveTab('history')}
              className={`flex items-center space-x-2 px-4 py-2.5 text-xs font-bold border-b-2 transition-all whitespace-nowrap rounded-t-lg ${
                activeTab === 'history'
                  ? 'border-greenblack-900 dark:border-blue-500 text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-800/60'
                  : 'border-transparent text-slate-600 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-slate-200'
              }`}
            >
              <History className="w-4 h-4" />
              <span>History</span>
            </button>
          </div>
        </div>
      </header>

      {/* Status banner alert */}
      {statusMessage && (
        <div
          className={`px-4 py-2.5 text-xs font-medium flex items-center justify-between transition-all ${
            statusMessage.type === 'success'
              ? 'bg-emerald-50 dark:bg-navy-800 border-b border-emerald-200 dark:border-navy-700 text-emerald-900 dark:text-blue-200'
              : 'bg-red-50 dark:bg-red-950/50 border-b border-red-200 dark:border-red-900 text-red-900 dark:text-red-300'
          }`}
        >
          <div className="max-w-7xl mx-auto flex items-center space-x-2">
            <CheckCircle2 className="w-4 h-4 text-emerald-600 dark:text-blue-400" />
            <span>{statusMessage.text}</span>
          </div>
          <button onClick={() => setStatusMessage(null)} className="text-xs opacity-75 hover:opacity-100 font-bold">
            Dismiss
          </button>
        </div>
      )}

      {/* Main Content Area */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full space-y-6">
        {/* TAB 1: Incoming Lots */}
        {activeTab === 'incoming' && (
          <div className="space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
              <div>
                <h1 className="text-2xl font-bold text-greenblack-950 dark:text-white tracking-tight">Incoming Material Lots</h1>
                <p className="text-slate-500 dark:text-slate-400 text-xs">
                  Review digital lots created by informal collectors matching your accepted materials.
                </p>
              </div>
            </div>

            {incomingLots.length === 0 ? (
              <div className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl p-12 text-center shadow-sm">
                <Inbox className="w-12 h-12 text-slate-400 dark:text-slate-600 mx-auto mb-3" />
                <h3 className="text-base font-semibold text-greenblack-900 dark:text-slate-300">No Pending Incoming Lots</h3>
                <p className="text-slate-500 dark:text-slate-400 text-xs mt-1">
                  New collector pickups will appear here as soon as they are registered or matched.
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {incomingLots.map((lot) => (
                  <div
                    key={lot.id}
                    className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl p-5 hover:border-greenblack-900/40 dark:hover:border-blue-500/50 transition-all flex flex-col justify-between shadow-sm"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-3">
                        <span className="font-mono text-xs font-bold text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-950 px-2.5 py-1 rounded-md border border-slate-200 dark:border-navy-800">
                          {lot.id}
                        </span>
                        <span className="text-xs px-2.5 py-0.5 rounded-full bg-slate-100 dark:bg-navy-800 text-slate-700 dark:text-slate-300 capitalize font-medium">
                          {lot.transactionStatus.replace('_', ' ')}
                        </span>
                      </div>

                      <div className="flex items-start space-x-3 mb-4">
                        <div className="w-14 h-14 rounded-xl bg-slate-100 dark:bg-navy-950 border border-slate-200 dark:border-navy-800 flex items-center justify-center overflow-hidden flex-shrink-0">
                          <span className="text-xl font-extrabold text-greenblack-900 dark:text-blue-400">{lot.material.category[0]}</span>
                        </div>
                        <div>
                          <h3 className="font-bold text-greenblack-950 dark:text-white text-base">{lot.material.category}</h3>
                          <p className="text-xs text-slate-500 dark:text-slate-400 line-clamp-1">{lot.material.subCategory || 'Standard Grade'}</p>
                          <div className="flex items-center space-x-3 mt-1.5 text-xs text-slate-600 dark:text-slate-300">
                            <span className="flex items-center font-semibold text-greenblack-900 dark:text-blue-300">
                              <Scale className="w-3.5 h-3.5 mr-1" />
                              {lot.weightKg} kg
                            </span>
                            <span className="flex items-center text-slate-500 dark:text-slate-400">
                              <MapPin className="w-3.5 h-3.5 mr-1" />
                              {lot.collectionArea || 'Local Center'}
                            </span>
                          </div>
                        </div>
                      </div>

                      <div className="bg-slate-50 dark:bg-navy-950 rounded-xl p-3 border border-slate-200 dark:border-navy-800/80 mb-4 space-y-1 text-xs">
                        <div className="flex justify-between text-slate-500 dark:text-slate-400">
                          <span>Est. Valuation:</span>
                          <span className="font-semibold text-greenblack-950 dark:text-slate-200">
                            ₹{lot.material.estimatedValueMinInr} – ₹{lot.material.estimatedValueMaxInr}
                          </span>
                        </div>
                        <div className="flex justify-between text-slate-500 dark:text-slate-400">
                          <span>Collector:</span>
                          <span className="font-medium text-greenblack-900 dark:text-slate-200">{lot.collectorName || 'Ramesh'}</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center space-x-2 pt-3 border-t border-slate-200 dark:border-navy-800">
                      <button
                        onClick={() => setSelectedLot(lot)}
                        className="flex-1 py-2 px-3 text-xs font-semibold rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-navy-800 dark:hover:bg-navy-700 text-slate-800 dark:text-slate-200 transition-colors flex items-center justify-center space-x-1"
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
                        className="flex-1 py-2 px-3 text-xs font-bold rounded-xl bg-greenblack-900 hover:bg-greenblack-800 dark:bg-blue-600 dark:hover:bg-blue-500 text-white transition-colors flex items-center justify-center space-x-1 shadow-sm"
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
              <h1 className="text-2xl font-bold text-greenblack-950 dark:text-white tracking-tight">Active Offers & Commitments</h1>
              <p className="text-slate-500 dark:text-slate-400 text-xs">Track quotes submitted to collectors awaiting pickup or handover.</p>
            </div>

            <div className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl overflow-hidden shadow-sm">
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-100 dark:bg-navy-950 text-xs uppercase text-slate-600 dark:text-slate-400 border-b border-slate-200 dark:border-navy-800">
                    <tr>
                      <th className="px-6 py-4 font-semibold">Lot ID</th>
                      <th className="px-6 py-4 font-semibold">Material</th>
                      <th className="px-6 py-4 font-semibold">Weight</th>
                      <th className="px-6 py-4 font-semibold">Offered Amount</th>
                      <th className="px-6 py-4 font-semibold">Status</th>
                      <th className="px-6 py-4 font-semibold text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-200 dark:divide-navy-800 text-slate-700 dark:text-slate-300">
                    {myOffers.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="px-6 py-8 text-center text-slate-500 dark:text-slate-400">
                          No active offers currently pending.
                        </td>
                      </tr>
                    ) : (
                      myOffers.map((lot) => (
                        <tr key={lot.id} className="hover:bg-slate-50 dark:hover:bg-navy-850/50 transition-colors">
                          <td className="px-6 py-4 font-mono font-bold text-greenblack-950 dark:text-blue-400">{lot.id}</td>
                          <td className="px-6 py-4">
                            <div className="font-semibold text-greenblack-950 dark:text-white">{lot.material.category}</div>
                            <div className="text-xs text-slate-500 dark:text-slate-400">{lot.material.subCategory || 'Standard'}</div>
                          </td>
                          <td className="px-6 py-4 font-medium">{lot.weightKg} kg</td>
                          <td className="px-6 py-4 font-bold text-greenblack-900 dark:text-blue-300">
                            ₹{lot.finalPriceInr || lot.quotedPriceInr}
                          </td>
                          <td className="px-6 py-4">
                            <span
                              className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                                lot.transactionStatus === 'offer_accepted'
                                  ? 'bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800'
                                  : 'bg-amber-100 dark:bg-amber-950/60 text-amber-800 dark:text-amber-300 border border-amber-300 dark:border-amber-800'
                              }`}
                            >
                              {lot.transactionStatus === 'offer_accepted' ? 'Accepted by Collector' : 'Quote Sent'}
                            </span>
                          </td>
                          <td className="px-6 py-4 text-right">
                            <button
                              onClick={() => setSelectedLot(lot)}
                              className="text-xs text-emerald-700 dark:text-blue-400 hover:underline font-semibold"
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
          </div>
        )}

        {/* TAB 3: Handovers */}
        {activeTab === 'handovers' && (
          <div className="space-y-6">
            <div>
              <h1 className="text-2xl font-bold text-greenblack-950 dark:text-white tracking-tight">Physical Handover Verification</h1>
              <p className="text-slate-500 dark:text-slate-400 text-xs">
                Verify physical delivery, certify scale weight, and complete digital sign-off.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {handovers.length === 0 ? (
                <div className="col-span-2 bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl p-12 text-center shadow-sm">
                  <Truck className="w-12 h-12 text-slate-400 dark:text-slate-600 mx-auto mb-3" />
                  <h3 className="text-base font-semibold text-greenblack-900 dark:text-slate-300">No Pending Handovers</h3>
                  <p className="text-slate-500 dark:text-slate-400 text-xs mt-1">
                    Lots marked as physically handed over by collectors will appear here for verification.
                  </p>
                </div>
              ) : (
                handovers.map((lot) => (
                  <div
                    key={lot.id}
                    className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl p-6 flex flex-col justify-between shadow-sm"
                  >
                    <div>
                      <div className="flex items-center justify-between mb-4">
                        <span className="font-mono text-sm font-bold text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-950 px-3 py-1 rounded-lg border border-slate-200 dark:border-navy-800">
                          {lot.id}
                        </span>
                        <span
                          className={`text-xs px-3 py-1 rounded-full font-semibold ${
                            lot.transactionStatus === 'recycler_confirmed'
                              ? 'bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300'
                              : 'bg-blue-100 dark:bg-blue-950/60 text-blue-800 dark:text-blue-300'
                          }`}
                        >
                          {lot.transactionStatus === 'recycler_confirmed'
                            ? 'Verified & Certified'
                            : 'Awaiting Recycler Verification'}
                        </span>
                      </div>

                      <div className="grid grid-cols-2 gap-4 bg-slate-50 dark:bg-navy-950/70 p-4 rounded-xl border border-slate-200 dark:border-navy-800/80 mb-4 text-xs">
                        <div>
                          <span className="text-slate-500 dark:text-slate-400">Material:</span>
                          <p className="font-bold text-greenblack-950 dark:text-white text-sm mt-0.5">{lot.material.category}</p>
                        </div>
                        <div>
                          <span className="text-slate-500 dark:text-slate-400">Scale Weight:</span>
                          <p className="font-bold text-greenblack-900 dark:text-blue-300 text-sm mt-0.5">{lot.weightKg} kg</p>
                        </div>
                        <div>
                          <span className="text-slate-500 dark:text-slate-400">Handover Ref:</span>
                          <p className="font-mono text-slate-700 dark:text-slate-300 mt-0.5">
                            {lot.traceability?.handoverReferenceNumber || `REF-${lot.id}`}
                          </p>
                        </div>
                        <div>
                          <span className="text-slate-500 dark:text-slate-400">Settlement:</span>
                          <p className="font-bold text-emerald-700 dark:text-blue-300 text-sm mt-0.5">
                            ₹{lot.finalPriceInr || lot.quotedPriceInr}
                          </p>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-2 pt-2 border-t border-slate-200 dark:border-navy-800">
                      {lot.transactionStatus === 'handed_over' && (
                        <button
                          onClick={() => handleConfirmHandover(lot.id)}
                          className="w-full py-2.5 px-4 rounded-xl bg-greenblack-900 hover:bg-greenblack-800 dark:bg-blue-600 dark:hover:bg-blue-500 text-white font-bold text-xs flex items-center justify-center space-x-2 shadow-sm transition-colors"
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
                          className="w-full py-2.5 px-4 rounded-xl bg-greenblack-900 hover:bg-greenblack-800 dark:bg-blue-600 dark:hover:bg-blue-500 text-white font-bold text-xs flex items-center justify-center space-x-2 shadow-sm transition-colors"
                        >
                          <IndianRupee className="w-4 h-4" />
                          <span>Disburse Payment (₹{lot.finalPriceInr || lot.quotedPriceInr})</span>
                        </button>
                      )}

                      <button
                        onClick={() => setSelectedLot(lot)}
                        className="w-full py-2 px-3 text-xs text-slate-500 dark:text-slate-400 hover:text-greenblack-900 dark:hover:text-white font-medium"
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
              <h1 className="text-2xl font-bold text-greenblack-950 dark:text-white tracking-tight">Facility Profile & Rate Card</h1>
              <p className="text-slate-500 dark:text-slate-400 text-xs">
                Manage your government authorization details, accepted materials, and buying price sheet.
              </p>
            </div>

            <div className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl p-6 space-y-6 shadow-sm">
              <div className="flex items-center space-x-4 border-b border-slate-200 dark:border-navy-800 pb-6">
                <div className="w-16 h-16 rounded-2xl bg-slate-100 dark:bg-navy-950 border border-slate-200 dark:border-navy-800 flex items-center justify-center text-greenblack-900 dark:text-blue-300">
                  <Building2 className="w-8 h-8" />
                </div>
                <div>
                  <h2 className="text-xl font-bold text-greenblack-950 dark:text-white">{profile.name}</h2>
                  <p className="text-xs text-slate-500 dark:text-slate-400">{profile.address}</p>
                  <div className="flex items-center space-x-3 mt-2">
                    <span className="text-xs bg-emerald-100 dark:bg-emerald-950/60 text-emerald-800 dark:text-emerald-300 border border-emerald-300 dark:border-emerald-800 px-2.5 py-0.5 rounded-full flex items-center font-semibold">
                      <ShieldCheck className="w-3.5 h-3.5 mr-1" />
                      {profile.authorizationStatus.toUpperCase()}
                    </span>
                    <span className="text-xs text-slate-500 dark:text-slate-400">{profile.authorizationDetails}</span>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-sm font-bold text-greenblack-950 dark:text-white mb-3">Live Offered Rates (₹ per kg)</h3>
                <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                  {Object.entries(profile.offeredRatesInrPerKg || {}).map(([category, rate]) => (
                    <div
                      key={category}
                      className="bg-slate-50 dark:bg-navy-950 p-4 rounded-xl border border-slate-200 dark:border-navy-800 flex justify-between items-center"
                    >
                      <div>
                        <span className="text-xs text-slate-500 dark:text-slate-400 font-medium">{category}</span>
                        <div className="text-lg font-extrabold text-greenblack-950 dark:text-blue-300 mt-0.5">₹{rate} /kg</div>
                      </div>
                      <span className="w-2 h-2 rounded-full bg-emerald-500 dark:bg-blue-400"></span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="border-t border-slate-200 dark:border-navy-800 pt-6 grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
                <div className="bg-slate-50 dark:bg-navy-950 p-4 rounded-xl border border-slate-200 dark:border-navy-800">
                  <span className="text-slate-500 dark:text-slate-400">Pickup Logistics:</span>
                  <p className="font-bold text-greenblack-950 dark:text-white text-sm mt-1">
                    {profile.pickupAvailable ? 'Active (Pickup Vehicles Dispatched)' : 'Drop-off Only'}
                  </p>
                </div>
                <div className="bg-slate-50 dark:bg-navy-950 p-4 rounded-xl border border-slate-200 dark:border-navy-800">
                  <span className="text-slate-500 dark:text-slate-400">Service Area Radius:</span>
                  <p className="font-bold text-greenblack-950 dark:text-white text-sm mt-1">{profile.serviceAreaRadiusKm} km</p>
                </div>
              </div>

              {/* Logout */}
              <div className="border-t border-slate-200 dark:border-navy-800 pt-6 flex justify-end">
                <button
                  onClick={handleLogout}
                  className="px-4 py-2 rounded-xl text-sm font-bold text-red-500 border border-red-500/30 hover:bg-red-500/10 transition-colors"
                >
                  Logout
                </button>
              </div>
            </div>
          </div>
        )}

        {/* TAB 5: Transaction History */}
        {activeTab === 'history' && (
          <div className="space-y-6">
            <div>
              <h1 className="text-2xl font-bold text-greenblack-950 dark:text-white tracking-tight">Settled Transaction Ledger</h1>
              <p className="text-slate-500 dark:text-slate-400 text-xs">
                Audited digital transfer records with immutable timestamped traceability logs.
              </p>
            </div>

            <div className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-800 rounded-2xl overflow-hidden shadow-sm">
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-100 dark:bg-navy-950 text-xs uppercase text-slate-600 dark:text-slate-400 border-b border-slate-200 dark:border-navy-800">
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
                  <tbody className="divide-y divide-slate-200 dark:divide-navy-800 text-slate-700 dark:text-slate-300">
                    {completedHistory.length === 0 ? (
                      <tr>
                        <td colSpan={7} className="px-6 py-8 text-center text-slate-500 dark:text-slate-400">
                          No completed transactions recorded yet.
                        </td>
                      </tr>
                    ) : (
                      completedHistory.map((lot) => (
                        <tr key={lot.id} className="hover:bg-slate-50 dark:hover:bg-navy-850/50 transition-colors">
                          <td className="px-6 py-4 font-mono font-bold text-greenblack-950 dark:text-blue-400">{lot.id}</td>
                          <td className="px-6 py-4 font-semibold text-greenblack-950 dark:text-white">{lot.material.category}</td>
                          <td className="px-6 py-4 font-medium">{lot.weightKg} kg</td>
                          <td className="px-6 py-4 font-bold text-greenblack-900 dark:text-blue-300">₹{lot.finalPriceInr}</td>
                          <td className="px-6 py-4 capitalize">{lot.paymentMethod || 'digital'}</td>
                          <td className="px-6 py-4 font-mono text-xs text-slate-500 dark:text-slate-400">
                            {lot.traceability?.handoverReferenceNumber || `REF-${lot.id}`}
                          </td>
                          <td className="px-6 py-4 text-right">
                            <button
                              onClick={() => setSelectedLot(lot)}
                              className="text-xs text-emerald-700 dark:text-blue-400 hover:underline font-semibold"
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
          </div>
        )}
      </main>

      {/* Modal 1: Send Quote Dialog */}
      {quoteModalLot && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-700 rounded-3xl max-w-md w-full p-6 shadow-2xl space-y-5">
            <div className="flex justify-between items-center">
              <h3 className="text-lg font-bold text-greenblack-950 dark:text-white">Submit Rate Quote</h3>
              <span className="font-mono text-xs text-greenblack-900 dark:text-blue-400 font-bold">{quoteModalLot.id}</span>
            </div>

            <div className="bg-slate-50 dark:bg-navy-950 p-4 rounded-xl border border-slate-200 dark:border-navy-800 text-xs space-y-1">
              <div className="flex justify-between text-slate-500 dark:text-slate-400">
                <span>Material & Weight:</span>
                <span className="text-greenblack-950 dark:text-white font-bold">
                  {quoteModalLot.material.category} · {quoteModalLot.weightKg} kg
                </span>
              </div>
              <div className="flex justify-between text-slate-500 dark:text-slate-400">
                <span>Collector AI Estimate:</span>
                <span className="text-emerald-700 dark:text-amber-400 font-bold">
                  ₹{quoteModalLot.material.estimatedValueMinInr} – ₹{quoteModalLot.material.estimatedValueMaxInr}
                </span>
              </div>
            </div>

            <form onSubmit={handleSendQuote} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
                  Total Offered Price (₹ INR)
                </label>
                <input
                  type="number"
                  value={quotePriceInput}
                  onChange={(e) => setQuotePriceInput(e.target.value)}
                  className="w-full bg-slate-50 dark:bg-navy-950 border border-slate-300 dark:border-navy-700 rounded-xl px-4 py-3 text-lg font-bold text-greenblack-950 dark:text-white focus:outline-none focus:border-greenblack-900 dark:focus:border-blue-500 font-mono"
                  placeholder="e.g. 2100"
                  required
                />
              </div>

              <div className="flex space-x-3 pt-2">
                <button
                  type="button"
                  onClick={() => setQuoteModalLot(null)}
                  className="flex-1 py-3 text-xs font-semibold rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-navy-800 dark:hover:bg-navy-700 text-slate-700 dark:text-slate-300"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 py-3 text-xs font-bold rounded-xl bg-greenblack-900 hover:bg-greenblack-800 dark:bg-blue-600 dark:hover:bg-blue-500 text-white shadow-sm"
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
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white dark:bg-navy-900 border border-slate-200 dark:border-navy-700 rounded-3xl max-w-2xl w-full p-6 shadow-2xl space-y-6 max-h-[90vh] overflow-y-auto custom-scrollbar">
            <div className="flex justify-between items-center border-b border-slate-200 dark:border-navy-800 pb-4">
              <div>
                <span className="font-mono text-xs font-bold text-greenblack-950 dark:text-blue-400 bg-slate-100 dark:bg-navy-950 px-2.5 py-1 rounded-md border border-slate-200 dark:border-navy-800">
                  {selectedLot.id}
                </span>
                <h3 className="text-xl font-bold text-greenblack-950 dark:text-white mt-1">Material Lot & Traceability Record</h3>
              </div>
              <button
                onClick={() => setSelectedLot(null)}
                className="text-slate-500 dark:text-slate-400 hover:text-greenblack-950 dark:hover:text-white p-2 rounded-lg bg-slate-100 dark:bg-navy-800"
              >
                ✕
              </button>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs bg-slate-50 dark:bg-navy-950 p-4 rounded-2xl border border-slate-200 dark:border-navy-800">
              <div>
                <span className="text-slate-500 dark:text-slate-400">Category:</span>
                <p className="font-bold text-greenblack-950 dark:text-white mt-0.5">{selectedLot.material.category}</p>
              </div>
              <div>
                <span className="text-slate-500 dark:text-slate-400">Weight:</span>
                <p className="font-bold text-greenblack-900 dark:text-blue-300 mt-0.5">{selectedLot.weightKg} kg</p>
              </div>
              <div>
                <span className="text-slate-500 dark:text-slate-400">Final Price:</span>
                <p className="font-bold text-emerald-700 dark:text-blue-300 mt-0.5">
                  ₹{selectedLot.finalPriceInr || selectedLot.quotedPriceInr}
                </p>
              </div>
              <div>
                <span className="text-slate-500 dark:text-slate-400">Data Maturity:</span>
                <p className="font-mono text-slate-700 dark:text-slate-300 mt-0.5">{selectedLot.dataMaturity}</p>
              </div>
            </div>

            {/* Traceability Timeline */}
            <div>
              <h4 className="text-sm font-bold text-greenblack-950 dark:text-white mb-4 flex items-center space-x-2">
                <FileCheck className="w-4 h-4 text-greenblack-900 dark:text-blue-400" />
                <span>Verified Traceability Timeline</span>
              </h4>

              <div className="space-y-4 relative before:absolute before:inset-0 before:left-3.5 before:w-0.5 before:bg-slate-200 dark:before:bg-navy-800">
                {(selectedLot.traceability?.timeline || []).map((event, idx) => (
                  <div key={idx} className="relative flex items-start space-x-4 pl-2">
                    <div className="w-4 h-4 rounded-full bg-greenblack-900 dark:bg-blue-500 border-2 border-white dark:border-navy-900 z-10 flex-shrink-0 mt-1"></div>
                    <div className="bg-slate-50 dark:bg-navy-950 p-3.5 rounded-xl border border-slate-200 dark:border-navy-800/80 flex-1 text-xs">
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-greenblack-950 dark:text-blue-300">{event.stage}</span>
                        <span className="text-slate-500 dark:text-slate-400 font-mono text-[10px]">
                          {new Date(event.timestamp).toLocaleString('en-IN', {
                            dateStyle: 'short',
                            timeStyle: 'short'
                          })}
                        </span>
                      </div>
                      <p className="text-slate-600 dark:text-slate-400 mt-1">{event.note}</p>
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
