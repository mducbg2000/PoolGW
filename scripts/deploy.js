const hre = require("hardhat");
const ethers = hre.ethers;

const weth9 = require("../abi/WETH9.json");
const address = require("../address");

async function main() {
  const PoolGW = await ethers.getContractFactory("PoolGW");
  const gw = await PoolGW.deploy();
  await gw.deployed();

  const AaveGW = await ethers.getContractFactory("AaveGW");
  const aaveGw = await AaveGW.deploy();
  await aaveGw.deployed();

  await gw.newGateway("Aave", aaveGw.address);

  console.log(await gw.getGatewayAddress("Aave"));

  const [owner, user] = await ethers.getSigners();

  // mint 1000 weth token for user
  const weth = new ethers.Contract(address.WETH, weth9, ethers.provider);
  await weth.connect(user).deposit({
    value: ethers.utils.parseEther("0.000000000000001"),
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
