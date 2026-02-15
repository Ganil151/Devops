// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecureBank is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public nonReentrant {
        uint256 bal = balances[msg.sender];
        require(bal > 0);

        // ✅ FIX 1: Checks-Effects-Interactions Pattern
        // Update state BEFORE calling external address
        balances[msg.sender] = 0;

        // ✅ FIX 2: ReentrancyGuard modifier (nonReentrant)
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
    }
}
