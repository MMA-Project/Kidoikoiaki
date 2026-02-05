import { Router, Request, Response } from 'express';
import { getConnection } from '../db/database';
import { CreateListDto, List } from '../types';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

// GET /api/lists - Get all lists
router.get('/', async (req: Request, res: Response) => {
  try {
    const pool = await getConnection();
    const result = await pool.request().query(`
      SELECT id, name, description, createdAt, updatedAt
      FROM Lists
      ORDER BY createdAt DESC
    `);
    res.json(result.recordset);
  } catch (error) {
    console.error('Error fetching lists:', error);
    res.status(500).json({ error: 'Failed to fetch lists' });
  }
});

// GET /api/lists/:id - Get a single list with details
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    // Get the list
    const listResult = await pool.request()
      .input('id', id)
      .query(`
        SELECT id, name, description, createdAt, updatedAt
        FROM Lists
        WHERE id = @id
      `);

    if (listResult.recordset.length === 0) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    const list = listResult.recordset[0];

    // Get participants
    const participantsResult = await pool.request()
      .input('listId', id)
      .query(`
        SELECT id, listId, name, createdAt
        FROM Participants
        WHERE listId = @listId
        ORDER BY createdAt
      `);

    // Get expenses with participants
    const expensesResult = await pool.request()
      .input('listId', id)
      .query(`
        SELECT 
          e.id, e.listId, e.title, e.amount, e.category, e.payerId, e.imageUrl, e.createdAt,
          p.name as payerName
        FROM Expenses e
        LEFT JOIN Participants p ON e.payerId = p.id
        WHERE e.listId = @listId
        ORDER BY e.createdAt DESC
      `);

    // Get expense participants for each expense
    const expenses = await Promise.all(
      expensesResult.recordset.map(async (expense: any) => {
        const expenseParticipantsResult = await pool.request()
          .input('expenseId', expense.id)
          .query(`
            SELECT p.id, p.name
            FROM ExpenseParticipants ep
            JOIN Participants p ON ep.participantId = p.id
            WHERE ep.expenseId = @expenseId
          `);
        return {
          ...expense,
          participants: expenseParticipantsResult.recordset,
        };
      })
    );

    res.json({
      ...list,
      participants: participantsResult.recordset,
      expenses,
    });
  } catch (error) {
    console.error('Error fetching list:', error);
    res.status(500).json({ error: 'Failed to fetch list' });
  }
});

// POST /api/lists - Create a new list
router.post('/', async (req: Request, res: Response) => {
  try {
    const { name, description }: CreateListDto = req.body;

    if (!name || name.trim() === '') {
      res.status(400).json({ error: 'Name is required' });
      return;
    }

    const id = uuidv4();
    const pool = await getConnection();

    await pool.request()
      .input('id', id)
      .input('name', name.trim())
      .input('description', description?.trim() || null)
      .query(`
        INSERT INTO Lists (id, name, description)
        VALUES (@id, @name, @description)
      `);

    const result = await pool.request()
      .input('id', id)
      .query(`
        SELECT id, name, description, createdAt, updatedAt
        FROM Lists
        WHERE id = @id
      `);

    res.status(201).json(result.recordset[0]);
  } catch (error) {
    console.error('Error creating list:', error);
    res.status(500).json({ error: 'Failed to create list' });
  }
});

// PUT /api/lists/:id - Update a list
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, description }: CreateListDto = req.body;

    if (!name || name.trim() === '') {
      res.status(400).json({ error: 'Name is required' });
      return;
    }

    const pool = await getConnection();

    await pool.request()
      .input('id', id)
      .input('name', name.trim())
      .input('description', description?.trim() || null)
      .query(`
        UPDATE Lists
        SET name = @name, description = @description, updatedAt = GETDATE()
        WHERE id = @id
      `);

    const result = await pool.request()
      .input('id', id)
      .query(`
        SELECT id, name, description, createdAt, updatedAt
        FROM Lists
        WHERE id = @id
      `);

    if (result.recordset.length === 0) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    res.json(result.recordset[0]);
  } catch (error) {
    console.error('Error updating list:', error);
    res.status(500).json({ error: 'Failed to update list' });
  }
});

// DELETE /api/lists/:id - Delete a list
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    const result = await pool.request()
      .input('id', id)
      .query(`DELETE FROM Lists WHERE id = @id`);

    if (result.rowsAffected[0] === 0) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    res.status(204).send();
  } catch (error) {
    console.error('Error deleting list:', error);
    res.status(500).json({ error: 'Failed to delete list' });
  }
});

export default router;
