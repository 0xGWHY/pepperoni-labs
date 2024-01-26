import { encodeAbiParameters, parseEther, encodeFunctionData, createPublicClient, http, keccak256, encodePacked } from "viem";
import { executorAbi } from "./abis/executor-abi.js";
import { registryAbi } from "./abis/registry-abi.js";
import { sepolia } from "viem/chains";

const client = createPublicClient({
  chain: sepolia,
  transport: http(),
});

export const encode = async () => {
  // const REGISTRY_ADDR = "0xD77bAB549A6f2DbbF7b4e9071257C307eC97458f";
  const daiTokenAddress = "0xff34b3d4aee8ddcd6f9afffb6fe49bd371b8a357";
  const daiAmount = parseEther("1"); // dai 토큰 100개 -> wei 단위로
  const dylanAddress = "0x2595F7Cd55BedEdaA09e8988a9B4daef5aEaDF82"
  // const flashLoanSelector = keccak256(encodePacked(["string"], ["AaveV3FlashLoanSimple"])).slice(0, 10);

  const sendTokenParams = encodeAbiParameters(
    [
      { name: "tokenAddr", type: "address", internalType: "address" },
      { name: "to", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    [daiTokenAddress, dylanAddress , daiAmount]
  );

  // const flashLoanContractAddress = await client.readContract({
  //   address: REGISTRY_ADDR,
  //   abi: registryAbi,
  //   functionName: "getAddr",
  //   args: [flashLoanSelector],
  // });

  // const sendTokenParams = encodeAbiParameters(
  //   [
  //     { name: "tokenAddr", type: "address", internalType: "address" },
  //     { name: "to", type: "address", internalType: "address" },
  //     { name: "amount", type: "uint256", internalType: "uint256" },
  //   ],
  //   [daiTokenAddress, flashLoanContractAddress, BigInt(0)]
  // );

  const callData = encodeFunctionData({
    abi: executorAbi,
    functionName: "execute1Tx",
    args: [
      BigInt(2),
      [sendTokenParams],
      [
        [0, 0, 0],
      ],
      "0x",
    ],
  });

  // console.log(callData);
  console.log(callData);
};

encode();
