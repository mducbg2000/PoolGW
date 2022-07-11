const IERC20 = require('./abi/IERC20.json')
const address = require('./address')
const [owner, user] = await ethers.getSigners()
const bat = new ethers.Contract(address.BAT, IERC20, user);
await bat.approve("0xAe120F0df055428E45b264E7794A18c54a2a3fAF", 20)
