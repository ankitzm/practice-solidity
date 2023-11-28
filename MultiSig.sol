// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

contract MultiSig {

    address[] public owners;
    uint public numConfirmationRequired;

    struct Transaction {
        address to;
        uint value;
        bool executed;
    }

    mapping(uint => mapping(address => bool)) isConfirmed;

    Transaction[] public transactions;

    //event
    event TransactionSubmitted(uint transactionId, address sender, address reciever, uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);

    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 1, "Owners Required must be greater than 1");
        require(_numConfirmationRequired>0 && numConfirmationRequired<=owners.length, "number of confirmation is not with sync with number of owners");

        // 
        for(uint i=0; i < _owners.length; i++) {
            require(_owners[i]!= address(0), "Invalid address");
            owners.push(_owners[i]);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }

    // transaction only submitted but not executed
    function submitTransaction(address _to) public payable{
        require(_to!=address(0), "Invalid Reciever Address");
        require(msg.value>0, "Transfer Reciever's Address must be greater than 0");

        uint transactionId = transactions.length;

        transactions.push(Transaction({to: _to, value: msg.value, executed: false}));

        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    // if owner is confirming txn
    function confirmTransaction(uint _transactionId) public {
        require(_transactionId < transactions.length, "Invalid txn id");
        require(!isConfirmed[_transactionId][msg.sender]);
        isConfirmed[_transactionId][msg.sender]=true;
        
        emit TransactionConfirmed(_transactionId);
        
        // checking if we got the required confirmations
        if(isTransactionConfirmed(_transactionId)) {
            //execute txn
            executeTransaction(_transactionId);
        }
    }

    function executeTransaction(uint _transactionId) public  payable {
        require(_transactionId < transactions.length, "Invalid txn id");
        require(!transactions[_transactionId].executed, "The txn is already executed");
        // transactions[_transactionId].executed=true;

        (bool success,) =transactions[_transactionId].to.call{value: transactions[_transactionId].value}("");
        require(success, "Transaction execution failed");

        emit TransactionExecuted(_transactionId);
    }

    // helper
    function isTransactionConfirmed(uint _transactionId) internal view returns(bool) {
        require(_transactionId < transactions.length, "Invalid txn id");
        uint confirmationCount; // initally 0

        for(uint i=0; i<owners.length; i++) {
            if(isConfirmed[_transactionId][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount >= numConfirmationRequired;

    }

}