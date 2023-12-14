import React, { useState } from "react";
import "./App.css";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { usePrepareSendUserOperation, useSendUserOperation } from "@zerodev/wagmi";
import { waitForTransaction, watchAccount } from "wagmi/actions";
import { useBalance } from "wagmi";
import { useEcdsaProvider } from "@zerodev/wagmi";
import { parseEther } from "viem";
import { toast } from "react-hot-toast";

function App() {
  const ecdsaProvider = useEcdsaProvider();
  const [to, setTo] = useState<string>("");
  const [data, setData] = useState<string>("");
  const [value, setValue] = useState("");
  const [render, setRender] = useState(0);
  // const []

  // const { config } = usePrepareSendUserOperation({
  //   to: to,
  //   data: callData || "0x",
  //   value: parseEther(value),
  // });
  // const { sendUserOperation, data } = useSendUserOperation({
  //   ...config,
  //   onSuccess: () => {
  //     console.log("sended");
  //   },
  // });
  // useWaitForTransaction({
  //   hash: data?.hash,
  //   onSuccess(data) {
  //     console.log("success!");
  //     console.log(data);
  //   },
  // });

  const sendTx = async () => {
    const toastId = toast.loading("Transaction Processing...");
    let toAddress: `0x${string}` = "0x";
    let callData: `0x${string}` = "0x";
    if (to.slice(0, 2) === "0x") {
      if (data.slice(0, 2) === "0x" || data === "") {
        toAddress = `0x${to.slice(2)}`;
        callData = `0x${data.slice(2)}`;
        let sended;
        try {
          sended = await ecdsaProvider?.sendUserOperation({
            target: toAddress,
            data: callData,
            value: parseEther(value),
          });
        } catch (error) {
          toast.dismiss(toastId);
          console.error(error);
          return;
        }

        toast("✍️ Sign order successfully!", { duration: 3000 });
        console.log(sended);
        setTo("");
        setData("");
        setValue("");

        if (sended?.hash.slice(0, 2) === "0x") {
          const completed = await ecdsaProvider?.waitForUserOperationTransaction(`0x${sended.hash.slice(2)}`);
          setRender(render + 1);
          // await fetchBalance({ address: `0x${address?.slice(2)}}` || "0x" });
          toast.success("Confirmed!", {
            id: toastId,
            duration: 3000,
          });
          if (completed?.slice(0, 2) === "0x") {
            const data = await waitForTransaction({ hash: completed });
          }
        }
      } else {
        toast.error("Unvalid call data!", { id: toastId });
      }
    } else {
      toast.error("Unvalid address!", { id: toastId });
    }
  };

  const testTx = async () => {
    const toastId = toast.loading("Transaction Processing...");

    let sended;
    try {
      sended = await ecdsaProvider?.sendUserOperation({
        target: "0x024D4836EEf1a20E83BB943038f641FF96432409",
        data: "0x3330880e",
        value: parseEther("0"),
      });
    } catch (error) {
      toast.dismiss(toastId);
      console.error(error);
      return;
    }

    toast("✍️ Sign order successfully!", { duration: 3000 });
    console.log(sended);
    setTo("");
    setData("");
    setValue("");

    if (sended?.hash.slice(0, 2) === "0x") {
      const completed = await ecdsaProvider?.waitForUserOperationTransaction(`0x${sended.hash.slice(2)}`);
      setRender(render + 1);
      toast.success("Confirmed!", {
        id: toastId,
        duration: 3000,
      });
      if (completed?.slice(0, 2) === "0x") {
        const data = await waitForTransaction({ hash: completed });
      }
    }
  };

  return (
    <div className="App flex justify-center w-screen items-center h-screen flex-col">
      <div key={render} className="w-full mb-10 flex justify-center">
        <ConnectButton />
      </div>
      <div className="form-control max-w-md w-full">
        <div className="label">
          <span className="label-text font-bold text-white">To</span>
        </div>
        <input type="text" placeholder="Wallet address (0x..)" value={to} onChange={(e) => setTo(e.target.value)} className="input input-bordered w-full" />
      </div>
      <div className="form-control max-w-md w-full">
        <div className="label">
          <span className="label-text font-bold text-white">value</span>
        </div>
        <input type="text" placeholder="Ether value (ETH)" value={value} onChange={(e) => setValue(e.target.value)} className="input input-bordered w-full" />
      </div>
      <div className="form-control max-w-md w-full">
        <div className="label">
          <span className="label-text font-bold text-white">Call Data</span>
        </div>
        <input type="text" placeholder="Call Data (0x..)" value={data} onChange={(e) => setData(e.target.value)} className="input input-bordered w-full" />
        <div className="label">
          <span className="label-text-alt">
            <a href="https://abi.hashex.org" target="_blank" rel="noopener noreferrer" className="text-blue-500">
              Encoder
            </a>
          </span>
          <span className="label-text-alt select-text">
            <button
              className="btn btn-xs btn-outline"
              onClick={() => {
                testTx();
              }}
            >
              Contract call test
            </button>
          </span>
        </div>
      </div>
      <div className="mt-10 flex flex-col justify-center items-center">
        <button
          className="btn btn-outline btn-primary"
          onClick={() => {
            sendTx();
          }}
        >
          Execute
        </button>
      </div>
    </div>
  );
}

export default App;
