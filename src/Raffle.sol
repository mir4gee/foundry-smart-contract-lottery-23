//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {VRFCoordinatorV2Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {ConfirmedOwner} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

/**
 * @title Raffle
 * @author Kushagra
 * @notice This is for creating a raffle contract
 * @dev This contract is for creating a raffle contract and implementing Chainlink VRF
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughFunds();
    error Raffle__TransferFailed();
    error Raffle__NotOpen();

    /** Type Declaration*/
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    /** State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUMWORDS = 1;

    uint private immutable i_entranceFee;
    uint private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    address payable[] private s_participants;
    uint private s_lastTimeStamp;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address private s_recentWinner;
    RaffleState private s_RaffleState = RaffleState.OPEN;

    event EnteredRaffle(address indexed participant);
    event WinnerSelected(address indexed winner);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enter() external payable {
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughFunds();
        }
        if (s_RaffleState == RaffleState.CALCULATING) {
            revert Raffle__NotOpen();
        }
        s_participants.push(payable(msg.sender));
        // Events
        // 1. Makes migration easier
        // 2. makes front end easier
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        if (block.timestamp - s_lastTimeStamp >= i_interval) {
            revert();
            // Pick a random winner
            // Transfer the money to the winner
            // Reset the participants
        }
        s_RaffleState = RaffleState.CALCULATING;
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUMWORDS
        );
    }

    /** Getter Function */

    function getEntranceFee() public view returns (uint) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint256 randomIndex = _randomWords[0] % s_participants.length;
        address payable winner = s_participants[randomIndex];
        s_recentWinner = winner;
        s_RaffleState = RaffleState.OPEN;
        s_participants = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        (bool success, ) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransferFailed();
        }
        emit WinnerSelected(winner);
    }
}
