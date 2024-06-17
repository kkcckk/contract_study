// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.4.22 <0.9.0;

contract TodoList {
    // 任务数量
    uint256 public taskCount = 0;

    // 定义任务结构体
    struct Task {
        // 任务id
        uint256 id;
        // 任务名称
        string taskName;
        // 是否运行
        bool status;
    }

    // 使用任务id映射task
    mapping(uint256 => Task) public tasks;

    // 定义一个事件，任务创建时调用
    event TaskCreated(uint256 id, string taskName, bool status);

    // 状态转换事件
    event TaskStatus(uint id, bool status);

    constructor() {
        // 合约创建的时候调用创建事件函数
        createTask("Todo List Tutorial");
    }

    // 创建task
    function createTask(string memory _taskName) public {
        // 创建一个task，任务总数自增1
        taskCount++;
        tasks[taskCount] = Task({
            id: taskCount,
            taskName: _taskName,
            status: false
        });

        // 创建task触发一个事件
        emit TaskCreated(taskCount, _taskName, false);
    }

    // 切换状态
    function toggleStatus(uint256 _id) public {
        // 转换状态，true->false或者false->true
        tasks[_id].status = !tasks[_id].status;

        // 切换状态后触发事件
        emit TaskStatus(_id, tasks[_id].status);
    }
}
