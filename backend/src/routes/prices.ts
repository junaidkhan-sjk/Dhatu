import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

export function createPricesRouter(prisma: PrismaClient) {
  const router = Router();

  // GET /api/prices/board - current price board with latest averages by material
  router.get('/board', async (req, res) => {
    const { locationArea } = req.query;

    const categories = ['PCB', 'Battery', 'Cable', 'CRT', 'Motor'];
    const board = await Promise.all(
      categories.map(async (cat) => {
        const records = await prisma.priceRecord.findMany({
          where: {
            materialCategory: cat
          },
          orderBy: {
            dateTime: 'desc'
          },
          take: 10
        });

        if (records.length === 0) {
          const defaults: Record<string, { price: number; trend: string }> = {
            PCB: { price: 135, trend: '+4%' },
            Battery: { price: 85, trend: '+2%' },
            Cable: { price: 240, trend: '+6%' },
            CRT: { price: 35, trend: '0%' },
            Motor: { price: 195, trend: '+3%' }
          };
          const def = defaults[cat] || { price: 100, trend: '0%' };
          return {
            category: cat,
            currentRateInrPerKg: def.price,
            minRateInrPerKg: Math.round(def.price * 0.9),
            maxRateInrPerKg: Math.round(def.price * 1.1),
            trendPercent: def.trend,
            sampleSize: 0,
            lastUpdated: new Date().toISOString(),
            dataMaturity: 'synthetic'
          };
        }

        const prices = records.map((r) => r.buyingPriceInr);
        const avg = Math.round((prices.reduce((a, b) => a + b, 0) / prices.length) * 10) / 10;
        const min = Math.min(...prices);
        const max = Math.max(...prices);

        return {
          category: cat,
          currentRateInrPerKg: avg,
          minRateInrPerKg: min,
          maxRateInrPerKg: max,
          trendPercent: '+3.5%',
          sampleSize: records.length,
          lastUpdated: records[0].dateTime.toISOString(),
          dataMaturity: records[0].dataMaturity
        };
      })
    );

    return res.json({
      board,
      location: locationArea || 'Maharashtra / All India Markets',
      currency: 'INR',
      dataMaturity: 'synthetic'
    });
  });

  // GET /api/prices/history - 7d / 30d / 90d historical price points for charting
  router.get('/history', async (req, res) => {
    const category = (req.query.category as string) || 'PCB';
    const range = (req.query.range as string) || '30d'; // 7d, 30d, 90d

    const days = range === '7d' ? 7 : range === '90d' ? 90 : 30;
    const since = new Date();
    since.setDate(since.getDate() - days);

    const records = await prisma.priceRecord.findMany({
      where: {
        materialCategory: category,
        dateTime: {
          gte: since
        }
      },
      orderBy: {
        dateTime: 'asc'
      }
    });

    // If records found, format into date points
    const points = records.map((r) => ({
      date: r.dateTime.toISOString().split('T')[0],
      priceInr: r.buyingPriceInr,
      quotedPriceInr: r.quotedPriceInr,
      area: r.areaName,
      dataMaturity: r.dataMaturity
    }));

    return res.json({
      category,
      range,
      points,
      count: points.length,
      dataMaturity: 'synthetic'
    });
  });

  // POST /api/prices/record - add new price record (admin or aggregator)
  router.post('/record', async (req, res) => {
    const {
      materialCategory,
      locationLat,
      locationLng,
      areaName,
      buyingPriceInr,
      quotedPriceInr,
      unit,
      recyclerOrAggregatorId,
      recyclerName
    } = req.body;

    const record = await prisma.priceRecord.create({
      data: {
        materialCategory,
        locationLat: parseFloat(locationLat || 19.076),
        locationLng: parseFloat(locationLng || 72.8777),
        areaName: areaName || 'Mumbai Central Yard',
        buyingPriceInr: parseFloat(buyingPriceInr),
        quotedPriceInr: parseFloat(quotedPriceInr || buyingPriceInr),
        unit: unit || 'per_kg',
        recyclerOrAggregatorId: recyclerOrAggregatorId || 'agg-001',
        recyclerName: recyclerName || 'Authorized Yard',
        dataMaturity: 'synthetic'
      }
    });

    return res.status(201).json(record);
  });

  return router;
}
