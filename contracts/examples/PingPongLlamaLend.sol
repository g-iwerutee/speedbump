// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/LlamaLendLimited.sol";

contract PingPongLlamaLend is LlamaLendLimited(100) {
    // just for testing
    function getCurrentDailyBorrows() public view returns (uint) {
        return currentDailyBorrows;
    }

    function ping() public isRateLimited returns (string memory) {
        return "pong";
    }
}
