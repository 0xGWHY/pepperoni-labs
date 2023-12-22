// const { ethers } = require("ethers");
import { ethers, formatUnits, parseEther, parseUnits } from "ethers";
import QuoterV2ABI from "../abis/QuoterV2ABI.js"; // Update the path to your ABI file

const quoterAddress = "0x61fFE014bA17989E743c5F6cB21bF9697530B21e"; // QuoterV2 contract address on Ethereum mainnet

import dotenv from "dotenv";
dotenv.config();

async function getQuote() {
  const provider = new ethers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`);
  const wallet = new ethers.Wallet(process.env.FREE_KEY, provider);
  const quoterContract = new ethers.Contract(quoterAddress, QuoterV2ABI, wallet);

  const tokenIn = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // DAI
  //   const tokenOut = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH
  const tokenOut = "0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0";
  const fee = 3000; // Pool fee tier

  const amountIn = parseUnits("1", 18); // 1 DAI

  const quote = await quoterContract.quoteExactInputSingle.staticCall({
    tokenIn,
    tokenOut,
    fee,
    amountIn,
    sqrtPriceLimitX96: 0, // No price limit
  });

  console.log("Amount out:", formatUnits(quote.amountOut, 18));
}

getQuote().catch(console.error);
