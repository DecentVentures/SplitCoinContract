pragma solidity ^0.4.18;
import "./ClaimableSplitCoinLibrary.sol";

contract ClaimableSplitCoin is SplitCoin {

	using CSCLib for CSCLib.CSCStorage;

	CSCLib.CSCStorage csclib;

	function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable) SplitCoin(members, ppms, refer) public {
		csclib.isClaimable = claimable;
		csclib.lib = lib;
	}

	function () public payable {
		csclib.pay();
	}

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
