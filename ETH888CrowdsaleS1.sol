pragma solidity ^0.4.11;

import './VanilCoin.sol';
import 'token/MintableToken.sol';
import 'math/SafeMath.sol';

contract ETH888CrowdsaleS1 {

	using SafeMath for uint256;
	
	// The token being sold
	MintableToken public token;
	
	// address where funds are collected
	address public wallet;
	
	// how many token units a buyer gets per wei
	uint256 public rate = 1250;
	
	// timestamps for ICO starts and ends
	uint public startTimestamp;
	uint public endTimestamp;
	
	// amount of raised money in wei
	uint256 public weiRaised;
	
	// first round ICO cap
	uint256 public cap;
	
	/**
	   * event for token purchase logging
	   * @param purchaser who paid for the tokens
	   * @param beneficiary who got the tokens
	   * @param value weis paid for purchase
	   * @param amount amount of tokens purchased
	   */ 
	event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
	
	function ETH888CrowdsaleS1(address _wallet) {
		
		require(_wallet != 0x0);
		
		// 11 Aug 2017, 00:00:00 GMT: 1502409600
		startTimestamp = 1502409600;
		
		// 30 Sep 2017, 23:59:59 GMT: 1506815999
		endTimestamp = 1506815999;
		
		token = createTokenContract();
		
		// maximum 8000 ETH for this stage 1 crowdsale
		cap = 8000 ether;
		
		wallet = _wallet;
	}
		
	// fallback function can be used to buy tokens
	function () payable {
	    buyTokens(msg.sender);
	}
	
	// low level token purchase function
	function buyTokens(address beneficiary) payable {
		require(beneficiary != 0x0);
		require(validPurchase());

		uint256 weiAmount = msg.value;

		// calculate token amount to be created
		uint256 tokens = weiAmount.mul(rate);

		// update state
		weiRaised = weiRaised.add(weiAmount);

		token.mint(beneficiary, tokens);
		TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

		forwardFunds();
	}

	// send ether to the fund collection wallet
	function forwardFunds() internal {
		wallet.transfer(msg.value);
	}	
	
	// @return true if investors can buy at the moment
	function validPurchase() internal constant returns (bool) {
		bool withinCap = weiRaised.add(msg.value) <= cap;
		
		uint current = now;
		bool withinPeriod = current >= startTimestamp && current <= endTimestamp;
		bool nonZeroPurchase = msg.value != 0;
		
		return withinPeriod && nonZeroPurchase && withinCap && msg.value >= 1000 szabo;
	}

	// @return true if crowdsale event has ended
	function hasEnded() public constant returns (bool) {
		bool capReached = weiRaised >= cap;
		
		return now > endTimestamp || capReached;
	}
	
	// creates the token to be sold.
	function createTokenContract() internal returns (MintableToken) {
		return new VanilCoin();
	}
	
}