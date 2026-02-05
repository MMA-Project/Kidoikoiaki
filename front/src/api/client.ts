import { 
  List, 
  ListDetail, 
  Participant, 
  Expense, 
  BalanceSummary,
  CreateListDto,
  CreateParticipantDto,
  CreateExpenseDto
} from '../types';

const API_BASE = 'http://localhost:3001/api';

// Helper function for API calls
async function fetchApi<T>(
  endpoint: string, 
  options?: RequestInit
): Promise<T> {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      ...(options?.body instanceof FormData ? {} : { 'Content-Type': 'application/json' }),
      ...options?.headers,
    },
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: 'An error occurred' }));
    throw new Error(error.error || `HTTP error! status: ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json();
}

// Lists API
export const listsApi = {
  getAll: (): Promise<List[]> => fetchApi<List[]>('/lists'),
  
  getById: (id: string): Promise<ListDetail> => fetchApi<ListDetail>(`/lists/${id}`),
  
  create: (data: CreateListDto): Promise<List> => 
    fetchApi<List>('/lists', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  
  update: (id: string, data: CreateListDto): Promise<List> =>
    fetchApi<List>(`/lists/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
  
  delete: (id: string): Promise<void> =>
    fetchApi<void>(`/lists/${id}`, {
      method: 'DELETE',
    }),
};

// Participants API
export const participantsApi = {
  getByListId: (listId: string): Promise<Participant[]> => 
    fetchApi<Participant[]>(`/participants?listId=${listId}`),
  
  create: (data: CreateParticipantDto): Promise<Participant> =>
    fetchApi<Participant>('/participants', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
  
  update: (id: string, name: string): Promise<Participant> =>
    fetchApi<Participant>(`/participants/${id}`, {
      method: 'PUT',
      body: JSON.stringify({ name }),
    }),
  
  delete: (id: string): Promise<void> =>
    fetchApi<void>(`/participants/${id}`, {
      method: 'DELETE',
    }),
};

// Expenses API
export const expensesApi = {
  getByListId: (listId: string): Promise<Expense[]> =>
    fetchApi<Expense[]>(`/expenses?listId=${listId}`),
  
  getById: (id: string): Promise<Expense> =>
    fetchApi<Expense>(`/expenses/${id}`),
  
  create: (data: CreateExpenseDto): Promise<Expense> => {
    const formData = new FormData();
    formData.append('listId', data.listId);
    formData.append('title', data.title);
    formData.append('amount', data.amount.toString());
    formData.append('payerId', data.payerId);
    formData.append('participantIds', JSON.stringify(data.participantIds));
    
    if (data.image) {
      formData.append('image', data.image);
    }

    return fetchApi<Expense>('/expenses', {
      method: 'POST',
      body: formData,
    });
  },
  
  delete: (id: string): Promise<void> =>
    fetchApi<void>(`/expenses/${id}`, {
      method: 'DELETE',
    }),
};

// Balances API
export const balancesApi = {
  getByListId: (listId: string): Promise<BalanceSummary> =>
    fetchApi<BalanceSummary>(`/balances/${listId}`),
};

// Query Keys
export const queryKeys = {
  lists: ['lists'] as const,
  list: (id: string) => ['lists', id] as const,
  participants: (listId: string) => ['participants', listId] as const,
  expenses: (listId: string) => ['expenses', listId] as const,
  balances: (listId: string) => ['balances', listId] as const,
};
