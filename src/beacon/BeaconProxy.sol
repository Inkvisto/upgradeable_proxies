// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {IBeacon} from "./IBeacon.sol";
import {Proxy} from "../Proxy.sol";
import {ERC1967Utils} from "../ERC1967/ERC1967Utils.sol";

contract BeaconProxy is Proxy {
    address private immutable _beacon;

    constructor(address beacon, bytes memory data) payable {
        ERC1967Utils.upgradeBeaconToAndCall(beacon, data);
        _beacon = beacon;
    }

    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    function _getBeacon() internal view virtual returns (address) {
        return _beacon;
    }
}
