//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;
import {IPoolGW} from "./IPoolGW.sol";

contract PoolGW {


    mapping (string => address) pools;

    function deposit(
        address pool,
        address asset,
        uint256 amount
    ) external {
        IPoolGW(pool).deposit(msg.sender, asset, amount);
    }
}
