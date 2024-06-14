const { expect } = require("chai")
const { ethers } = require("hardhat")

/**
 * 这是一个测试合约Ballot用例
 */
describe("Ballot", function() {
    // 合约
    let Ballot;
    // 合约对象
    let ballot;
    // 投票发起人;
    let chairperson;
    // 投票者1
    let v1;
    // 投票者2
    let v2;

    // 每次测试之前都重新部署一次合约
    this.beforeEach(async function() {
        // 从hardhat中获取测试用户账户
        [chairperson, v1, v2] = await ethers.getSigners();

        // 构建提案
        const proposalName = [ethers.utils.formatBytes32String("p1"), ethers.utils.formatBytes32String("p2"), ethers.utils.formatBytes32String("p3")];
        // 获取Ballot
        Ballot = await ethers.getContractFactory("Ballot");
        // 部署合约
        ballot = await Ballot.deploy(proposalName);
    });

    it("Should set the right chairperson", async function(){
        expect(await ballot.chairperson)
    })
})

