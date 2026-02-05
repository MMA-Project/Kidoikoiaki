import { Router, Request, Response } from 'express';
import { getConnection } from '../db/database';
import { calculateBalances, calculateOptimalTransactions } from '../services/balanceService';

const router = Router();

// GET /api/balances/:listId - Get balances and transactions for a list
router.get('/:listId', async (req: Request, res: Response) => {
  try {
    const { listId } = req.params;
    const pool = await getConnection();

    // Verify the list exists
    const listCheck = await pool.request()
      .input('listId', listId)
      .query(`SELECT id, name FROM Lists WHERE id = @listId`);

    if (listCheck.recordset.length === 0) {
      res.status(404).json({ error: 'List not found' });
      return;
    }

    // Get all participants
    const participantsResult = await pool.request()
      .input('listId', listId)
      .query(`
        SELECT id, name
        FROM Participants
        WHERE listId = @listId
      `);

    const participants = participantsResult.recordset;

    // Get all expenses with their participants
    const expensesResult = await pool.request()
      .input('listId', listId)
      .query(`
        SELECT e.id, e.amount, e.payerId
        FROM Expenses e
        WHERE e.listId = @listId
      `);

    // Get expense participants for each expense
    const expenses = await Promise.all(
      expensesResult.recordset.map(async (expense: any) => {
        const participantsResult = await pool.request()
          .input('expenseId', expense.id)
          .query(`
            SELECT participantId
            FROM ExpenseParticipants
            WHERE expenseId = @expenseId
          `);
        return {
          ...expense,
          participantIds: participantsResult.recordset.map((p: any) => p.participantId),
        };
      })
    );

    // Calculate balances
    const balances = calculateBalances(participants, expenses);

    // Calculate optimal transactions
    const transactions = calculateOptimalTransactions(balances);

    // Calculate total amount spent
    const totalAmount = expenses.reduce((sum: number, e: any) => sum + parseFloat(e.amount), 0);

    res.json({
      listId,
      listName: listCheck.recordset[0].name,
      totalAmount: Math.round(totalAmount * 100) / 100,
      participantCount: participants.length,
      expenseCount: expenses.length,
      balances,
      transactions,
    });
  } catch (error) {
    console.error('Error calculating balances:', error);
    res.status(500).json({ error: 'Failed to calculate balances' });
  }
});

export default router;
