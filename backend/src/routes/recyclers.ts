import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { matchRecyclers } from '../services/matching-engine';
import { AuthRequest, requireAuth } from '../middleware/auth';
import { requireRole } from '../middleware/rbac';

export function createRecyclersRouter(prisma: PrismaClient) {
  const router = Router();

  // GET /api/recyclers - list all authorized recyclers
  router.get('/', async (req, res) => {
    const { status, category } = req.query;

    const where: any = {};
    if (status) {
      where.authorizationStatus = status;
    }

    const recyclers = await prisma.recycler.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });

    const parsed = recyclers.map((r) => {
      let materials: string[] = [];
      let rates: Record<string, number> = {};
      try {
        materials = JSON.parse(r.materialsAccepted);
        rates = JSON.parse(r.offeredRatesJson);
      } catch {}

      return {
        ...r,
        materialsAccepted: materials,
        offeredRatesInrPerKg: rates
      };
    });

    return res.json(parsed);
  });

  // POST /api/recyclers/match - rank recyclers for a collector's material
  router.post('/match', async (req, res) => {
    const { category, lat, lng } = req.body;
    if (!category) {
      return res.status(400).json({ error: 'category is required.' });
    }

    const collectorLat = parseFloat(lat || 19.076); // Mumbai default
    const collectorLng = parseFloat(lng || 72.8777);

    const rankings = await matchRecyclers(prisma, category, collectorLat, collectorLng);
    return res.json({
      category,
      collectorLocation: { lat: collectorLat, lng: collectorLng },
      rankings,
      totalMatched: rankings.length,
      dataMaturity: 'synthetic'
    });
  });

  // GET /api/recyclers/:id - get single recycler details
  router.get('/:id', async (req, res) => {
    const recycler = await prisma.recycler.findUnique({
      where: { id: req.params.id }
    });

    if (!recycler) {
      return res.status(404).json({ error: 'Recycler not found.' });
    }

    let materials: string[] = [];
    let rates: Record<string, number> = {};
    try {
      materials = JSON.parse(recycler.materialsAccepted);
      rates = JSON.parse(recycler.offeredRatesJson);
    } catch {}

    return res.json({
      ...recycler,
      materialsAccepted: materials,
      offeredRatesInrPerKg: rates
    });
  });

  // PUT /api/recyclers/profile - update rates and service area (for logged-in recycler)
  router.put('/profile', requireAuth, requireRole('recycler', 'admin'), async (req: AuthRequest, res: Response) => {
    const {
      name,
      address,
      phone,
      email,
      materialsAccepted,
      offeredRatesInrPerKg,
      pickupAvailable,
      serviceAreaRadiusKm
    } = req.body;

    const recyclerId = req.user?.recyclerId;
    if (!recyclerId && req.user?.role !== 'admin') {
      return res.status(400).json({ error: 'No associated recycler account found.' });
    }

    const targetId = recyclerId || req.body.id;

    const updated = await prisma.recycler.update({
      where: { id: targetId },
      data: {
        ...(name && { name }),
        ...(address && { address }),
        ...(phone && { phone }),
        ...(email && { email }),
        ...(materialsAccepted && {
          materialsAccepted: JSON.stringify(materialsAccepted)
        }),
        ...(offeredRatesInrPerKg && {
          offeredRatesJson: JSON.stringify(offeredRatesInrPerKg)
        }),
        ...(pickupAvailable !== undefined && { pickupAvailable }),
        ...(serviceAreaRadiusKm && { serviceAreaRadiusKm: parseFloat(serviceAreaRadiusKm) })
      }
    });

    return res.json(updated);
  });

  return router;
}
