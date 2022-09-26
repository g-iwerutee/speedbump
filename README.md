# speedbump

Implements global rate limiters for Solidity contracts.

## TODO:

- [x] Global rate limiters
    - [x] `FixedWindow`
    - [x] `SlidingWindow`
- [ ] Scoped rate limiters (e.g. by address / account key)
- [ ] Quantity-based rate limiters (e.g. quantity/time limits)

## Local development:

```shell
npm install --save-dev      // install dependencies
npx hardhat test            // run tests
```
