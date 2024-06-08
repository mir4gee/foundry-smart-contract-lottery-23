// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script,console} from "forge-std/Script.sol";
import {Raffle} from "src/Raffle.sol";
import {VRFCoordinatorV2Mock} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            ,
            address vrfCoordinatorV2,
            ,
            ,
        ) = helperConfig.ActiveConfig();
        return createSubscription(vrfCoordinatorV2);
    }

    function createSubscription(
        address vrfCoordinatorV2
    ) public returns (uint64) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.startBroadcast();
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinatorV2)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol");
        return (subId);
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script{
    uint96 public constant FUND_AMOUNT = 3 ether;

    function run() 
}