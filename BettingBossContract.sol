// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Leading the lottery
 * @author Maurits Arissen
 * @dev All functions are implemented to support managing a lottery
 */
contract BettingBossContract is Ownable {
    
    uint bettingAmount = 0.1 ether;
    
    mapping (address => bool) public participants;
    
    /**
     * @dev Add a check to see if the person interacting with a function is a participant
     */
    modifier onlyParticipant {
        require(participants[msg.sender] == true, "BettingBossContract: msg.sender is not a participants");
        _;
    }
    
    /**
     * @dev Adds an address as participant
     * @param _address Address that will be added to the participants list
     */
    function addParticipant(address _address) external onlyOwner {
        participants[_address] = true;
    }
    
    /**
     * @dev Removes an address as participant
     * @param _address Address that will be removed from the participants list
     */
    function removeParticipant(address _address) external onlyOwner {
        participants[_address] = false;
    }
    
    /**
     * @dev Change the lottery betting amount
     * @param _amount The new betting price
     */
    function changeBettingAmount(uint _amount) external onlyOwner {
        bettingAmount = _amount / (1 ether);
    }
    
}