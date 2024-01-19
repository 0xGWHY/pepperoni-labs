import { encodeAbiParameters, parseEther, encodeFunctionData } from "viem";
import { uExecutorAbi } from "./abis/u-executor-abi.js";

export const encode = () => {
  const daiTokenAddress = "0xff34b3d4aee8ddcd6f9afffb6fe49bd371b8a357";
  const daiAmount = parseEther("100"); // dai 토큰 100개 -> wei 단위로

  const flashLoanParams = encodeAbiParameters(
    [
      { name: "asset", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
      { name: "referralCode", type: "uint16", internalType: "uint16" },
    ],
    [daiTokenAddress, daiAmount, 0]
  );

  const flashLoanContractAddress = "0xC460D5cBFB5AADeC3D37D646ac6e6F3532878258";
  const sendTokenParams = encodeAbiParameters(
    [
      { name: "tokenAddr", type: "address", internalType: "address" },
      { name: "to", type: "address", internalType: "address" },
      { name: "amount", type: "uint256", internalType: "uint256" },
    ],
    [daiTokenAddress, flashLoanContractAddress, BigInt(0)]
  );

  const callData = encodeFunctionData({
    abi: uExecutorAbi,
    functionName: "uExecute",
    args: [
      BigInt(2),
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
