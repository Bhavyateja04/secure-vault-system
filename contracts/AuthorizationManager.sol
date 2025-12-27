// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AuthorizationManager
 * @dev Validates withdrawal permissions and tracks authorization consumption
 */
contract AuthorizationManager {
    // Address of the vault contract that can call verification functions
    address public vaultAddress;
    bool private initialized = false;

    // Track which authorizations have been consumed
    mapping(bytes32 => bool) public consumedAuthorizations;

    // Events for observability
    event AuthorizationVerified(bytes32 indexed authId, address indexed vaultAddr, address indexed recipient, uint256 amount);
    event AuthorizationConsumed(bytes32 indexed authId);

    /**
     * @dev Initialize with vault address. Can only be called once.
     */
    function initialize(address _vaultAddress) external {
        require(!initialized, "Already initialized");
        require(_vaultAddress != address(0), "Invalid vault address");
        vaultAddress = _vaultAddress;
        initialized = true;
    }

    /**
     * @dev Verify and consume an authorization
     * @param authId Unique authorization identifier
     * @param recipient Intended recipient of funds
     * @param amount Amount to withdraw
     * @param signature Signature validating the authorization
     */
    function verifyAuthorization(
        bytes32 authId,
        address recipient,
        uint256 amount,
        bytes calldata signature
    ) external returns (bool) {
        require(msg.sender == vaultAddress, "Only vault can verify");
        require(!consumedAuthorizations[authId], "Authorization already consumed");
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");

        // Verify signature was generated for this exact authorization
        bytes32 messageHash = keccak256(abi.encodePacked(
            authId,
            vaultAddress,
            recipient,
            amount,
            block.chainid
        ));
        
        bytes32 prefixedHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            messageHash
        ));

        address signer = recoverSigner(prefixedHash, signature);
        require(signer != address(0), "Invalid signature");

        // Mark authorization as consumed
        consumedAuthorizations[authId] = true;
        emit AuthorizationConsumed(authId);
        emit AuthorizationVerified(authId, vaultAddress, recipient, amount);

        return true;
    }

    /**
     * @dev Recover signer from signature
     */
    function recoverSigner(
        bytes32 messageHash,
        bytes calldata signature
    ) internal pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature.offset, 0x20))
            s := mload(add(signature.offset, 0x40))
            v := byte(0, mload(add(signature.offset, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature 'v' value");

        address recovered = ecrecover(messageHash, v, r, s);
        return recovered;
    }

    /**
     * @dev Check if an authorization has been consumed
     */
    function isAuthorizationConsumed(bytes32 authId) external view returns (bool) {
        return consumedAuthorizations[authId];
    }
}
