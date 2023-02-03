// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "./packages/ERC721WithOperatorFilter.sol";

contract BaronsCollection is ERC721WithOperatorFilter {

    constructor(address[] memory _administrators)
        ERC721("BaronsCollection", "BC")
    {
        _setRoleAdmin(CONTRACT_ADMIN, CONTRACT_ADMIN);
        _setDefaultRoyalty(payable(_administrators[0]), 1000);

        for (uint256 i = 0; i < _administrators.length; i++) {
            _setupRole(CONTRACT_ADMIN, _administrators[i]);
        }
    }

}
