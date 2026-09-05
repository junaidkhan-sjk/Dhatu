import { Router, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, generateToken, requireAuth } from '../middleware/auth';

export function createAuthRouter(prisma: PrismaClient) {
  const router = Router();

  // POST /api/auth/send-otp
  router.post('/send-otp', async (req, res) => {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ error: 'Phone number is required.' });
    }

    // In dev / hackathon mode, standard OTP is 123456
    return res.json({
      success: true,
      message: 'OTP sent successfully to ' + phone,
      debugOtp: '123456'
    });
  });

  // POST /api/auth/verify-otp
  router.post('/verify-otp', async (req, res) => {
    const { phone, otp, role, name, language } = req.body;

    if (!phone || !otp) {
      return res.status(400).json({ error: 'Phone and OTP are required.' });
    }

    // Verify OTP (123456 in dev/demo)
    if (otp !== '123456') {
      return res.status(400).json({ error: 'Invalid OTP code. For demo, use 123456.' });
    }

    // Find or create user
    let user = await prisma.user.findUnique({
      where: { phone }
    });

    if (!user) {
      const defaultNames: Record<string, string> = {
        collector: 'Ramesh (कबाड़ी)',
        recycler: 'EcoMetals Authorized Yard',
        admin: 'Dhatu Platform Admin'
      };

      user = await prisma.user.create({
        data: {
          phone,
          name: name || defaultNames[role || 'collector'] || 'Dhatu User',
          role: role || 'collector',
          language: language || 'hi',
          dataMaturity: 'demo'
        }
      });
    }

    const tokenPayload = {
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role as 'collector' | 'recycler' | 'admin',
      language: user.language,
      recyclerId: user.recyclerId || undefined
    };

    const token = generateToken(tokenPayload);

    return res.json({
      token,
      user: tokenPayload
    });
  });

  // GET /api/auth/me
  router.get('/me', requireAuth, async (req: AuthRequest, res: Response) => {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.id }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found.' });
    }

    return res.json({
      id: user.id,
      phone: user.phone,
      name: user.name,
      role: user.role,
      language: user.language,
      recyclerId: user.recyclerId,
      dataMaturity: user.dataMaturity
    });
  });

  // POST /api/auth/update-language
  router.post('/update-language', requireAuth, async (req: AuthRequest, res: Response) => {
    const { language } = req.body;
    if (!['en', 'hi', 'mr'].includes(language)) {
      return res.status(400).json({ error: 'Language must be one of en, hi, mr.' });
    }

    const updated = await prisma.user.update({
      where: { id: req.user!.id },
      data: { language }
    });

    return res.json({ success: true, language: updated.language });
  });

  return router;
}
