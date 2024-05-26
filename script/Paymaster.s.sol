// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Paymaster} from "../src/Paymaster.sol";

contract PaymasterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Paymaster paymaster = new Paymaster(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789); // sepolia
        vm.stopBroadcast();
        console.log("Paymaster deployed at: ", address(paymaster));
    }
}
