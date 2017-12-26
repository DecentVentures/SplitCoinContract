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

	function getSplitCount() public view returns (uint count) {
		return csclib.getSplitCount();
	}

	function splits(uint index) public view returns (address to, uint ppm) {
		return (csclib.splits[index].to, csclib.splits[index].ppm);
	}

	function isClaimable() public view returns (bool) {
		return csclib.isClaimable;
	}

	event SplitTransfer(address to, uint amount, uint balance);

	function claimFor(address user) public {
		csclib.claimFor(user);
	}

	function claim() public {
		csclib.claimFor(msg.sender);
	}

	function getClaimableBalanceFor(address user) public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(user);
	}

	function getClaimableBalance() public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(msg.sender);
	}

	function transfer(address to, uint ppm) public {
		csclib.transfer(to, ppm);
	}
}
