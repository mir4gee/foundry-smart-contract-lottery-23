//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/**
 * @title Raffle
 * @author Kushagra
 * @notice This is for creating a raffle contract
 * @dev This contract is for creating a raffle contract and implementing Chainlink VRF
 */
contract Raffle {
    error Raffle__NotEnoughFunds();

    uint private immutable i_entranceFee;
    address payable[] private s_participants;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enter() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughFunds();
        }
        s_participants.push(payable(msg.sender));
        // Events
        // 1. Makes migration easier
        // 2. makes front end easier
    }

    function pickWinner() public returns () {}

    /** Getter Function */

    function getEntranceFee() public view returns (uint) {
        return i_entranceFee;
    }
}
