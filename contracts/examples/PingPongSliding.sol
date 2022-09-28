// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/SlidingWindowRateLimited.sol";

contract PingPongSliding is SlidingWindowRateLimited(24 * 60 * 60, 100) {
    function ping() public isRateLimited returns (string memory) {
        return "pong";
    }
}
