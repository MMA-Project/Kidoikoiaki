import { Router, Request, Response } from 'express';
import multer from 'multer';
import { getConnection } from '../db/database';
import { uploadImage, deleteImage } from '../blob/blobService';
import { CreateExpenseDto } from '../types';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

// Configure multer for file upload
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed.'));
    }
  },
});

// GET /api/expenses?listId=xxx - Get expenses for a list
router.get('/', async (req: Request, res: Response) => {
  try {
    const { listId } = req.query;

    if (!listId) {
      res.status(400).json({ error: 'listId query parameter is required' });
      return;
    }

    const pool = await getConnection();

    const expensesResult = await pool.request()
      .input('listId', listId as string)
      .query(`
        SELECT 
          e.id, e.listId, e.title, e.amount, e.payerId, e.imageUrl, e.createdAt,
          p.name as payerName
        FROM Expenses e
        LEFT JOIN Participants p ON e.payerId = p.id
        WHERE e.listId = @listId
        ORDER BY e.createdAt DESC
      `);

    // Get participants for each expense
    const expenses = await Promise.all(
      expensesResult.recordset.map(async (expense: any) => {
        const participantsResult = await pool.request()
          .input('expenseId', expense.id)
          .query(`
            SELECT p.id, p.name
            FROM ExpenseParticipants ep
            JOIN Participants p ON ep.participantId = p.id
            WHERE ep.expenseId = @expenseId
          `);
        return {
          ...expense,
          participants: participantsResult.recordset,
        };
      })
    );

    res.json(expenses);
  } catch (error) {
    console.error('Error fetching expenses:', error);
    res.status(500).json({ error: 'Failed to fetch expenses' });
  }
});

// GET /api/expenses/:id - Get a single expense
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    const expenseResult = await pool.request()
      .input('id', id)
      .query(`
        SELECT 
          e.id, e.listId, e.title, e.amount, e.payerId, e.imageUrl, e.createdAt,
          p.name as payerName
        FROM Expenses e
        LEFT JOIN Participants p ON e.payerId = p.id
        WHERE e.id = @id
      `);

    if (expenseResult.recordset.length === 0) {
      res.status(404).json({ error: 'Expense not found' });
      return;
    }

    const expense = expenseResult.recordset[0];

    // Get participants
    const participantsResult = await pool.request()
      .input('expenseId', id)
      .query(`
        SELECT p.id, p.name
        FROM ExpenseParticipants ep
        JOIN Participants p ON ep.participantId = p.id
        WHERE ep.expenseId = @expenseId
      `);

    res.json({
      ...expense,
      participants: participantsResult.recordset,
    });
  } catch (error) {
    console.error('Error fetching expense:', error);
    res.status(500).json({ error: 'Failed to fetch expense' });
  }
});

// POST /api/expenses - Create a new expense
router.post('/', upload.single('image'), async (req: Request, res: Response) => {
  try {
    const { listId, title, amount, payerId, participantIds } = req.body;

    // Parse participantIds if it's a string (from FormData)
    let parsedParticipantIds: string[];
    if (typeof participantIds === 'string') {
      try {
        parsedParticipantIds = JSON.parse(participantIds);
      } catch {
        parsedParticipantIds = participantIds.split(',').filter(Boolean);
      }
    } else {
      parsedParticipantIds = participantIds || [];
    }

    // Validation
    if (!listId) {
      res.status(400).json({ error: 'listId is required' });
      return;
    }
    if (!title || title.trim() === '') {
      res.status(400).json({ error: 'Title is required' });
      return;
    }
    if (!amount || isNaN(parseFloat(amount)) || parseFloat(amount) <= 0) {
      res.status(400).json({ error: 'Valid positive amount is required' });
      return;
    }
    if (!payerId) {
      res.status(400).json({ error: 'payerId is required' });
      return;
    }
    if (!parsedParticipantIds || parsedParticipantIds.length === 0) {
      res.status(400).json({ error: 'At least one participant is required' });
      return;
    }

    const pool = await getConnection();

    // Verify the list exists
    const listCheck = await pool.request()
      .input('listId', listId)
      .query(`SELECT id FROM Lists WHERE id = @listId`);

    if (listCheck.recordset.length === 0) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    // Verify payer exists
    const payerCheck = await pool.request()
      .input('payerId', payerId)
      .query(`SELECT id FROM Participants WHERE id = @payerId`);

    if (payerCheck.recordset.length === 0) {
      res.status(404).json({ error: 'Payer not found' });
      return;
    }

    // Upload image if provided
    let imageUrl: string | null = null;
    if (req.file) {
      imageUrl = await uploadImage(
        req.file.buffer,
        req.file.originalname,
        req.file.mimetype
      );
    }

    const id = uuidv4();

    // Create expense
    await pool.request()
      .input('id', id)
      .input('listId', listId)
      .input('title', title.trim())
      .input('amount', parseFloat(amount))
      .input('payerId', payerId)
      .input('imageUrl', imageUrl)
      .query(`
        INSERT INTO Expenses (id, listId, title, amount, payerId, imageUrl)
        VALUES (@id, @listId, @title, @amount, @payerId, @imageUrl)
      `);

    // Add expense participants
    for (const participantId of parsedParticipantIds) {
      await pool.request()
        .input('expenseId', id)
        .input('participantId', participantId)
        .query(`
          INSERT INTO ExpenseParticipants (expenseId, participantId)
          VALUES (@expenseId, @participantId)
        `);
    }

    // Fetch and return the created expense
    const result = await pool.request()
      .input('id', id)
      .query(`
        SELECT 
          e.id, e.listId, e.title, e.amount, e.payerId, e.imageUrl, e.createdAt,
          p.name as payerName
        FROM Expenses e
        LEFT JOIN Participants p ON e.payerId = p.id
        WHERE e.id = @id
      `);

    const participantsResult = await pool.request()
      .input('expenseId', id)
      .query(`
        SELECT p.id, p.name
        FROM ExpenseParticipants ep
        JOIN Participants p ON ep.participantId = p.id
        WHERE ep.expenseId = @expenseId
      `);

    res.status(201).json({
      ...result.recordset[0],
      participants: participantsResult.recordset,
    });
  } catch (error) {
    console.error('Error creating expense:', error);
    res.status(500).json({ error: 'Failed to create expense' });
  }
});

// DELETE /api/expenses/:id - Delete an expense
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    // Get the expense to check for image
    const expense = await pool.request()
      .input('id', id)
      .query(`SELECT imageUrl FROM Expenses WHERE id = @id`);

    if (expense.recordset.length === 0) {
      res.status(404).json({ error: 'Expense not found' });
      return;
    }

    // Delete image from blob storage if exists
    if (expense.recordset[0].imageUrl) {
      try {
        await deleteImage(expense.recordset[0].imageUrl);
      } catch (error) {
        console.error('Error deleting image from blob:', error);
        // Continue with expense deletion even if blob deletion fails
      }
    }

    // Delete expense (cascade will delete ExpenseParticipants)
    await pool.request()
      .input('id', id)
      .query(`DELETE FROM Expenses WHERE id = @id`);

    res.status(204).send();
  } catch (error) {
    console.error('Error deleting expense:', error);
    res.status(500).json({ error: 'Failed to delete expense' });
  }
});

export default router;
