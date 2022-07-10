//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

import "@aave/protocol-v2/contracts/interfaces/ILendingPool.sol";
import "@aave/protocol-v2/contracts/misc/AaveProtocolDataProvider.sol";
import "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import "@aave/protocol-v2/contracts/dependencies/openzeppelin/contracts/SafeERC20.sol";
import "@openzeppelin/";
import "../interfaces/IPoolGW.sol";
import "@aave/protocol-v2/contracts/misc/interfaces/IWETHGateway.sol";
import "hardhat/console.sol";

contract AaveGW is IPoolGW {
    using SafeERC20 for IERC20;

    address constant poolAddress = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address constant dataProviderAddress =
        0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d;

    ILendingPool lendingPool = ILendingPool(poolAddress);

    AaveProtocolDataProvider dataProvider =
        AaveProtocolDataProvider(dataProviderAddress);

    function deposit(
        address account,
        address asset,
        uint256 amount
    ) external override {
        uint256 allowance = IERC20(asset).allowance(account, address(this));
        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(asset).transferFrom(account, address(this), amount);

        IERC20(asset).approve(poolAddress, amount);

        lendingPool.deposit(asset, amount, account, 0);
    }

    function withdraw(
        address account,
        address asset,
        uint256 amount
    ) external override {
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
    ) external override {
        lendingPool.borrow(asset, amount, 1, 0, account);
        IERC20(asset).safeTransfer(account, amount);
    }

    function repay(
        address account,
        address asset,
        uint256 amount
    ) external override {
        uint256 allowance = IERC20(asset).allowance(account, address(this));

        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(asset).safeTransferFrom(account, address(this), amount);

        IERC20(asset).approve(poolAddress, amount);

        lendingPool.repay(asset, amount, 1, account);
    }

    function getReverse(address asset)
        external
        view
        override
        returns (address aTokenAddress, address debtTokenAddress)
    {
        (address aToken, address debtToken, ) = dataProvider
            .getReserveTokensAddresses(asset);

        return (aToken, debtToken);
    }
}
