import express, { Request, Response } from "express";
import sqlite3 from "sqlite3";
import { open, Database } from "sqlite";
import path from "path";

const PORT = process.env.PORT ? Number(process.env.PORT) : 4000;
const DB_FILE = process.env.DATABASE_URL ?? "/app/data/database.sqlite";

let db: Database<sqlite3.Database, sqlite3.Statement>;

async function initDb() {
  // Ensure path: if user provided "file:/app/data/database.sqlite", strip "file:" prefix
  const filename = DB_FILE.startsWith("file:") ? DB_FILE.replace(/^file:/, "") : DB_FILE;
  const resolved = path.resolve(filename);

  db = await open({
    filename: resolved,
    driver: sqlite3.Database
  });

  // Example: create a simple users table
  await db.exec(
    `CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`
  );
}

async function startServer() {
  await initDb();
  const app = express();
  app.use(express.json());

  // Healthcheck
  app.get("/health", async (_req: Request, res: Response) => {
    res.json({ status: "ok", service: "dbwriter" });
  });

  // Create user (write) — only dbwriter should write to DB
  app.post("/users", async (req: Request, res: Response) => {
    try {
      const { name } = req.body;
      if (!name || typeof name !== "string") {
        return res.status(400).json({ error: "Missing or invalid 'name' field" });
      }

      const result = await db.run("INSERT INTO users (name) VALUES (?)", [name]);
      const created = await db.get("SELECT * FROM users WHERE id = ?", [result.lastID]);
      res.status(201).json(created);
    } catch (err) {
      console.error("POST /users error:", err);
      res.status(500).json({ error: "Internal server error" });
    }
  });

  // Read users (list)
  app.get("/users", async (_req: Request, res: Response) => {
    try {
      const users = await db.all("SELECT * FROM users ORDER BY id ASC");
      res.json(users);
    } catch (err) {
      console.error("GET /users error:", err);
      res.status(500).json({ error: "Internal server error" });
    }
  });

  // Optional: read single user
  app.get("/users/:id", async (req: Request, res: Response) => {
    const id = Number(req.params.id);
    if (Number.isNaN(id)) return res.status(400).json({ error: "Invalid id" });
    try {
      const user = await db.get("SELECT * FROM users WHERE id = ?", [id]);
      if (!user) return res.status(404).json({ error: "Not found" });
      res.json(user);
    } catch (err) {
      console.error("GET /users/:id error:", err);
      res.status(500).json({ error: "Internal server error" });
    }
  });

  app.listen(PORT, () => {
    console.log(`✅ dbwriter running on port ${PORT} — DB file: ${DB_FILE}`);
  });
}

startServer().catch((err) => {
  console.error("Failed to start dbwriter:", err);
  process.exit(1);
});
