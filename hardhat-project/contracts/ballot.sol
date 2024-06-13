// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.7.0 <0.9.0;

// 投票合约
contract Ballot {
    // 创建投票结构体 Voter
    struct Voter {
        // 投票权重
        uint weight;
        // 是否投过票
        bool voted;
        // 投票的提案的编号
        uint vote;
    }
    
    // 创建提案结构体 Proposal
    struct Proposal {
        // 提案的名称
        bytes32 shortName;
        // 投票的票数
        uint voteCount;
    }

    // 投票发起人
    address public chairperson;

    // 提案数组
    Proposal[] proposals;
    
    // 投票人，通过地址进行映射
    mapping (address => Voter) voters;

    // 构造器，会初始化投票发起人，和提案数组
    constructor(bytes32[] memory proposalNames) {
        // 初始化投票发起人
        chairperson = msg.sender;
        // 赋予投票权重，创建voter后，weight都会赋值为1
        voters[chairperson].weight = 1;

        // 初始化提案
        for (uint i = 0; i < proposalNames.length; i++) {
            // 创建结构体
            // 方式1
            // Proposal memory p = Proposal(proposalNames[i], 0);

            // 方式2
            // Proposal memory p = Proposal({shortName: proposalNames[i], voteCount: 0});
            proposals.push(Proposal({shortName: proposalNames[i], voteCount: 0}));

            /**
             * 注意，先创建结构体实例再push进数组会消耗更多的gas，因为要先分配内存空间存储结构体的临时变量，之后再push进数组，两步操作都要消耗gas；
             * 而直接将结构体实例push进数组，只有一步操作，减少了内存分配的这一步开销，会消耗更少的gas，
             * 以后只使用直接push结构体实例进数组这一方式
             */
        }
    }

    // 权限修饰器，用于指定giveRight2Address函数只能被chairperson调用
    modifier onlyOwner {
        require(chairperson == msg.sender, "Access denied, only chairperson can use.");
        _;
    }

    // 分发投票数量给每个地址,只有投票发起人可以调用
    function giveRight2Address(address voterAddress) public onlyOwner{
        // 找出传入的地址对应的voter
        // Voter memory v = voters[voterAddress];
        // 只有chairperson有权利调用这个函数
        // require(msg.sender == chairperson, "Access denied, only chairperson can use");
        // 判断 传入地址是否投票
        require(voters[voterAddress].voted, "You have already voted.");

        // 如果没有投票，那么必须要给予一张选票
        require(voters[voterAddress].weight == 0);

        voters[voterAddress].weight = 1;

        // 再把数据写入
        // voters[voterAddress] = v;

        /**
         * 注意：先读数据，修改，再写入会消耗更多的gas，因为读和写都需要消耗gas
         * 如果直接操作map[key].property，仅需要完成一次写入操作，会消耗更少的gas，
         * 所以以后注意只使用直接操作的方式
         */
    }

    // 投票者可以委派别人投票
    function delegate(address to) public {
        
    }
}