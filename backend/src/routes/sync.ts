import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/auth';
import { buildDefaultTimeline } from '../services/timeline-builder';

export function createSyncRouter(prisma: PrismaClient) {
  const router = Router();

  // POST /api/sync/batch - synchronize offline queue
  router.post('/batch', async (req: AuthRequest, res: Response) => {
    const { items } = req.body; // Array of offline lots or state updates

    if (!Array.isArray(items)) {
      return res.status(400).json({ error: 'items must be an array.' });
    }

    const results: any[] = [];

    for (const item of items) {
      try {
        const {
          clientLotId,
          category,
          subCategory,
          description,
          imageUrl,
          approxWeightKg,
          condition,
          sourceType,
          estimatedValueMinInr,
          estimatedValueMaxInr,
          collectionLat,
          collectionLng,
          collectionArea,
          dataMaturity
        } = item;

        // Check if lot already exists on server
        const existing = await prisma.transaction.findUnique({
          where: { id: clientLotId },
          include: { material: true, traceability: true, recycler: true }
        });

        if (existing) {
          // Already synced! Return existing server record
          results.push({
            clientLotId,
            status: 'synced',
            serverTransaction: existing,
            message: 'Record already synced on server.'
          });
          continue;
        }

        // Newly created offline lot -> save to database
        const weight = parseFloat(approxWeightKg || 1);
        const minVal = parseFloat(estimatedValueMinInr || (weight * 115).toString());
        const maxVal = parseFloat(estimatedValueMaxInr || (weight * 155).toString());
        const quotedRate = Math.round((minVal + maxVal) / 2);

        let collectorId = req.user?.id;
        if (!collectorId) {
          const defaultCollector = await prisma.user.findFirst({
            where: { role: 'collector' }
          });
          collectorId = defaultCollector ? defaultCollector.id : 'demo-collector-id';
        }

        const material = await prisma.material.create({
          data: {
            category: category || 'PCB',
            subCategory,
            description,
            imageUrl: imageUrl || '/uploads/sample_pcb.jpg',
            approxWeightKg: weight,
            condition: condition || 'good',
            sourceType: sourceType || 'collector_pickup',
            estimatedValueMinInr: minVal,
            estimatedValueMaxInr: maxVal,
            dataMaturity: dataMaturity || 'field_collected'
          }
        });

        const timeline = buildDefaultTimeline();

        const transaction = await prisma.transaction.create({
          data: {
            id: clientLotId,
            collectorId,
            collectorName: req.user?.name || 'Ramesh Collector',
            collectorPhone: req.user?.phone || '+91 9876543210',
            materialId: material.id,
            weightKg: weight,
            quotedPriceInr: quotedRate,
            collectionLat: parseFloat(collectionLat || 19.076),
            collectionLng: parseFloat(collectionLng || 72.8777),
            collectionArea: collectionArea || 'Offline Collection',
            paymentStatus: 'pending',
            transactionStatus: 'draft',
            dataMaturity: dataMaturity || 'field_collected'
          }
        });

        await prisma.traceabilityRecord.create({
          data: {
            lotId: transaction.id,
            photosJson: JSON.stringify([material.imageUrl]),
            weightKg: weight,
            gpsLat: parseFloat(collectionLat || 19.076),
            gpsLng: parseFloat(collectionLng || 72.8777),
            gpsAddress: collectionArea || 'Offline Field Collection Point',
            handoverReferenceNumber: `REF-${clientLotId.replace('DH-', '')}`,
            recyclerConfirmation: false,
            timelineJson: JSON.stringify(timeline),
            dataMaturity: dataMaturity || 'field_collected'
          }
        });

        const fullRecord = await prisma.transaction.findUnique({
          where: { id: transaction.id },
          include: { material: true, traceability: true, recycler: true }
        });

        results.push({
          clientLotId,
          status: 'synced',
          serverTransaction: fullRecord
        });
      } catch (err: any) {
        results.push({
          clientLotId: item.clientLotId,
          status: 'attention_required',
          error: err.message
        });
      }
    }

    return res.json({
      success: true,
      syncedCount: results.filter((r) => r.status === 'synced').length,
      results
    });
  });

  return router;
}
