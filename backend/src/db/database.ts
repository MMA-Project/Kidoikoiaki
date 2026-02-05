import sql, { ConnectionPool, config as SqlConfig } from 'mssql';
import { AzureCliCredential } from '@azure/identity';

let pool: ConnectionPool | null = null;

export async function getConnection(): Promise<ConnectionPool> {
  if (pool) {
    return pool;
  }

  const credential = new AzureCliCredential({
    tenantId: undefined,
  });
  
  const tokenResponse = await credential.getToken('https://database.windows.net/.default');

  const config: SqlConfig = {
    server: process.env.AZURE_SQL_SERVER!,
    database: process.env.AZURE_SQL_DATABASE!,
    authentication: {
      type: 'azure-active-directory-access-token',
      options: { 
        token: tokenResponse.token 
      },
    },
    options: {
      encrypt: true,
      trustServerCertificate: false,
    },
  };

  pool = await sql.connect(config);
  return pool;
}

export async function initializeDatabase(): Promise<void> {
  const connection = await getConnection();
  
  // Create Lists table
  await connection.request().query(`
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Lists' AND xtype='U')
    CREATE TABLE Lists (
      id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
      name NVARCHAR(255) NOT NULL,
      description NVARCHAR(MAX),
      createdAt DATETIME2 DEFAULT GETDATE(),
      updatedAt DATETIME2 DEFAULT GETDATE()
    )
  `);

  // Create Participants table
  await connection.request().query(`
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Participants' AND xtype='U')
    CREATE TABLE Participants (
      id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
      listId UNIQUEIDENTIFIER NOT NULL,
      name NVARCHAR(255) NOT NULL,
      createdAt DATETIME2 DEFAULT GETDATE(),
      FOREIGN KEY (listId) REFERENCES Lists(id) ON DELETE CASCADE
    )
  `);

  // Create Expenses table
  await connection.request().query(`
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Expenses' AND xtype='U')
    CREATE TABLE Expenses (
      id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
      listId UNIQUEIDENTIFIER NOT NULL,
      title NVARCHAR(255) NOT NULL,
      amount DECIMAL(10, 2) NOT NULL,
      category NVARCHAR(50) DEFAULT 'other',
      payerId UNIQUEIDENTIFIER NOT NULL,
      imageUrl NVARCHAR(MAX),
      createdAt DATETIME2 DEFAULT GETDATE(),
      FOREIGN KEY (listId) REFERENCES Lists(id) ON DELETE CASCADE,
      FOREIGN KEY (payerId) REFERENCES Participants(id)
    )
  `);

  // Add category column if it doesn't exist (migration for existing tables)
  await connection.request().query(`
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Expenses') AND name = 'category')
    ALTER TABLE Expenses ADD category NVARCHAR(50) DEFAULT 'other'
  `);

  // Create ExpenseParticipants junction table
  await connection.request().query(`
    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='ExpenseParticipants' AND xtype='U')
    CREATE TABLE ExpenseParticipants (
      expenseId UNIQUEIDENTIFIER NOT NULL,
      participantId UNIQUEIDENTIFIER NOT NULL,
      PRIMARY KEY (expenseId, participantId),
      FOREIGN KEY (expenseId) REFERENCES Expenses(id) ON DELETE CASCADE,
      FOREIGN KEY (participantId) REFERENCES Participants(id)
    )
  `);

  console.log('📊 Database tables created/verified');
}

export async function closeConnection(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
  }
}
