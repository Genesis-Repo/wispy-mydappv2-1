// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import the ERC20.sol file from the OpenZeppelin library to inherit ERC20 token functionalities
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Import Context.sol for context functionalities
import "@openzeppelin/contracts/utils/Context.sol";
// Import AccessControl.sol for role-based access control functionalities
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FriendTech is ERC20, AccessControl {
    // Define the contract owner address
    address public owner;

    // Mapping to store the share price set by each address
    mapping(address => uint256) private sharePrice;
    // Mapping to store the total shares held by each address
    mapping(address => uint256) public totalShares;

    // Define the role for the contract owner
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");

    constructor() ERC20("FriendTech", "FTK") {
        // Assign the deployer address as the owner when the contract is deployed
        owner = msg.sender;
        // Assign the owner role to the deployer
        _setupRole(OWNER_ROLE, msg.sender);
    }

    // Function for the contract owner to set the share price
    function setSharePrice(uint256 price) external {
        // Check if the caller has the owner role
        require(hasRole(OWNER_ROLE, msg.sender), "Caller is not the owner");
        // Check if the price is greater than zero
        require(price > 0, "Price must be greater than zero");
        // Set the share price for the caller address
        sharePrice[msg.sender] = price;
    }

    // Function to get the share price for a specific address
    function getSharePrice(address user) public view returns (uint256) {
        return sharePrice[user];
    }

    // Function for any address to set the total shares they hold
    function setTotalShares(uint256 amount) external {
        // Check if the amount is greater than zero
        require(amount > 0, "Amount must be greater than zero");
        // Set the total shares for the caller address
        totalShares[msg.sender] = amount;
    }

    // Function to get the total shares held by a specific address
    function getTotalShares(address user) public view returns (uint256) {
        return totalShares[user];
    }

    // Function for a buyer to purchase shares from a seller
    function buyShares(address seller, uint256 amount) external payable {
        // Check if the amount is greater than zero
        require(amount > 0, "Amount must be greater than zero");
        // Check if the seller has enough shares to sell
        require(totalShares[seller] >= amount, "Seller does not have enough shares");
        // Check if the sent value is sufficient to buy the shares
        require(sharePrice[seller] <= msg.value, "Insufficient payment");

        // Update the total shares for both the seller and the buyer
        totalShares[seller] -= amount;
        totalShares[msg.sender] += amount;

        // Calculate the amount of tokens to mint based on the share price
        uint256 tokensToMint = (msg.value * 10**decimals()) / sharePrice[seller];
        _mint(msg.sender, tokensToMint);
    }

    // Function for a seller to sell shares to a buyer
    function sellShares(address buyer, uint256 amount) external {
        // Check if the amount is greater than zero
        require(amount > 0, "Amount must be greater than zero");
        // Check if the seller has enough shares to sell
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        // Update the total shares for both the seller and the buyer
        totalShares[msg.sender] -= amount;
        totalShares[buyer] += amount;

        // Calculate the amount of tokens to burn based on the share price
        uint256 tokensToBurn = (amount * sharePrice[msg.sender]) / 10**decimals();
        _burn(msg.sender, tokensToBurn);
        // Transfer the payment to the seller
        payable(buyer).transfer(tokensToBurn);
    }

    // Function for an address to transfer shares to another address
    function transferShares(address to, uint256 amount) external {
        // Check if the amount is greater than zero
        require(amount > 0, "Amount must be greater than zero");
        // Check if the sender has enough shares to transfer
        require(totalShares[msg.sender] >= amount, "Insufficient shares");

        // Update the total shares for both the sender and the recipient
        totalShares[msg.sender] -= amount;
        totalShares[to] += amount;

        // Transfer the corresponding amount of tokens
        _transfer(msg.sender, to, amount);
    }
}