// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract TestWallet {

    address public immutable owner;

    // 构造方法
    constructor() {
        owner = msg.sender;
    }
    
    // 接受eth
    receive() external payable {}

    // 取款
    function withdraw(uint amount) external payable {
        require(msg.sender == owner, "caller not owner");
        payable(msg.sender).transfer(amount);
    }

    // 查询合约的余额
    function balanceOf() public view returns(uint balance) {
        return address(this).balance;
    }

}