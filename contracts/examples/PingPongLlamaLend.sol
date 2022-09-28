// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/LlamaLendLimited.sol";

contract PingPongLlamaLend is LlamaLendLimited(10) {
    function ping() public isRateLimited returns (string memory) {
        return "pong";
    }
}
