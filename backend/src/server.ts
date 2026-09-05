import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import { PrismaClient } from '@prisma/client';

import { authenticateJWT } from './middleware/auth';
import { createAuthRouter } from './routes/auth';
import { createLotsRouter } from './routes/lots';
import { createPricesRouter } from './routes/prices';
import { createRecyclersRouter } from './routes/recyclers';
import { createTransactionsRouter } from './routes/transactions';
import { createEarningsRouter } from './routes/earnings';
import { createAdminRouter } from './routes/admin';
import { createAiRouter } from './routes/ai';
import { createSyncRouter } from './routes/sync';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 5000;

// Enable CORS for frontend web apps & mobile/emulator access
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-dhatu-client']
  })
);

app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ extended: true, limit: '20mb' }));

// Static uploads directory
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
app.use('/uploads', express.static(uploadsDir));

// Attach JWT auth middleware globally (populates req.user if token present)
app.use(authenticateJWT);

// API Health Check
app.get('/api/health', (_req, res) => {
  res.json({
    status: 'healthy',
    platform: 'Dhatu E-Waste Recycling Platform',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    dataMaturityPolicy: 'All records carry explicit dataMaturity tag (demo | synthetic | field_collected | verified)'
  });
});

// API Routes
app.use('/api/auth', createAuthRouter(prisma));
app.use('/api/lots', createLotsRouter(prisma));
app.use('/api/prices', createPricesRouter(prisma));
app.use('/api/recyclers', createRecyclersRouter(prisma));
app.use('/api/transactions', createTransactionsRouter(prisma));
app.use('/api/earnings', createEarningsRouter(prisma));
app.use('/api/admin', createAdminRouter(prisma));
app.use('/api/ai', createAiRouter(prisma));
app.use('/api/sync', createSyncRouter(prisma));

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: 'Endpoint not found.' });
});

// Error handling middleware
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('Server error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`[Dhatu Backend] Server running on http://localhost:${PORT}`);
    console.log(`[Dhatu Backend] Data maturity standard active.`);
  });
}

export { app, prisma };
