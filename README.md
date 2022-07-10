# Lending Pool Gateway

First, create ```.env``` file, then input alchemy or infura key like this: 
```
MAINNET_URL='https://eth-mainnet.g.alchemy.com/v2/xxx'
```

Run second command after first run complete

```shell
npx hardhat node
npx hardhat run --network localhost scripts/deploy.js
```

After that, the local account #1 will have 200 BAT token which borrow from AAVE