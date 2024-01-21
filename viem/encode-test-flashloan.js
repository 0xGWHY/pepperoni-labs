import { encodeAbiParameters, parseEther, encodeFunctionData, createPublicClient, http, keccak256, encodePacked } from "viem";
import { executorAbi } from "./abis/executor-abi.js";
import { registryAbi } from "./abis/registry-abi.js";
import { sepolia } from "viem/chains";

const client = createPublicClient({
  chain: sepolia,
  transport: http(),
});

export const encode = async () => {
  const REGISTRY_ADDR = "0xD77bAB549A6f2DbbF7b4e9071257C307eC97458f";
  const daiTokenAddress = "0xff34b3d4aee8ddcd6f9afffb6fe49bd371b8a357";
  const daiAmount = parseEther("100"); // dai 토큰 100개 -> wei 단위로
  const flashLoanSelector = keccak256(encodePacked(["string"], ["AaveV3FlashLoanSimple"])).slice(0, 10);

  const flashLoanParams = encodeAbiParameters(
    [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "referralCode", type: "uint16", internalType: "uint16" },
    ],
    [daiTokenAddress, daiAmount, 0]
  );

  const flashLoanContractAddress = await client.readContract({
    address: REGISTRY_ADDR,
    abi: registryAbi,
    functionName: "getAddr",
    args: [flashLoanSelector],
  });

  const sendTokenParams = encodeAbiParameters(
    [
      { name: "tokenAddr", type: "address", internalType: "address" },
      { name: "to", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    [daiTokenAddress, flashLoanContractAddress, BigInt(0)]
  );

  const callData = encodeFunctionData({
    abi: executorAbi,
    functionName: "execute1Tx",
    args: [
      BigInt(1),
      [flashLoanParams, sendTokenParams],
      [
        [0, 0, 0],
        [0, 0, 1],
      ],
      `0x0000000000000000000000000000000000000000000000000000000000000000`,
    ],
  });

  // console.log(callData);
  console.log(callData);
};

encode();
