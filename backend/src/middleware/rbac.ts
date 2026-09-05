import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth';

export function requireRole(...allowedRoles: Array<'collector' | 'recycler' | 'admin'>) {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required.' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        error: `Access denied. Role '${req.user.role}' is not authorized to access this resource. Required: ${allowedRoles.join(', ')}.`
      });
    }

    return next();
  };
}
