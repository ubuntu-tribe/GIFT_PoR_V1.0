// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing necessary components from OpenZeppelin's upgradeable contracts library.
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Declaring the contract, inheriting from OpenZeppelin's Initializable, AccessControlUpgradeable, and UUPSUpgradeable to enable upgradeability and access control.
contract GIFT is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


// Variable to keep track of reserves.
    uint256 public GIFT_reserve;


// Structure to represent a vault with a name and an amount.
    struct Vault {
        string name;
        uint256 amount;
    }


// Array to store multiple vaults.
    Vault[] public vaults;
    mapping(address => uint256) public mintAllowances;


// Events for logging actions within the contract.
    event UpdateReserve(uint256 GIFT_reserve, address indexed sender);
    event SetMintAllowance(address indexed minter, uint256 allowance);
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


// Initialization function to replace the constructor
    function initialize(address upgrader) initializer public {
        __AccessControl_init();
        __UUPSUpgradeable_init();

// Grants roles to the message sender and a specified upgrader.
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AUDITOR_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

// Function to add a new vault. Restricted to ADMIN_ROLE.
    function addVault(string memory _name) public onlyRole(ADMIN_ROLE) {
        vaults.push(Vault({name: _name, amount: 0}));
    }

// Function to retrieve all vaults. Publicly accessible.
    function getVaults() public view returns (Vault[] memory) {
        return vaults;
    }

// Function to set the reserve amount of a specific vault. Restricted to AUDITOR_ROLE.
    function setReserve(uint _index, uint256 _amount) public onlyRole(AUDITOR_ROLE) {
        uint256 new_GIFT_reserve = 0;

        Vault storage vault = vaults[_index];
        vault.amount = _amount;

// Summing the amounts in all vaults to update the total reserve.
        uint arrayLength = vaults.length;
        for (uint i = 0; i < arrayLength; i++) {
            new_GIFT_reserve = new_GIFT_reserve + vaults[i].amount;
        }
        emit UpdateReserve(GIFT_reserve = new_GIFT_reserve, msg.sender);
    }

// Function to retrieve the total reserve amount.
    function retrieveReserve() public view returns (uint256) {
        return GIFT_reserve;
    }

// Functions below manage roles and permissions for minting and admin tasks, leveraging OpenZeppelin's AccessControl
    function grantMinterRole(address minter) public onlyRole(ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, minter);
    }

    function revokeMinterRole(address minter) public onlyRole(ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, minter);
    }
    
    function setMintAllowance(address minter, uint256 allowance) public onlyRole(ADMIN_ROLE) {
        mintAllowances[minter] = allowance;
        emit SetMintAllowance(minter, allowance);
    }
    
    function getMintAllowance(address minter) public view returns (uint256) {
        return mintAllowances[minter];
    }
    
    function isMinter(address account) public view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }

    function transferAdminRole(address newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        grantRole(ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
        renounceRole(ADMIN_ROLE, msg.sender);
    }
// Internal function to authorize contract upgrades, restricted to UPGRADER_ROLE.
    function _authorizeUpgrade(address newImplementation) internal onlyRole(UPGRADER_ROLE) override {}
}
