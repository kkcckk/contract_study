const { expect } = require("chai");
// const hre = require("hardhat");
const { ethers } = require("hardhat");

/**
 * 这是一个测试合约Ballot用例
 */
describe("Ballot", function () {
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
  beforeEach(async function () {
    // 从hardhat中获取测试用户账户
    // [chairperson, v1, v2] = await ethers.getSigners();
    [chairperson, v1, v2] = await ethers.getSigners();

    // 构建提案
    const proposalNames = [
      ethers.encodeBytes32String("p1"),
      ethers.encodeBytes32String("p2"),
      ethers.encodeBytes32String("p3"),
    ];

    // 获取Ballot
    Ballot = await ethers.getContractFactory("Ballot");
    // 部署合约
    ballot = await Ballot.deploy(proposalNames);
  });

  // 用于检查是否是投票发起人调用的合约
  it("Should set the right chairperson", async function () {
    // console.log("开始验证")
    expect(await ballot.chairperson()).to.equal(chairperson.address);
  });

  // 判断是否初始化成功提案
  it("Should initialize proposals correctly", async function () {
    // 找出三个提案
    // 从合约中的数组中获取元素
    const p1 = await ballot.proposals(0);
    const p2 = await ballot.proposals(1);
    const p3 = await ballot.proposals(2);

    // 开始验证提案是否初始化成功
    expect(p1.shortName).to.equal(ethers.encodeBytes32String("p1"));
    expect(p2.shortName).to.equal(ethers.encodeBytes32String("p2"));
    expect(p3.shortName).to.equal(ethers.encodeBytes32String("p3"));
  });

  // 是否成功分配投票权
  it("Should give right to vote", async function () {
    // 调用giveRight2Address
    await ballot.giveRight2Address(v1.address);

    // 找出v1
    const voter = await ballot.voters(v1.address);
    // const voter = await ballot.voters[v1.address];

    // 验证是否成功给v1分配投票权，正常情况下分配成功之后，投票者的weight>0
    expect(voter.weight).to.equal(1);
  });

  // 验证是否其他地址也有权力分配投票权
  it("Should not give right to vote if not chairperson", async function () {
    // 使用voter1的地址去调用合约的giveRight2Address
    await expect(
      ballot.connect(v2).giveRight2Address(v1.address)
    ).to.be.revertedWith("Access denied, only chairperson can use.");
  });

  // 验证是否能成功将选票委派给其他地址
  it("Should allow a voter delegate to their vote", async function () {
    // 分配选票v1 v2
    await ballot.giveRight2Address(v1.address);
    await ballot.giveRight2Address(v2.address);

    // v1把选票委派给v2
    await ballot.connect(v1).delegate(v2.address);

    // 找出合约中保存的票民的信息
    const v1Info = await ballot.voters(v1.address);
    const v2Info = await ballot.voters(v2.address);

    // 判断是否委派成功
    expect(v1Info.delegate).to.equal(v2.address);
    expect(v2Info.weight).to.equal(2);
  });

  // 验证是否能投票
  it("Should allow voting and track vote count", async function () {
    await ballot.giveRight2Address(v1.address);
    await ballot.connect(v1).vote(0);

    // 找出数组中index为0的提案
    const proposal = await ballot.proposals(0);

    expect(proposal.voteCount).to.equal(1);
  });

  // 测试找出提案票数最多的
  it("Should compute the winning proposal correctly", async function () {
    await ballot.giveRight2Address(v1.address);
    await ballot.giveRight2Address(v2.address);

    await ballot.connect(v1).vote(0);
    await ballot.connect(v2).vote(0);

    expect(await ballot.winningProposalName()).to.equal(
      ethers.encodeBytes32String("p1")
    );
  });

  // 测试防止多次投票
  it("Should prevent double voting", async function () {
    await ballot.giveRight2Address(v1.address);
    await ballot.connect(v1).vote(0);

    await expect(ballot.connect(v1).vote(0)).to.be.revertedWith(
      "Sender has already voted."
    );
  });

  // 测试地址没有投票权而调用vote去投票
  it("Should prevent voting without right", async function () {
    await expect(ballot.connect(v1).vote(0)).to.be.revertedWith(
      "Sender has no right to vote."
    );
  });

  // 测试地址能否自我委派
  it("Should prevent self-delegation", async function () {
    await ballot.giveRight2Address(v1.address);
    await expect(ballot.connect(v1).delegate(v1.address)).to.be.revertedWith(
      "You can't deletegate yourself."
    );
  });
});
