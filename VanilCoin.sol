pragma solidity ^0.4.11;

import 'token/MintableToken.sol';

contract VanilCoin is MintableToken {
  	
	string public name = "Vanil";
  	string public symbol = "VAN";
  	uint256 public decimals = 18;
  
  	// tokens locked for one week after ICO, 8 Oct 2017, 0:0:0 GMT: 1507420800
  	uint public releaseTime = 1507420800;
  
	modifier canTransfer(address _sender, uint256 _value) {
		require(_value <= transferableTokens(_sender, now));
	   	_;
	}
	
	function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) returns (bool) {
		return super.transfer(_to, _value);
	}
	
	function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) returns (bool) {
		return super.transferFrom(_from, _to, _value);
	}
	
	function transferableTokens(address holder, uint time) constant public returns (uint256) {
		
		uint256 result = 0;
				
		if(time > releaseTime){
			result = balanceOf(holder);
		}
		
		return result;
	}
	
}