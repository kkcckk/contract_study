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
    event LogAlert(string logStr);

    // 使用构造器初始化货物的状态
    constructor(){
        status = ShippingStatus.Pending;
    }

    // 状态改变为Shipping
    function setShipping() public {
        status = ShippingStatus.Shipping;
        emit LogAlert("\u8d27\u7269\u7684\u72b6\u6001\u6709Pending\u53d8\u4e3aShipping");
    }

    // 状态改变Delivered
    function setDelivered() public {
        status = ShippingStatus.Delivered;
        emit LogAlert("\u8d27\u7269\u7684\u72b6\u6001\u6709Shipping\u53d8\u4e3aDelivered");
    }

    // 内部判断状态之后，有枚举值转换为unicode字面值
    function getStatusInterval(ShippingStatus _status) internal pure returns(string memory) {
        if (_status == ShippingStatus.Pending) return "Pending";
        if (_status == ShippingStatus.Shipping) return "Shipping";
        if (_status == ShippingStatus.Delivered) return "Delivered";
        return "\u672a\u77e5\u72b6\u6001";
    }

    // 供外部使用获取货物状态
    function getStatusExternal() public view returns(string memory) {
        ShippingStatus _status = status;
        return getStatusInterval(_status);
    }
}
