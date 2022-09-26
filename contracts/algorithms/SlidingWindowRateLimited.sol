// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "contracts/algorithms/RateLimited.sol";

contract SlidingWindowRateLimited is RateLimited {
    struct SlidingWindowRateLimitRecord {
        uint256 discreteWindowIndex;
        uint256 hitsRecorded;
    }

    uint256 windowLengthSeconds;
    uint256 maxHitsPerWindow;
    uint256 currentWindowStart;
    uint256 currentHits;
    bool expired;

    // buffer[0] should be most recent record
    SlidingWindowRateLimitRecord[2] buffer;

    constructor(uint256 _windowLengthSeconds, uint256 _maxHitsPerWindow) {
        windowLengthSeconds = _windowLengthSeconds;
        maxHitsPerWindow = _maxHitsPerWindow;
    }

    function updateBuffer() private {
        currentWindowStart = block.timestamp / windowLengthSeconds;

        if (currentWindowStart > buffer[0].discreteWindowIndex) {
            buffer[1] = buffer[0];
            buffer[0] = SlidingWindowRateLimitRecord(currentWindowStart, 0);
            expired = true;
        } else {
            expired = false;
        }
    }

    modifier isRateLimited() override {
        updateBuffer();
        require(doesNotExceedRateLimit(), "Rate limit exceeded");
        hitRateLimit();
        _;
    }

    function hitRateLimit() public override {
        // we know buffer has been shuffled by this point
        buffer[0].hitsRecorded++;
    }

    function doesNotExceedRateLimit() public view override returns (bool) {
        if (expired) {
            if (buffer[1].discreteWindowIndex < currentWindowStart - 1) {
                // twa(count(N+1)=0, count(N)=0)
                return true;
            } else {
                // twa(count(N+1)=0, count(N))
                uint256 windowStart = (block.timestamp / windowLengthSeconds) *
                    windowLengthSeconds;
                uint256 propThroughWindow = (1_000 *
                    (block.timestamp - windowStart)) / windowLengthSeconds;

                uint256 avgCount = (propThroughWindow *
                    buffer[0].hitsRecorded) +
                    ((1_000 - propThroughWindow) * buffer[1].hitsRecorded) /
                    1_000;

                return avgCount <= maxHitsPerWindow;
            }
        } else {
            if (buffer[1].discreteWindowIndex < currentWindowStart - 1) {
                // twa(count(N), count(N-1)=0)
                return buffer[0].hitsRecorded <= maxHitsPerWindow;
            } else {
                // twa(count(N), count(N-1))
                uint256 windowStart = (block.timestamp / windowLengthSeconds) *
                    windowLengthSeconds;
                uint256 propThroughWindow = (1_000 *
                    (block.timestamp - windowStart)) / windowLengthSeconds;

                uint256 avgCount = (propThroughWindow *
                    buffer[0].hitsRecorded) +
                    ((1_000 - propThroughWindow) * buffer[1].hitsRecorded) /
                    1_000;

                return avgCount <= maxHitsPerWindow;
            }
        }
    }
}
