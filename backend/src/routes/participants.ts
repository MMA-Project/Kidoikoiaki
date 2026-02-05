import { Router, Request, Response } from 'express';
import { getConnection } from '../db/database';
import { CreateParticipantDto } from '../types';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

// GET /api/participants?listId=xxx - Get participants for a list
router.get('/', async (req: Request, res: Response) => {
  try {
    const { listId } = req.query;

    if (!listId) {
      res.status(400).json({ error: 'listId query parameter is required' });
      return;
    }

    const pool = await getConnection();
    const result = await pool.request()
      .input('listId', listId as string)
      .query(`
        SELECT id, listId, name, createdAt
        FROM Participants
        WHERE listId = @listId
        ORDER BY createdAt
      `);

    res.json(result.recordset);
  } catch (error) {
    console.error('Error fetching participants:', error);
    res.status(500).json({ error: 'Failed to fetch participants' });
  }
});

// GET /api/participants/:id - Get a single participant
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    const result = await pool.request()
      .input('id', id)
      .query(`
        SELECT id, listId, name, createdAt
        FROM Participants
        WHERE id = @id
      `);

    if (result.recordset.length === 0) {
      res.status(404).json({ error: 'Participant not found' });
      return;
    }

    res.json(result.recordset[0]);
  } catch (error) {
    console.error('Error fetching participant:', error);
    res.status(500).json({ error: 'Failed to fetch participant' });
  }
});

// POST /api/participants - Create a new participant
router.post('/', async (req: Request, res: Response) => {
  try {
    const { listId, name }: CreateParticipantDto = req.body;

    if (!listId) {
      res.status(400).json({ error: 'listId is required' });
      return;
    }

    if (!name || name.trim() === '') {
      res.status(400).json({ error: 'Name is required' });
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

    const id = uuidv4();

    await pool.request()
      .input('id', id)
      .input('listId', listId)
      .input('name', name.trim())
      .query(`
        INSERT INTO Participants (id, listId, name)
        VALUES (@id, @listId, @name)
      `);

    const result = await pool.request()
      .input('id', id)
      .query(`
        SELECT id, listId, name, createdAt
        FROM Participants
        WHERE id = @id
      `);

    res.status(201).json(result.recordset[0]);
  } catch (error) {
    console.error('Error creating participant:', error);
    res.status(500).json({ error: 'Failed to create participant' });
  }
});

// PUT /api/participants/:id - Update a participant
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    if (!name || name.trim() === '') {
      res.status(400).json({ error: 'Name is required' });
      return;
    }

    const pool = await getConnection();

    await pool.request()
      .input('id', id)
      .input('name', name.trim())
      .query(`
        UPDATE Participants
        SET name = @name
        WHERE id = @id
      `);

    const result = await pool.request()
      .input('id', id)
      .query(`
        SELECT id, listId, name, createdAt
        FROM Participants
        WHERE id = @id
      `);

    if (result.recordset.length === 0) {
      res.status(404).json({ error: 'Participant not found' });
      return;
    }

    res.json(result.recordset[0]);
  } catch (error) {
    console.error('Error updating participant:', error);
    res.status(500).json({ error: 'Failed to update participant' });
  }
});

// DELETE /api/participants/:id - Delete a participant
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    // Check if participant is used in any expense as payer
    const payerCheck = await pool.request()
      .input('id', id)
      .query(`SELECT COUNT(*) as count FROM Expenses WHERE payerId = @id`);

    if (payerCheck.recordset[0].count > 0) {
      res.status(400).json({ 
        error: 'Cannot delete participant who has paid for expenses. Delete the expenses first.' 
      });
      return;
    }

    // Remove from expense participants
    await pool.request()
      .input('id', id)
      .query(`DELETE FROM ExpenseParticipants WHERE participantId = @id`);

    // Delete participant
    const result = await pool.request()
      .input('id', id)
      .query(`DELETE FROM Participants WHERE id = @id`);

    if (result.rowsAffected[0] === 0) {
      res.status(404).json({ error: 'Participant not found' });
      return;
    }

    res.status(204).send();
  } catch (error) {
    console.error('Error deleting participant:', error);
    res.status(500).json({ error: 'Failed to delete participant' });
  }
});

export default router;
