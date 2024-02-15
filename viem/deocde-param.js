import { decodeAbiParameters, parseEther, encodeFunctionData, encodePacked, keccak256, toFunctionSelector, http } from "viem";
import { kernelAbi } from "./abis/kernel-abi.js";
import { registryAbi } from "./abis/registry-abi.js";
import { createPublicClient } from "viem";
import { mainnet, sepolia } from "viem/chains";

export const encode = () => {
  const value = decodeAbiParameters(
    [
      { name: "tokenAddr", type: "address" },
      { name: "to", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    "0x000000000000000000000000aa8e23fb1079ea71e0a56f48a2aa51851d8433d0000000000000000000000000fda9c831090eb4e006b54846c435dd333856001e000000000000000000000000000000000000000000000000000000000059abc0"
  );

  console.log(value);
};

encode();
