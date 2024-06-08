// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {Test,console} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    event EnteredRaffle(address indexed participant);

    Raffle raffle;
    HelperConfig helperConfig;
    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 100 ether;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle,helperConfig) = deployRaffle.run();
        console.log("Raffle Contract Address: ", address(raffle));
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        ) = helperConfig.ActiveConfig();

        vm.deal(PLAYER, STARTING_USER_BALANCE);
        
    }
    function testRaffleInitializesInOpenState() public view {
            assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
        }


    /********************************************************
     * ENTER RAFFLE
     * ************************************************************/

    function testRaffleRevertsWhenNotEnoughFunds() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__NotEnoughFunds.selector);
        raffle.enter();
    }

    function testRaffleRevertsWhenTransferFails() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__TransferFailed.selector);
        raffle.enter();
    }


    function testRaffleRevertsWhenNotOpen() public {
        vm.prank(PLAYER);
        raffle.enter({value: entranceFee});
        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
    }

    function testRaffleRevertsWhenUpkeepNotNeeded() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__UpkeepNotNeeded.selector);
        raffle.enter();
    }

    function testRaffleRecordPlayerWhenEnter() public {
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
        assert(raffle.getParticipants(0) == PLAYER);
    }
    
    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        // raffle.enter{value: entranceFee}();
        vm.expectEvent(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enter{value: entranceFee}();
    }

    function testCantEnterWhenRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__NotOpen.selector);
        vm.prank(PLAYER);
        raffle.enter{value: entranceFee}();
    }
}