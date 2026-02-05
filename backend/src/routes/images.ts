import { Router, Request, Response } from 'express';
import { getImageBuffer } from '../blob/blobService';

const router = Router();

// GET /api/images/:blobPath(*) - Serve image from blob storage
router.get('/*', async (req: Request, res: Response) => {
  try {
    const blobName = req.params[0];
    
    if (!blobName) {
      res.status(400).json({ error: 'Blob path is required' });
      return;
    }

    const { buffer, contentType } = await getImageBuffer(blobName);
    
    res.setHeader('Content-Type', contentType);
    res.setHeader('Cache-Control', 'public, max-age=31536000'); // Cache for 1 year
    res.send(buffer);
  } catch (error) {
    console.error('Error serving image:', error);
    res.status(404).json({ error: 'Image not found' });
  }
});

export default router;
