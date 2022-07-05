const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  const PoolGW = await ethers.getContractFactory("PoolGW");
  const gw = await PoolGW.deploy();
  await gw.deployed();

  const AaveGW = await ethers.getContractFactory("AaveGW");
  const aaveGw = await AaveGW.deploy();
  await aaveGw.deployed();

  await gw.newGateway("Aave", aaveGw.address);

  console.log(await gw.getGatewayAddress("Aave"));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
