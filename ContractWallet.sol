// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract ContractWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    // make smart contract compatible to recieve funds
    receive() external payable {}

    // withdraw function
    function withdraw(uint _amount) external {
        require(msg.sender == owner, "Only the owner can call this.");
        payable(msg.sender).transfer(_amount);
    }

    // get balance function - read only
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}