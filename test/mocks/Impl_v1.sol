// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

contract Impl_v1{
    uint256 public state;
    string public text;
    uint256[] public states;

     function initialize(uint256 _state, string memory _text, uint8[] memory _states) public {
        state = _state;
        text = _text;
        states = _states;
    }

    function initNonPayable() public {
        state = 10;
    }

    function initPayable() public payable {
        state = 100;
    }
    function version() public pure virtual returns (string memory) {
        return "V1";
    } 

    function reverts() public pure {
        revert("Impl_v1 reverted");
    }
}

