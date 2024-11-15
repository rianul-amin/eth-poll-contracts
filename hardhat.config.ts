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
    apiKey: process.env.API_KEY!
  }
};

export default config;

// 0x2bB3f2958db9478D63Ba6da51402C6249541dE30
// https://sepolia.etherscan.io/address/0x2bB3f2958db9478D63Ba6da51402C6249541dE30#code
