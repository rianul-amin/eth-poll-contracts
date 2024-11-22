import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    sepolia: {
      url: process.env.RPC_URL!,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
  etherscan: {
    apiKey: process.env.API_KEY!,
  },
};

export default config;

// 0xF90dF81d6cFFd1469a1F91Ac633F2E40cE56dE99
// https://sepolia.etherscan.io/address/0xF90dF81d6cFFd1469a1F91Ac633F2E40cE56dE99#code
