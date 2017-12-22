pragma solidity ^0.4.17;
import "./SplitCoin.sol";

library CSCLib {

	using SCLib for SCLib.SplitStorage;

	struct CSCStorage {
		mapping(address => uint) lastUserClaim;
		uint[] deposits;
		bool isClaimable;

		address developer;
		uint dev_fee;
		uint refer_fee;
		SCLib.Split[] splits;
		mapping(address => uint) userSplit;

		SCLib.SplitStorage lib;
	}

	function claimFor(CSCStorage storage self, address user) internal {
		require(self.isClaimable);
		uint sum = getClaimableBalanceFor(self, user);
		uint splitIndex = self.userSplit[user];
		self.lastUserClaim[user] = self.deposits.length;
		require(self.splits[splitIndex].to.call.gas(60000).value(sum)());
		SplitTransfer(self.splits[splitIndex].to, sum, this.balance);
	}

	function claim(CSCStorage storage self)  internal {
		require(self.isClaimable);
		return claimFor(self, msg.sender);
	}

	function getClaimableBalanceFor(CSCStorage storage self, address user) internal view returns (uint balance) {
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

	function getClaimableBalance(CSCStorage storage self)  internal view returns (uint balance) {
		return getClaimableBalanceFor(self, msg.sender);
	}

	function transfer(CSCStorage storage self, address to, uint ppm) internal {
		uint splitIndex = self.userSplit[msg.sender];
		if(splitIndex > 0 && self.splits[splitIndex].to == msg.sender && self.splits[splitIndex].ppm > ppm) {
			claimFor(self, to);
			claimFor(self, msg.sender);
			// neither user can have a pending balance to use transfer
			self.lastUserClaim[to] = self.lastUserClaim[msg.sender];
			self.splits[splitIndex].ppm -= ppm;
			self.lib.addSplit(SCLib.Split({to: to, ppm: ppm}));
		}
	}

	function pay(CSCStorage storage self) internal {
		if(self.isClaimable) {
			self.deposits.push(msg.value);
		} else {
			self.lib.pay();
		}
	}

	event SplitTransfer(address to, uint amount, uint balance);
}



