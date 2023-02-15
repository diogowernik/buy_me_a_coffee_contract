// SPDX-License-Identifier: MIT
// Author: @diogowernik
// Version: 1.0.0
// Build for: https://wtr.ee/buymeacoffee

pragma solidity ^0.8.17;

import "../node_modules/hardhat/console.sol";

contract BuyCoffee {

    // Models Profile and Coffee

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

    // Contract

    // Array to hold all coffee purchases
    Coffee[] public coffee;

    // Total balance of the contract
    uint256 public total_contract_balance;

    // Constructor function to initialize the contract
    constructor() payable {
        console.log("Initialize Smart Contract");
        profiles[msg.sender].wallet_address = msg.sender;
        profiles[msg.sender].balance = msg.value;       
    }

    // Function to return the current balance of the contract
    function getContractBalance() public view returns (uint256) {
        return total_contract_balance;
    }

    // Function to return an array of all coffee purchases
    function getAllCoffee() public view returns (Coffee[] memory) {
        return coffee;
    }

    // Profile 

    // Mapping of profiles to their wallet addresses and balances
    mapping (address => Profile) public profiles;

    // Setter function to enforce the creation of an profile record only when they receive funds
    function setProfile(address profile) public {
        if (profiles[profile].wallet_address == address(0)) {
            profiles[profile].wallet_address = profile;
        }
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

    // Function to return an array of all coffee purchases for a specific profile
    function getCoffeeByProfile(address profile) public view returns (Coffee[] memory) {
        Coffee[] memory result = new Coffee[](coffee.length);
        uint256 counter = 0;
        for (uint256 i = 0; i < coffee.length; i++) {
            if (coffee[i].profile == profile) {
                result[counter] = coffee[i];
                counter++;
            }
        }
        Coffee[] memory result2 = new Coffee[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result2[i] = result[i];
        }
        return result2;
    }

    // Function to return the current balance of an profile
    function getProfileBalance(address profile) public view returns (uint256) {
        return profiles[profile].balance;
    }

    // Declare the Withdrawal event outside of the function
    event Withdrawal(address indexed profile, uint256 amount);

    // Function to allow a profile to withdraw their balance
    function withdrawProfileBalance() public {
        // Check that the profile has a balance
        require(profiles[msg.sender].balance > 0, "Profile has no balance");
        // Store the profile's balance in a local variable
        uint256 amount = profiles[msg.sender].balance;
        // Check that the profile has enough ETH to withdraw their balance
        require(address(this).balance >= amount, "Contract doesn't have enough ETH to fulfill the withdrawal");
        // Reset the profile's balance to 0 before sending the funds to prevent reentrancy attacks
        profiles[msg.sender].balance = 0;
        // Subtract the profile's balance from the total contract balance
        total_contract_balance -= amount;
        // Transfer the profile's balance to their wallet
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
        // Emit an event to log the withdrawal
        emit Withdrawal(msg.sender, amount);
    }

}

