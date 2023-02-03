// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./packages/ERC1155WithOperatorFilterSVG.sol";

contract JapanNouns is ERC1155WithOperatorFilterSVG {

    constructor(address[] memory _administrators)
        ERC1155WithOperatorFilterSVG("JapanNouns", "JNOUNS")
    {
        _setRoleAdmin(CONTRACT_ADMIN, CONTRACT_ADMIN);
        _setDefaultRoyalty(payable(_administrators[0]), 1000);

        for (uint256 i = 0; i < _administrators.length; i++) {
            _setupRole(CONTRACT_ADMIN, _administrators[i]);
        }
    }

}
