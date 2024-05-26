// SPDX-License-Identifier: UNLICENSED
// TODO: fix
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Paymaster} from "../src/Paymaster.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";

contract MockEntryPoint is IEntryPoint {
    address public paymaster;

    function setPaymaster(address _paymaster) external {
        paymaster = _paymaster;
    }

    function depositTo(address) external payable override {
        // Mock deposit function
    }

    function addStake(uint32) external payable override {
        // Mock stake function
    }

    function balanceOf(address account) external view override returns (uint256) {
        return 0;
    }
}

contract PaymasterTest is Test {
    Paymaster paymaster;
    MockEntryPoint entryPoint;
    address user = address(0x123);

    function setUp() public {
        entryPoint = new MockEntryPoint();
        paymaster = new Paymaster(address(entryPoint));
        entryPoint.setPaymaster(address(paymaster));
    }

    function testInitialSocialNorm() public {
        assertTrue(paymaster.socialNorms("the internet should be free"));
    }

    function testValidatePaymasterUserOp() public {
        string memory message = "the internet should be free";
        bytes memory encoded = abi.encodePacked(message);
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: user,
            nonce: 0,
            initCode: "",
            callData: "",
            callGas: 0,
            verificationGas: 0,
            preVerificationGas: 0,
            maxFeePerGas: 0,
            maxPriorityFeePerGas: 0,
            paymaster: address(paymaster),
            paymasterData: encoded,
            signature: ""
        });

        vm.prank(address(entryPoint));
        (bytes memory context, uint256 gasUsed) = paymaster.validatePaymasterUserOp(userOp, bytes32(0), 0);
        assertEq(string(context), "Accepted:the internet should be free");
    }

    function testValidatePaymasterUserOpFail() public {
        string memory message = "pay for the internet";
        bytes memory encoded = abi.encodePacked(message);
        PackedUserOperation memory userOp = PackedUserOperation({
            sender: user,
            nonce: 0,
            initCode: "",
            callData: "",
            callGas: 0,
            verificationGas: 0,
            preVerificationGas: 0,
            maxFeePerGas: 0,
            maxPriorityFeePerGas: 0,
            paymaster: address(paymaster),
            paymasterData: encoded,
            signature: ""
        });

        vm.prank(address(entryPoint));
        vm.expectRevert("Message not accepted");
        paymaster.validatePaymasterUserOp(userOp, bytes32(0), 0);
    }

    function testEnshrineTradition() public {
        string memory newNorm = "education should be free";
        vm.deal(address(this), 1 ether);
        vm.prank(address(this));
        paymaster.enshrineTradition{value: 1 ether}(newNorm);
        assertTrue(paymaster.socialNorms(newNorm));
    }

    function testTearDownSocialNorm() public {
        string memory norm = "the internet should be free";
        vm.deal(address(this), 1 ether);
        vm.prank(address(this));
        paymaster.tearDownSocialNorm{value: 1 ether}(norm);
        assertFalse(paymaster.socialNorms(norm));
    }

    function testStartTheRevolution() public {
        string[] memory messages = new string[](2);
        messages[0] = "free speech for all";
        messages[1] = "free movement for all";
        vm.deal(address(this), 10 ether);
        vm.prank(address(this));
        paymaster.startTheRevolution{value: 10 ether}(messages);
        assertTrue(paymaster.socialNorms(messages[0]));
        assertTrue(paymaster.socialNorms(messages[1]));
    }

    function testStrengthenSociety() public {
        uint32 unstakeDelay = 3600;
        uint256 stakeAmount = 5 ether;
        vm.deal(address(this), stakeAmount);
        vm.prank(address(this));
        paymaster.strengthenSociety{value: stakeAmount}(unstakeDelay);
        // Check if the stake was added (mocked)
    }
}
