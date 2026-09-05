import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { AuthRequest } from '../middleware/auth';
import { buildDefaultTimeline } from '../services/timeline-builder';

// Setup local uploads storage
const uploadsDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename: (_req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'lot-' + uniqueSuffix + path.extname(file.originalname || '.jpg'));
  }
});

const upload = multer({ storage, limits: { fileSize: 10 * 1024 * 1024 } });

export function createLotsRouter(prisma: PrismaClient) {
  const router = Router();

  // POST /api/lots/upload-photo - upload image for lot creation
  router.post('/upload-photo', upload.single('photo'), (req, res) => {
    if (!req.file) {
      // Return sample URL if no file was uploaded
      return res.json({
        imageUrl: '/uploads/sample_pcb.jpg',
        filename: 'sample_pcb.jpg'
      });
    }

    const imageUrl = `/uploads/${req.file.filename}`;
    return res.json({
      imageUrl,
      filename: req.file.filename,
      size: req.file.size
    });
  });

  // POST /api/lots - create new digital material lot
  router.post('/', async (req: AuthRequest, res: Response) => {
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
    } = req.body;

    if (!category || !approxWeightKg) {
      return res.status(400).json({ error: 'category and approxWeightKg are required.' });
    }

    // Determine collector ID
    let collectorId = req.user?.id;
    let collectorName = req.user?.name || 'Ramesh Collector';
    let collectorPhone = req.user?.phone || '+91 9876543210';

    if (!collectorId) {
      // Find or fallback to default collector
      const defaultCollector = await prisma.user.findFirst({
        where: { role: 'collector' }
      });
      collectorId = defaultCollector ? defaultCollector.id : 'demo-collector-id';
    }

    // Generate unique Lot ID if not provided (e.g. DH-2026-XXXX)
    const lotId =
      clientLotId ||
      `DH-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`;

    const weight = parseFloat(approxWeightKg);
    const minVal = parseFloat(estimatedValueMinInr || (weight * 115).toString());
    const maxVal = parseFloat(estimatedValueMaxInr || (weight * 155).toString());
    const quotedRate = Math.round((minVal + maxVal) / 2);

    // 1. Create Material record
    const material = await prisma.material.create({
      data: {
        category,
        subCategory: subCategory || undefined,
        description: description || undefined,
        imageUrl: imageUrl || '/uploads/sample_pcb.jpg',
        approxWeightKg: weight,
        condition: condition || 'good',
        sourceType: sourceType || 'collector_pickup',
        estimatedValueMinInr: minVal,
        estimatedValueMaxInr: maxVal,
        dataMaturity: dataMaturity || 'demo'
      }
    });

    const now = new Date();
    const timeline = buildDefaultTimeline(now);

    // 2. Create Transaction / Lot record
    const transaction = await prisma.transaction.create({
      data: {
        id: lotId,
        collectorId,
        collectorName,
        collectorPhone,
        materialId: material.id,
        weightKg: weight,
        quotedPriceInr: quotedRate,
        collectionLat: parseFloat(collectionLat || 19.076),
        collectionLng: parseFloat(collectionLng || 72.8777),
        collectionArea: collectionArea || 'Dharavi Collection Center',
        paymentStatus: 'pending',
        transactionStatus: 'draft',
        dataMaturity: dataMaturity || 'demo'
      }
    });

    // 3. Create TraceabilityRecord
    await prisma.traceabilityRecord.create({
      data: {
        lotId: transaction.id,
        photosJson: JSON.stringify([material.imageUrl]),
        weightKg: weight,
        gpsLat: parseFloat(collectionLat || 19.076),
        gpsLng: parseFloat(collectionLng || 72.8777),
        gpsAddress: collectionArea || 'Dharavi Sector 5',
        handoverReferenceNumber: `REF-${lotId.replace('DH-', '')}`,
        recyclerConfirmation: false,
        timelineJson: JSON.stringify(timeline),
        dataMaturity: dataMaturity || 'demo'
      }
    });

    const fullRecord = await prisma.transaction.findUnique({
      where: { id: transaction.id },
      include: {
        material: true,
        traceability: true,
        recycler: true
      }
    });

    return res.status(201).json(fullRecord);
  });

  // GET /api/lots - list lots (with filters for status and collector)
  router.get('/', async (req: AuthRequest, res: Response) => {
    const { status, collectorId } = req.query;

    const where: any = {};
    if (status && status !== 'all') {
      where.transactionStatus = status;
    }
    if (collectorId) {
      where.collectorId = collectorId;
    } else if (req.user?.role === 'collector') {
      where.collectorId = req.user.id;
    }

    const transactions = await prisma.transaction.findMany({
      where,
      include: {
        material: true,
        traceability: true,
        recycler: true
      },
      orderBy: { dateTime: 'desc' }
    });

    const formatted = transactions.map((t) => {
      let timeline: any[] = [];
      let photos: string[] = [];
      try {
        if (t.traceability?.timelineJson) {
          timeline = JSON.parse(t.traceability.timelineJson);
        }
        if (t.traceability?.photosJson) {
          photos = JSON.parse(t.traceability.photosJson);
        }
      } catch {}

      return {
        ...t,
        traceability: t.traceability
          ? {
              ...t.traceability,
              timeline,
              photos
            }
          : undefined
      };
    });

    return res.json(formatted);
  });

  // GET /api/lots/:id - get full lot details and traceability timeline
  router.get('/:id', async (req, res) => {
    const transaction = await prisma.transaction.findUnique({
      where: { id: req.params.id },
      include: {
        material: true,
        traceability: true,
        recycler: true
      }
    });

    if (!transaction) {
      return res.status(404).json({ error: 'Material lot not found.' });
    }

    let timeline: any[] = [];
    let photos: string[] = [];
    try {
      if (transaction.traceability?.timelineJson) {
        timeline = JSON.parse(transaction.traceability.timelineJson);
      }
      if (transaction.traceability?.photosJson) {
        photos = JSON.parse(transaction.traceability.photosJson);
      }
    } catch {}

    return res.json({
      ...transaction,
      traceability: transaction.traceability
        ? {
            ...transaction.traceability,
            timeline,
            photos
          }
        : undefined
    });
  });

  return router;
}
