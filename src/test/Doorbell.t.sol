// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../lib/solmate/src/tokens/ERC20.sol";
import "../Doorbell.sol";

contract DoorbellTest is DSTest {
    ERC20 token;
    Doorbell doorbell;

    function setUp() public {
        doorbell = new Doorbell();
        token = new ERC20();
    }

    function testExample() public {
        assertTrue(true);
    }

    function test_getActiveOffers() public {}

    function test_getOfferByIndex() public {}

    function test_makeOffer() public {}

    function testFail_makeOffer_valueMismatch() public {}

    function test_stakeToken() public {
        // should also check that putting in more than target is truncated properly
    }

    function testFail_stakeToken_deadlinePassed() public {}

    function testFail_stakeToken_offererStake() public {}

    function testFail_stakeToken_zeroAmount() public {}

    function testFail_stakeToken_notEnoughERC20() public {}

    function test_execute() public {}

    function testFail_execute_deadlinePassed() public {}

    function testFail_execute_targetNotMet() public {}

    function test_withdraw() public {}

    function testFail_withdraw_deadlineNotPassed() public {}
}
