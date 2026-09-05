import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, requireAuth } from '../middleware/auth';

export function createEarningsRouter(prisma: PrismaClient) {
  const router = Router();

  // GET /api/earnings/summary - collector earnings overview
  router.get('/summary', requireAuth, async (req: AuthRequest, res: Response) => {
    const collectorId = req.user?.id;

    // Fetch all transactions for this collector
    const transactions = await prisma.transaction.findMany({
      where: collectorId ? { collectorId } : {},
      include: { material: true }
    });

    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    let todayEarningsInr = 0;
    let totalEarningsInr = 0;
    let pendingEarningsInr = 0;
    let completedCount = 0;
    let pendingCount = 0;
    let totalWeightKg = 0;

    for (const t of transactions) {
      const amount = t.finalPriceInr || t.quotedPriceInr;
      totalWeightKg += t.weightKg;

      if (t.paymentStatus === 'paid') {
        totalEarningsInr += amount;
        completedCount++;
        if (new Date(t.updatedAt) >= startOfToday) {
          todayEarningsInr += amount;
        }
      } else {
        pendingEarningsInr += amount;
        pendingCount++;
      }
    }

    // Recent payouts list
    const recentPayouts = transactions
      .filter((t) => t.paymentStatus === 'paid')
      .slice(0, 10)
      .map((t) => ({
        lotId: t.id,
        category: t.material.category,
        weightKg: t.weightKg,
        amountInr: t.finalPriceInr || t.quotedPriceInr,
        dateTime: t.updatedAt.toISOString(),
        paymentMethod: t.paymentMethod || 'digital',
        recyclerName: t.recyclerName || 'Authorized Recycler',
        dataMaturity: t.dataMaturity
      }));

    return res.json({
      todayEarningsInr,
      totalEarningsInr,
      pendingEarningsInr,
      completedCount,
      pendingCount,
      totalWeightKg: Math.round(totalWeightKg * 10) / 10,
      recentPayouts,
      currency: 'INR',
      dataMaturity: 'demo'
    });
  });

  return router;
}
