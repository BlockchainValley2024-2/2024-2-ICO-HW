require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: process.env.API_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    local: {
      url: "http://127.0.0.1:8545", // 로컬 Hardhat 노드 URL
      chainId: 31337, // Hardhat 로컬 노드 기본 체인 ID
    },
  },
};
