import { useState, useEffect } from 'react';
import {
  ShieldAlert,
  Building2,
  TrendingUp,
  Boxes,
  Activity,
  CheckCircle2,
  AlertTriangle,
  RefreshCw,
  MapPin,
  Check,
  X
} from 'lucide-react';

interface AnomalyFlag {
  id: string;
  transactionId: string;
  materialCategory: string;
  locationArea: string;
  finalPriceInr: number;
  expectedMeanPriceInr: number;
  standardDeviationInr: number;
  zScore: number;
  severity: string;
  status: string;
  details: string;
  detectedAt: string;
  dataMaturity: string;
  transaction?: {
    collectorName?: string;
    recyclerName?: string;
    weightKg: number;
  };
}

interface Recycler {
  id: string;
  name: string;
  address: string;
  phone: string;
  authorizationDetails: string;
  authorizationStatus: string;
  materialsAccepted: string[];
  offeredRatesInrPerKg: Record<string, number>;
  pickupAvailable: boolean;
  serviceAreaRadiusKm: number;
  dataMaturity: string;
}

interface PriceBoardItem {
  category: string;
  currentRateInrPerKg: number;
  minRateInrPerKg: number;
  maxRateInrPerKg: number;
  trendPercent: string;
  sampleSize: number;
  lastUpdated: string;
  dataMaturity: string;
}

interface PlatformMetrics {
  totalRecyclers: number;
  authorizedRecyclers: number;
  totalTransactions: number;
  completedTransactions: number;
  totalEwasteWeightKg: number;
  totalEwasteTons: number;
  totalPayoutsInr: number;
  pendingAnomaliesCount: number;
  dataMaturity: string;
}

export default function App() {
  const [activeTab, setActiveTab] = useState<'anomalies' | 'recyclers' | 'pricing' | 'transactions' | 'activity'>('anomalies');
  const [anomalies, setAnomalies] = useState<AnomalyFlag[]>([]);
  const [recyclers, setRecyclers] = useState<Recycler[]>([]);
  const [priceBoard, setPriceBoard] = useState<PriceBoardItem[]>([]);
  const [transactions, setTransactions] = useState<any[]>([]);
  const [metrics, setMetrics] = useState<PlatformMetrics | null>(null);
  const [loading, setLoading] = useState(true);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);

  const fetchAdminData = async () => {
    try {
      setLoading(true);
      const [anomRes, recRes, priceRes, txRes, metRes] = await Promise.all([
        fetch('http://localhost:5000/api/admin/anomalies'),
        fetch('http://localhost:5000/api/recyclers'),
        fetch('http://localhost:5000/api/prices/board'),
        fetch('http://localhost:5000/api/lots'),
        fetch('http://localhost:5000/api/admin/metrics')
      ]);

      if (anomRes.ok) setAnomalies(await anomRes.json());
      if (recRes.ok) setRecyclers(await recRes.json());
      if (priceRes.ok) {
        const pData = await priceRes.json();
        setPriceBoard(pData.board || []);
      }
      if (txRes.ok) setTransactions(await txRes.json());
      if (metRes.ok) setMetrics(await metRes.json());
    } catch (err) {
      console.error('Failed to load admin data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAdminData();
  }, []);

  const handleAuthorizeRecycler = async (id: string, status: 'authorized' | 'unverified') => {
    try {
      const res = await fetch(`http://localhost:5000/api/admin/recyclers/${id}/authorize`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status })
      });
      if (res.ok) {
        setStatusMessage(`Recycler status updated to ${status}.`);
        fetchAdminData();
      }
    } catch (err) {
      console.error(err);
    }
  };

  const handleResolveAnomaly = async (id: string, resolution: 'resolved' | 'dismissed') => {
    try {
      const res = await fetch(`http://localhost:5000/api/admin/anomalies/${id}/resolve`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          status: resolution,
          resolutionNote: `Audited and marked as ${resolution} by Dhatu compliance administrator.`
        })
      });
      if (res.ok) {
        setStatusMessage(`Anomaly flag marked as ${resolution}.`);
        fetchAdminData();
      }
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col font-sans">
      {/* Top Header */}
      <header className="bg-slate-900 border-b border-slate-800 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-amber-600 to-amber-500 flex items-center justify-center shadow-lg shadow-amber-950/40">
                <ShieldAlert className="w-6 h-6 text-slate-950" />
              </div>
              <div>
                <div className="flex items-center space-x-2">
                  <span className="font-extrabold text-xl tracking-tight text-white">DHATU</span>
                  <span className="text-xs bg-amber-500/20 text-amber-300 font-bold px-2 py-0.5 rounded-full border border-amber-500/30 font-mono">
                    ADMIN & COMPLIANCE PORTAL
                  </span>
                </div>
                <p className="text-xs text-slate-400">National Informal E-Waste Channel Regularization</p>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <span className="inline-flex items-center text-xs px-2.5 py-1 rounded-md bg-amber-500/10 text-amber-300 border border-amber-500/20 font-mono">
                dataMaturity: synthetic & demo
              </span>
              <button
                onClick={fetchAdminData}
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
              onClick={() => setActiveTab('anomalies')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'anomalies'
                  ? 'border-amber-500 text-amber-400 bg-amber-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <AlertTriangle className="w-4 h-4" />
              <span>Anomaly Flags</span>
              {anomalies.filter((a) => a.status === 'pending_review').length > 0 && (
                <span className="ml-1.5 px-2 py-0.5 text-xs bg-red-500 text-white font-bold rounded-full animate-pulse">
                  {anomalies.filter((a) => a.status === 'pending_review').length}
                </span>
              )}
            </button>

            <button
              onClick={() => setActiveTab('recyclers')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'recyclers'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Building2 className="w-4 h-4" />
              <span>Recyclers & Compliance</span>
            </button>

            <button
              onClick={() => setActiveTab('pricing')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'pricing'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <TrendingUp className="w-4 h-4" />
              <span>Materials & Pricing</span>
            </button>

            <button
              onClick={() => setActiveTab('transactions')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'transactions'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Boxes className="w-4 h-4" />
              <span>Transactions</span>
            </button>

            <button
              onClick={() => setActiveTab('activity')}
              className={`flex items-center space-x-2 px-4 py-3 text-sm font-medium border-b-2 transition-all whitespace-nowrap ${
                activeTab === 'activity'
                  ? 'border-teal-500 text-teal-400 bg-teal-500/5'
                  : 'border-transparent text-slate-400 hover:text-slate-200'
              }`}
            >
              <Activity className="w-4 h-4" />
              <span>Platform Activity</span>
            </button>
          </div>
        </div>
      </header>

      {/* Alert Banner */}
      {statusMessage && (
        <div className="bg-teal-900/60 border-b border-teal-700 px-4 py-2.5 text-xs text-teal-200 flex justify-between items-center">
          <span>{statusMessage}</span>
          <button onClick={() => setStatusMessage(null)} className="opacity-75 hover:opacity-100">
            Dismiss
          </button>
        </div>
      )}

      {/* Main Content Area */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex-1 w-full space-y-8">
        {/* KPI Metric Summary Strip */}
        {metrics && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
              <span className="text-xs text-slate-400 font-medium">Total E-Waste Diverted</span>
              <div className="text-2xl font-extrabold text-teal-400 mt-1">{metrics.totalEwasteTons} Tons</div>
              <p className="text-[11px] text-slate-500 mt-1">{metrics.totalEwasteWeightKg} kg logged</p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
              <span className="text-xs text-slate-400 font-medium">Authorized Recycler Network</span>
              <div className="text-2xl font-extrabold text-white mt-1">
                {metrics.authorizedRecyclers} / {metrics.totalRecyclers}
              </div>
              <p className="text-[11px] text-teal-400 mt-1">
                {Math.round((metrics.authorizedRecyclers / (metrics.totalRecyclers || 1)) * 100)}% CPCB Compliant
              </p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
              <span className="text-xs text-slate-400 font-medium">Formal Collector Payouts</span>
              <div className="text-2xl font-extrabold text-amber-400 mt-1">₹{metrics.totalPayoutsInr.toLocaleString('en-IN')}</div>
              <p className="text-[11px] text-slate-500 mt-1">{metrics.completedTransactions} settled transactions</p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 shadow-lg">
              <span className="text-xs text-slate-400 font-medium">Statistical Anomaly Flags</span>
              <div className="text-2xl font-extrabold text-red-400 mt-1">{metrics.pendingAnomaliesCount}</div>
              <p className="text-[11px] text-slate-500 mt-1">&gt; 2σ Price Deviations</p>
            </div>
          </div>
        )}

        {/* TAB 1: Anomaly Flags */}
        {activeTab === 'anomalies' && (
          <div className="space-y-6">
            <div className="bg-amber-950/20 border border-amber-800/40 rounded-2xl p-5 flex items-start space-x-4">
              <AlertTriangle className="w-6 h-6 text-amber-400 flex-shrink-0 mt-1" />
              <div className="text-xs text-slate-300 space-y-1">
                <p className="font-bold text-amber-300 text-sm">Automated 2-Sigma Transaction Anomaly Detection</p>
                <p className="text-slate-400">
                  Transactions with final settlement rates deviating more than 2 standard deviations (|z-score| &gt; 2.0)
                  from the rolling 30-day baseline for the material and location are flagged for administrative review.
                  Flags are advisory and do not automatically block legitimate transactions.
                </p>
              </div>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
              <table className="w-full text-left text-sm text-slate-300">
                <thead className="bg-slate-950 text-xs uppercase text-slate-400 border-b border-slate-800">
                  <tr>
                    <th className="px-6 py-4 font-semibold">Lot ID</th>
                    <th className="px-6 py-4 font-semibold">Material</th>
                    <th className="px-6 py-4 font-semibold">Actual Rate</th>
                    <th className="px-6 py-4 font-semibold">Expected Mean (30d)</th>
                    <th className="px-6 py-4 font-semibold">Deviation (Z-Score)</th>
                    <th className="px-6 py-4 font-semibold">Status</th>
                    <th className="px-6 py-4 font-semibold text-right">Audit Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800">
                  {anomalies.length === 0 ? (
                    <tr>
                      <td colSpan={7} className="px-6 py-8 text-center text-slate-500">
                        No statistical anomalies detected.
                      </td>
                    </tr>
                  ) : (
                    anomalies.map((a) => (
                      <tr key={a.id} className="hover:bg-slate-800/40">
                        <td className="px-6 py-4 font-mono font-bold text-teal-400">{a.transactionId}</td>
                        <td className="px-6 py-4 font-semibold text-white">{a.materialCategory}</td>
                        <td className="px-6 py-4 font-bold text-red-400">₹{a.finalPriceInr} /kg</td>
                        <td className="px-6 py-4 text-slate-400">₹{a.expectedMeanPriceInr} /kg</td>
                        <td className="px-6 py-4 font-mono">
                          <span className="px-2 py-0.5 rounded-full text-xs font-bold bg-red-500/20 text-red-300 border border-red-500/30">
                            +{a.zScore}σ
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <span
                            className={`px-2 py-0.5 rounded-full text-xs font-semibold ${
                              a.status === 'pending_review'
                                ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                                : 'bg-teal-500/20 text-teal-300 border border-teal-500/30'
                            }`}
                          >
                            {a.status.replace('_', ' ')}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-right space-x-2">
                          {a.status === 'pending_review' ? (
                            <>
                              <button
                                onClick={() => handleResolveAnomaly(a.id, 'resolved')}
                                className="px-2.5 py-1 rounded-lg bg-teal-600 hover:bg-teal-500 text-white text-xs font-semibold inline-flex items-center space-x-1"
                              >
                                <Check className="w-3.5 h-3.5" />
                                <span>Resolve</span>
                              </button>
                              <button
                                onClick={() => handleResolveAnomaly(a.id, 'dismissed')}
                                className="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold inline-flex items-center space-x-1"
                              >
                                <X className="w-3.5 h-3.5" />
                                <span>Dismiss</span>
                              </button>
                            </>
                          ) : (
                            <span className="text-xs text-slate-500 font-semibold">Reviewed</span>
                          )}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* TAB 2: Recyclers & Compliance */}
        {activeTab === 'recyclers' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-xl font-bold text-white">Registered Recycler Facilities</h2>
                <p className="text-xs text-slate-400">
                  Verify State Pollution Control Board authorization certificates.
                </p>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {recyclers.map((r) => (
                <div
                  key={r.id}
                  className="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex flex-col justify-between shadow-lg"
                >
                  <div>
                    <div className="flex items-center justify-between mb-2">
                      <span className="font-mono text-xs text-slate-400">{r.id}</span>
                      <span
                        className={`text-xs px-2.5 py-0.5 rounded-full font-bold uppercase ${
                          r.authorizationStatus === 'authorized'
                            ? 'bg-teal-500/20 text-teal-300 border border-teal-500/30'
                            : r.authorizationStatus === 'pending'
                            ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                            : 'bg-red-500/20 text-red-300 border border-red-500/30'
                        }`}
                      >
                        {r.authorizationStatus}
                      </span>
                    </div>

                    <h3 className="font-bold text-white text-base">{r.name}</h3>
                    <p className="text-xs text-slate-400 mt-1 flex items-start">
                      <MapPin className="w-3.5 h-3.5 mr-1 flex-shrink-0 mt-0.5 text-slate-500" />
                      {r.address}
                    </p>

                    <div className="bg-slate-950 p-3 rounded-xl border border-slate-800/80 my-3 text-xs space-y-1">
                      <span className="text-slate-500 block">Authorization Certificate:</span>
                      <p className="text-slate-300 font-mono text-[11px] leading-tight">{r.authorizationDetails}</p>
                    </div>
                  </div>

                  <div className="pt-2 border-t border-slate-800 flex items-center space-x-2">
                    {r.authorizationStatus !== 'authorized' ? (
                      <button
                        onClick={() => handleAuthorizeRecycler(r.id, 'authorized')}
                        className="w-full py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs"
                      >
                        Grant Authorization
                      </button>
                    ) : (
                      <button
                        onClick={() => handleAuthorizeRecycler(r.id, 'unverified')}
                        className="w-full py-2 rounded-xl bg-slate-800 hover:bg-red-950 text-slate-300 hover:text-red-300 font-semibold text-xs border border-slate-700 hover:border-red-800"
                      >
                        Revoke Authorization
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* TAB 3: Materials & Pricing */}
        {activeTab === 'pricing' && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-bold text-white">Live Material Price Board Datasets</h2>
              <p className="text-xs text-slate-400">
                Transparent market reference rates derived from authorized aggregator intakes.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
              {priceBoard.map((item) => (
                <div
                  key={item.category}
                  className="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex flex-col justify-between"
                >
                  <div>
                    <div className="flex justify-between items-center">
                      <span className="font-extrabold text-lg text-white">{item.category}</span>
                      <span className="text-xs text-teal-400 font-bold">{item.trendPercent}</span>
                    </div>
                    <div className="text-2xl font-extrabold text-amber-400 mt-2 font-mono">
                      ₹{item.currentRateInrPerKg}
                      <span className="text-xs text-slate-400 font-normal"> /kg</span>
                    </div>
                    <div className="text-xs text-slate-500 mt-1">
                      Spread: ₹{item.minRateInrPerKg} – ₹{item.maxRateInrPerKg}
                    </div>
                  </div>
                  <div className="mt-4 pt-2 border-t border-slate-800 text-[10px] text-slate-500 flex justify-between">
                    <span>{item.sampleSize} samples</span>
                    <span className="font-mono">{item.dataMaturity}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* TAB 4: Transactions */}
        {activeTab === 'transactions' && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-bold text-white">Global Traceability & Transaction Log</h2>
              <p className="text-xs text-slate-400">Full audit trail of material digital lots.</p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
              <table className="w-full text-left text-sm text-slate-300">
                <thead className="bg-slate-950 text-xs uppercase text-slate-400 border-b border-slate-800">
                  <tr>
                    <th className="px-6 py-4 font-semibold">Lot ID</th>
                    <th className="px-6 py-4 font-semibold">Collector</th>
                    <th className="px-6 py-4 font-semibold">Material</th>
                    <th className="px-6 py-4 font-semibold">Weight</th>
                    <th className="px-6 py-4 font-semibold">Recycler</th>
                    <th className="px-6 py-4 font-semibold">Amount</th>
                    <th className="px-6 py-4 font-semibold">Stage</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800">
                  {transactions.map((tx) => (
                    <tr key={tx.id} className="hover:bg-slate-800/40">
                      <td className="px-6 py-4 font-mono font-bold text-teal-400">{tx.id}</td>
                      <td className="px-6 py-4 text-white font-medium">{tx.collectorName || 'Ramesh'}</td>
                      <td className="px-6 py-4">{tx.material.category}</td>
                      <td className="px-6 py-4 font-medium">{tx.weightKg} kg</td>
                      <td className="px-6 py-4 text-slate-400">{tx.recyclerName || 'Unmatched'}</td>
                      <td className="px-6 py-4 font-bold text-amber-400">
                        ₹{tx.finalPriceInr || tx.quotedPriceInr}
                      </td>
                      <td className="px-6 py-4">
                        <span className="text-xs px-2.5 py-0.5 rounded-full bg-slate-800 text-slate-200 capitalize">
                          {tx.transactionStatus.replace('_', ' ')}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {/* TAB 5: Platform Activity */}
        {activeTab === 'activity' && (
          <div className="space-y-6">
            <div>
              <h2 className="text-xl font-bold text-white">System Architecture & Audit Log</h2>
              <p className="text-xs text-slate-400">Immutable platform security and state transition records.</p>
            </div>

            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 space-y-4">
              <div className="flex items-center space-x-3 text-sm text-teal-400 font-bold">
                <CheckCircle2 className="w-5 h-5" />
                <span>Prisma ORM & PostgreSQL / SQLite Relational Engine Active</span>
              </div>
              <p className="text-xs text-slate-400 leading-relaxed">
                All digital material lots, GPS coordinates, verified scale weights, and transaction timeline events are
                cryptographically tagged with role-based access control and persistent audit logging.
              </p>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
