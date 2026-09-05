import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { classifyMaterialImage, KNOWN_MATERIAL_CATEGORIES } from '../services/ai-classifier';
import { estimateMaterialValue } from '../services/value-estimation';

export function createAiRouter(prisma: PrismaClient) {
  const router = Router();

  // POST /api/ai/classify
  router.post('/classify', (req, res) => {
    const { imageHint, explicitCategory } = req.body;
    const result = classifyMaterialImage(imageHint || 'sample_pcb.jpg', explicitCategory);
    return res.json(result);
  });

  // GET /api/ai/categories
  router.get('/categories', (req, res) => {
    return res.json(KNOWN_MATERIAL_CATEGORIES);
  });

  // POST /api/ai/estimate-value
  router.post('/estimate-value', async (req, res) => {
    const { category, weightKg, locationArea } = req.body;
    if (!category || !weightKg) {
      return res.status(400).json({ error: 'category and weightKg are required.' });
    }

    const result = await estimateMaterialValue(
      prisma,
      category,
      parseFloat(weightKg),
      locationArea
    );

    return res.json(result);
  });

  return router;
}
