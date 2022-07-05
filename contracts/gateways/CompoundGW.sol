//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IPoolGW.sol";

interface CERC20 {
    function mint(uint256) external returns (uint256);

    function redeem(uint) external returns (uint);

    function borrow(uint256) external returns (uint256);

    function repayBorrow(uint256) external returns (uint256);
}

contract CompoundGW is IPoolGW {

    address constant cTokenAddress = 0x00; //Address of cToken

    function deposit(
        address account,
        address asset,
        uint256 amount
    ) external override {
        //asset -> Erc20
        uint256 allowance = IERC20(asset).allowance(account, address(this));
        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(asset).transferFrom(account, address(this), amount);

        IERC20(asset).approve(cTokenAddress, amount);
        
        CERC20(cTokenAddress).mint(amount);        
    }

    function withdraw(
        address account,
        address asset,
        uint256 amount
    ) external override {
        //asset -> cErc20
        uint256 allowance = IERC20(asset).allowance(
            account,
            address(this)
        );

        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(asset).transferFrom(account, address(this), amount);

        CERC20(asset).redeem(amount);
    }

    function borrow(
        address account,
        address asset,
        uint256 amount
    ) external override {
        //asset -> cErc20
        require(CERC20(asset).borrow(ammount) == 0, "Account doesn't have excess collateral!");     

        IERC20(asset).transfer(account, amount);
    }

    function repay(
        address account,
        address asset,
        uint256 amount
    ) external override {
        //asset -> Erc20
        uint256 allowance = IERC20(asset).allowance(account, address(this));

        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(asset).transferFrom(account, address(this), amount);

        IERC20(asset).approve(cTokenAddress, amount);

        CERC20(cTokenAddress).repayBorrow(amount);
    }

}