// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract TestUsdt {

    mapping(address => uint256) usdtMap;

    function balanceOf(address contractAddr) public view returns(uint256) {
        return usdtMap[contractAddr];
    }

    function setBalanceOf(address contractAddr, uint balance) public {
        usdtMap[contractAddr] = balance;
    }

}