pragma solidity ^0.4.15;

contract SplitCoin {
  struct Split {
    address to;
    uint ppm;
  }

  address public developer = 0xaB48Dd4b814EBcb4e358923bd719Cd5cd356eA16;
  uint public constant dev_fee = 2500;
  uint public constant refer_fee = 250;

  Split[] public splits;
  mapping(address => uint) userSplit;


  function SplitCoin(address[] members, uint[] ppms, address refer) public {
    // TODO: make sure referer is a splitcoin contract
    uint shift_amt = dev_fee / members.length;
    if(refer != 0x0){
      addSplit(Split({to: developer, ppm: dev_fee - refer_fee}));
      addSplit(Split({to: refer, ppm: refer_fee}));
    } else {
      addSplit(Split({to: developer, ppm: dev_fee}));
    }

    for(uint index = 0; index < members.length; index++) {
      addSplit(Split({to: members[index], ppm: ppms[index] - shift_amt}));
    }
  }

  function addSplit(Split newSplit) internal {
    uint index = userSplit[newSplit.to];
    if(index > 0){
      newSplit.ppm += splits[index].ppm;
      splits[index] = newSplit;
    } else {
      userSplit[newSplit.to] = splits.length;
      splits.push(newSplit);
    }
  }

  function transfer(address to, uint ppm) public {
    uint splitIndex = userSplit[msg.sender];
    if(splitIndex > 0 && splits[splitIndex].to == msg.sender && splits[splitIndex].ppm > ppm) {
      splits[splitIndex].ppm -= ppm;
      addSplit(Split({to: to, ppm: ppm}));
    }
  }

  function () public payable {
    pay();
  }

  function pay () public payable {
    for(uint index = 0; index < splits.length; index++) {
      uint value = (msg.value) * splits[index].ppm / 1000000.00;
      splits[index].to.transfer(value);
      SplitTransfer(splits[index].to, value, this.balance);
    }
  }

  function getSplitCount() public view returns (uint count) {
    return splits.length;
  }

  event SplitTransfer(address to, uint amount, uint balance);
}
