const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Pool", () => {
  it("Should deployed", async () => {
    const PoolGW = await ethers.getContractFactory("PoolGW");
    const gw = await PoolGW.deploy();

    await gw.deployed();

    const AaveGW = await ethers.getContractFactory("AaveGW");
    const aaveGw = await AaveGW.deploy();

    await aaveGw.deployed();

    await gw.newGateway("Aave", aaveGw.address);

    const gwAddr = await gw.getGatewayAddress("Aave");

    expect(gwAddr).to.equal(aaveGw.address);
  });
});
