const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("Starting deployment...");

  // Deploy AuthorizationManager
  const AuthorizationManager = await hre.ethers.getContractFactory("AuthorizationManager");
  const authManager = await AuthorizationManager.deploy();
  await authManager.deployed();
  console.log("AuthorizationManager deployed to:", authManager.address);

  // Deploy SecureVault
  const SecureVault = await hre.ethers.getContractFactory("SecureVault");
  const vault = await SecureVault.deploy();
  await vault.deployed();
  console.log("SecureVault deployed to:", vault.address);

  // Initialize AuthorizationManager with vault address
  await authManager.initialize(vault.address);
  console.log("AuthorizationManager initialized with vault address");

  // Initialize SecureVault with AuthorizationManager address
  await vault.initialize(authManager.address);
  console.log("SecureVault initialized with AuthorizationManager address");

  // Save deployment info
  const deploymentInfo = {
    authorizationManager: authManager.address,
    secureVault: vault.address,
    network: hre.network.name,
    chainId: (await hre.ethers.provider.getNetwork()).chainId,
    deployedAt: new Date().toISOString()
  };

  const outputPath = path.join(__dirname, "../deployment.json");
  fs.writeFileSync(outputPath, JSON.stringify(deploymentInfo, null, 2));
  console.log("Deployment info saved to:", outputPath);

  console.log("\n=== Deployment Summary ===");
  console.log("AuthorizationManager:", authManager.address);
  console.log("SecureVault:", vault.address);
  console.log("Network:", hre.network.name);
  console.log("Chain ID:", deploymentInfo.chainId);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
