// SPDX-License-Identifier: UNLICENSED                                                                                                       
pragma solidity ^0.8.21;    

import {Impl_v1} from "./Impl_v1.sol";
contract Impl_v2 is Impl_v1{                                                                                                                 
                                                                                                                                            
    function migrate(uint256 newState) public payable {                                                                                      
        state = newState;                                                                                                                    
    }                                                                                                                                        
                                                                                                                                                   
    function version() public pure override returns (string memory) {                                                                       
        return "V2";                                                                                                                         
    }                                                                                                                                        
}   