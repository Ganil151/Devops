#!/bin/bash

# Load environment variables
source .env

# Deploy to Sepolia
# --verify: Automatically verifies code on Etherscan
# --broadcast: Actually executes the transaction (vs just simulation)
# --rpc-url: The endpoint for the Sepolia network (Alchemy/Infura)
forge script script/Deploy.s.sol:DeployScript \
    --rpc-url $SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    -vvvv
