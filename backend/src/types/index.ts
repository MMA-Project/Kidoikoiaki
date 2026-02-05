// Types for the Kidoikoiaki application

export interface List {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Participant {
  id: string;
  listId: string;
  name: string;
  createdAt: Date;
}

export interface Expense {
  id: string;
  listId: string;
  title: string;
  amount: number;
  payerId: string;
  imageUrl?: string;
  createdAt: Date;
  participants?: Participant[];
}

export interface ExpenseParticipant {
  expenseId: string;
  participantId: string;
}

export interface CreateListDto {
  name: string;
  description?: string;
}

export interface CreateParticipantDto {
  listId: string;
  name: string;
}

export interface CreateExpenseDto {
  listId: string;
  title: string;
  amount: number;
  payerId: string;
  participantIds: string[];
  imageUrl?: string;
}

export interface Balance {
  participantId: string;
  participantName: string;
  totalPaid: number;
  totalOwed: number;
  balance: number; // positive = is owed money, negative = owes money
}

export interface Transaction {
  from: string;
  fromName: string;
  to: string;
  toName: string;
  amount: number;
}

export interface ListSummary {
  list: List;
  participants: Participant[];
  expenses: Expense[];
  balances: Balance[];
  transactions: Transaction[];
  totalAmount: number;
}
