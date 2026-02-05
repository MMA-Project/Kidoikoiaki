// API Types for Kidoikoiaki

// Expense Categories with icons
export const EXPENSE_CATEGORIES = {
  food: { label: 'Nourriture', icon: '🍽️' },
  transport: { label: 'Transport', icon: '🚗' },
  accommodation: { label: 'Hébergement', icon: '🏨' },
  entertainment: { label: 'Loisirs', icon: '🎉' },
  shopping: { label: 'Shopping', icon: '🛒' },
  health: { label: 'Santé', icon: '💊' },
  utilities: { label: 'Services', icon: '💡' },
  other: { label: 'Autre', icon: '📦' },
} as const;

export type ExpenseCategory = keyof typeof EXPENSE_CATEGORIES;

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
  category: ExpenseCategory;
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

export interface UpdateListDto {
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
  category: ExpenseCategory;
  payerId: string;
  participantIds: string[];
  image?: File;
}

export interface UpdateExpenseDto {
  title: string;
  amount: number;
  category: ExpenseCategory;
  payerId: string;
  participantIds: string[];
}
