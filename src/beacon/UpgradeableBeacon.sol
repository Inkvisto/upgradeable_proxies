// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {IBeacon} from "./IBeacon.sol";
import {Ownable} from "../access/Ownable.sol";

contract UpgradeableBeacon is IBeacon, Ownable {
    address private _implementation;

    error BeaconInvalidImplementation(address implementation);

    event Upgraded(address indexed implementation);

    constructor(address implementation_, address initialOwner) Ownable(initialOwner) {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual returns (address) {
        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {
        _setImplementation(newImplementation);
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert BeaconInvalidImplementation(newImplementation);
        }
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
    }
}
