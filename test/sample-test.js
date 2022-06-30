const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return list of address", async function () {
    const PoolGW = await ethers.getContractFactory("PoolGW");
    const gw = await PoolGW.deploy();

    await gw.deployed();

    const address = await gw.getReservesList();

    console.log(address);
  });
});
