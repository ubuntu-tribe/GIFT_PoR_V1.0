# GIFT Token and Minting Documentation

This documentation explains the functionality and reasoning behind the GIFT token and minting contracts.

## GIFT Contract

The GIFT contract is an upgradeable contract that manages the gold reserves, vaults, and minting allowances for the GIFT token. It utilizes the OpenZeppelin library for access control and upgradability.

### Roles

The contract defines the following roles:

- `UPGRADER_ROLE`: Allows the upgrading of the contract implementation.
- `AUDITOR_ROLE`: Permits setting the gold reserves for each vault.
- `ADMIN_ROLE`: Enables administrative actions such as adding vaults, granting minter roles, and setting mint allowances.
- `MINTER_ROLE`: Allows minting of GIFT tokens based on the assigned allowance.

### Vaults

The contract maintains an array of `Vault` structs, each representing a physical gold vault. The `addVault` function, accessible only to the `ADMIN_ROLE`, allows adding new vaults to the contract.

### Gold Reserves

The total gold reserves backing the GIFT token are stored in the `GIFT_reserve` variable. The `setReserve` function, accessible only to the `AUDITOR_ROLE`, updates the gold amount for a specific vault and recalculates the total reserves. The `retrieveReserve` function allows retrieving the current total reserves.

### Minting Allowances

The contract maintains a mapping of minting allowances for each minter address. The `setMintAllowance` function, accessible only to the `ADMIN_ROLE`, sets the minting allowance for a specific minter. The `getMintAllowance` function allows retrieving the current minting allowance for a minter.

### Reasoning

The GIFT contract provides a secure and auditable framework for managing the gold reserves and minting allowances. The use of access control ensures that only authorized roles can perform critical actions such as setting reserves and minting allowances. The upgradeable nature of the contract allows for future enhancements and bug fixes without requiring a full redeployment.

## Minting Contract

The Minting contract is responsible for the actual minting and burning of GIFT tokens. It interacts with the GIFT contract to ensure proper authorization and allowance checks.

### Chainlink Oracle Integration

The contract includes an optional integration with a Chainlink oracle for additional minting allowance verification. The `setChainlinkOracle` function, accessible only to the `ADMIN_ROLE`, allows setting the address of the Chainlink oracle. The `toggleChainlinkOracleUsage` function, also accessible only to the `ADMIN_ROLE`, enables or disables the usage of the Chainlink oracle.

### Minting Process

The `mint` function allows authorized minters to mint GIFT tokens to a specified address. The function checks the following conditions:

1. The caller has the `MINTER_ROLE`.
2. The minting amount does not exceed the minter's allowance in the GIFT contract.
3. If the Chainlink oracle is enabled, the minting amount does not exceed the allowance reported by the oracle.

Upon successful minting, the minter's allowance in the GIFT contract is reduced by the minted amount.

### Burning Process

The `burn` function allows the `ADMIN_ROLE` to burn GIFT tokens from their own address. This function can be used to reduce the total supply of GIFT tokens if necessary.

### Updating GIFT Contract Address

The `updateGiftContractAddress` function, accessible only to the `ADMIN_ROLE`, allows updating the address of the GIFT contract. This functionality provides flexibility in case the GIFT contract needs to be upgraded or replaced.

### Reasoning

The Minting contract separates the token minting functionality from the core GIFT contract, providing a modular and flexible design. The integration with the Chainlink oracle adds an extra layer of security and verification to the minting process. The burning functionality allows for supply management if needed. The ability to update the GIFT contract address ensures that the Minting contract can adapt to changes in the GIFT contract.

## Conclusion

The GIFT token and minting contracts provide a secure, auditable, and flexible framework for managing gold-backed tokens. The use of access control, upgradability, and optional oracle integration ensures the system can evolve and adapt to future requirements while maintaining a high level of security and transparency.
