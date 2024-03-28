import express from "express";
import { connectWardDB, db } from "./db/ward-db.ts";
import { viemClient, getChain } from "./config/chain.ts";
import { fetchTransactions } from "./funcs/tx-list.ts";

const app = express();
app.use(express.json());
const port = 3000;

connectWardDB();

app.get("/", (req, res) => {
  res.send("server is live");
});

app.post("/create", async (req, res) => {
  const { name, age } = req.body;
  if (typeof name !== "string" || typeof age !== "number") {
    return res.status(400).send("invalid type");
  }
  try {
    const result = await db.collection("users").insertOne({ name, age });
    res.status(201).send(result);
  } catch (error) {
    res.status(500).send((error as Error).message);
  }
});

app.get("/tx", async (req, res) => {
  const chainId = req.query.chain;
  const address = req.query.address;
  if (typeof chainId !== "string" || typeof address !== "string") {
    return res.status(400).send("Invalid query parameters");
  }
  const startBlock = req.query.startblock ? (req.query.startblock as string) : null;
  const endBlock = req.query.endblock ? (req.query.endblock as string) : null;
  try {
    const transactions = await fetchTransactions(chainId, address, startBlock, endBlock);
    res.send(transactions);
  } catch (error) {
    res.status(500).send((error as Error).message);
  }
});

app.get("/find/:name", async (req, res) => {
  try {
    const name = req.params.name;
    const user = await db.collection("users").findOne({ name });
    if (user) {
      res.status(200).send(user);
    } else {
      res.status(404).send("No matching user name found");
    }
  } catch (error) {
    res.status(500).send((error as Error).message);
  }
});

app.listen(port, () => {
  console.log(`start`);
});
