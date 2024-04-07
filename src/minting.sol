// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./GIFT.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Minting is ERC20 {
    GIFT public giftContract;
    AggregatorV3Interface public chainlinkOracle;
    bool public useChainlinkOracle = false;

    event ChainlinkOracleSet(address indexed oracleAddress);
    event ChainlinkOracleUsageToggled(bool indexed enabled);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event GiftContractAddressUpdated(address indexed newAddress);

    constructor(address _giftContractAddress) ERC20("Gold Incentivized Futures Token", "GIFT") {
        giftContract = GIFT(_giftContractAddress);
    }

    function setChainlinkOracle(address _chainlinkOracleAddress) public {
        require(giftContract.hasRole(giftContract.ADMIN_ROLE(), msg.sender), "Only admin can set Chainlink oracle");
        chainlinkOracle = AggregatorV3Interface(_chainlinkOracleAddress);
        emit ChainlinkOracleSet(_chainlinkOracleAddress);
    }

    function toggleChainlinkOracleUsage() public {
        require(giftContract.hasRole(giftContract.ADMIN_ROLE(), msg.sender), "Only admin can toggle Chainlink oracle usage");
        useChainlinkOracle = !useChainlinkOracle;
        emit ChainlinkOracleUsageToggled(useChainlinkOracle);
    }

    function mint(address to, uint256 amount) public {
        require(giftContract.isMinter(msg.sender), "Only minters can mint");
        require(giftContract.getMintAllowance(msg.sender) >= amount, "Minting amount exceeds allowance");

        if (useChainlinkOracle) {
            (, int256 chainlinkAllowance,,,) = chainlinkOracle.latestRoundData();
            require(uint256(chainlinkAllowance) >= amount, "Minting amount exceeds Chainlink allowance");
        }

        _mint(to, amount);
        giftContract.setMintAllowance(msg.sender, giftContract.getMintAllowance(msg.sender) - amount);
        emit TokensMinted(to, amount);
    }

    function burn(uint256 amount) public {
        require(giftContract.hasRole(giftContract.ADMIN_ROLE(), msg.sender), "Only admin can burn tokens");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }


    function updateGiftContractAddress(address _newGiftContractAddress) public {
        require(giftContract.hasRole(giftContract.ADMIN_ROLE(), msg.sender), "Only admin can update GIFT contract address");
        giftContract = GIFT(_newGiftContractAddress);
        emit GiftContractAddressUpdated(_newGiftContractAddress);
    }
}