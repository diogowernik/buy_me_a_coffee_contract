//SPDX=Licence-Identifier: MIT

pragma solidity ^0.8.17;

import "../node_modules/hardhat/console.sol";

contract BuyCoffee {

    struct Author {
        address wallet_address;
        uint256 balance;
    }
    

    struct Coffee {
        address author_wallet_address;
        address sender_wallet_address;
        uint256 amount;
        uint256 timestamp;
        string message;
    }



    Coffee[] coffees;

    address payable public owner;
    constructor() payable {
        console.log("I am a smart contract. Please buy me a coffee!");
        owner = payable(msg.sender);
    }

    function buyCoffee(string memory _message, string memory _name) public payable {
        require(msg.sender.balance >= msg.value, "You don't have enough ETH");

        coffees.push(Coffee(msg.sender, _message, _name, msg.value, block.timestamp));
    }

    function getAllCoffees() public view returns(Coffee[] memory) {
        return coffees;
    }

    function getBalance() public view returns(uint256) {
        require(msg.sender == owner, "You are not the owner");
        return address(this).balance;
    }

    function withdraw() public {
        require(msg.sender == owner, "You are not the owner");
        uint256 amount = address(this).balance;
        require(amount > 0, "You don't have any balance");
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to withdraw");
    }
}