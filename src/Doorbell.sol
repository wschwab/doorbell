// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/// @title Doorbell
/// @author @wschwab
/// @notice Allows trustless buyout of a precentage of an ERC20 token at a given price in ETH
/// @dev Offerer must put up full amount, cannot reneg, offer must be executed before deadline
/// @dev contract may accumulate ETH dust

import "../lib/solmate/src/utils/SafeTransferLib.sol";
import "../lib/solmate/src/utils/ReentrancyGuard.sol";

//TODO: consider failure cases with payouts

struct Offer {
  // address of offer creator
  address offerer;
  // address of token to purchase
  address token;
  // target amount of token to buy
  uint256 target;
  // amount of target staked to date
  uint256 staked;
  // price in ETH to pay for token
  uint256 price;
  // target amount must be accrued by deadline
  uint256 deadline;
}
contract Doorbell is ReentrancyGuard {
  using SafeTransferLib for ERC20;

  mapping(uint256 => Offer) private offers;
  // index => staker => amount
  mapping(uint256 => mapping(address => uint256)) private staked;
  mapping(uint256 => address[]) private stakers;
  uint256 private offerCounter;

  event OfferMade(address indexed token, address indexed offerer, uint256 target, uint256 price, uint256 deadline);
  event TokensStaked(uint256 indexed offer, address indexed staker, uint256 amount, uint256 indexed amountRemaining);
  event OfferExecuted(uint256 index);
  event Withdrawal(uint256 index, address withdrawer);

  function getActiveOffers() external view returns(Offer[] memory) {
    Offer[] memory allOffers;
    for (uint256 i = 0; i < offerCounter; i++) {
      if (offers[i].deadline >= block.timestamp) continue;
      allOffers[i] = offers[i];
    }
    return allOffers;
  }

  function getOfferByIndex(uint256 index) external view returns(Offer memory){
    return offers[index];
  }
  
  function makeOffer(
    address _token,
    uint256 _target,
    uint256 _price,
    uint256 _deadline
  ) external payable {
    require(msg.value >= _price * _target, "insuffient ETH sent");
    offers[offerCounter] = Offer({
      offerer: msg.sender,
      token: _token,
      target: _target,
      staked: 0,
      price: _price,
      deadline: _deadline
    });

    offerCounter++;

    emit OfferMade(_token, msg.sender, _target, _price, _deadline);
  }

  //TODO: rewrite so that cannot deposit more than target
  function stakeToken(uint256 index, uint256 amount) external {
    // load offer into memory for cheaper reference
    Offer memory off = offers[index];
    require(block.timestamp < off.deadline, "offer closed");
    require(msg.sender != off.offerer, "cannot stake in own offer");

    uint256 amountRemaining = off.target - off.staked;
    uint256 finalAmount = amountRemaining > amount ? amount : amountRemaining;
    off.staked += finalAmount;
    // recalculating for the event at the end
    amountRemaining = off.target - off.staked;

    ERC20 token = ERC20(off.token);
    token.safeTransferFrom(msg.sender, address(this), finalAmount);
    
    if (staked[index][msg.sender] == 0) stakers[index].push(msg.sender);
    staked[index][msg.sender] += finalAmount;

    offers[index].staked = off.staked;
    emit TokensStaked(index, msg.sender, finalAmount, amountRemaining);
  }
  function exectue(uint256 index) external nonReentrant {
    // load offer into memory
    Offer memory off = offers[index];
    require(block.timestamp <= off.deadline, "deadline passed");
    require(off.staked >= off.target, "target not met");

    uint256 totalPrice = off.target * off.price;

    for (uint256 i = 0; i < stakers[index].length; i++) {
      uint256 ratio = staked[index][msg.sender] * 1e18 / off.staked;
      ratio /= 1e18;

      (bool success,) = msg.sender.call{value: totalPrice / ratio}("");
    }

    ERC20 token = ERC20(off.token);
    token.safeTransfer(off.offerer, off.staked);

    emit OfferExecuted(index);
  }
  function withdraw(uint256 index) external nonReentrant {
    // load offer into memory
    Offer memory off = offers[index];
    require(block.timestamp >= off.deadline, "offer still active");
    // for the initial deposit
    if(msg.sender == off.offerer) {
      (bool success,) = msg.sender.call{value: off.price * off.target}("");
    } else {
      ERC20 token = ERC20(off.token);
      token.safeTransfer(msg.sender, staked[index][msg.sender]);
    }

    emit Withdrawal(index, msg.sender);
  }
}
