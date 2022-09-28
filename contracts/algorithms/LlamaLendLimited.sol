// SPDX-License-Identifier: None
// Derived from https://github.com/LlamaLend/contracts/blob/89cd0624873b3f11791725b930009353eac3d632/contracts/LendingPool.sol
pragma solidity ^0.8.17;

import "contracts/algorithms/RateLimited.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

contract LlamaLendLimited is RateLimited {
    uint maxDailyBorrows; // IMPORTANT: an attacker can borrow up to 150% of this limit if they prepare beforehand
    uint currentDailyBorrows;
    uint lastUpdateDailyBorrows;

    constructor(uint _maxDailyBorrows) {
        maxDailyBorrows = _maxDailyBorrows;
    }

    modifier isRateLimited() override {
        // N.B.: slightly changes code structure - previously `doesNotExceedRateLimit()`'s
        // code came immediately before the update to `lastUpdateDailyBorrows`.
        updateDailyBorrows();
        require(doesNotExceedRateLimit(), "Rate limit exceeded");
        hitRateLimit();
        _;
    }

    function updateDailyBorrows() private {
        uint elapsed = block.timestamp - lastUpdateDailyBorrows;

        currentDailyBorrows = (currentDailyBorrows -
            Math.min(
                (maxDailyBorrows * elapsed) / (1 days),
                currentDailyBorrows
            ));

        lastUpdateDailyBorrows = block.timestamp;
    }

    function doesNotExceedRateLimit() public view override returns (bool) {
        return currentDailyBorrows <= maxDailyBorrows;
    }

    function hitRateLimit() public override {
        currentDailyBorrows++;
    }
}
