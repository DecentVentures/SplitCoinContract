pragma solidity ^0.4.15;
import "./SplitCoin.sol";

contract ClaimableSplitCoin is SplitCoin {

	using ClaimableSplitCoinLibrary for ClaimableSplitCoinLibrary.ClaimableSplitStorage;
	ClaimableSplitStorage lib;

  function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable) public {
		lib.init(members, ppms, refer, claimable);
  }

  function claimFor(address user) claimableMode public {
		return lib.claimFor(user);
  }

  function claim() claimableMode public {
    return lib.claimFor(msg.sender);
  }

  function getClaimableBalanceFor(address user) claimableMode public view returns (uint balance) {
    return lib.getClaimableBalanceFor(user);
  }

  function getClaimableBalance() claimableMode public view returns (uint balance) {
    return lib.getClaimableBalanceFor(msg.sender);
  }

  function transfer(address to, uint ppm) public {
		return lib.transfer(to, ppm);
  }

  function pay() public payable {
		return lib.pay();
  }
}

