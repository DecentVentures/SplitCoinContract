pragma solidity ^0.4.15;
import "./SplitCoin.sol";

library ClaimableSplitCoinLibrary {

	using SplitCoinLibrary for SplitCoinLibrary.SplitStorage;

	struct ClaimableSplitStorage {
		mapping(address => uint) lastUserClaim;
		uint[] deposits;
		bool public isClaimable = false;
		SplitCoinLibrary.SplitStorage base;
	}

	function init(ClaimableSplitStorage storage self, address[] members, uint[] ppms, address refer, bool claimable) public {
		self.base.init(members, ppms, refer);
		self.isClaimable = claimable;
	}

	modifier claimableMode(ClaimableSplitStorage storage self) {
		require(self.isClaimable == true);
		_;
	}

	function claimFor(ClaimableSplitStorage storage self, address user) claimableMode public {
		uint sum = getClaimableBalanceFor(user);
		uint splitIndex = self.userSplit[user];
		self.lastUserClaim[user] = self.deposits.length;
		require(self.splits[splitIndex].to.call.gas(60000).value(sum)());
		SplitTransfer(self.splits[splitIndex].to, sum, self.balance);
	}

	function claim(ClaimableSplitStorage storage self) claimableMode public {
		return claimFor(msg.sender);
	}

	function getClaimableBalanceFor(ClaimableSplitStorage storage self, address user) claimableMode public view returns (uint balance) {
		uint splitIndex = self.userSplit[user];
		uint lastClaimIndex = self.lastUserClaim[user];
		uint unclaimed = 0;
		if(self.splits[splitIndex].to == user) {
			for(uint depositIndex = lastClaimIndex; depositIndex < self.deposits.length; depositIndex++) {
				uint value = self.deposits[depositIndex] * self.splits[splitIndex].ppm / 1000000.00;
				unclaimed += value;
			}
		}
		return unclaimed;
	}

	function getClaimableBalance(ClaimableSplitStorage storage self) claimableMode public view returns (uint balance) {
		return getClaimableBalanceFor(msg.sender);
	}

	function transfer(ClaimableSplitStorage storage self, address to, uint ppm) public {
		uint splitIndex = self.userSplit[msg.sender];
		if(splitIndex > 0 && self.splits[splitIndex].to == msg.sender && self.splits[splitIndex].ppm > ppm) {
			claimFor(to);
			claimFor(msg.sender);
			// neither user can have a pending balance to use transfer
			self.lastUserClaim[to] = self.lastUserClaim[msg.sender];
			self.splits[splitIndex].ppm -= ppm;
			addSplit(Split({to: to, ppm: ppm}));
		}
	}

	function pay(ClaimableSplitStorage storage self) public payable {
		if(self.isClaimable) {
			self.deposits.push(msg.value);
		} else {
			self.base.pay();
		}
	}
}

