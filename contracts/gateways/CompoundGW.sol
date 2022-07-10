//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IPoolGW.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface CERC20 {
    function mint(uint256) external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function borrow(uint256) external returns (uint256);

    function repayBorrowBehalf(address, uint256) external returns (uint256);

    function borrowBalanceCurrent(address) external returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint256);

    function balanceOf(address) external returns (uint256);
}

interface Comptroller {
    function markets(address) external returns (bool, uint256);

    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );
}

interface ComptrollerInterface {
    function enterMarkets(address[] calldata cTokens)
        external
        returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);
}

contract CompoundGW is IPoolGW {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    mapping(address => address) cToken; // Token -> cToken
    Comptroller comptroller =
        Comptroller(address(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B));

    constructor() public {
        cToken[
            0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9
        ] = 0xe65cdB6479BaC1e22340E4E755fAE7E509EcD06c; //AAVE
        cToken[
            0x6B3595068778DD592e39A122f4f5a5cF09C90fE2
        ] = 0x4B0181102A0112A2ef11AbEE5563bb4a3176c9d7; //SUSHI
        cToken[
            0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e
        ] = 0x80a2AE356fc9ef4305676f7a3E2Ed04e12C33946; //YFI
        cToken[
            0x0000000000000000000000000000000000000000
        ] = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5; //ETH
        cToken[
            0xE41d2489571d322189246DaFA5ebDe1F4699F498
        ] = 0xB3319f5D18Bc0D84dD1b4825Dcde5d5f7266d407; //ZRX
        cToken[
            0x6B175474E89094C44Da98b954EedeAC495271d0F
        ] = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643; //DAI
        cToken[
            0xdAC17F958D2ee523a2206206994597C13D831ec7
        ] = 0xf650C3d88D12dB855b8bf7D11Be6C55A4e07dCC9; //USDT
        cToken[
            0xc00e94Cb662C3520282E6f5717214004A7f26888
        ] = 0x70e36f6BF80a52b3B46b3aF8e106CC0ed743E8e4; //COMP
        cToken[
            0x0D8775F648430679A709E98d2b0Cb6250d2887EF
        ] = 0x6C8c6b02E7b2BE14d4fA6022Dfd6d75921D90E4E; //BAT
        cToken[
            0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599
        ] = 0xC11b1268C1A384e55C48c2391d8d480264A3A7F4; //WBTC
        cToken[
            0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359
        ] = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC; //SAI
        cToken[
            0x1985365e9f78359a9B6AD760e32412f4a445E862
        ] = 0x158079Ee67Fce2f58472A96584A73C7Ab9AC95c1; //REP
        cToken[
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
        ] = 0x39AA39c021dfbaE8faC545936693aC917d5E7563; //USDC
    }

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

        IERC20(asset).safeTransferFrom(account, address(this), amount);

        address cAddress = cToken[asset];

        address[] memory enters = new address[](1);
        enters[0] = cAddress;
        comptroller.enterMarkets(enters);
        IERC20(asset).safeApprove(cToken[asset], amount);

        uint256 balance = IERC20(asset).balanceOf(address(this));

        console.log("Balance: %s", balance);

        uint256 result = CERC20(cToken[asset]).mint(amount);

        console.log("Result: %s", result);

        uint256 cBalance = CERC20(cToken[asset]).balanceOf(address(this));

        console.log("cBalance: %s", cBalance);

        IERC20(cToken[asset]).safeTransfer(account, cBalance);
    }

    function withdraw(
        address account,
        address asset,
        uint256 amount
    ) external override {
        address cTokenAddress = cToken[asset];
        //asset -> Erc20
        uint256 allowance = IERC20(cTokenAddress).allowance(
            account,
            address(this)
        );

        require(
            amount <= allowance,
            "Amount must be equals or less than allowance"
        );

        IERC20(cTokenAddress).transferFrom(account, address(this), amount);

        require(
            IERC20(cTokenAddress).balanceOf(address(this)) == amount,
            "Cannot transfer cToken from user to this contract!"
        );

        CERC20(cTokenAddress).redeem(amount);

        IERC20(asset).safeTransfer(account, amount);
    }

    function borrow(
        address account,
        address asset,
        uint256 amount
    ) external override {
        //asset -> Erc20
        // require(
        //     CERC20(cToken[asset]).borrow(amount) == 0,
        //     "Account doesn't have excess collateral!"
        // );
        // IERC20(cToken[asset]).transfer(account, amount);
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

        IERC20(asset).safeTransferFrom(account, address(this), amount);

        IERC20(asset).safeApprove(cToken[asset], amount);

        CERC20(cToken[asset]).repayBorrowBehalf(account, amount);
    }

    function getReverse(address asset)
        external
        view
        override
        returns (address, address)
    {
        return (cToken[asset], cToken[asset]);
    }
}
