// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IAccess {
    function isSender(address sender) external view returns (bool);
    function preAuthValidations(bytes32 message, bytes32 token, bytes memory signature) external view returns (address);
}