// SPDX-License-Identifier: MIT

// // // // // // // // // // // // //
// society is a contract.
//
// ⠀⠀⢀⣴⣶⣿⣿⣷⡶⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⢶⣿⣿⣿⣿⣶⣄⠀⠀
// ⠀⢠⡿⠿⠿⠿⢿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⢀⣴⣾⣿⣿⡿⠿⠿⠿⠿⣦⠀
// ⠀⠀⠀⠀⠀⠀⠀⠈⠙⠿⣿⡿⠆⠀⠀⠀⠀⠰⣿⣿⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⣀⣤⡤⠄⢤⣀⡈⢿⡄⠀⠀⠀⠀⢠⡟⢁⣠⡤⠠⠤⢤⣀⠀⠀⠀⠀
// ⠐⢄⣀⣼⢿⣾⣿⣿⣿⣷⣿⣆⠁⡆⠀⠀⢰⠈⢸⣿⣾⣿⣿⣿⣷⡮⣧⣀⡠⠀
// ⠰⠛⠉⠙⠛⠶⠶⠏⠷⠛⠋⠁⢠⡇⠀⠀⢸⡄⠈⠛⠛⠿⠹⠿⠶⠚⠋⠉⠛⠆
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡇⠀⠀⢸⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⢻⠇⠀⠀⠘⡟⠳⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠰⣄⡀⠀⠀⣀⣠⡤⠞⠠⠁⠀⢸⠀⠀⠀⠀⡇⠀⠘⠄⠳⢤⣀⣀⠀⠀⣀⣠⠀
// ⠀⢻⣏⢻⣯⡉⠀⠀⠀⠀⠀⠒⢎⣓⠶⠶⣞⡱⠒⠀⠀⠀⠀⠀⢉⣽⡟⣹⡟⠀
// ⠀⠀⢻⣆⠹⣿⣆⣀⣀⣀⣀⣴⣿⣿⠟⠻⣿⣿⣦⣀⣀⣀⣀⣰⣿⠟⣰⡟⠀⠀
// ⠀⠀⠀⠻⣧⡘⠻⠿⠿⠿⠿⣿⣿⣃⣀⣀⣙⣿⣿⠿⠿⠿⠿⠟⢃⣴⠟⠀⠀⠀
// ⠀⠀⠀⠀⠙⣮⠐⠤⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠁⠀⠀⠀⠤⠊⡵⠋⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠈⠳⡀⠀⠀⠀⠀⠀⠲⣶⣶⠖⠀⠀⠀⠀⠀⢀⠜⠁⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⢀⣿⣿⡀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
// ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡿⠀
//
// // // // // // // // // // // // //
// @title Paymaster
// @dev This paymaster sponsors any userOp that includes messages
// part of the current social norm.
// // // // // // // // // // // // //

pragma solidity ^0.8.19;

import "lib/account-abstraction/contracts/interfaces/IPaymaster.sol";
import "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

abstract contract Paymaster is IPaymaster {
    IEntryPoint public immutable entryPoint;
    mapping(string => bool) public socialNorms;

    event TraditionEnshrined(string message, address enshrinedBy);
    event TraditionTornDown(string message, address tornDownBy);

    constructor(address _entryPointAddress) {
        entryPoint = IEntryPoint(_entryPointAddress);
        socialNorms["the internet should be free"] = true;
    }

    function validatePaymasterUserOp(PackedUserOperation calldata userOp, bytes32, uint256)
        external
        view
        override
        returns (bytes memory context, uint256 gasUsed)
    {
        require(msg.sender == address(entryPoint), "Sender not EntryPoint");
        uint256 gasStart = gasleft();
        (string memory message) = abi.decode(userOp.paymasterAndData, (string));
        require(socialNorms[message], "Message not accepted");
        context = abi.encodePacked("Accepted:", message);
        uint256 gasSpent = gasStart - gasleft() + 21000;
        return (context, gasSpent);
    }

    function enshrineTradition(string memory message) external payable {
        // require 1 ETH donation to add a new message
        require(msg.value == 1 ether, "Change Requires Sacrifice");
        entryPoint.depositTo{value: msg.value}(address(this));
        socialNorms[message] = true;
        emit TraditionEnshrined(message, msg.sender);
    }

    function tearDownSocialNorm(string memory message) external payable {
        // require 1 ETH donation to remove a message
        require(msg.value == 1 ether, "Change Requires Sacrifice");
        entryPoint.depositTo{value: msg.value}(address(this));
        socialNorms[message] = false;
        emit TraditionTornDown(message, msg.sender);
    }

    function startTheRevolution(string[] memory messages) external payable {
        require(msg.value == 10 ether, "Change Requires Sacrifice");
        entryPoint.depositTo{value: msg.value}(address(this));
        for (uint256 i = 0; i < messages.length; i++) {
            socialNorms[messages[i]] = true;
        }
    }

    function strengthenSociety(uint32 unstakeDelaySec) external payable {
        entryPoint.addStake{value: msg.value}(unstakeDelaySec);
    }
}
