import { PrismaClient } from '@prisma/client';

export interface AnomalyDetectionResult {
  isAnomaly: boolean;
  transactionId: string;
  materialCategory: string;
  locationArea: string;
  finalPriceInr: number;
  expectedMeanPriceInr: number;
  standardDeviationInr: number;
  zScore: number;
  severity: 'low' | 'medium' | 'high';
  details: string;
}

export async function detectTransactionAnomaly(
  prisma: PrismaClient,
  transactionId: string,
  materialCategory: string,
  finalPricePerKg: number,
  locationArea?: string
): Promise<AnomalyDetectionResult | null> {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  // Fetch all recent transactions or price records for this category & location in last 30 days
  const baselineRecords = await prisma.priceRecord.findMany({
    where: {
      materialCategory,
      dateTime: {
        gte: thirtyDaysAgo
      }
    }
  });

  const prices = baselineRecords.map((r) => r.buyingPriceInr);

  // If insufficient sample size, cannot establish 2-sigma baseline reliably
  if (prices.length < 3) {
    return null;
  }

  // Mean calculation
  const mean = prices.reduce((a, b) => a + b, 0) / prices.length;

  // Standard deviation calculation
  const variance =
    prices.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / prices.length;
  const stdDev = Math.sqrt(variance);

  // Avoid divide by zero
  if (stdDev < 1) {
    return null;
  }

  const deviation = Math.abs(finalPricePerKg - mean);
  const zScore = Math.round((deviation / stdDev) * 100) / 100;

  // Flag if |z-score| > 2 (2 standard deviations)
  if (zScore > 2.0) {
    const severity = zScore > 3.5 ? 'high' : zScore > 2.5 ? 'medium' : 'low';
    const direction = finalPricePerKg > mean ? 'significantly higher' : 'significantly lower';

    const details = `Transaction rate ₹${finalPricePerKg}/kg is ${direction} than 30-day baseline mean ₹${Math.round(mean)}/kg (σ = ₹${Math.round(stdDev)}, z-score = ${zScore}). Flagged for administrative audit.`;

    // Persist anomaly flag in database
    await prisma.anomalyFlag.create({
      data: {
        transactionId,
        materialCategory,
        locationArea: locationArea || 'General Market',
        finalPriceInr: finalPricePerKg,
        expectedMeanPriceInr: Math.round(mean * 100) / 100,
        standardDeviationInr: Math.round(stdDev * 100) / 100,
        zScore,
        severity,
        status: 'pending_review',
        details,
        dataMaturity: 'synthetic'
      }
    });

    return {
      isAnomaly: true,
      transactionId,
      materialCategory,
      locationArea: locationArea || 'General Market',
      finalPriceInr: finalPricePerKg,
      expectedMeanPriceInr: Math.round(mean * 100) / 100,
      standardDeviationInr: Math.round(stdDev * 100) / 100,
      zScore,
      severity,
      details
    };
  }

  return {
    isAnomaly: false,
    transactionId,
    materialCategory,
    locationArea: locationArea || 'General Market',
    finalPriceInr: finalPricePerKg,
    expectedMeanPriceInr: Math.round(mean * 100) / 100,
    standardDeviationInr: Math.round(stdDev * 100) / 100,
    zScore,
    severity: 'low',
    details: 'Transaction within normal statistical variance.'
  };
}
