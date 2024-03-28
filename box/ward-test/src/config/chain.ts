import { extractChain, Chain, createPublicClient, http } from "viem";
import * as viemChains from "viem/chains";

const chains: { [key: string]: { chain: Chain; blockExplorerAPIUrl: string; apiKey: string } } = {};

// apiUrl 속성이 있는지 확인하는 타입 가드 함수
function hasApiUrl(blockExplorer: any): blockExplorer is { apiUrl: string } {
  return "apiUrl" in blockExplorer;
}

export const getChain = (chainId: string) => {
  if (!chains[chainId]?.chain) {
    chains[chainId].chain = extractChain({
      chains: Object.values(viemChains),
      id: Number(chainId) as any,
    });
  }
  return chains[chainId].chain;
};

export const getExplorerUrlAndKey = (chainId: string) => {
  if (!chains[chainId]?.blockExplorerAPIUrl) {
    const chain = extractChain({
      chains: Object.values(viemChains),
      id: Number(chainId) as any,
    });
    // 타입 가드 함수를 사용하여 apiUrl 속성이 있는지 확인
    if (chain.blockExplorers?.default && hasApiUrl(chain.blockExplorers.default)) {
      const apiUrl = chain.blockExplorers.default.apiUrl;
      chains[chainId].blockExplorerAPIUrl = apiUrl;
    } else {
      // apiUrl 속성이 없는 경우의 처리 로직
      // 별도 json 에서 저장
    }
  }
  // apiKey를 추가하는 로직
  // 별도 json에서 저장
  return chains[chainId].blockExplorerAPIUrl;
};

export const viemClient = (chainId: string) => {
  const publicClient = createPublicClient({
    chain: getChain(chainId),
    transport: http(),
  });
  return publicClient;
};
