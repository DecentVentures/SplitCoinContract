pragma solidity ^0.4.15;
import "./SplitCoin.sol";

contract SplitCoinFactory {
	mapping(address => address[]) public contracts;
  event Deployed (
    address _deployed
  );
	function make(address[] users, uint[] ppms, address refer) public returns (address) {
		SplitCoin sc = new SplitCoin(users, ppms, refer);
		contracts[msg.sender].push(sc);
    Deployed(sc);
		return sc;
	}
}
