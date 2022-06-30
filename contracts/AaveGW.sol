//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

import {ILendingPool} from "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import {AaveProtocolDataProvider} from "@aave/protocol-v2/contracts/misc/AaveProtocolDataProvider.sol";
import {IERC20} from "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import {SafeERC20} from "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/SafeERC20.sol";
import {ICreditDelegationToken} from "@aave/protocol-v2/contracts/interfaces/ICreditDelegationToken.sol";
import {IPoolGW} from "./IPoolGW.sol";

contract AaveGW is IPoolGW {
    using SafeERC20 for IERC20;

    address poolAddress;
    address dataProviderAddress;

    constructor(address _pool, address _dataProvider) public {
        poolAddress = _pool;
        dataProviderAddress = _dataProvider;
    }

    ILendingPool lendingPool = ILendingPool(poolAddress);

    AaveProtocolDataProvider dataProvider =
        AaveProtocolDataProvider(dataProviderAddress);

    function deposit(
        address account,
        address token,
        uint256 amount
    ) public override {
        uint256 allowance = IERC20(token).allowance(account, address(this));
        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(token).safeTransferFrom(account, address(this), amount);

        IERC20(token).safeApprove(poolAddress, amount);

        lendingPool.deposit(token, amount, account, 0);
    }

    function withdraw(
        address account,
        address asset,
        uint256 amount
    ) public override {
        (address aTokenAddress, , ) = dataProvider.getReserveTokensAddresses(
            asset
        );

        uint256 allowance = IERC20(aTokenAddress).allowance(
            account,
            address(this)
        );

        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(aTokenAddress).safeTransferFrom(account, address(this), amount);

        lendingPool.withdraw(asset, amount, account);
    }

    function borrow(
        address account,
        address asset,
        uint256 amount
    ) public override {
        lendingPool.borrow(asset, amount, 1, 0, account);
        IERC20(asset).safeTransfer(account, amount);
    }

    function repay(
        address account,
        address asset,
        uint256 amount
    ) public override {
        uint256 allowance = IERC20(asset).allowance(account, address(this));

        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        lendingPool.repay(asset, amount, 1, account);
    }
}
