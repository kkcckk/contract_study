// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.4.25 <0.9.0;

contract Shipping {
    // 预先定义好枚举值，表示商品的状态
    enum ShippingStatus {
        Pending,
        Shipping,
        Delivered
    }

    // 状态
    ShippingStatus private status;

    // 定义事件，如果状态改变使用该事件进行记录
    event LogNewAlert(string logStr);

    // 使用构造器初始化货物的状态
    constructor(){
        status = ShippingStatus.Pending;
    }

    // 状态改变为Shipping
    function setShipping() public {
        status = ShippingStatus.Shipping;
        emit LogNewAlert("Your package has been shipping");
    }

    // 状态改变Delivered
    function setDelivered() public {
        status = ShippingStatus.Delivered;
        emit LogNewAlert("Your package has been delievered");
    }

    // 内部判断状态之后，有枚举值转换为unicode字面值
    function getStatusInterval(ShippingStatus _status) internal pure returns(string memory status_) {
        if (_status == ShippingStatus.Pending) return "Pending";
        if (_status == ShippingStatus.Shipping) return "Shipping";
        if (_status == ShippingStatus.Delivered) return "Delivered";
        // return "\u672a\u77e5\u72b6\u6001";
    }

    // 供外部使用获取货物状态
    function getStatus() public view returns(string memory status_) {
        ShippingStatus _status = status;
        return getStatusInterval(_status);
    }
}
