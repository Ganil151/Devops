// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// Interface for a real-world contract (e.g., WETH)
interface IWETH {
    function balanceOf(address) external view returns (uint256);
    function deposit() external payable;
}

contract ForkTest is Test {
    IWETH public weth;
    // Real WETH address on Ethereum Mainnet
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        // This test requires a mainnet fork
        // Run with: forge test --fork-url <your_rpc_url>
        weth = IWETH(WETH_ADDRESS);
    }

    function testWethDeposit() public {
        uint256 initialBalance = weth.balanceOf(address(this));
        
        // Deposit 1 ETH into the real WETH contract on our fork
        weth.deposit{value: 1 ether}();
        
        assertEq(weth.balanceOf(address(this)), initialBalance + 1 ether);
    }
}
