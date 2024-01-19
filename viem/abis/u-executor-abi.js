export const uExecutorAbi = [
  {
    type: "function",
    name: "logger",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "contract UEventLogger",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "registry",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "contract URegistry",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "uExecute",
    inputs: [
      {
        name: "_queueId",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "_params",
        type: "bytes[]",
        internalType: "bytes[]",
      },
      {
        name: "_paramMappings",
        type: "uint8[][]",
        internalType: "uint8[][]",
      },
      {
        name: "_debt",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "event",
    name: "Process",
    inputs: [
      {
        name: "queueId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      {
        name: "actionAddress",
        type: "address",
        indexed: false,
        internalType: "address",
      },
      {
        name: "currentStep",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "totalStep",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
];
