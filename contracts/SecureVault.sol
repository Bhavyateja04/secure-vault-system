// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AuthorizationManager.sol";

/**
 * @title SecureVault
 * @dev Holds funds and executes withdrawals based on authorization validation
 */
contract SecureVault {
    // Reference to authorization manager
    AuthorizationManager public authorizationManager;
    bool private initialized = false;

    // Track vault balance
    uint256 public totalBalance;
    mapping(address => uint256) public balances;

    // Events for observability
    event Deposit(address indexed depositor, uint256 amount, uint256 timestamp);
    event Withdrawal(address indexed recipient, uint256 amount, bytes32 indexed authId, uint256 timestamp);
    event AuthorizationManagerSet(address indexed managerAddress);

    /**
     * @dev Initialize with authorization manager address. Can only be called once.
     */
    function initialize(address _authorizationManager) external {
        require(!initialized, "Already initialized");
        require(_authorizationManager != address(0), "Invalid manager address");
        authorizationManager = AuthorizationManager(_authorizationManager);
        initialized = true;
        emit AuthorizationManagerSet(_authorizationManager);
    }

    /**
     * @dev Accept deposits of native currency
     */
    receive() external payable {
        require(msg.value > 0, "Invalid deposit amount");
        totalBalance += msg.value;
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @dev Explicit deposit function
     */
    function deposit() external payable {
        require(msg.value > 0, "Invalid deposit amount");
        totalBalance += msg.value;
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    /**
     * @dev Execute withdrawal after authorization validation
     * @param recipient Address to receive funds
     * @param amount Amount to withdraw
     * @param authId Unique authorization identifier
     * @param signature Signature validating the authorization
     */
    function withdraw(
        address payable recipient,
        uint256 amount,
        bytes32 authId,
        bytes calldata signature
    ) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");
        require(totalBalance >= amount, "Insufficient vault balance");

        // Request authorization validation from manager
        bool authorized = authorizationManager.verifyAuthorization(
            authId,
            recipient,
            amount,
            signature
        );

        require(authorized, "Authorization failed");

        // Update balance before transfer (checks-effects-interactions pattern)
        totalBalance -= amount;

        // Transfer funds to recipient
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(recipient, amount, authId, block.timestamp);
    }

    /**
     * @dev Get current vault balance
     */
    function getVaultBalance() external view returns (uint256) {
        return totalBalance;
    }

    /**
     * @dev Get depositor's balance
     */
    function getBalance(address depositor) external view returns (uint256) {
        return balances[depositor];
    }
}
