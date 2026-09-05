import { PrismaClient } from '@prisma/client';

export interface ValueEstimationResult {
  category: string;
  weightKg: number;
  avgBaseRateInrPerKg: number;
  estimatedValueMinInr: number;
  estimatedValueMaxInr: number;
  confidenceMarginPercent: number;
  historicalSampleCount: number;
  locationArea: string;
  disclaimer: string;
}

export async function estimateMaterialValue(
  prisma: PrismaClient,
  category: string,
  weightKg: number,
  locationArea?: string
): Promise<ValueEstimationResult> {
  // Query recent price records for this category
  const priceRecords = await prisma.priceRecord.findMany({
    where: {
      materialCategory: {
        equals: category
      }
    },
    orderBy: {
      dateTime: 'desc'
    },
    take: 20
  });

  let avgRate = 120; // default fallback if no records yet

  if (priceRecords.length > 0) {
    // If location match exists, prioritize same area
    const locationMatched = locationArea
      ? priceRecords.filter((p) => p.areaName.toLowerCase().includes(locationArea.toLowerCase()))
      : [];

    const dataset = locationMatched.length >= 2 ? locationMatched : priceRecords;
    const sum = dataset.reduce((acc, curr) => acc + curr.buyingPriceInr, 0);
    avgRate = Math.round((sum / dataset.length) * 100) / 100;
  } else {
    // Fallback baseline rates by category
    const categoryFallbacks: Record<string, number> = {
      PCB: 135,
      Battery: 85,
      Cable: 240,
      CRT: 35,
      Motor: 195
    };
    avgRate = categoryFallbacks[category] || 100;
  }

  const baselineTotal = weightKg * avgRate;
  const minEst = Math.round(baselineTotal * 0.85); // -15%
  const maxEst = Math.round(baselineTotal * 1.15); // +15%

  return {
    category,
    weightKg,
    avgBaseRateInrPerKg: avgRate,
    estimatedValueMinInr: minEst,
    estimatedValueMaxInr: maxEst,
    confidenceMarginPercent: 15,
    historicalSampleCount: priceRecords.length,
    locationArea: locationArea || 'General Market',
    disclaimer: 'अनुमानित मूल्य / Estimated range, not final price. Final price is confirmed upon recycler inspection.'
  };
}
