import { encodeAbiParameters, parseEther, encodeFunctionData, encodePacked, keccak256, toFunctionSelector, http } from "viem";
import { kernelAbi } from "./abis/kernel-abi.js";
import { registryAbi } from "./abis/registry-abi.js";
import { createPublicClient } from "viem";
import { mainnet, sepolia } from "viem/chains";

const client = createPublicClient({
  chain: sepolia,
  transport: http(),
});

export const encode = async () => {
  const REGISTRY_ADDR = "0xD77bAB549A6f2DbbF7b4e9071257C307eC97458f";
  const DYLAN_ADDR = "0x2595F7Cd55BedEdaA09e8988a9B4daef5aEaDF82";

  const executorSelector = keccak256(encodePacked(["string"], ["Executor"])).slice(0, 10);
  const validatorSelector = keccak256(encodePacked(["string"], ["Validator"])).slice(0, 10);
  const funcSig = toFunctionSelector({
    type: "function",
    name: "execute1Tx",
    inputs: [
      { name: "_recipeId", type: "uint256", internalType: "uint256" },
      { name: "_params", type: "bytes[]", internalType: "bytes[]" },
      { name: "_paramMappings", type: "uint8[][]", internalType: "uint8[][]" },
      { name: "_debt", type: "bytes32", internalType: "bytes32" },
    ],
    outputs: [],
    stateMutability: "payable",
  });

  const executorAddr = await client.readContract({
    address: REGISTRY_ADDR,
    abi: registryAbi,
    functionName: "getAddr",
    args: [executorSelector],
  });
  const validatorAddr = await client.readContract({
    address: REGISTRY_ADDR,
    abi: registryAbi,
    functionName: "getAddr",
    args: [validatorSelector],
  });

  const callData = encodeFunctionData({
    abi: kernelAbi,
    functionName: "setExecution",
    args: [funcSig, executorAddr, validatorAddr, 0, 0, DYLAN_ADDR],
  });

  console.log(callData);
};

encode();
