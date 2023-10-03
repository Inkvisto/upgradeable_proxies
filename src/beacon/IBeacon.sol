// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

interface IBeacon {
    function implementation() external view returns (address);
}
