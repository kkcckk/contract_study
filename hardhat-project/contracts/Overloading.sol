// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.4.25 <0.9.0;

contract Overloading {
    function f(uint8 _n) public pure returns(uint8 out) {
        out=_n;
    }

    function f(uint256 _n) public pure returns(uint256 out) {
        out = _n;
    }
}
