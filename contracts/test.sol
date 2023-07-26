// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface testUSDT{
    function balanceOf(address contractAddr) external view returns(uint256);
}

contract contractNmaeWhosYourDad {
    uint256 aaa = 256;
    
}

contract Owner {
    address public owner;
    modifier priOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract sonTest is Owner {
    uint public bbb = 90;
    string public str = "str";
    bool public isTrue = true;
    address public addr;
    uint256 public max = type(uint256).max;
    uint256[] public arr;

    struct NftInfo{
        string name;
        uint256 att;
        bool stat;
    }

    NftInfo[] public param;

    struct UserInfo{
        string name;
        uint age;
        bool stat;
    }

    mapping(address => UserInfo) public UserInfoMap;
    mapping(address => uint256) public mapInt;
    mapping(address => mapping(address => uint256)) nestUint;

    // 构造函数

    constructor(uint256 bac) {
        addr = msg.sender; // 获取调用合约的客户端的地址
        bbb = bac;
    }

    function setOwner(address userAddr) public returns(bool) {
        owner = userAddr;
        return true;
    }

    function isOwner(address userAddr) public view returns(bool) {
        return owner == userAddr;
    }

    function setOwnerV2(address userAddr) public priOwner returns(bool) {
        owner = userAddr;
        return false;
    }

    function setOwnerV3(address userAddr, address usdtContractAddr) public returns(bool) {
        require(testUSDT(usdtContractAddr).balanceOf(address(this)) > 10000_000000000000000000, 'not enough');
        owner = userAddr;
        return true;
    }


}

