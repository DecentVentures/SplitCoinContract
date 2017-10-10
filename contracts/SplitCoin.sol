pragma solidity ^0.4.15;

contract SplitCoin {
	struct Split {
		address to;
		uint ppm;
	}
	// developer address
	address public developer = 0xec281419bdaf624b363f6cb0e88ceba2d9d3a95d;
	// developer gets transfer * 10/10000
	uint dev_fee = 1000;
	// referer gets transfer * 1/10000
	uint refer_fee = 100;
	Split[] public splits;

	function SplitCoin(address[] members, uint[] ppms, address refer) {
		//require(members.length == ppms.length);
		// if referall was used, referer gets 10% of the dev fee
		// need to make sure referer is a splitcoin contract
		uint shift_amt = dev_fee / members.length;
		if(refer != 0x0){
			splits.push(Split({to: developer, ppm: dev_fee - refer_fee}));
			splits.push(Split({to: refer, ppm: refer_fee}));
		} else {
			splits.push(Split({to: developer, ppm: dev_fee}));
		}

		for(uint index = 0; index < members.length; index++) {
			splits.push(Split({to: members[index], ppm: ppms[index] - shift_amt}));
		}
	}
	function () payable {
		for(uint index = 0; index < splits.length; index++) {
			uint value = (msg.value) * splits[index].ppm / 1000000.00;
			splits[index].to.transfer(value);
			SplitTransfer(splits[index].to, value, this.balance);
		}
	}

	function getSplitCount() public returns (uint count) {
		return splits.length;
	}

	event SplitTransfer(address to, uint amount, uint balance);
}
