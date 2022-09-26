// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/FixedWindowRateLimited.sol";

contract PingPong is FixedWindowRateLimited(60, 10) {
    function ping() public isRateLimited returns (string memory) {
        return "pong";
    }
}
