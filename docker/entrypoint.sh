#!/bin/sh

echo "Starting Hardhat node..."
npx hardhat node &
NODE_PID=$!

sleep 5

echo "Deploying contracts..."
npx hardhat run scripts/deploy.js --network localhost

echo "Deployment complete. Keeping node running..."
wait $NODE_PID
