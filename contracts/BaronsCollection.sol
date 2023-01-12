// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "./packages/opensea/DefaultOperatorFilterer.sol";

abstract contract ERC721WithOperatorFilter is
    ERC721URIStorage,
    ERC2981,
    AccessControlEnumerable,
    Ownable,
    DefaultOperatorFilterer
{
    bytes32 public constant CONTRACT_ADMIN = keccak256("CONTRACT_ADMIN");

    ////////// modifiers //////////
    modifier onlyAdminOrOwner() {
        require(hasAdminOrOwner(), "caller is not the admin");
        _;
    }

    ////////// internal functions start //////////
    function hasAdminOrOwner() internal view returns (bool) {
        return
            owner() == _msgSender() || hasRole(CONTRACT_ADMIN, _msgSender());
    }

    ////////// onlyOwner functions start //////////
    function setAdminRole(address[] memory _administrators)
        external
        onlyAdminOrOwner
    {
        for (uint256 i = 0; i < _administrators.length; i++) {
            _grantRole(CONTRACT_ADMIN, _administrators[i]);
        }
    }

    function revokeAdminRole(address[] memory _administrators)
        external
        onlyAdminOrOwner
    {
        for (uint256 i = 0; i < _administrators.length; i++) {
            _revokeRole(CONTRACT_ADMIN, _administrators[i]);
        }
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        virtual
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function setDefaultRoyalty(address payable recipient, uint96 value)
        public
        onlyAdminOrOwner
    {
        _setDefaultRoyalty(recipient, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, AccessControlEnumerable, ERC2981)
        returns (bool)
    {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControlEnumerable.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }
}

contract BaronsCollection is ERC721WithOperatorFilter {
    uint256 public currentTokenId;

    constructor(address[] memory _administrators)
        ERC721("BaronsCollection", "BC")
    {
        _setRoleAdmin(CONTRACT_ADMIN, CONTRACT_ADMIN);
        setDefaultRoyalty(payable(0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB), 1000);

        for (uint256 i = 0; i < _administrators.length; i++) {
            _setupRole(CONTRACT_ADMIN, _administrators[i]);
        }
    }

    function createToken(address _to, stirng memory _tokenURI)
        public
        onlyAdminOrOwner
    {
        uint256 _tokenId = currentTokenId++;
        _setTokenURI(_tokenId, _tokenURI);
        _safeMint(_to, _tokenId);
    }

}
