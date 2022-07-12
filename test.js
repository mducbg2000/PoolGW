const IERC20 = require("./abi/IERC20.json");
const address = require("./address");
const [owner, user] = await ethers.getSigners();
const bat = new ethers.Contract(address.BAT, IERC20, user);
const poolGw = await ethers.getContractAt(
  "PoolGW",
  "0x1c9fD50dF7a4f066884b58A05D91e4b55005876A"
);
await bat.approve("0xb185e9f6531ba9877741022c92ce858cdcc5760e", 200);
