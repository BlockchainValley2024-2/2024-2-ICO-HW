const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TokenModule = buildModule("BVTOKEN", (m) => {
  // 1000개의 토큰 발행
  const initialSupply = ethers.parseEther("1000");

  const token = m.contract("BlockchainValleyToken", [initialSupply]);

  return token;
});

module.exports = TokenModule;
