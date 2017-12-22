pragma solidity ^0.4.18;

library SCLib {


	struct Split {
		address to;
		uint ppm;
	}

	struct SplitStorage  {
		address developer;
		uint dev_fee;
		uint refer_fee;
		Split[] splits;
		mapping(address => uint) userSplit;
	}

	function init(SplitStorage storage self,  address[] members, uint[] ppms, address refer) internal {
		// TODO: make sure referer is a splitcoin contract
		uint shift_amt = self.dev_fee / members.length;
		if(refer != 0x0){
			addSplit(self, Split({to: self.developer, ppm: self.dev_fee - self.refer_fee}));
			addSplit(self, Split({to: refer, ppm: self.refer_fee}));
		} else {
			addSplit(self, Split({to: self.developer, ppm: self.dev_fee}));
		}

		for(uint index = 0; index < members.length; index++) {
			addSplit(self, Split({to: members[index], ppm: ppms[index] - shift_amt}));
		}
	}

	function addSplit(SplitStorage storage self, Split newSplit) internal {
		require(newSplit.ppm > 0);
		uint index = self.userSplit[newSplit.to];
		if(index > 0) {
			newSplit.ppm += self.splits[index].ppm;
			self.splits[index] = newSplit;
		} else {
			self.userSplit[newSplit.to] = self.splits.length;
			self.splits.push(newSplit);
		}
	}

	function pay(SplitStorage storage self) internal {
		for(uint index = 0; index < self.splits.length; index++) {
			uint value = (msg.value) * self.splits[index].ppm / 1000000.00;
			require(self.splits[index].to.call.gas(60000).value(value)());
			SplitTransfer(self.splits[index].to, value, this.balance);
		}
	}

	function getSplitCount(SplitStorage storage self) internal view returns (uint count) {
		return self.splits.length;
	}


	event SplitTransfer(address to, uint amount, uint balance);
}

