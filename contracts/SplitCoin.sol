pragma solidity ^0.4.15;

import "./SplitCoinLibrary.sol";

contract SplitCoin {

	struct Split {
		address to;
		uint ppm;
	}

	using SCLib for SCLib.SplitStorage;

	SCLib.SplitStorage lib;

	function SplitCoin(address[] members, uint[] ppms, address refer) public {
		lib.dev_fee = 2500;
		lib.developer = 0xaB48Dd4b814EBcb4e358923bd719Cd5cd356eA16;
		lib.refer_fee = 250;
		lib.init(members, ppms, refer);
	}

	function () public payable {
		lib.pay();
	}

	function splits(uint index) public view returns(SCLib.Split) {
		return lib.splits[index];
	}
	function getSplitCount() public view returns (uint count) {
		return lib.getSplitCount();
	}

	event SplitTransfer(address to, uint amount, uint balance);
}
