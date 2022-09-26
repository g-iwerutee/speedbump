// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract RateLimited {
    function hitRateLimit() public virtual;

    function doesNotExceedRateLimit() public view virtual returns (bool);

    modifier isRateLimited() virtual;
}
