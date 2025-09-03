import Fastify from 'fastify';
import sqlite3 from 'sqlite3';
import { open } from 'sqlite';
import path from 'path';
import { fileURLToPath } from 'url';

// Calculer __dirname en ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Fastify avec logger simple
const fastify = Fastify({
  logger: true
});

// Définir le chemin de la base SQLite
const dbPath = path.join(__dirname, '../data/database.sqlite');

let db: sqlite3.Database;

// Route test
fastify.get('/', async () => {
  return { status: 'ok', message: 'Fastify backend is running!' };
});

const start = async () => {
  try {
    db = await open({
      filename: dbPath,
      driver: sqlite3.Database
    });

    await db.exec('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT)');

    const address = await fastify.listen({ port: 3000, host: '0.0.0.0' });
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
