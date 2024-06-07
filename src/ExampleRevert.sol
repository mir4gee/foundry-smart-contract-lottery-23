// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ExampleRevert {

    error ExampleRevert__Error();

    function revertWithReason() public pure {
        if(false) {
            revert ExampleRevert__Error();
        }
    }

    function revertWithRequire() public pure {
        require(false, "ExampleRevert__Error");
    }


    // Custom Errors give less gas consumption
    
}