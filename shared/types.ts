export type DataMaturity = 'demo' | 'synthetic' | 'field_collected' | 'verified';

export type UserRole = 'collector' | 'recycler' | 'admin';

export type LanguageCode = 'en' | 'hi' | 'mr';

export type MaterialCondition = 'good' | 'damaged' | 'mixed';

export type MaterialSourceType = 'collector_pickup' | 'aggregator' | 'other';

export type PriceUnit = 'per_kg' | 'per_unit';

export type RecyclerAuthStatus = 'authorized' | 'pending' | 'unverified';

export type PaymentStatus = 'pending' | 'partial' | 'paid';

export type PaymentMethod = 'cash' | 'digital';

export type TransactionStatus =
  | 'draft'
  | 'matched'
  | 'offer_sent'
  | 'offer_accepted'
  | 'handed_over'
  | 'recycler_confirmed'
  | 'paid';

export type SyncState = 'offline_saved' | 'syncing' | 'synced' | 'attention_required';

export interface LocationCoordinates {
  lat: number;
  lng: number;
  areaName?: string;
  address?: string;
}

export interface Material {
  id: string;
  category: string;              // e.g. "PCB", "Cable", "Battery", "CRT", "Motor"
  subCategory?: string;
  description?: string;
  imageUrl: string;
  approxWeightKg: number;
  condition: MaterialCondition;
  sourceType: MaterialSourceType;
  estimatedValueMinInr: number;
  estimatedValueMaxInr: number;
  dataMaturity: DataMaturity;
  createdAt?: string;
}

export interface PriceRecord {
  id: string;
  materialCategory: string;
  location: LocationCoordinates;
  dateTime: string;              // ISO timestamp
  buyingPriceInr: number;
  quotedPriceInr: number;
  unit: PriceUnit;
  recyclerOrAggregatorId: string;
  recyclerName?: string;
  dataMaturity: DataMaturity;
}

export interface Recycler {
  id: string;
  name: string;
  facilityLocation: LocationCoordinates;
  materialsAccepted: string[];
  authorizationDetails: string;
  authorizationStatus: RecyclerAuthStatus;
  contact: { phone: string; email?: string };
  offeredRatesInrPerKg: Record<string, number>;  // category -> rate
  pickupAvailable: boolean;
  serviceAreaRadiusKm: number;
  dataMaturity: DataMaturity;
}

export interface TimelineEvent {
  stage: string;
  timestamp: string;
  note?: string;
  actorRole?: string;
}

export interface Transaction {
  id: string;                    // Lot ID (e.g., "DH-2026-0812")
  collectorId: string;
  collectorName?: string;
  collectorPhone?: string;
  material: Material;
  weightKg: number;
  quotedPriceInr: number;
  finalPriceInr?: number;
  recyclerId?: string;
  recyclerName?: string;
  collectionLocation: LocationCoordinates;
  handoverLocation?: LocationCoordinates;
  dateTime: string;
  paymentStatus: PaymentStatus;
  paymentMethod?: PaymentMethod;
  transactionStatus: TransactionStatus;
  syncState?: SyncState;
  dataMaturity: DataMaturity;
  traceability?: TraceabilityRecord;
}

export interface TraceabilityRecord {
  lotId: string;
  photos: string[];
  weightKg: number;
  timestamp: string;
  gpsLocation: LocationCoordinates;
  handoverReferenceNumber: string;
  recyclerConfirmation: boolean;
  timeline: TimelineEvent[];
}

export interface AnomalyFlag {
  id: string;
  transactionId: string;
  materialCategory: string;
  locationArea: string;
  finalPriceInr: number;
  expectedMeanPriceInr: number;
  standardDeviationInr: number;
  zScore: number;
  severity: 'low' | 'medium' | 'high';
  status: 'pending_review' | 'resolved' | 'dismissed';
  detectedAt: string;
  details: string;
  dataMaturity: DataMaturity;
}

export interface UserProfile {
  id: string;
  phone: string;
  name: string;
  role: UserRole;
  language: LanguageCode;
  recyclerId?: string;
  createdAt: string;
}

export interface RecyclerMatchResult {
  recycler: Recycler;
  score: number;
  distanceKm: number;
  distanceScore: number;
  priceScore: number;
  pickupScore: number;
  authorizationScore: number;
  offeredRateInr: number;
}
