// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import {IPoolGW} from "./IPoolGW.sol";

interface CErc20 {
    function mint(uint256) external returns (uint256);

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function borrow(uint256) external returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);
}

interface Erc20 {
    function approve(address, uint256) external returns (bool);

    function transfer(address, uint256) external returns (bool);
}

interface Comptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (uint256, uint256, uint256);
}

interface PriceFeed {
    function getUnderlyingPrice(address cToken) external view returns (uint);
}

contract CompoundGW is IPoolGW {
    event MyLog(string, uint256);

    function deposit(
        address _erc20Contract,
        address _cErc20Contract,
        uint256 _numTokensToSupply
    ) public override {
        Erc20 underlying = Erc20(_erc20Contract);
        CErc20 cToken = CErc20(_cErc20Contract);

        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up): ", exchangeRateMantissa);

        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate (scaled up):", supplyRateMantissa);

        // Approve transfer on the ERC20 contract
        underlying.approve(_cErc20Contract, _numTokensToSupply);

        // Mint cTokens
        uint mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }

    function withdraw(
        uint256 amount,
        bool redeemType,
        address _cErc20Contract
    ) public override {
        CErc20 cToken = CErc20(_cErc20Contract);
        uint256 redeemResult;

        if (redeemType == true) {
            // Retrieve your asset based on a cToken amount
            redeemResult = cToken.redeem(amount);
        } else {
            // Retrieve your asset based on an amount of the asset
            redeemResult = cToken.redeemUnderlying(amount);
        }

        emit MyLog("If this is not 0, there was an error", redeemResult);
    }

    function borrow(
        address payable _cCollateralTokenAddress,
        address _comptrollerAddress,
        address _priceFeedAddress,
        address _cTokenAddress,
        uint _underlyingDecimals
    ) public payable override {
        CErc20 cCollateralToken = CErc20(_cCollateralTokenAddress);
        Comptroller comptroller = Comptroller(_comptrollerAddress);
        PriceFeed priceFeed = PriceFeed(_priceFeedAddress);
        CErc20 cToken = CErc20(_cTokenAddress);

        // Supply collateral
        cCollateralToken.mint{ value: msg.value, gas: 250000 }();

        // Enter the market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = _cCollateralTokenAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }

        // Get my account's total liquidity value in Compound
        (uint256 error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));
        if (error != 0) {
            revert("Comptroller.getAccountLiquidity failed.");
        }
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");

        uint256 underlyingPrice = priceFeed.getUnderlyingPrice(_cTokenAddress);
        uint256 maxBorrowUnderlying = liquidity / underlyingPrice;
        emit MyLog("Maximum underlying Borrow (borrow far less!)", maxBorrowUnderlying);
        uint256 numUnderlyingToBorrow = 10;

        cToken.borrow(numUnderlyingToBorrow * 10**_underlyingDecimals);

        // Get the borrow balance
        uint256 borrows = cToken.borrowBalanceCurrent(address(this));
        emit MyLog("Current underlying borrow amount", borrows);
    }

    function repay(
        address _erc20Address,
        address _cErc20Address,
        uint256 amount
    ) public override {
        Erc20 underlying = Erc20(_erc20Address);
        CErc20 cToken = CErc20(_cErc20Address);

        underlying.approve(_cErc20Address, amount);
        uint256 error = cToken.repayBorrow(amount);

        require(error == 0, "CErc20.repayBorrow Error");
    }
}