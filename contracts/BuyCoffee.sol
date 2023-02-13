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

    Coffee[] public coffee;
    mapping (address => Author) public authors;
    uint256 public total_contract_balance;

    function getContractBalance() public view returns (uint256) {
        return total_contract_balance;
    }

    function author_withdraw(address author_wallet_address) public {
        address payable wallet_address_payable = payable(author_wallet_address);
        uint256 balance = authors[author_wallet_address].balance;
        require(balance > 0, "Author has no balance to withdraw");
        authors[author_wallet_address].balance = 0;
        total_contract_balance -= balance;
        wallet_address_payable.transfer(balance);
    }

    function buymeacoffee(address author_wallet_address, address sender_wallet_address, uint256 amount, uint256 timestamp, string memory message) public {
        coffee.push(Coffee({
            author_wallet_address: author_wallet_address,
            sender_wallet_address: sender_wallet_address,
            amount: amount,
            timestamp: timestamp,
            message: message
        }));

        authors[author_wallet_address].balance += amount;
        total_contract_balance += amount;
    }

}