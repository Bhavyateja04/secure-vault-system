# Secure Vault System

Authorization-Governed Vault System for Controlled Asset Withdrawals - A blockchain-based multi-contract system for secure fund management.

## Overview

This project implements a secure vault system where fund movement is permitted only after an explicit authorization flow is validated on-chain. The system separates responsibility for asset custody and permission validation across two smart contracts to reduce risk and improve clarity.

## Project Structure

```
.
├── contracts/
│   ├── AuthorizationManager.sol
│   └── SecureVault.sol
├── scripts/
│   └── deploy.js
├── tests/
│   └── system.spec.js
├── docker/
│   ├── Dockerfile
│   └── entrypoint.sh
├── package.json
├── hardhat.config.js
├── docker-compose.yml
└── README.md
```

## Running with Docker

```bash
docker-compose up
```

This will:
1. Start a local Hardhat node
2. Install dependencies
3. Deploy both contracts
4. Output contract addresses

## Key Features

- **AuthorizationManager**: Validates and consumes withdrawal permissions
- **SecureVault**: Holds funds and executes withdrawals after authorization
- **One-time Authorization**: Each authorization can only be used once
- **On-chain Verification**: All permissions are cryptographically verified on-chain
- **Deterministic Messages**: Authorization data is tightly scoped with contextual parameters

## Testing

Run tests locally:
```bash
npm install
npx hardhat test
```
