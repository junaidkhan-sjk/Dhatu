import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/auth';

export function createAdminRouter(prisma: PrismaClient) {
  const router = Router();

  // GET /api/admin/metrics - platform activity overview
  router.get('/metrics', async (_req, res) => {
    const totalRecyclers = await prisma.recycler.count();
    const authorizedRecyclers = await prisma.recycler.count({
      where: { authorizationStatus: 'authorized' }
    });
    const totalTransactions = await prisma.transaction.count();
    const completedTransactions = await prisma.transaction.count({
      where: { transactionStatus: 'paid' }
    });
    const anomalyCount = await prisma.anomalyFlag.count({
      where: { status: 'pending_review' }
    });

    const allTx = await prisma.transaction.findMany({
      select: { weightKg: true, finalPriceInr: true, quotedPriceInr: true, paymentStatus: true }
    });

    const totalEwasteWeightKg = allTx.reduce((acc, curr) => acc + curr.weightKg, 0);
    const totalPayoutsInr = allTx
      .filter((t) => t.paymentStatus === 'paid')
      .reduce((acc, curr) => acc + (curr.finalPriceInr || curr.quotedPriceInr), 0);

    return res.json({
      totalRecyclers,
      authorizedRecyclers,
      totalTransactions,
      completedTransactions,
      totalEwasteWeightKg: Math.round(totalEwasteWeightKg * 10) / 10,
      totalEwasteTons: Math.round((totalEwasteWeightKg / 1000) * 100) / 100,
      totalPayoutsInr,
      pendingAnomaliesCount: anomalyCount,
      dataMaturity: 'synthetic'
    });
  });

  // GET /api/admin/anomalies - list all flagged anomalies
  router.get('/anomalies', async (_req, res) => {
    const flags = await prisma.anomalyFlag.findMany({
      include: {
        transaction: {
          include: { material: true, recycler: true }
        }
      },
      orderBy: { detectedAt: 'desc' }
    });

    return res.json(flags);
  });

  // POST /api/admin/anomalies/:id/resolve - resolve or dismiss anomaly flag
  router.post('/anomalies/:id/resolve', async (req, res) => {
    const { status, resolutionNote } = req.body;
    const flag = await prisma.anomalyFlag.update({
      where: { id: req.params.id },
      data: {
        status: status || 'resolved',
        details: resolutionNote ? `${resolutionNote}` : undefined
      }
    });

    return res.json(flag);
  });

  // POST /api/admin/recyclers/:id/authorize - update recycler authorization status
  router.post('/recyclers/:id/authorize', async (req: AuthRequest, res: Response) => {
    const { status, authorizationDetails } = req.body;
    const recycler = await prisma.recycler.update({
      where: { id: req.params.id },
      data: {
        authorizationStatus: status,
        ...(authorizationDetails && { authorizationDetails })
      }
    });

    // Create audit log
    if (req.user?.id) {
      await prisma.auditLog.create({
        data: {
          userId: req.user.id,
          action: `UPDATE_RECYCLER_STATUS_TO_${status}`,
          targetEntity: 'Recycler',
          targetId: recycler.id,
          details: `Updated authorization status of ${recycler.name} to ${status}`
        }
      });
    }

    return res.json(recycler);
  });

  // GET /api/admin/audit-logs
  router.get('/audit-logs', async (_req, res) => {
    const logs = await prisma.auditLog.findMany({
      include: { user: true },
      orderBy: { timestamp: 'desc' },
      take: 50
    });
    return res.json(logs);
  });

  return router;
}
