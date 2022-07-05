const ethers = require("hardhat").ethers;
const weth9 = require("../abi/WETH9.json");
const ierc20 = require("../abi/IERC20.json");
const address = require("../address");

async function main() {
  const [owner, user] = await ethers.getSigners();

  // mint 100 weth token for user
  const weth = new ethers.Contract(address.WETH, weth9, ethers.provider);
  await weth.connect(user).deposit({
    value: ethers.utils.parseEther("0.0000000000000001"),
  });

  console.log(`Amount of WETH: ${await weth.balanceOf(user.address)}`);

  // connect to pool gateway
  const gw = await ethers.getContractAt(
    "PoolGW",
    "0xcd0048a5628b37b8f743cc2fea18817a29e97270",
    user
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
