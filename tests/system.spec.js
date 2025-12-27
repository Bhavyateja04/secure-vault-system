const { expect } = require("chai");
const hre = require("hardhat");
const { ethers } = hre;

describe("Secure Vault System", function () {
  let authManager, vault, owner, recipient;

  beforeEach(async function () {
    [owner, recipient] = await ethers.getSigners();
    
    const AuthManager = await ethers.getContractFactory("AuthorizationManager");
    authManager = await AuthManager.deploy();
    await authManager.deployed();

    const Vault = await ethers.getContractFactory("SecureVault");
    vault = await Vault.deploy();
    await vault.deployed();

    await authManager.initialize(vault.address);
    await vault.initialize(authManager.address);
  });

  it("Should accept deposits", async function () {
    const amount = ethers.utils.parseEther("1.0");
    await owner.sendTransaction({ to: vault.address, value: amount });
    expect(await vault.getVaultBalance()).to.equal(amount);
  });
});
