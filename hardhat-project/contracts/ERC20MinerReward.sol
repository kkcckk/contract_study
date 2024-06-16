// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.4.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ERC20MinerReward is ERC20{

    // 定义一个事件
    event LogNewAlert(string description, address indexed _from, uint256 _n);

    // 继承了ERC20，有一个有参构造器，得传入参数
    constructor() ERC20("MinerReward", "MRW") {

    }

    // 定义一个奖励方法
    function _reward() public {
        // _mint()是ERC20的一个函数，用于给矿工增加相应的代币
        _mint(block.coinbase, 20);
        emit LogNewAlert("_reward", block.coinbase, block.number);
    }
}