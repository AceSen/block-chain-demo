// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract MultiSigWallet {

    // 存款事件
    event Diposite(address indexed sender, uint amount, uint balance);
    // 提交交易事件
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    // 确认交易
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    // 撤销确认
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);

    // 验证人地址集合
    address[] public owners;

}