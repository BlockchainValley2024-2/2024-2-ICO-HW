const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ICO 컨트랙트 테스트", function () {
  let ICO, ico, Token, token, owner, user, creator;

  const initialSupply = ethers.parseEther("1000");
  const tokenPrice = ethers.parseEther("0.01");
  const saleSupply = 100;

  beforeEach(async function () {
    [owner, user, creator] = await ethers.getSigners();

    // 1. 토큰 배포
    Token = await ethers.getContractFactory("BlockchainValleyToken");
    token = await Token.connect(creator).deploy(initialSupply);
    await token.waitForDeployment();

    // 2. ICO 컨트랙트 배포
    ICO = await ethers.getContractFactory("TokenIco");
    ico = await ICO.connect(owner).deploy();
    await ico.waitForDeployment();

    // 3. 허용량 설정 (approve)
    await token
      .connect(creator)
      .approve(await ico.getAddress(), ethers.parseEther("100"));

    // 4. ICO 생성 및 토큰 예치
    await ico
      .connect(creator)
      .createICOSale(await token.getAddress(), tokenPrice, saleSupply);
  });

  it("사용자가 토큰을 성공적으로 구매합니다.", async function () {
    const amountToBuy = 10;
    const totalCost = tokenPrice * BigInt(amountToBuy);

    await expect(
      ico.connect(user).buyToken(await token.getAddress(), amountToBuy, {
        value: totalCost,
      })
    ).to.changeEtherBalances([user, creator], [-totalCost, totalCost]);

    const userBalance = await token.balanceOf(user.address);
    expect(userBalance).to.equal(ethers.parseEther(amountToBuy.toString()));
  });

  it("판매 수량을 초과하는 구매는 실패해야 합니다.", async function () {
    const amountToBuy = saleSupply + 1;
    const totalCost = tokenPrice * BigInt(amountToBuy);

    await expect(
      ico.connect(user).buyToken(await token.getAddress(), amountToBuy, {
        value: totalCost,
      })
    ).to.be.revertedWith("Not enough tokens available");
  });

  it("잘못된 Ether 금액으로는 구매할 수 없습니다.", async function () {
    const amountToBuy = 10;
    const incorrectCost =
      tokenPrice * BigInt(amountToBuy) - ethers.parseEther("0.001");

    await expect(
      ico.connect(user).buyToken(await token.getAddress(), amountToBuy, {
        value: incorrectCost,
      })
    ).to.be.revertedWith("Incorrect Ether amount sent");
  });

  it("구매 후 남은 공급량이 정확한지 확인합니다.", async function () {
    const amountToBuy = 10;
    const totalCost = tokenPrice * BigInt(amountToBuy);

    await ico.connect(user).buyToken(await token.getAddress(), amountToBuy, {
      value: totalCost,
    });

    const remainingSupply = await ico.getAvailableSupply(
      await token.getAddress()
    );
    expect(remainingSupply).to.equal(saleSupply - amountToBuy);
  });

  it("크리에이터만 판매 후 남은 토큰을 출금할 수 있어야 합니다.", async function () {
    const withdrawAmount = 50;

    await expect(
      ico.connect(user).withdraw(await token.getAddress(), withdrawAmount)
    ).to.be.revertedWith("Caller is not the token creator");

    await expect(
      ico.connect(creator).withdraw(await token.getAddress(), withdrawAmount)
    )
      .to.emit(ico, "TokenWithdraw")
      .withArgs(await token.getAddress(), creator.address, withdrawAmount);
  });

  it("예치된 토큰 잔고가 정확한지 확인합니다.", async function () {
    const contractBalance = await token.balanceOf(await ico.getAddress());
    expect(contractBalance).to.equal(ethers.parseEther("100"));
  });

  it("구매 후 컨트랙트의 토큰 잔고가 감소합니다.", async function () {
    const amountToBuy = 10;
    const totalCost = tokenPrice * BigInt(amountToBuy);

    await ico.connect(user).buyToken(await token.getAddress(), amountToBuy, {
      value: totalCost,
    });

    const contractBalance = await token.balanceOf(await ico.getAddress());
    expect(contractBalance).to.equal(ethers.parseEther("90"));
  });
});
