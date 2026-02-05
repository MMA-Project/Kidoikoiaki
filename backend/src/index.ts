import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import cors from 'cors';
import { initializeDatabase } from './db/database';
import listsRouter from './routes/lists';
import participantsRouter from './routes/participants';
import expensesRouter from './routes/expenses';
import balancesRouter from './routes/balances';
import imagesRouter from './routes/images';

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/lists', listsRouter);
app.use('/api/participants', participantsRouter);
app.use('/api/expenses', expensesRouter);
app.use('/api/balances', balancesRouter);
app.use('/api/images', imagesRouter);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Initialize database and start server
async function startServer() {
  try {
    console.log('🔄 Initializing database...');
    await initializeDatabase();
    console.log('✅ Database initialized');
    
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
