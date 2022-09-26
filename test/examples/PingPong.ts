import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PingPong, PingPong__factory } from "../../typechain-types";

const ONE_HOUR = 60 * 60;

describe("PingPong", function () {
    let owner: SignerWithAddress;
    let caller: SignerWithAddress;
    let factory: PingPong__factory;
    let pingPong: PingPong;

    before(async function () {
        const [_owner, _caller] = await ethers.getSigners();
        owner = _owner;
        caller = _caller;

        factory = await ethers.getContractFactory("PingPong");
    });

    beforeEach(async function () {
        pingPong = await factory.deploy();

        await pingPong.deployed();

    });

    it("should return a pong to our ping", async function () {
        expect(await pingPong.callStatic.ping()).to.equal("pong");
    });

    it("should allow calls up until the rate limit", async function () {
        for (let i = 0; i < 10; i++) {
            await (await pingPong.ping()).wait();
        }
    });

    it("should revert calls exceeding the rate limit", async function () {
        for (let i = 0; i < 10; i++) {
            await (await pingPong.ping()).wait();
        }
        
        expect(await pingPong.ping()).to.be.revertedWith("Rate limit exceeded");
    });

    it("should reset the rate limit when enough time has passed", async function () {
        for (let i = 0; i < 10; i++) {
            await (await pingPong.ping()).wait();
        }
        
        expect(await pingPong.ping()).to.be.revertedWith("Rate limit exceeded");

        await ethers.provider.send("evm_increaseTime", [ONE_HOUR]);

        await (await pingPong.ping()).wait();
    });
});
