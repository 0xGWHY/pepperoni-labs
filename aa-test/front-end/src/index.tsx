import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import App from "./App";
import reportWebVitals from "./reportWebVitals";

//web3
import { ECDSAValidator } from "@zerodev/sdk";
import { enhanceWalletWithAAConnector, googleWallet, githubWallet, twitterWallet, discordWallet } from "@zerodev/wagmi/rainbowkit";
import { RainbowKitProvider, connectorsForWallets, darkTheme, midnightTheme } from "@rainbow-me/rainbowkit";
import { rainbowWallet, metaMaskWallet, walletConnectWallet } from "@rainbow-me/rainbowkit/wallets";
import { configureChains, createConfig, WagmiConfig } from "wagmi";
import { mainnet, sepolia, polygon, polygonMumbai } from "wagmi/chains";
import { publicProvider } from "wagmi/providers/public";
import "@rainbow-me/rainbowkit/styles.css";
import { Toaster } from "react-hot-toast";

const chainList = [mainnet, polygon, sepolia, polygonMumbai];
const { chains, publicClient } = configureChains(chainList, [publicProvider()]);
const projectId = process.env.REACT_APP_PROJECT_ID!;
const zerodev = process.env.REACT_APP_ZERODEV!;

const connectors = connectorsForWallets([
  {
    groupName: "EOA",
    wallets: [
      enhanceWalletWithAAConnector(metaMaskWallet({ chains, projectId }), { projectId: zerodev }),
      // enhanceWalletWithAAConnector(walletConnectWallet({ chains, projectId }), { projectId: zerodev }),
      // enhanceWalletWithAAConnector(rainbowWallet({ chains, projectId }), { projectId: zerodev }),
    ],
  },
  {
    groupName: "Social",
    wallets: [
      googleWallet({ chains: chainList, options: { projectId: zerodev, shimDisconnect: true } }),
      twitterWallet({ chains: chainList, options: { projectId: zerodev, shimDisconnect: true } }),
      githubWallet({ chains: chainList, options: { projectId: zerodev, shimDisconnect: true } }),
      discordWallet({ chains: chainList, options: { projectId: zerodev, shimDisconnect: true } }),
    ],
  },
]);

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
});

const root = ReactDOM.createRoot(document.getElementById("root") as HTMLElement);
root.render(
  <React.StrictMode>
    <WagmiConfig config={wagmiConfig}>
      <RainbowKitProvider
        chains={chains}
        locale="en"
        theme={midnightTheme({
          accentColor: "oklch(var(--ac))",
        })}
        showRecentTransactions={true}
      >
        <Toaster
          reverseOrder={true}
          containerStyle={{
            top: 20,
          }}
          toastOptions={{
            style: {
              background: "oklch(var(--nc))",
              color: "oklch(var(--pc))",
            },
            loading: {
              iconTheme: {
                secondary: "oklch(var(--pc))",
                primary: "oklch(var(--p))",
              },
            },
            success: {
              iconTheme: {
                secondary: "oklch(var(--pc))",
                primary: "oklch(var(--p))",
              },
            },
          }}
        />
        <App />
      </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
