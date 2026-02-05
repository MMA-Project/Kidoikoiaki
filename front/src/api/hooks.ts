import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { listsApi, participantsApi, expensesApi, balancesApi, queryKeys } from './client';
import type { CreateListDto, UpdateListDto, CreateParticipantDto, CreateExpenseDto, UpdateExpenseDto } from '../types';

// Lists Hooks
export function useLists() {
  return useQuery({
    queryKey: queryKeys.lists,
    queryFn: listsApi.getAll,
  });
}

export function useList(id: string) {
  return useQuery({
    queryKey: queryKeys.list(id),
    queryFn: () => listsApi.getById(id),
    enabled: !!id,
  });
}

export function useCreateList() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateListDto) => listsApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}

export function useUpdateList() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateListDto }) => listsApi.update(id, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
      queryClient.invalidateQueries({ queryKey: queryKeys.list(variables.id) });
    },
  });
}

export function useDeleteList() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (id: string) => listsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.lists });
    },
  });
}

// Participants Hooks
export function useParticipants(listId: string) {
  return useQuery({
    queryKey: queryKeys.participants(listId),
    queryFn: () => participantsApi.getByListId(listId),
    enabled: !!listId,
  });
}

export function useCreateParticipant() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateParticipantDto) => participantsApi.create(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.list(variables.listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.participants(variables.listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.balances(variables.listId) });
    },
  });
}

export function useDeleteParticipant(listId: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (id: string) => participantsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.list(listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.participants(listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.balances(listId) });
    },
  });
}

// Expenses Hooks
export function useExpenses(listId: string) {
  return useQuery({
    queryKey: queryKeys.expenses(listId),
    queryFn: () => expensesApi.getByListId(listId),
    enabled: !!listId,
  });
}

export function useCreateExpense() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (data: CreateExpenseDto) => expensesApi.create(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: queryKeys.list(variables.listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.expenses(variables.listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.balances(variables.listId) });
    },
  });
}

export function useUpdateExpense(listId: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateExpenseDto }) => expensesApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.list(listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.expenses(listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.balances(listId) });
    },
  });
}

export function useDeleteExpense(listId: string) {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: (id: string) => expensesApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.list(listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.expenses(listId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.balances(listId) });
    },
  });
}

// Balances Hooks
export function useBalances(listId: string) {
  return useQuery({
    queryKey: queryKeys.balances(listId),
    queryFn: () => balancesApi.getByListId(listId),
    enabled: !!listId,
  });
}
