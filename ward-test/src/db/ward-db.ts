import { MongoClient, Db } from "mongodb";
import "dotenv/config";

export let client: MongoClient;
export let db: Db;

const mongoUrl = process.env.MONGODB_URL as string;
const dbName = "ward";

export const connectWardDB = async () => {
  if (!client) {
    client = new MongoClient(mongoUrl);
    await client.connect();
  }
  db = client.db(dbName);
  return { client, db };
};
