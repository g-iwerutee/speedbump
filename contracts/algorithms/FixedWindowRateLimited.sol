// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/RateLimited.sol";

contract FixedWindowRateLimited is RateLimited {
    uint256 windowLengthSeconds;
    uint256 maxHitsPerWindow;
    uint256 currentWindowStart;
    uint256 currentHits;

    constructor(uint256 _windowLengthSeconds, uint256 _maxHitsPerWindow) {
        windowLengthSeconds = _windowLengthSeconds;
        maxHitsPerWindow = _maxHitsPerWindow;
        currentWindowStart = block.timestamp / windowLengthSeconds;
    }

    function hitRateLimit() public override {
        uint256 currentWindow = block.timestamp / windowLengthSeconds;

        if (currentWindow == currentWindowStart) {
            currentHits++;
        } else if (currentWindow > currentWindowStart) {
            currentWindowStart = currentWindow;
            currentHits = 1;
        }
    }

    function doesNotExceedRateLimit() public view override returns (bool) {
        uint256 currentWindow = block.timestamp / windowLengthSeconds;

        if (currentWindow == currentWindowStart) {
            return currentHits <= maxHitsPerWindow;
        } else {
            return true;
        }
    }

    modifier isRateLimited() override {
        require(doesNotExceedRateLimit(), "Rate limit exceeded");
        hitRateLimit();
        _;
    }
}
