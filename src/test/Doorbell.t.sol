// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "../Doorbell.sol";
import "./MockERC20.sol";
import "./Console.sol";

interface Vm {
    // Set block.timestamp (newTimestamp)
    function warp(uint256) external;
    // Set block.height (newHeight)
    function roll(uint256) external;
    // Loads a storage slot from an address (who, slot)
    function load(address,bytes32) external returns (bytes32);
    // Stores a value to an address' storage slot, (who, slot, value)
    function store(address,bytes32,bytes32) external;
    // Signs data, (privateKey, digest) => (r, v, s)
    function sign(uint256,bytes32) external returns (uint8,bytes32,bytes32);
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
    // Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);
    // Performs the next smart contract call with specified `msg.sender`, (newSender)
    function prank(address) external;
    // Performs all the following smart contract calls with specified `msg.sender`, (newSender)
    function startPrank(address) external;
    // Stop smart contract calls using the specified address with prankStart()
    function stopPrank() external;
    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;
    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;
    // Expects an error on next call
    function expectRevert(bytes calldata) external;
}

contract DoorbellTest is DSTest {
    MockERC20 token;
    Doorbell doorbell;
    Vm evm;

    function setUp() public {
        doorbell = new Doorbell();
        token = new MockERC20();
        evm = Vm(address(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D));
        evm.deal(address(this), 10_000_000 ether);
        // mint 1M tokens to self
        token.mint(address(this), 1e24);
    }

    function testExample() public {
        assertTrue(true);
    }

    function test_getActiveOffers() public {}

    function test_getOfferByIndex() public {}

    function test_makeOffer() public {
        // 1 million tokens for 100 ETH
        doorbell.makeOffer{ value: 100 ether }(
            address(token), 
            1_000_000 ether, 
            1e14, 
            block.timestamp + 1 days
        );
        Offer memory off = doorbell.getOfferByIndex(0);
        assertEq(off.token, address(token));
        assertEq(off.offerer, address(this));
        assertEq(off.target, 1_000_000 ether);
        assertEq(off.decimals, 18);
        assertEq(off.price, 1e14);
        assertEq(off.deadline, block.timestamp + 1 days);
    }

    function testFail_makeOffer_valueMismatch() public {
        doorbell.makeOffer{ value: 99 ether }(
            address(token), 
            1_000_000 ether, 
            1e14, 
            block.timestamp + 1 days
        );
    }

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
