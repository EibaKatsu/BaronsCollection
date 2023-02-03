// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./packages/ERC721WithOperatorFilterSVG.sol";

contract SampleSVG is ERC721WithOperatorFilterSVG {
    constructor() ERC721("SampleSVG", "SSVG") {
        address admin = 0x52A76a606AC925f7113B4CC8605Fe6bCad431EbB; // 管理者用アドレスを定義

        // 管理者グループに登録
        _setRoleAdmin(CONTRACT_ADMIN, CONTRACT_ADMIN);
        _setupRole(CONTRACT_ADMIN, admin);

        // 二次販売ロイヤリティは10%
        setDefaultRoyalty(payable(admin), 1000); 
    }
}
