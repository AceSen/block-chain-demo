// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

/**
 * 多签钱包;
 * 多签钱包的工作原理是，为了执行一笔交易，
 * 钱包需要事先设定一个指定数量的私钥（通常是多个不同的用户或设备）
 * 作为联合签名者。当有一笔交易需要执行时，
 * 钱包会向每个签名者发送交易信息，每个签名者根据设定的规则对交易进行签名，
 * 只有当所有必要的签名都得到确认时，交易才能被广播到区块链网络上执行。
 */
contract MultiSigWallet {

    // 存款事件
    event Diposite(address indexed sender, uint amount, uint balance);
    // 提交交易事件
    event SubmitTransaction(address indexed owner, uint indexed txIndex, address indexed to, uint value, bytes data);
    // 确认交易
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    // 撤销确认
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    // 执行交易
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    // 验证人地址集合
    address[] public owners;
    // 验证人地址map, 为了不从owners数组中循环验证,节约gas
    mapping(address => bool) public isOwner;

    // 需要的验证人数, <= owners.length
    uint public numConfirmationRequired;

    /**
    交易结构体
     */
    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool excuted;
        uint numConfirmations;
    }

    // 交易记录
    Transaction[] transactions;
    
    // 交易是否被某个owner确认
    mapping(uint => mapping(address => bool)) isConfirm;


    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 0, "owners is required");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length, "invalid num of confirmation required");
        // 验证是否存在0x0地址, 是否存在重复地址
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);

        }

        numConfirmationRequired = _numConfirmationRequired;
    }

    // 接收主币 
    receive() external payable {
        emit Diposite(msg.sender, msg.value, address(this).balance);
    }

    // 校验是否owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "requir owner");
        _;
    }


    // 校验交易是否存在
    modifier txExists(uint _txIndex) {
        require(_txIndex < transactions.length, "tx not exists");
        _;
    }

    // 校验交易是否执行
    modifier notExcute(uint _txIndex) {
        require(transactions[_txIndex].excuted, "tx already excute");
        _;
    }
    
    // 校验交易是否被某个owner确认
    modifier notConfirm(uint _txIndex) {
        require(!isConfirm[_txIndex][msg.sender], "address is already confirmed");
        _;
    }

    // 提交一笔交易
    function submitTransaction(address _to, uint _value, bytes memory _data) public onlyOwner {
        transactions.push(
            Transaction({
                to : _to,
                value : _value,
                data : _data,
                excuted : false,
                numConfirmations : 0
            })
        );

        emit SubmitTransaction(msg.sender, transactions.length - 1, _to, _value, _data);
    }

    // 确认交易
    function confirmTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExcute(_txIndex) notConfirm(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirm[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    // 执行交易
    function executeTransaction(uint _txIndex) public onlyOwner txExists(_txIndex) notExcute(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        require(transaction.numConfirmations >= numConfirmationRequired, "cannot execute tx");

        transaction.excuted = true;
        (bool success, ) = transaction.to.call{value : transaction.value}(transaction.data);

        require(success, "tx failed");
        
        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    // 撤销确认
    function revokeConfirmation(uint _txIndex) public onlyOwner txExists(_txIndex) notExcute(_txIndex) {

        require(isConfirm[_txIndex][msg.sender], "address not confirmed");

        isConfirm[_txIndex][msg.sender] = false;
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    
    function getOwners() external view returns(address[] memory) {
        return owners;
    }

    function getTransactionsCount() external view returns(uint256) {
        return transactions.length;
    }



}