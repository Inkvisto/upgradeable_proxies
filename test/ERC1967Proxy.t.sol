// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {ERC1967Proxy} from "src/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "src/ERC1967/ERC1967Utils.sol";  
import {Utils} from "./utils/Utils.sol";
import {Impl_v1} from "./mocks/Impl_v1.sol";
import {Impl_v2} from "./mocks/Impl_v2.sol";

contract LogicInvalidUUID {
    bytes32 public proxiableUUID = 0x0000000000000000000000000000000000000000000000000000000000001234;
}

/// @title Test for ERC1967 proxy contract
/// @author Inkvisto
contract ERC1967ProxyTest is Test {
    Utils internal utils;
    
    event Upgraded(address indexed implementation);
    
    address internal proxy;
    address payable[] internal users;
    address internal owner;
    
    bytes emptyInitializeData = "";    
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc; 
    uint8[] public states;
    
    address internal logicV1;
    address internal logicV2;
   
    function assertProxyV1Initialization(uint256 state, uint256 balance) public virtual {
        assertEq(Impl_v1(proxy).state(), state);
        assertEq(logicV1.balance, balance);    
    }   

    function deployProxy(address implementation, bytes memory initCalldata) internal virtual returns (address) {
        return address(new ERC1967Proxy(implementation, initCalldata));
    }
    
    function setUp() public {
        utils = new Utils();
        users = utils.createUsers(2);
        owner = users[0];
        vm.label(owner, "Owner");
        
        logicV1 = address(new Impl_v1());
        logicV2 = address(new Impl_v2());
        proxy = deployProxy(logicV1, "");
    }

    function test_setUp() public {
        assertEq(Impl_v1(logicV1).version(), "V1");
        assertEq(Impl_v1(proxy).version(), "V1");
    }

    function test_deployUpgradedEvent() public {
        vm.expectEmit(true, false, false, false);
        emit Upgraded(logicV1);
        proxy = deployProxy(logicV1, "");
    }

    function test_NonContractAddressCreation() public {
        vm.expectRevert();    
        proxy = deployProxy(owner, emptyInitializeData);
    }

    function test_deployNonExistentInit() public {
        vm.expectRevert();
        proxy = deployProxy(logicV1, abi.encodePacked(bytes4(uint32(0x123456))));
    }

    function test_initNonPayableProxy() public {
        proxy = deployProxy(logicV1, abi.encodePacked(Impl_v1.initNonPayable.selector));
        assertProxyV1Initialization(10,0);

        vm.expectRevert();
        proxy = deployProxy(logicV1, abi.encodePacked(Impl_v1.initNonPayable.selector));
    }

    function test_deployInitRevert() public {
        vm.expectRevert("Impl_v1 reverted");
        proxy = deployProxy(logicV1, abi.encodePacked(Impl_v1.reverts.selector)); 
    }

    function test_upgradeLogic() public {
        states.push(1);
        Impl_v1(proxy).initialize(1,"some",states);
        assertProxyV1Initialization(1,0);

        vm.expectRevert();
        Impl_v2(proxy).migrate(1);
        
        proxy = deployProxy(logicV2, "");
        Impl_v2(proxy).migrate(2);
        assertEq(Impl_v2(proxy).version(), "V2");
        assertEq(Impl_v2(proxy).state(), 2);

        proxy = deployProxy(logicV1, "");
        vm.expectRevert(); 
        Impl_v2(proxy).migrate(1);
    }
}