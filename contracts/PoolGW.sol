//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;
import "./interfaces/IPoolGW.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PoolGW is Ownable {
    string[] private names;
    mapping(string => address) private pools;

    function deposit(
        string memory name,
        address asset,
        uint256 amount
    ) external {
        IPoolGW(pools[name]).deposit(msg.sender, asset, amount);
    }

    function withdraw(
        string memory name,
        address asset,
        uint256 amount
    ) external {
        IPoolGW(pools[name]).withdraw(msg.sender, asset, amount);
    }

    function borrow(
        string memory name,
        address asset,
        uint256 amount
    ) external {
        IPoolGW(pools[name]).borrow(msg.sender, asset, amount);
    }

    function repay(
        string memory name,
        address asset,
        uint256 amount
    ) external {
        IPoolGW(pools[name]).repay(msg.sender, asset, amount);
    }

    function getReverse(string memory name, address asset)
        external
        view
        returns (address rTokenAddress, address debtTokenAddress)
    {
        return IPoolGW(pools[name]).getReverse(asset);
    }

    function newGateway(string memory name, address poolAddress)
        external
        onlyOwner
    {
        names.push(name);
        pools[name] = poolAddress;
    }

    function allGateway() public view returns (string[] memory) {
        return names;
    }

    function getGatewayAddress(string memory name)
        public
        view
        returns (address)
    {
        return pools[name];
    }
}
