import { PrismaClient } from '@prisma/client';

export interface RecyclerRanking {
  recyclerId: string;
  name: string;
  address: string;
  phone: string;
  email?: string;
  authorizationStatus: string;
  authorizationDetails: string;
  offeredRateInrPerKg: number;
  pickupAvailable: boolean;
  distanceKm: number;
  totalScore: number;
  scoreBreakdown: {
    distanceScore: number;
    priceScore: number;
    pickupScore: number;
    authorizationScore: number;
  };
}

export const MATCHING_WEIGHTS = {
  distance: 0.30,
  price: 0.35,
  pickup: 0.15,
  authorization: 0.20
};

// Haversine formula for distance in kilometers
function calculateHaversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Earth radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 10) / 10;
}

export async function matchRecyclers(
  prisma: PrismaClient,
  category: string,
  collectorLat: number,
  collectorLng: number
): Promise<RecyclerRanking[]> {
  // 1. Fetch ALL recyclers who are strictly "authorized"
  const allRecyclers = await prisma.recycler.findMany({
    where: {
      authorizationStatus: 'authorized'
    }
  });

  // 2. Filter recyclers who accept this material category
  const matchingRecyclers = allRecyclers.filter((r) => {
    try {
      const materials = JSON.parse(r.materialsAccepted) as string[];
      return materials.map((m) => m.toLowerCase()).includes(category.toLowerCase());
    } catch {
      return false;
    }
  });

  if (matchingRecyclers.length === 0) {
    return [];
  }

  // 3. Find max offered rate for normalization
  let maxRate = 1;
  const parsedRecyclers = matchingRecyclers.map((r) => {
    let rates: Record<string, number> = {};
    try {
      rates = JSON.parse(r.offeredRatesJson);
    } catch {
      rates = {};
    }
    const categoryRate = rates[category] || 100;
    if (categoryRate > maxRate) maxRate = categoryRate;

    const distanceKm = calculateHaversineDistance(
      collectorLat,
      collectorLng,
      r.locationLat,
      r.locationLng
    );

    return {
      recycler: r,
      rate: categoryRate,
      distanceKm
    };
  });

  // 4. Calculate weighted scores
  const ranked = parsedRecyclers.map((item) => {
    const { recycler, rate, distanceKm } = item;

    // Distance score: closer is better (100 for 0km, decreasing up to 50km)
    const distanceScore = Math.max(0, Math.min(100, 100 - (distanceKm / 50) * 100));

    // Price score: normalized against max offered rate
    const priceScore = Math.min(100, (rate / maxRate) * 100);

    // Pickup score: 100 if pickup is provided, 40 if self-drop only
    const pickupScore = recycler.pickupAvailable ? 100 : 40;

    // Authorization score: 100 for authorized government verified
    const authorizationScore = 100;

    const totalScore = Math.round(
      distanceScore * MATCHING_WEIGHTS.distance +
      priceScore * MATCHING_WEIGHTS.price +
      pickupScore * MATCHING_WEIGHTS.pickup +
      authorizationScore * MATCHING_WEIGHTS.authorization
    );

    return {
      recyclerId: recycler.id,
      name: recycler.name,
      address: recycler.address,
      phone: recycler.phone,
      email: recycler.email || undefined,
      authorizationStatus: recycler.authorizationStatus,
      authorizationDetails: recycler.authorizationDetails,
      offeredRateInrPerKg: rate,
      pickupAvailable: recycler.pickupAvailable,
      distanceKm,
      totalScore,
      scoreBreakdown: {
        distanceScore: Math.round(distanceScore),
        priceScore: Math.round(priceScore),
        pickupScore: Math.round(pickupScore),
        authorizationScore: Math.round(authorizationScore)
      }
    };
  });

  // Sort by highest totalScore descending
  ranked.sort((a, b) => b.totalScore - a.totalScore);

  return ranked;
}
