pragma solidity ^0.4.15;

contract SplitCoin {

	using SplitCoinLibrary for SplitCoinLibrary.SplitStorage;

	SplitCoinLibrary.SplitStorage lib;

	function SplitCoin(address[] members, uint[] ppms, address refer) public {
		lib.init(members, ppms, refer);
	}

	function () public payable {
		lib.pay();
	}

	function getSplitCount() public view returns (uint count) {
		return lib.getSplitCount();
	}

	event SplitTransfer(address to, uint amount, uint balance);
}
