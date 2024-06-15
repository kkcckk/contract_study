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
        // 委派地址
        address delegate;
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
    Proposal[] public proposals;

    // 投票人，通过地址进行映射
    mapping(address => Voter) public voters;

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
            proposals.push(
                Proposal({shortName: proposalNames[i], voteCount: 0})
            );

            /**
             * 注意，先创建结构体实例再push进数组会消耗更多的gas，因为要先分配内存空间存储结构体的临时变量，之后再push进数组，两步操作都要消耗gas；
             * 而直接将结构体实例push进数组，只有一步操作，减少了内存分配的这一步开销，会消耗更少的gas，
             * 以后只使用直接push结构体实例进数组这一方式
             */
        }
    }

    // 权限修饰器，用于指定giveRight2Address函数只能被chairperson调用
    modifier onlyOwner() {
        require(
            chairperson == msg.sender,
            "Access denied, only chairperson can use."
        );
        _;
    }

    // 分发投票数量给每个地址,只有投票发起人可以调用
    function giveRight2Address(address voterAddress) public onlyOwner {
        // 找出传入的地址对应的voter
        // Voter memory v = voters[voterAddress];
        // 只有chairperson有权利调用这个函数
        // require(msg.sender == chairperson, "Access denied, only chairperson can use");
        // 判断 传入地址是否投票
        require(!voters[voterAddress].voted, "You have already voted.");

        // 如果没有投票，那么必须要给予一张选票
        require(voters[voterAddress].weight == 0, "the address already have the weight");

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
        /**
         * 首先要做一些判断：
         * 1. 首先委托者不能投过票了，投票过了就没有权力进行委托了
         * 2. 其次委托者的权重必须是大于0,大于0说明有选票
         * 3. 最后不能自己委托自己
         */

        // 找出委托地址, 因为要改变状态，所以用storage存储位置，其实就是找出调用这个函数的人，即msg.sender
        Voter storage dv = voters[msg.sender];

        // 进行条件判断
        require(!dv.voted, "This address has been voted.");

        // 权重大于0
        require(dv.weight > 0, "You don't have the right to vote");

        // 地址不能是自己
        require(msg.sender != to, "You can't deletegate yourself.");

        // 循环找出最终的委派地址，因为可能委派的人其实把把自己的权力委派出去了
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            // 要求to不能是msg.sender
            require(to != msg.sender, "Address can not be msg.sender");
        }

        // 认为委派地址必须是有投票权利的
        require(voters[to].weight >= 1, "voter don't have the right to vote");

        // 找出最终委派地址后，如果投票了，直接给对应的提案票数+1
        // 如果没有投票，则把委托地址的权重加给委派地址的权重
        if (!voters[to].voted) {
            voters[to].weight += dv.weight;
        } else {
            proposals[voters[to].vote].voteCount += dv.weight;
        }

        // 同时改变一下委托者的状态
        dv.voted = true;
        dv.weight = 0;
        dv.delegate = to;
    }

    // 给提案投票投票
    function vote(uint proposal) external {
        // 找出调用这个函数的sender，如果sender没有投票，则把sender的票加到对应提案中
        require(voters[msg.sender].weight > 0, "Sender has no right to vote.");
        require(!voters[msg.sender].voted, "Sender has already voted.");

        // 开始加票
        proposals[proposal].voteCount += voters[msg.sender].weight;

        // 改变状态
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = proposal;
    }

    // 找出最终票数最多的提案编号
    function winningProposal() private view returns (uint winningProposal_) {
        // 循环比较，找出提案编号
        // uint winningProposal_ = 0;
        // 投票数
        uint voteCount = 0;

        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > voteCount) {
                voteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }

        // return winningProposal_;
    }

    // 返回提案名称
    function winningProposalName()
        external
        view
        returns (bytes32 winningProposalName_)
    {
        winningProposalName_ = proposals[winningProposal()].shortName;
    }
}
