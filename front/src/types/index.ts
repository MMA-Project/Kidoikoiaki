// API Types for Kidoikoiaki

export interface List {
  id: string;
  name: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
}

export interface Participant {
  id: string;
  listId: string;
  name: string;
  createdAt: string;
}

export interface Expense {
  id: string;
  listId: string;
  title: string;
  amount: number;
  payerId: string;
  payerName?: string;
  imageUrl?: string;
  createdAt: string;
  participants: { id: string; name: string }[];
}

export interface Balance {
  participantId: string;
  participantName: string;
  totalPaid: number;
  totalOwed: number;
  balance: number;
}

export interface Transaction {
  from: string;
  fromName: string;
  to: string;
  toName: string;
  amount: number;
}

export interface BalanceSummary {
  listId: string;
  listName: string;
  totalAmount: number;
  participantCount: number;
  expenseCount: number;
  balances: Balance[];
  transactions: Transaction[];
}

export interface ListDetail extends List {
  participants: Participant[];
  expenses: Expense[];
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
  image?: File;
}
