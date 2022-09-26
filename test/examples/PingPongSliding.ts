import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PingPongSliding, PingPongSliding__factory } from "../../typechain-types";

const ONE_HOUR = 60 * 60;
const WINDOW = 60;
const MAX_HITS = 10;

describe("PingPongSliding", function () {
    let owner: SignerWithAddress;
    let caller: SignerWithAddress;
    let factory: PingPongSliding__factory;
    let pingPong: PingPongSliding;

    before(async function () {
        const [_owner, _caller] = await ethers.getSigners();
        owner = _owner;
        caller = _caller;

        factory = await ethers.getContractFactory("PingPongSliding");
    });

    beforeEach(async function () {
        await ethers.provider.send("evm_increaseTime", [ONE_HOUR]);
        await ethers.provider.send("evm_mine", []);

        pingPong = await factory.deploy();

        await pingPong.deployed();

    });

    this.afterEach(async function () {
        await ethers.provider.send("hardhat_reset", []);
    });

    it("should call the ping() function and return the expected result", async function () {
        expect(await pingPong.callStatic.ping()).to.equal("pong");
    });

    it("should allow calls to ping() up until the rate limit", async function () {
        for (let i = 0; i < MAX_HITS; i++) {
            await (await pingPong.ping()).wait();
        }
    });

    it("should revert calls to ping() exceeding the rate limit", async function () {
        for (let i = 0; i < MAX_HITS; i++) {
            await (await pingPong.ping()).wait();
        }
        
        expect(await pingPong.ping()).to.be.revertedWith("Rate limit exceeded");
    });

    it("should reset the rate limit when enough time has passed", async function () {
        for (let i = 0; i < MAX_HITS; i++) {
            await (await pingPong.ping()).wait();
        }
        
        expect(await pingPong.ping()).to.be.revertedWith("Rate limit exceeded");

        await ethers.provider.send("evm_increaseTime", [ONE_HOUR]);

        for (let i = 0; i < MAX_HITS; i++) {
            await (await pingPong.ping()).wait();
        }

    });

    it("should enforce an average rate", async function () {
        // get 'current' timestamp
        await ethers.provider.send("evm_mine", []);
        const block = await ethers.provider.send("eth_getBlockByNumber", ["latest", false]);

        // we want to arrive in the final 10% of the current window
        const secondsToForward = WINDOW - (block.timestamp % WINDOW) + (WINDOW * 0.8);

        // then wait until the next window has started
        const secondsToWait = (WINDOW * 0.4);

        await ethers.provider.send("evm_increaseTime", [Math.round(secondsToForward)]);

        // use up our rate limit for the current window
        for (let i = 0; i < MAX_HITS; i++) {
            await (await pingPong.ping()).wait();
        }
        
        // mine a block so that block.timestamp is increased
        await ethers.provider.send("evm_mine", []);

        // wait until the next window has begun
        await ethers.provider.send("evm_increaseTime", [Math.round(secondsToWait)]);

        // get away with one extra request
        await (await pingPong.ping()).wait();

        // then bump into the average rate limit
        expect(await pingPong.ping()).to.be.revertedWith("Rate limit exceeded");

    });
});
