// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../node_modules/hardhat/console.sol";

contract BuyCoffee {
    // Struct to hold the details of each profile
    struct Profile {
        address wallet_address;  // The address of the profile's wallet
        uint256 balance;         // The balance of the profile
    }

    // Struct to hold the details of each coffee purchase
    struct Coffee {
        address profile;          // The address of the profile who received the purchase
        address supporter;       // The address of the person who made the purchase
        uint256 amount;          // The amount of ETH sent in the purchase
        uint256 timestamp;       // The timestamp of the purchase
    }

    // Array to hold all coffee purchases
    Coffee[] public coffee;

    // Mapping of profiles to their wallet addresses and balances
    mapping (address => Profile) public profiles;

    // Setter function to enforce the creation of an profile record only when they receive funds
    function setProfile(address profile) public {
        if (profiles[profile].wallet_address == address(0)) {
            profiles[profile].wallet_address = profile;
        }
    }

    // Total balance of the contract
    uint256 public total_contract_balance;

    // Constructor function to initialize the contract
    constructor() payable {
        console.log("Initialize Smart Contract");
        profiles[msg.sender].wallet_address = msg.sender;
    }

    // Function to return the current balance of the contract
    function getContractBalance() public view returns (uint256) {
        return total_contract_balance;
    }

    // Function to allow supporters to buy a coffee for an profile
    function buymeacoffee(address profile) public payable {
        // Check if the supporter has enough ETH to make the purchase
        require(msg.sender.balance >= msg.value, "You don't have enough ETH");
        // Call the setter function to enforce the creation of an profile record
        setProfile(profile);
        // Check that the profile is not the same as the supporter
        require(profile != msg.sender, "You can't buy your own coffee");
        // Check that the profile's address is a valid address (not the zero address)
        require(profile != address(0), "Profile address cannot be the zero address");

        // Add the purchase to the `coffee` array
        coffee.push(Coffee(
            profile,
            msg.sender,
            msg.value,
            block.timestamp
        ));

        // Add the purchase amount to the profile's balance
        profiles[profile].balance += msg.value;
        // Add the purchase amount to the total contract balance
        total_contract_balance += msg.value;
    }

    // Function to return an array of all coffee purchases
    function getAllCoffee() public view returns (Coffee[] memory) {
        return coffee;
    }

    // Function for profiles to withdraw their funds
    function withdraw() public {
        // Get the current balance of the contract
        uint256 amount = address(this).balance;
        // Check if the contract has any funds to withdraw
        require(amount > 0, "You have no ethers to withdraw");
        // Check if the profile has any funds to withdraw
        (bool success, ) = msg.sender.call{value: amount}("");
        
        require(success, "Withdraw failed");
    }

}