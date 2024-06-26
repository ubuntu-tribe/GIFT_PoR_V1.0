// SPDX-License-Identifier: MIT
// Specifies the software license under which this code is released. The MIT License is a permissive free software license.
pragma solidity ^0.8.20;
// Sets the compiler version to 0.8.20, ensuring compatibility and preventing compilation with newer, potentially incompatible versions.

// Import statements bring in external code from other contracts and libraries.
import "./GIFTPoR.sol"; // Importing the GIFT PoR contract for interaction.
import "./GIFT.sol"; // Importing the GIFT PoR contract for interaction.
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // Importing the Chainlink oracle interface for price feeds or other data.

// The Minting contract extends ERC20, providing standard token functionalities with additional minting and burning capabilities.
contract Minting {
    GIFTPoR public giftporContract; // Instance of the GIFT contract to interact with.
    GIFT public giftTokenContract; // Instance of the GIFT contract to interact with.
    AggregatorV3Interface public chainlinkOracle; // Instance of the Chainlink oracle for data queries.
    bool public useChainlinkOracle = false; // Toggle to determine if Chainlink oracle should be used for additional verification.

    // Events for logging significant actions within the contract.
    event ChainlinkOracleSet(address indexed oracleAddress);
    event ChainlinkOracleUsageToggled(bool indexed enabled);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);
    event giftPorContractAddressUpdated(address indexed);

    // Constructor initializes the contract with the address of the GIFT_PoR contract.
    constructor(
        address _giftPorContractAddress,
        address _giftTokenContractAddress
    ) {
        giftporContract = GIFTPoR(_giftPorContractAddress);
        giftTokenContract = GIFT(_giftTokenContractAddress);
    }

    // Allows an admin of the GIFT contract to set the address of a Chainlink oracle.
    function setChainlinkOracle(address _chainlinkOracleAddress) public {
        require(
            giftporContract.hasRole(giftporContract.ADMIN_ROLE(), msg.sender),
            "Only admin can set Chainlink oracle"
        );
        chainlinkOracle = AggregatorV3Interface(_chainlinkOracleAddress);
        emit ChainlinkOracleSet(_chainlinkOracleAddress);
    }

    // Allows an admin to toggle the usage of the Chainlink oracle for additional checks during minting.
    function toggleChainlinkOracleUsage() public {
        require(
            giftporContract.hasRole(giftporContract.ADMIN_ROLE(), msg.sender),
            "Only admin can toggle Chainlink oracle usage"
        );
        useChainlinkOracle = !useChainlinkOracle;
        emit ChainlinkOracleUsageToggled(useChainlinkOracle);
    }

    // Function to mint new tokens. It checks if the sender is authorized and if the minting amount is within the allowed limit.
    function mint(address to, uint256 amount) public {
        require(giftporContract.isMinter(msg.sender), "Only minters can mint");
        require(
            giftporContract.getMintAllowance(msg.sender) >= amount,
            "Minting amount exceeds allowance"
        );

        // If using the Chainlink oracle, it verifies the allowance through Chainlink's data.
        if (useChainlinkOracle) {
            (, int256 chainlinkAllowance, , , ) = chainlinkOracle
                .latestRoundData();
            require(
                uint256(chainlinkAllowance) >= amount,
                "Minting amount exceeds Chainlink allowance"
            );
        }

        giftTokenContract.increaseSupply(to, amount); // Mint the tokens.
        giftporContract.setMintAllowance(
            msg.sender,
            giftporContract.getMintAllowance(msg.sender) - amount
        ); // Reduce the minter's allowance.
        emit TokensMinted(to, amount); // Log the minting event.
    }

    // Allows an admin to burn tokens from a specified account.
    function burnFrom(address account, uint256 amount) public {
        require(
            giftporContract.hasRole(giftporContract.ADMIN_ROLE(), msg.sender),
            "Only admin can burn tokens"
        );
        giftTokenContract.redeemGold(account, amount);
        emit TokensBurned(account, amount);
    }

    // Allows an admin to update the GIFT PoR contract
    function updategiftporContractAddress(address _newgiftporContractAddress)
        public
    {
        require(
            giftporContract.hasRole(giftporContract.ADMIN_ROLE(), msg.sender),
            "Only admin can update GIFT PoR contract address"
        );
        giftporContract = GIFTPoR(_newgiftporContractAddress);
        emit giftPorContractAddressUpdated(_newgiftporContractAddress);
    }
}
