const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules")
const { ethers } = require("hardhat")

// 编译Ballot合约
module.exports = buildModule("BallotModule", (m) => {
    
    const proposals = [
        ethers.encodeBytes32String("p1"),
        ethers.encodeBytes32String("p2"),
        ethers.encodeBytes32String("p3")
    ];
    const ballot = m.contract("Ballot", [proposals]);
    // m.call(ballot, "Status", []);
    return { ballot };
});