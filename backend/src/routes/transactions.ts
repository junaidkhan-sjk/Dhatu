import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest } from '../middleware/auth';
import { appendTimelineStage } from '../services/timeline-builder';
import { detectTransactionAnomaly } from '../services/anomaly-detection';

export function createTransactionsRouter(prisma: PrismaClient) {
  const router = Router();

  // POST /api/transactions/:id/match - match lot with recycler
  router.post('/:id/match', async (req: AuthRequest, res: Response) => {
    const { recyclerId } = req.body;
    const lotId = req.params.id;

    const recycler = await prisma.recycler.findUnique({
      where: { id: recyclerId }
    });

    if (!recycler) {
      return res.status(404).json({ error: 'Recycler not found.' });
    }

    const current = await prisma.transaction.findUnique({
      where: { id: lotId },
      include: { traceability: true }
    });

    if (!current) {
      return res.status(404).json({ error: 'Lot not found.' });
    }

    const updatedTimeline = appendTimelineStage(
      current.traceability?.timelineJson || '[]',
      'Recycler Matched',
      `Matched with authorized recycler: ${recycler.name}`,
      req.user?.role || 'collector'
    );

    if (current.traceability) {
      await prisma.traceabilityRecord.update({
        where: { id: current.traceability.id },
        data: { timelineJson: updatedTimeline }
      });
    }

    const updated = await prisma.transaction.update({
      where: { id: lotId },
      data: {
        recyclerId: recycler.id,
        recyclerName: recycler.name,
        transactionStatus: 'matched'
      },
      include: { material: true, recycler: true, traceability: true }
    });

    return res.json(updated);
  });

  // POST /api/transactions/:id/offer - send or update price offer
  router.post('/:id/offer', async (req: AuthRequest, res: Response) => {
    const { quotedPriceInr, finalPriceInr, recyclerId } = req.body;
    const lotId = req.params.id;

    const current = await prisma.transaction.findUnique({
      where: { id: lotId },
      include: { traceability: true }
    });

    if (!current) {
      return res.status(404).json({ error: 'Lot not found.' });
    }

    const updated = await prisma.transaction.update({
      where: { id: lotId },
      data: {
        ...(quotedPriceInr && { quotedPriceInr: parseFloat(quotedPriceInr) }),
        ...(finalPriceInr && { finalPriceInr: parseFloat(finalPriceInr) }),
        ...(recyclerId && { recyclerId }),
        transactionStatus: 'offer_sent'
      },
      include: { material: true, recycler: true, traceability: true }
    });

    return res.json(updated);
  });

  // POST /api/transactions/:id/accept-offer - collector accepts offer
  router.post('/:id/accept-offer', async (req: AuthRequest, res: Response) => {
    const lotId = req.params.id;

    const current = await prisma.transaction.findUnique({
      where: { id: lotId },
      include: { traceability: true, recycler: true }
    });

    if (!current) {
      return res.status(404).json({ error: 'Lot not found.' });
    }

    const updatedTimeline = appendTimelineStage(
      current.traceability?.timelineJson || '[]',
      'Offer Accepted',
      `Offer accepted at ₹${current.finalPriceInr || current.quotedPriceInr}. Scheduled for handover.`,
      'collector'
    );

    if (current.traceability) {
      await prisma.traceabilityRecord.update({
        where: { id: current.traceability.id },
        data: { timelineJson: updatedTimeline }
      });
    }

    const updated = await prisma.transaction.update({
      where: { id: lotId },
      data: {
        transactionStatus: 'offer_accepted',
        finalPriceInr: current.finalPriceInr || current.quotedPriceInr
      },
      include: { material: true, recycler: true, traceability: true }
    });

    return res.json(updated);
  });

  // POST /api/transactions/:id/handover - record physical handover
  router.post('/:id/handover', async (req: AuthRequest, res: Response) => {
    const { handoverPhotoUrl, finalWeightKg, handoverLat, handoverLng, handoverArea } = req.body;
    const lotId = req.params.id;

    const current = await prisma.transaction.findUnique({
      where: { id: lotId },
      include: { traceability: true, material: true }
    });

    if (!current) {
      return res.status(404).json({ error: 'Lot not found.' });
    }

    const weight = finalWeightKg ? parseFloat(finalWeightKg) : current.weightKg;
    const refNumber = `REF-${lotId.replace('DH-', '')}`;

    const updatedTimeline = appendTimelineStage(
      current.traceability?.timelineJson || '[]',
      'Material Handed Over',
      `Material physically transferred at ${handoverArea || 'Facility'}. Weight: ${weight} kg. Reference: ${refNumber}`,
      req.user?.role || 'collector'
    );

    let photos: string[] = [];
    try {
      if (current.traceability?.photosJson) {
        photos = JSON.parse(current.traceability.photosJson);
      }
    } catch {}
    if (handoverPhotoUrl) photos.push(handoverPhotoUrl);

    if (current.traceability) {
      await prisma.traceabilityRecord.update({
        where: { id: current.traceability.id },
        data: {
          weightKg: weight,
          photosJson: JSON.stringify(photos),
          handoverReferenceNumber: refNumber,
          timelineJson: updatedTimeline,
          gpsLat: parseFloat(handoverLat || 19.076),
          gpsLng: parseFloat(handoverLng || 72.8777),
          gpsAddress: handoverArea || 'Handover Point'
        }
      });
    }

    const updated = await prisma.transaction.update({
      where: { id: lotId },
      data: {
        weightKg: weight,
        handoverLat: parseFloat(handoverLat || 19.076),
        handoverLng: parseFloat(handoverLng || 72.8777),
        handoverArea: handoverArea || 'Handover Point',
        transactionStatus: 'handed_over'
      },
      include: { material: true, recycler: true, traceability: true }
    });

    return res.json(updated);
  });

  // POST /api/transactions/:id/confirm - recycler confirms handover receipt
  router.post('/:id/confirm', async (req: AuthRequest, res: Response) => {
    const lotId = req.params.id;

    const current = await prisma.transaction.findUnique({
      where: { id: lotId },
      include: { traceability: true, material: true }
    });

    if (!current) {
      return res.status(404).json({ error: 'Lot not found.' });
    }

    const updatedTimeline = appendTimelineStage(
      current.traceability?.timelineJson || '[]',
      'Recycler Confirmed',
      'Authorized recycler verified weight and quality. Digital receipt certified.',
      'recycler'
    );

    if (current.traceability) {
      await prisma.traceabilityRecord.update({
        where: { id: current.traceability.id },
        data: {
          recyclerConfirmation: true,
          timelineJson: updatedTimeline
        }
      });
    }

    const updated = await prisma.transaction.update({
      where: { id: lotId },
      data: {
        transactionStatus: 'recycler_confirmed'
      },
      include: { material: true, recycler: true, traceability: true }
    });

    return res.json(updated);
  });

  // POST /api/transactions/:id/pay - complete payment
  router.post('/:id/pay', async (req: AuthRequest, res: Response) => {
    const { paymentMethod, finalPriceInr } = req.body;
    const lotId = req.params.id;

    const current = await prisma.transaction.findUnique({
      where: { id: lotId },
      include: { traceability: true, material: true }
    });

    if (!current) {
      return res.status(404).json({ error: 'Lot not found.' });
    }

    const finalAmount = finalPriceInr ? parseFloat(finalPriceInr) : current.finalPriceInr || current.quotedPriceInr;

    const updatedTimeline = appendTimelineStage(
      current.traceability?.timelineJson || '[]',
      'Payment Completed',
      `Payment of ₹${finalAmount} settled via ${paymentMethod || 'digital'} transfer.`,
      'recycler'
    );

    if (current.traceability) {
      await prisma.traceabilityRecord.update({
        where: { id: current.traceability.id },
        data: { timelineJson: updatedTimeline }
      });
    }

    const updated = await prisma.transaction.update({
      where: { id: lotId },
      data: {
        finalPriceInr: finalAmount,
        paymentStatus: 'paid',
        paymentMethod: paymentMethod || 'digital',
        transactionStatus: 'paid'
      },
      include: { material: true, recycler: true, traceability: true }
    });

    // Run statistical anomaly detection test
    const ratePerKg = Math.round(finalAmount / (current.weightKg || 1));
    await detectTransactionAnomaly(
      prisma,
      lotId,
      current.material.category,
      ratePerKg,
      current.collectionArea || undefined
    );

    return res.json(updated);
  });

  return router;
}
