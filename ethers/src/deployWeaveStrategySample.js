// const { ethers } = require("ethers");
import { ethers, formatUnits, parseEther, parseUnits } from "ethers";
import QuoterV2ABI from "../abis/QuoterV2ABI.js"; // Update the path to your ABI file
import WeaveByteCode from "../consts/WeaveByteCode.js";

const quoterAddress = "0x61fFE014bA17989E743c5F6cB21bF9697530B21e"; // QuoterV2 contract address on Ethereum mainnet

import dotenv from "dotenv";
dotenv.config();

async function getQuote() {
  const provider = new ethers.JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`);
  const wallet = new ethers.Wallet(process.env.FREE_KEY, provider);
  const signer = wallet.connect(provider);
  const factory = new ethers.ContractFactory([], WeaveByteCode, signer);
  const contract = await factory.deploy();
  console.log(contract);
}

getQuote().catch(console.error);
