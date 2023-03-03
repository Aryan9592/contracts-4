// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "../dynamic-contracts/TWRouter.sol";
import "../extension/interface/IPermissions.sol";
import "../openzeppelin-presets/utils/EnumerableSet.sol";
import "../interfaces/ITWMultichainRegistry.sol";
import "../dynamic-contracts/utils/init/PermissionsEnumerableInit.sol";
import { ERC2771ContextInit } from "../dynamic-contracts/utils/init/ERC2771ContextInit.sol";

library TWMultichainRegistryStorage {
    bytes32 public constant MULTICHAIN_REGISTRY_STORAGE_POSITION = keccak256("multichain.registry.storage");

    struct Data {
        /// @dev wallet address => [contract addresses]
        mapping(address => mapping(uint256 => EnumerableSet.AddressSet)) deployments;
        /// @dev contract address deployed => imported metadata uri
        mapping(uint256 => mapping(address => string)) addressToMetadataUri;
        EnumerableSet.UintSet chainIds;
    }

    function multichainRegistryStorage() internal pure returns (Data storage multichainRegistryData) {
        bytes32 position = MULTICHAIN_REGISTRY_STORAGE_POSITION;
        assembly {
            multichainRegistryData.slot := position
        }
    }
}

contract TWMultichainRegistry is PermissionsEnumerableInit, ERC2771ContextInit, TWRouter {
    /*///////////////////////////////////////////////////////////////
                        Generic contract logic
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns the type of the contract.
    function contractType() external pure returns (bytes32) {
        return bytes32("TWMultichainRegistry");
    }

    /// @dev Returns the version of the contract.
    function contractVersion() external pure returns (uint8) {
        return uint8(1);
    }

    /*///////////////////////////////////////////////////////////////
                    Constructor and Initializer logic
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _extensionRegistry,
        string[] memory _extensionNames,
        address _defaultAdmin,
        address[] memory _trustedForwarders
    ) TWRouter(_extensionRegistry, _extensionNames) {
        bytes32 operatorRole = keccak256("OPERATOR_ROLE");
        bytes32 defaultAdminRole = 0x00;

        __ERC2771Context_init(_trustedForwarders);
        _setupRole(defaultAdminRole, _defaultAdmin);
        _setupRole(operatorRole, _defaultAdmin);
    }

    /*///////////////////////////////////////////////////////////////
                        Internal functions
    //////////////////////////////////////////////////////////////*/

    /// @dev Returns whether a extension can be set in the given execution context.
    function _canSetExtension() internal view virtual override returns (bool) {
        bytes32 defaultAdminRole = 0x00;
        return IPermissions(address(this)).hasRole(defaultAdminRole, msg.sender);
    }
}
