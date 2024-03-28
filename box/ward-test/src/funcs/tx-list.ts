import axios from "axios";
import { explorerAPIUrl } from "../constants/explorer-url.ts";
import { throttle } from "../config/throttle.ts";

export const fetchTransactions = async (chainId: string, userAddress: string, startBlock: string | null, endBlock: string | null) => {
  let page = 1;
  let hasMore = true;

  if (!explorerAPIUrl[chainId]) {
    throw new Error(`Unsupported chain ID: ${chainId}`);
  }

  const apiUrl = explorerAPIUrl[chainId];
  const apiKey = chainId === "137" ? process.env.POLYGONSCAN_API_KEY : process.env.ETHERSCAN_API_KEY;

  while (hasMore) {
    const url = `${apiUrl}?module=account&action=txlist&address=${userAddress}&startblock=${startBlock || 0}&endblock=${endBlock || 99999999999}&page=${page}&offset=1000&sort=asc&apikey=${apiKey}`;

    try {
      const throttledGet = throttle(async () => {
        return await axios.get(url);
      });
      const response = await throttledGet();
      const data = response.data.result;
      if (data === null || data.length < 1000) {
        hasMore = false;
      } else {
        page++;
      }
    } catch (error) {
      console.error("Error fetching transactions:", error);
      break;
    }
  }
};
