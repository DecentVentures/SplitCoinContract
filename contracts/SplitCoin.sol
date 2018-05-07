pragma solidity ^0.4.18;
import "./ClaimableSplitCoinLibrary.sol";

contract SplitCoin {

	using CSCLib for CSCLib.CSCStorage;

	CSCLib.CSCStorage lib;

	function SplitCoin(address[] members, uint[] ppms, address refer) public {
		lib.dev_fee = 2500;
		lib.developer = 0xaB48Dd4b814EBcb4e358923bd719Cd5cd356eA16;
		lib.refer_fee = 250;
		lib.init(members, ppms, refer, msg.sender);
	}

	function () public payable {
		lib.payAll();
	}

	function developer() public view returns(address) {
		return lib.developer;
	}

	function splits(uint index) public view returns(address to, uint ppm) {
		return (lib.splits[index].to, lib.splits[index].ppm);
	}

	function getSplitCount() public view returns (uint count) {
		return lib.getSplitCount();
	}

	event SplitTransfer(address to, uint amount, uint balance);
}
