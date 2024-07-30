const { expect } = require("chai")
const hre = require("hardhat")
const { time, loadFixture, } = require("@nomicfoundation/hardhat-toolbox/network-helpers")


describe("Lock", function () {
    /**
     * 目前每个测试都需要部署合约之类的步骤，这些步骤都是固定的，
     * 所以可以提取出来，单独存放在一个函数中，然后使用network-helpers中的函数loadFixure去读取
     */
    async function deployOneYearLockFixture() {
        // 部署合约时，转入的以太币的数量，这里是1eth=1 000 000 000 wei
        const lockedAmount = 1_000_000_000;

        // 一年转换为秒数
        const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;

        // 设定unlockTime为当前区块的最新的block.timestamp + 1年的秒数
        const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

        /** 
         * 部署合约
         * 使用hre.ethers.deployContract()函数进行部署
         * 第一个参数为合约的名称，是一个字符串
         * 第二个参数为合约的构造器的参数，是一个数组，如果没有可以传一个空数组
         * 第三个数组是一个对像，里面的key，value是交易的参数，是一个可选项，一般用来发送一些eth币的
        */
        const lock = await hre.ethers.deployContract("Lock", [unlockTime], {
            value: lockedAmount,
        });

        return { lock, unlockTime, lockedAmount };
    };

    it("Should set the right unlockTime", async function() {
        // 获取合约对象和检测的时间
        const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

        // 进行断言判断结果和预测的是否一致
        // 判断部署之后的合约的unlockTime和传入的是否一致
        // console.log(await lock.unlockTime());
        // console.log("unlockTime:", unlockTime);
        expect(await lock.unlockTime()).to.equal(unlockTime);
    });

    it("Should revert with the right error if called too soon", async function() {
        const { lock } = await loadFixture(deployOneYearLockFixture);

        /**
         * 进行断言判断结果和预测的是否一致
         * 这是一个行为断言，所以整个操作都是异步的，所以要把await放在外面，
         * 和上面的断言不一样，上面是返回值断言，只有获取返回值操作时异步的，所以把await放在里面
        */
        await expect(lock.withdraw()).to.be.revertedWith("You can't withdraw yet");
    });

    it("Should transfer the funds to the owner", async function() {
        const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

        // 模拟时间流逝到解锁时间
        await time.increaseTo(unlockTime);

        // 调用withdraw()
        await lock.withdraw();
    });

    it("Should revert with the right error if called from another account", async function() {
        const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

        // 获取owner账户和其他账户，使用hre.ethers.getSigners(),返回的是一个array
        const [owner, otherAccount] = await hre.ethers.getSigners();

        // 模式时间流逝
        await time.increaseTo(unlockTime);

        // 使用其他账户去调用withdraw()函数
        await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith("You aren't the owner");
    });
})