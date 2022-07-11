const hre = require("hardhat");
const ethers = hre.ethers;
const weth9 = require("../abi/WETH9.json");
const ierc20 = require("../abi/IERC20.json");
const address = require("../address");
const debtToken = require("../abi/DebtToken.json");

async function main() {
  const PoolGW = await ethers.getContractFactory("PoolGW");
  const poolGw = await PoolGW.deploy();
  await poolGw.deployed();
  console.log(`PoolGW address: ${poolGw.address}`);

  const AaveGW = await ethers.getContractFactory("AaveGW");
  const aaveGw = await AaveGW.deploy();
  await aaveGw.deployed();

  await poolGw.registerGateway("Aave", aaveGw.address);

  //Deploy Compound
  const CompoundGW = await ethers.getContractFactory("CompoundGW");
  const compoundGW = await CompoundGW.deploy();
  await compoundGW.deployed();

  await poolGw.registerGateway("Compound", compoundGW.address);

  console.log("Done!");

  const [owner, user] = await ethers.getSigners();

  // mint 1 ETH token for user
  const weth = new ethers.Contract(address.WETH, weth9, user);
  await weth.connect(user).deposit({
    value: ethers.utils.parseEther("1"),
  });

  console.log(`Weth balance: ${await weth.balanceOf(user.address)}`);

  // deposit 200 weth to aave
  await weth.connect(user).approve(aaveGw.address, 2000);
  await poolGw.connect(user).deposit("Aave", address.WETH, 2000);

  console.log(
    `Weth balance after deposit: ${await weth.balanceOf(user.address)}`
  );

  // borrow 100 bat from aave
  const debtBatAddress = (await poolGw.getReverse("Aave", address.BAT))
    .debtTokenAddress;
  const debtBat = new ethers.Contract(debtBatAddress, debtToken, user);
  await debtBat.approveDelegation(aaveGw.address, 200);
  const bat = new ethers.Contract(address.BAT, ierc20, user);
  await poolGw.connect(user).borrow("Aave", address.BAT, 200);

  console.log(`Bat balance: ${await bat.balanceOf(user.address)}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
