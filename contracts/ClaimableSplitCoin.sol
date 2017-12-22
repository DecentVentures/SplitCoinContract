pragma solidity ^0.4.18;
import "./ClaimableSplitCoinLibrary.sol";

contract ClaimableSplitCoin {

	using CSCLib for CSCLib.CSCStorage;

	CSCLib.CSCStorage csclib;

	function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable) public {
		csclib.isClaimable = claimable;
		csclib.dev_fee = 2500;
		csclib.developer = 0xaB48Dd4b814EBcb4e358923bd719Cd5cd356eA16;
		csclib.refer_fee = 250;
		csclib.init(members, ppms, refer);
	}

	function () public payable {
		csclib.pay();
	}

	function developer() public view returns(address) {
		return csclib.developer;
	}

	function splits(uint index) public view returns(CSCLib.Split) {
		return csclib.splits[index];
	}

	function getSplitCount() public view returns (uint count) {
		return csclib.getSplitCount();
	}

	event SplitTransfer(address to, uint amount, uint balance);

	function claimFor(address user) public {
		return csclib.claimFor(user);
	}

	function claim() public {
		return csclib.claimFor(msg.sender);
	}

	function getClaimableBalanceFor(address user) public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(user);
	}

	function getClaimableBalance() public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(msg.sender);
	}

	function transfer(address to, uint ppm) public {
		return csclib.transfer(to, ppm);
	}
}
