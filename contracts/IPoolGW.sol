//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;

interface IPoolGW {
    function deposit(address account, address asset, uint256 amount) external;

    function withdraw(address account, address asset, uint256 amount) external;

    function borrow(address account, address asset, uint256 amount) external;

    function repay(address account, address asset, uint256 amount) external;
}
