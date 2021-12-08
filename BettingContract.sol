// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./BettingBossContract.sol";

/**
 * @title A lottery contract
 * @author Maurits Arissen
 * @dev All functions are implemented to support a betting system
 */
contract BettingContract is BettingBossContract {
    
    uint16 private _min = 1;
    uint16 private _max = 2;
    
    event NewBet(address _address, uint bettingNumber);
    event RoundFinished(address[] winners, uint luckyNumber);
    
    struct Round {
        mapping (address => uint) bettingNumbers;
        mapping (uint => address[]) numberToAddress;
        uint16 luckyNumber;
    }
    
    Round[] public rounds;
    
    constructor() {
        rounds.push();
    }
    
    /**
     * @dev Get the last round of the rounds array
     */
    function _getLastRound() private view returns (Round storage) {
        return rounds[rounds.length - 1];
    }
    
    /**
     * @dev Returns a random number for the lottery as winning number
     */
    function _randomNumber() private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(block.timestamp, rounds.length)));
        return rand % _max + _min;
    }
    
    /**
     * @dev Finishes the current round, then handles the winner(s) (multiple winnings is
     * splitting the pot over those winners) and after that creates a new round.
     */
    function finishRound() external onlyOwner {
        Round storage round = _getLastRound();
        round.luckyNumber = uint16(_randomNumber());

        address[] memory winners = round.numberToAddress[round.luckyNumber];

        uint payout = address(this).balance / winners.length;
        for (uint i=0; i < winners.length; i++) {
            payable(winners[i]).transfer(payout);
        }

        emit RoundFinished(winners, round.luckyNumber);
        rounds.push();
    }
    
    /**
     * @dev Returns how many rounds have been played
     */
    function getRoundsPlayed() external view onlyParticipant returns (uint) {
        uint played = 0;

        for (uint i=0; i < rounds.length; i++) {
            if (rounds[i].bettingNumbers[msg.sender] != 0) {
                played++;
            }
        }

        return played;
    }
    
    /**
     * @dev Contract checks if the bet is valid and follows the lottery guidelines.
     * Then it applies the bet to the current lottery and it is locked in.
     * @param _bettingNumber A number that will be your bet
     */
    function bet(uint16 _bettingNumber) external payable onlyParticipant {
        require(_bettingNumber >= _min && _bettingNumber <= _max, "BettingContract: bettingNumber is not between or equal to 1 and 1000");
        require(msg.value == bettingAmount, "BettingContract: msg.value is not equal to the betting amount");
        
        Round storage round = _getLastRound();
        require(round.bettingNumbers[msg.sender] == 0, "BettingContract: you already placed a bet this round");
        
        round.bettingNumbers[msg.sender] = _bettingNumber;
        round.numberToAddress[_bettingNumber].push(msg.sender);
        
        emit NewBet(msg.sender, _bettingNumber);
    }
    
    /**
     * @dev Returns the balance of the pot (contract balance)
     */
    function pot() external view returns (uint) {
        return address(this).balance;
    }
    
}