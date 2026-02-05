import { useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import ListsPage from './pages/ListsPage';
import ListDetailPage from './pages/ListDetailPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60, // 1 minute
      retry: 1,
    },
  },
});

function AppContent() {
  const [selectedListId, setSelectedListId] = useState<string | null>(null);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      {selectedListId ? (
        <ListDetailPage 
          listId={selectedListId} 
          onBack={() => setSelectedListId(null)} 
        />
      ) : (
        <ListsPage onSelectList={setSelectedListId} />
      )}
    </div>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AppContent />
    </QueryClientProvider>
  );
}

export default App;
