# Dhatu (धातु — *हर तार में मूल्य*)
### Formal Integration Platform for Informal E-Waste Collectors and Authorized Recyclers

Built for **Smart India Hackathon**  
*Problem Theme: Informal E-Waste Collector Integration with Authorized Recyclers*

---

## 1. System Architecture & Tech Stack

Dhatu bridges informal waste collectors (*kabadis*) in India with authorized, licensed recyclers to solve the three core challenges: **no price transparency**, **no recycler visibility/matching**, and **no digital traceability records**.

```
dhatu/
├── backend/            # Node.js + Express + Prisma ORM + SQLite/PostgreSQL (TypeScript)
│   ├── src/
│   │   ├── prisma/schema.prisma  # Complete schema with mandatory dataMaturity fields
│   │   ├── services/             # AI Classifier, Value Estimation, Matching Engine, Anomaly Detection
│   │   ├── routes/               # REST API (auth, lots, prices, recyclers, transactions, admin, sync)
│   │   └── seed/                 # 12 Recyclers, 100+ Price Records, Synthetic Transactions
├── mobile/             # Flutter Mobile App (Android / Web / Desktop)
│   ├── lib/
│   │   ├── l10n/                 # Vernacular support: Hindi (हिन्दी), Marathi (मराठी), English
│   │   ├── services/             # Offline Drift/SQLite Sync Engine with 4-state indicator & Audio TTS
│   │   └── screens/              # All 25 screens & 5-tab persistent bottom navigation
├── web-recycler/       # React + TypeScript + Tailwind CSS (Authorized Recycler Dashboard)
├── web-admin/          # React + TypeScript + Tailwind CSS (Central Compliance & Audit Dashboard)
└── shared/             # Shared TypeScript definitions, models, and enums
```

---

## 2. Quick Start Guide

### Prerequisites
- Node.js (v18+)
- Flutter (v3.19+)

---

### Step 1: Start Backend API & Database

```bash
cd backend
npm install
npx prisma db push
npm run seed
npm run dev
```
- **Backend API:** `http://localhost:5000`
- **Health Check:** `http://localhost:5000/api/health`

---

### Step 2: Start Recycler Web Dashboard

```bash
cd web-recycler
npm install
npm run dev
```
- **Recycler Portal:** `http://localhost:5173`
- **Tabs:** `Incoming Lots`, `My Offers`, `Handovers`, `Profile & Rates`, `Transaction History`

---

### Step 3: Start Admin & Compliance Web Dashboard

```bash
cd web-admin
npm install
npm run dev
```
- **Admin Portal:** `http://localhost:5174`
- **Tabs:** `Anomaly Flags`, `Recyclers & Compliance`, `Materials & Pricing`, `Transactions`, `Platform Activity`

---

### Step 4: Run Collector Mobile App (Flutter)

```bash
cd mobile
flutter pub get
flutter run -d chrome  # Or: flutter run -d windows / flutter run (for Android device/emulator)
```

---

## 3. Demo Accounts & Credentials

| Role | Phone | Demo OTP | Name | Assigned Facility |
|---|---|---|---|---|
| **Collector** | `+91 9876543210` | `123456` | Ramesh Kumar (कबाड़ी) | Dharavi Central Zone |
| **Recycler** | `+91 9876543211` | `123456` | Yard Manager | EcoMetals Green Yard Pvt Ltd (MPCB Licensed) |
| **Admin** | `+91 9876543212` | `123456` | Platform Admin | Dhatu National Compliance Center |

---

## 4. AI / ML Services Implementation

### 1. Material Classification (`ai-classifier.ts`)
- **Input:** Image metadata / visual hint.
- **Logic:** Identifies material (PCB, Battery, Cable, CRT, Motor) with confidence score (e.g. 88%).
- **Rule:** UI **always** allows 1-tap manual category override.

### 2. Value Estimation (`value-estimation.ts`)
- **Input:** Category, weight (kg), location.
- **Logic:** `estimatedValue = weight * avg(recent buyingPrice for category + location)`.
- **Output:** Returned strictly as a **±15% valuation range** (e.g. ₹1,500–₹1,800), clearly labeled *"अनुमानित मूल्य / Estimated range, not final price"*.

### 3. Smart Recycler Matching Engine (`matching-engine.ts`)
- **Ranking Formula:**
  $$\text{Score} = 0.30 \times \text{Distance} + 0.35 \times \text{Price} + 0.15 \times \text{Pickup} + 0.20 \times \text{Authorization}$$
- **Constraint:** Unauthorized recyclers are strictly filtered out before scoring.

### 4. 2-Sigma Transaction Anomaly Detection (`anomaly-detection.ts`)
- **Logic:** Flags transactions whose rate per kg deviates **$> 2$ standard deviations ($|z\text{-score}| > 2.0$)** from the 30-day baseline mean.
- **Output:** Surfaced as an advisory flag to Admin only (e.g. Lot `DH-2026-0899` with $+15.63\sigma$ deviation). Never auto-blocks or auto-accuses.

---

## 5. Offline-First Architecture & 4-State Sync Indicator

The mobile app enables creating digital lots, capturing weights, and logging handovers **with zero network connectivity**:
- 🟡 **Saved Offline:** Persisted to local device queue.
- 🔵 **Synchronizing:** Auto-syncing in background with backoff retries.
- 🟢 **Synced Successfully:** Idempotently registered with Cloud Database & Traceability Timeline.
- 🔴 **Requires Attention:** Tappable for manual retry.

---

## 6. Vernacular & Audio Interface
- **Languages:** Hindi (हिन्दी), Marathi (मराठी), English (en).
- **Text-to-Speech (🔊):** Available on every screen that shows a price or number.
- **Safety Guidance:** Pictorial + voice guidance for hazardous items (Lithium Batteries, Lead Glass CRTs, Cables).

---

## 7. Data Maturity Compliance

Every single record in Dhatu carries an explicit, mandatory field:
```typescript
type DataMaturity = "demo" | "synthetic" | "field_collected" | "verified";
```
Seed data is explicitly tagged `demo` or `synthetic`. No fabricated claims of government integration or artificial accuracy numbers are displayed.
