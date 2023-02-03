// SPDX-License-Identifier: MIT

// Amended by HashLips
/**
    !Disclaimer!
    These contracts have been used to create tutorials,
    and was created for the purpose to teach people
    how to create smart contracts on the blockchain.
    please review this code on your own before using any of
    the following code for production.
    HashLips will not be liable in any way if for the use 
    of the code. That being said, the code has been tested 
    to the best of the developers' knowledge to work as intended.
*/

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract CryptoNFTOujiClub is ERC721Enumerable, Ownable {
    using Strings for uint256;
    uint256 public cost = 0.05 ether;
    uint256 public maxSupply = 10000;

    constructor() ERC721("Crypto NFTOuji Club", "CNF") {}

    // public
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(_mintAmount > 0);
        require(supply + _mintAmount <= maxSupply);
        if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount);
        }
        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "Crypto NFTOuji Club',
                                '", "description": "First test'
                                '", "image": "data:image/svg+xml;base64,',
                                buildImage(),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function withdraw() public payable onlyOwner {
        // This will pay HashLips 5% of the initial sale.
        // You can remove this if you want, or keep it in to support HashLips and his channel.
        // =============================================================================
        (bool hs, ) = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{
            value: (address(this).balance * 5) / 100
        }("");
        require(hs);
        // =============================================================================

        // This will payout the owner 95% of the contract balance.
        // Do not remove this otherwise you will not be able to withdraw the funds.
        // =============================================================================
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
        // =============================================================================
    }

    function buildImage() public pure returns (string memory) {
        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="500" height="500" xmlns="http://w3.org/2000/svg">',
                        "<defs>",
                        '<filter height="200%" width="200%" y="-50%" x="-50%" id="svg_28_blur">',
                        '<feGaussianBlur stdDeviation="6.6" in="SourceGraphic"/>',
                        "</filter>",
                        "</defs>",
                        '<path filter="url(#svg_28_blur)" d="m0.53702,-2.76226l500.45956,0l0,504.35634l-502.84125,0l2.38169,-504.35634z" fill="#c8ffe4"/>',
                        '<path d="m211.75588,167.95186l76.04366,0l0,96.48944l-76.04366,0l0,-96.48944z" opacity="undefined" fill="#ffc2a6"/>',
                        '<rect height="29.67267" width="105.34892" y="137.93722" x="197.35373" fill="#ffff00"/>',
                        '<rect height="14.48779" width="14.48881" y="145.42987" x="242.7379" fill="#CFCA6D"/>',
                        '<rect height="29.67267" width="105.34892" y="137.93722" x="197.35373" fill="#ffff00"/>',
                        '<rect height="29.67267" width="29.69611" y="122" x="273.04157" fill="#ffff00"/>',
                        '<rect height="29.67267" width="30" y="122" x="197.33221" fill="#ffff00"/>',
                        '<rect height="16.29433" width="14.69615" y="122.48176" x="242.67125" fill="#ffff00"/>',
                        '<rect height="15.70325" width="15.34483" y="258.54083" x="196.87776" fill="#ff0000"/>',
                        '<path d="m227.42183,198.70793l45.05207,0l0,44.99207l-45.05207,0l0,-44.99207z" opacity="undefined" fill="#ff0000"/>',
                        '<path d="m212.77582,274.36038l74.89174,0l0,89.48961l-74.89174,0l0,-89.48961z" opacity="undefined" fill="#c0c0c0"/>',
                        '<path d="m242.48465,243.89641l15.34483,0l0,14.86642l-15.34483,0l0,-14.86642z" opacity="undefined" fill="#ffffff"/>',
                        '<path d="m212.15549,349.55344l30.23156,0l0,30.26634l-30.23156,0l0,-30.26634z" opacity="undefined" fill="#0080c0"/>',
                        '<rect height="15.70325" width="15.34483" y="183.2267" x="227.42184" fill="#000000"/>',
                        '<rect height="15.70325" width="15.34483" y="183.2267" x="257.12908" fill="#000000"/>',
                        '<rect height="90.59896" width="15.34483" y="274.02209" x="287.67315" fill="#000000"/>',
                        '<rect height="90.59896" width="15.34483" y="168.16389" x="196.87777" fill="#000000"/>',
                        '<rect height="15.70325" width="15.34483" y="144.31439" x="242.06625" fill="#ff8040"/>',
                        '<rect height="90.59896" width="15.34483" y="168.16389" x="287.67315" fill="#000000"/>',
                        '<path d="m196.87776,274l15.34483,0l0,90.59896l-15.34483,0l0,-90.59896z" opacity="undefined" fill="#000000"/>',
                        '<rect height="15.70325" width="76.01453" y="258.54083" x="211.94057" fill="#000000"/>',
                        '<path d="m242.06625,363.98062l15.34483,0l0,15.70325l-15.34483,0l0,-15.70325z" opacity="undefined" fill="#000000"/>',
                        '<path d="m219.472,289.0849l15.34483,0l0,45.41049l-15.34483,0l0,-45.41049z" opacity="undefined" fill="#000000"/>',
                        '<path d="m242.06625,303.72931l15.34483,0l0,15.70325l-15.34483,0l0,-15.70325z" opacity="undefined" fill="#000000"/>',
                        '<path d="m227.42183,289.08489l15.34483,0l0,15.70325l-15.34483,0l0,-15.70325z" opacity="undefined" fill="#000000"/>',
                        '<path d="m257.54748,318.79213l15.34483,0l0,15.70325l-15.34483,0l0,-15.70325z" opacity="undefined" fill="#000000"/>',
                        '<path d="m265.07889,289.0849l15.34483,0l0,45.41049l-15.34483,0l0,-45.41049z" opacity="undefined" fill="#000000"/>',
                        '<rect height="15.70325" width="15.34483" y="258.54083" x="287.81626" fill="#ff0000"/>',
                        '<rect height="15.70325" width="15.34483" y="274.07481" x="303.02661" fill="#ff0000"/>',
                        '<rect height="15.70325" width="15.34483" y="274.07481" x="181.66741" fill="#ff0000"/>',
                        '<rect height="15.70325" width="15.34483" y="319.38225" x="181.66741" fill="#ff0000"/>',
                        '<rect height="15.70325" width="15.34483" y="333.94535" x="181.66741" fill="#ff0000"/>',
                        '<rect height="15.70325" width="15.34483" y="334" x="303.02661" fill="#ff0000"/>',
                        '<rect height="15.70325" width="15.34483" y="319.4369" x="303.02661" fill="#ff0000"/>',
                        '<path d="m257.46293,349.55344l30.23156,0l0,30.26634l-30.23156,0l0,-30.26634z" opacity="undefined" fill="#0080c0"/>',
                        '<path d="m181.62481,289.74774l15.34483,0l0,29.65959l-15.34483,0l0,-29.65959z" opacity="undefined" fill="#ffc2a6"/>',
                        '<path d="m166.30955,303.54683l15.34483,0l0,15.70324l-15.34483,0l0,-15.70324z" opacity="undefined" fill="#ffc2a6"/>',
                        '<path d="m302.99999,289.74774l15.34483,0l0,29.65959l-15.34483,0l0,-29.65959z" opacity="undefined" fill="#ffc2a6"/>',
                        '<path d="m318.39867,303.54683l15.34483,0l0,15.70324l-15.34483,0l0,-15.70324z" opacity="undefined" fill="#ffc2a6"/>',
                        "</svg>"
                    )
                )
            );
    }
}
