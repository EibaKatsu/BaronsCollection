// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./opensea/DefaultOperatorFilterer.sol";
import "./Base64.sol";

abstract contract ERC1155WithOperatorFilterSVG is
    ERC1155,
    ERC2981,
    AccessControlEnumerable,
    Ownable,
    DefaultOperatorFilterer
{
    bytes32 public constant CONTRACT_ADMIN = keccak256("CONTRACT_ADMIN");

    struct tokenInfo {
        address creator;
        uint256 tokenSupply;
        uint256 maxSupply;
        uint256 cost;
        string svg;
        bool isEncoded;
    }

    uint256 private _currentTokenID = 0;
    mapping(uint256 => tokenInfo) public tokenInfos;

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    constructor(string memory _name, string memory _symbol) ERC1155("") {
        name = _name;
        symbol = _symbol;
    }

    function uri(uint256 _id) public view override returns (string memory) {
        require(
            _exists(_id),
            "ERC1155WithOperatorFilterSVG#uri: NONEXISTENT_TOKEN"
        );

        string memory _svg;
        if (tokenInfos[_id].isEncoded) {
            _svg = tokenInfos[_id].svg;
        } else {
            _svg = Base64.encode(bytes(tokenInfos[_id].svg));
        }

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                symbol,
                                ' #',
                                _id,
                                '", "description": "',
                                'This is the collaboration NFT between pNounsDAO and NounsDAO Japan #',
                                _id,
                                '.", "image": "data:image/svg+xml;base64,',
                                _svg,
                                '"}'




                                
                            )
                        )
                    )
                )
            );
    }

    /**
     * @dev set the max quantity for a token ID
     * @param _id uint256 ID of the token to query
     * @param _maxSupply max quantity
     */
    function setMaxSupply(uint256 _id, uint256 _maxSupply)
        public
        onlyAdminOrOwner
    {
        require(
            _exists(_id),
            "ERC1155WithOperatorFilterSVG#setMaxSupply: NONEXISTENT_TOKEN"
        );
        require(
            tokenInfos[_id].tokenSupply <= _maxSupply,
            "ERC1155WithOperatorFilterSVG#setMaxSupply: NOT_UNDER_CURRENT_SUPPLY"
        );
        tokenInfos[_id].maxSupply = _maxSupply;
    }

    /**
     * @dev set the cost for a token ID
     * @param _id uint256 ID of the token to query
     * @param _cost cost of token in sales
     */
    function setCost(uint256 _id, uint256 _cost) public onlyAdminOrOwner {
        require(
            _exists(_id),
            "ERC1155WithOperatorFilterSVG#setCost: NONEXISTENT_TOKEN"
        );
        tokenInfos[_id].cost = _cost;
    }

    /**
     * @dev set the creator for a token ID
     * @param _id uint256 ID of the token to query
     * @param _creator new creator of token in sales
     */
    function setCreator(uint256 _id, address _creator) public onlyAdminOrOwner {
        require(
            _exists(_id),
            "ERC1155WithOperatorFilterSVG#setCreator: NONEXISTENT_TOKEN"
        );
        require(
            tokenInfos[_id].creator != _creator,
            "ERC1155WithOperatorFilterSVG#setCreator: ALREADY_SET_THIS_CREATOR"
        );
        tokenInfos[_id].creator = _creator;
    }

    /**
     * @dev set the creator for a token ID
     * @param _id uint256 ID of the token to query
     * @param _svg base64 encoded svg image data
     */
    function setSVG(
        uint256 _id,
        string calldata _svg,
        bool _isEncoded
    ) public onlyAdminOrOwner {
        require(
            _exists(_id),
            "ERC1155WithOperatorFilterSVG#setSVG: NONEXISTENT_TOKEN"
        );
        tokenInfos[_id].svg = _svg;
        tokenInfos[_id].isEncoded = _isEncoded;
    }

    /**
     * @dev Creates a new token type and assigns _initialSupply to an address
     * NOTE: remove onlyOwner if you want third parties to create new tokens on your contract (which may change your IDs)
     * @param _initialOwner address of the first owner of the token
     * @param _initialSupply amount to supply the first owner
     * @param _maxSupply max quantity
     * @param _svg base64 encoded svg image data
     * @param _isEncoded if svg is base64 encoded for true
     * @return The newly created token ID
     */
    function create(
        address _initialOwner,
        uint256 _initialSupply,
        uint256 _maxSupply,
        uint256 _cost,
        string calldata _svg,
        bool _isEncoded
    ) external onlyOwner returns (uint256) {
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();

        _mint(_initialOwner, _id, _initialSupply, "");
        tokenInfos[_id] = tokenInfo(
            msg.sender,
            _initialSupply,
            _maxSupply,
            _cost,
            _svg,
            _isEncoded
        );

        return _id;
    }

    /**
     * @dev Mints some amount of tokens to an address
     * @param _to          Address of the future owner of the token
     * @param _id          Token ID to mint
     * @param _quantity    Amount of tokens to mint
     */
    function mint(
        address _to,
        uint256 _id,
        uint256 _quantity
    ) public payable {
        require(
            _exists(_id),
            "ERC1155WithOperatorFilterSVG#mint: NONEXISTENT_TOKEN"
        );
        require(
            tokenInfos[_id].tokenSupply + _quantity <=
                tokenInfos[_id].maxSupply,
            "ERC1155WithOperatorFilterSVG#mint: OVER_MAX_SUPPLY"
        );
        require(
            msg.value >= tokenInfos[_id].cost * _quantity,
            "ERC1155WithOperatorFilterSVG#mint: INSUFFICIENT_VALUE"
        );
        _mint(_to, _id, _quantity, "");
        tokenInfos[_id].tokenSupply = tokenInfos[_id].tokenSupply + _quantity;
    }

    /**
     * @dev Returns whether the specified token exists by checking to see if it has a creator
     * @param _id uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 _id) internal view returns (bool) {
        return tokenInfos[_id].creator != address(0);
    }

    /**
     * @dev calculates the next token ID based on value of _currentTokenID
     * @return uint256 for the next token ID
     */
    function _getNextTokenID() private returns (uint256) {
        _currentTokenID++;
        return _currentTokenID;
    }

    /**
     * @dev increments the value of _currentTokenID
     */
    function _incrementTokenTypeId() private {
        _currentTokenID++;
    }

    /**
     * @dev withdraw contract's fund
     * @param _to address for pay
     */
    function withdraw(address _to) external payable onlyAdminOrOwner {
        require(
            _to != address(0),
            "ERC1155WithOperatorFilterSVG#withdraw: ADDRESS IS 0"
        );
        (bool sent, ) = payable(_to).call{value: address(this).balance}("");
        require(sent, "ERC1155WithOperatorFilterSVG#withdraw: WITHDRAW_FAILED");
    }

    //=======================================================================
    // AccessControl
    //=======================================================================
    modifier onlyAdminOrOwner() {
        require(hasAdminOrOwner(), "caller is not the admin");
        _;
    }

    function hasAdminOrOwner() internal view returns (bool) {
        return owner() == _msgSender() || hasRole(CONTRACT_ADMIN, _msgSender());
    }

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

    //=======================================================================
    // [public/override/onlyAllowedOperatorApproval] for OperatorFilter
    //=======================================================================
    function setApprovalForAll(address operator, bool approved)
        public
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    //=======================================================================
    // supportsInterface
    //=======================================================================
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControlEnumerable, ERC2981)
        returns (bool)
    {
        return
            ERC1155.supportsInterface(interfaceId) ||
            AccessControlEnumerable.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }
}
