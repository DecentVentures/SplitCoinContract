pragma solidity ^0.4.15;
import "./ClaimableSplitCoin.sol";

contract SplitCoinFactory {
	mapping(address => address) public referralContracts;
	mapping(address => address) public referredBy;
	event Deployed (address deployed, address creator, address refer);
	event Referral (address refer, address referred);



	function make(address[] users, uint[] ppms, address refer, bool claimable) public returns (address) {
		address referContract = referredBy[msg.sender];

		if(referContract == 0x0 && refer != 0x0) {
			//new referral
			referContract = handleReferral(msg.sender, refer);
		}
		// create split contract
		address sc = new ClaimableSplitCoin(users, ppms, referContract, claimable);
		Deployed(sc, msg.sender, referContract);
		return sc;
	}

	function handleReferral(address user, address referrer) internal returns (address) {
		address referContract = referralContracts[referrer];
		if(referContract != 0x0 && referrer != user) {
			referredBy[user] = referrer;
			Referral(referrer, user);
		}
		return referContract;
	}

	function generateReferralAddress(address refer) public returns (address) {
		uint[] memory ppms = new uint[](1);
		address[] memory users = new address[](1);
		ppms[0] = 1000000;
		users[0] = msg.sender;

		address referralContract = make(users, ppms, refer, true);
		if(referralContract != 0x0) {
			referralContracts[msg.sender] = referralContract;
		}
		return referralContract;
	}
}
