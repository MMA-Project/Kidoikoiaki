import dotenv from "dotenv";
dotenv.config();

import sql from "mssql";
import { v4 as uuidv4 } from "uuid";
import { getConnection, initializeDatabase, closeConnection } from "./database";

async function seed() {
  console.log("🌱 Seeding database...");
  await initializeDatabase();

  const pool = await getConnection();
  const transaction = new sql.Transaction(pool);

  await transaction.begin();

  try {
    // Clear tables in correct order
    await new sql.Request(transaction).query(`DELETE FROM ExpenseParticipants`);
    await new sql.Request(transaction).query(`DELETE FROM Expenses`);
    await new sql.Request(transaction).query(`DELETE FROM Participants`);
    await new sql.Request(transaction).query(`DELETE FROM Lists`);

    // Seed Lists
    const list1Id = uuidv4();
    const list2Id = uuidv4();

    await new sql.Request(transaction)
      .input("id", list1Id)
      .input("name", "Weekend Paris")
      .input("description", "Week-end entre amis à Paris")
      .query(
        `INSERT INTO Lists (id, name, description) VALUES (@id, @name, @description)`,
      );

    await new sql.Request(transaction)
      .input("id", list2Id)
      .input("name", "Road Trip Espagne")
      .input("description", "Voyage en voiture sur la côte")
      .query(
        `INSERT INTO Lists (id, name, description) VALUES (@id, @name, @description)`,
      );

    // Seed Participants
    const aliceId = uuidv4();
    const bobId = uuidv4();
    const claraId = uuidv4();
    const marcId = uuidv4();
    const linaId = uuidv4();

    await new sql.Request(transaction)
      .input("id", aliceId)
      .input("listId", list1Id)
      .input("name", "Alice")
      .query(
        `INSERT INTO Participants (id, listId, name) VALUES (@id, @listId, @name)`,
      );

    await new sql.Request(transaction)
      .input("id", bobId)
      .input("listId", list1Id)
      .input("name", "Bob")
      .query(
        `INSERT INTO Participants (id, listId, name) VALUES (@id, @listId, @name)`,
      );

    await new sql.Request(transaction)
      .input("id", claraId)
      .input("listId", list1Id)
      .input("name", "Clara")
      .query(
        `INSERT INTO Participants (id, listId, name) VALUES (@id, @listId, @name)`,
      );

    await new sql.Request(transaction)
      .input("id", marcId)
      .input("listId", list2Id)
      .input("name", "Marc")
      .query(
        `INSERT INTO Participants (id, listId, name) VALUES (@id, @listId, @name)`,
      );

    await new sql.Request(transaction)
      .input("id", linaId)
      .input("listId", list2Id)
      .input("name", "Lina")
      .query(
        `INSERT INTO Participants (id, listId, name) VALUES (@id, @listId, @name)`,
      );

    // Seed Expenses (List 1)
    const expense1Id = uuidv4();
    const expense2Id = uuidv4();
    const expense3Id = uuidv4();

    await new sql.Request(transaction)
      .input("id", expense1Id)
      .input("listId", list1Id)
      .input("title", "Restaurant")
      .input("amount", 78.5)
      .input("category", "food")
      .input("payerId", aliceId)
      .input("imageUrl", null).query(`
        INSERT INTO Expenses (id, listId, title, amount, category, payerId, imageUrl)
        VALUES (@id, @listId, @title, @amount, @category, @payerId, @imageUrl)
      `);

    await new sql.Request(transaction)
      .input("expenseId", expense1Id)
      .input("participantId", aliceId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense1Id)
      .input("participantId", bobId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense1Id)
      .input("participantId", claraId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );

    await new sql.Request(transaction)
      .input("id", expense2Id)
      .input("listId", list1Id)
      .input("title", "Métro")
      .input("amount", 30.2)
      .input("category", "transport")
      .input("payerId", bobId)
      .input("imageUrl", null).query(`
        INSERT INTO Expenses (id, listId, title, amount, category, payerId, imageUrl)
        VALUES (@id, @listId, @title, @amount, @category, @payerId, @imageUrl)
      `);

    await new sql.Request(transaction)
      .input("expenseId", expense2Id)
      .input("participantId", aliceId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense2Id)
      .input("participantId", bobId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );

    await new sql.Request(transaction)
      .input("id", expense3Id)
      .input("listId", list1Id)
      .input("title", "Souvenirs")
      .input("amount", 120.0)
      .input("category", "shopping")
      .input("payerId", claraId)
      .input("imageUrl", null).query(`
        INSERT INTO Expenses (id, listId, title, amount, category, payerId, imageUrl)
        VALUES (@id, @listId, @title, @amount, @category, @payerId, @imageUrl)
      `);

    await new sql.Request(transaction)
      .input("expenseId", expense3Id)
      .input("participantId", aliceId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense3Id)
      .input("participantId", bobId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense3Id)
      .input("participantId", claraId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );

    // Seed Expenses (List 2)
    const expense4Id = uuidv4();
    const expense5Id = uuidv4();

    await new sql.Request(transaction)
      .input("id", expense4Id)
      .input("listId", list2Id)
      .input("title", "Hôtel")
      .input("amount", 200.0)
      .input("category", "accommodation")
      .input("payerId", marcId)
      .input("imageUrl", null).query(`
        INSERT INTO Expenses (id, listId, title, amount, category, payerId, imageUrl)
        VALUES (@id, @listId, @title, @amount, @category, @payerId, @imageUrl)
      `);

    await new sql.Request(transaction)
      .input("expenseId", expense4Id)
      .input("participantId", marcId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense4Id)
      .input("participantId", linaId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );

    await new sql.Request(transaction)
      .input("id", expense5Id)
      .input("listId", list2Id)
      .input("title", "Musée")
      .input("amount", 50.0)
      .input("category", "entertainment")
      .input("payerId", linaId)
      .input("imageUrl", null).query(`
        INSERT INTO Expenses (id, listId, title, amount, category, payerId, imageUrl)
        VALUES (@id, @listId, @title, @amount, @category, @payerId, @imageUrl)
      `);

    await new sql.Request(transaction)
      .input("expenseId", expense5Id)
      .input("participantId", marcId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );
    await new sql.Request(transaction)
      .input("expenseId", expense5Id)
      .input("participantId", linaId)
      .query(
        `INSERT INTO ExpenseParticipants (expenseId, participantId) VALUES (@expenseId, @participantId)`,
      );

    await transaction.commit();
    console.log("✅ Seed completed");
  } catch (error) {
    await transaction.rollback();
    console.error("❌ Seed failed:", error);
    throw error;
  } finally {
    await closeConnection();
  }
}

seed().catch((error) => {
  console.error("❌ Seed failed:", error);
  process.exit(1);
});
