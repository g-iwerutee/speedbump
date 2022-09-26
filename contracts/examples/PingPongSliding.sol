// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/SlidingWindowRateLimited.sol";

contract PingPongSliding is SlidingWindowRateLimited(60, 10) {
    function ping() public isRateLimited returns (string memory) {
        return "pong";
    }
}
