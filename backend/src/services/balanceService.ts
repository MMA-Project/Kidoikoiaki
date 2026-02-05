import { Balance, Transaction } from '../types';

/**
 * Calculate optimal transactions to settle debts
 * Uses a greedy algorithm to minimize the number of transactions
 */
export function calculateOptimalTransactions(balances: Balance[]): Transaction[] {
  // Create a copy of balances with only non-zero amounts
  const debtors: { id: string; name: string; amount: number }[] = [];
  const creditors: { id: string; name: string; amount: number }[] = [];

  for (const balance of balances) {
    if (balance.balance < -0.01) {
      // This person owes money (debtor)
      debtors.push({
        id: balance.participantId,
        name: balance.participantName,
        amount: Math.abs(balance.balance),
      });
    } else if (balance.balance > 0.01) {
      // This person is owed money (creditor)
      creditors.push({
        id: balance.participantId,
        name: balance.participantName,
        amount: balance.balance,
      });
    }
  }

  // Sort by amount (descending) to optimize transaction count
  debtors.sort((a, b) => b.amount - a.amount);
  creditors.sort((a, b) => b.amount - a.amount);

  const transactions: Transaction[] = [];

  // Greedy algorithm: match largest debtor with largest creditor
  let i = 0;
  let j = 0;

  while (i < debtors.length && j < creditors.length) {
    const debtor = debtors[i];
    const creditor = creditors[j];

    const amount = Math.min(debtor.amount, creditor.amount);

    if (amount > 0.01) {
      transactions.push({
        from: debtor.id,
        fromName: debtor.name,
        to: creditor.id,
        toName: creditor.name,
        amount: Math.round(amount * 100) / 100, // Round to 2 decimal places
      });
    }

    debtor.amount -= amount;
    creditor.amount -= amount;

    if (debtor.amount < 0.01) {
      i++;
    }
    if (creditor.amount < 0.01) {
      j++;
    }
  }

  return transactions;
}

/**
 * Calculate the balance for each participant in a list
 */
export function calculateBalances(
  participants: { id: string; name: string }[],
  expenses: { payerId: string; amount: number; participantIds: string[] }[]
): Balance[] {
  // Initialize balances for all participants
  const balanceMap = new Map<string, { paid: number; owed: number; name: string }>();

  for (const participant of participants) {
    balanceMap.set(participant.id, {
      paid: 0,
      owed: 0,
      name: participant.name,
    });
  }

  // Process each expense
  for (const expense of expenses) {
    // Add to payer's "paid" amount
    const payerBalance = balanceMap.get(expense.payerId);
    if (payerBalance) {
      payerBalance.paid += expense.amount;
    }

    // Calculate share for each participant
    const sharePerPerson = expense.amount / expense.participantIds.length;

    // Add to each participant's "owed" amount
    for (const participantId of expense.participantIds) {
      const participantBalance = balanceMap.get(participantId);
      if (participantBalance) {
        participantBalance.owed += sharePerPerson;
      }
    }
  }

  // Convert to Balance array
  const balances: Balance[] = [];

  for (const [participantId, data] of balanceMap) {
    balances.push({
      participantId,
      participantName: data.name,
      totalPaid: Math.round(data.paid * 100) / 100,
      totalOwed: Math.round(data.owed * 100) / 100,
      balance: Math.round((data.paid - data.owed) * 100) / 100,
    });
  }

  return balances;
}
