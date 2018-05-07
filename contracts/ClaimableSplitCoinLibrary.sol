pragma solidity ^0.4.18;

library CSCLib {

  uint constant MILLION = 1000000;
  uint constant GASLIMIT = 65000;


  struct Split {
    address to;
    uint ppm;
  }

  struct CSCStorage {
    mapping(address => uint) lastUserClaim;
    uint[] deposits;
    bool isClaimable;

    address developer;
    uint dev_fee;
    uint refer_fee;
    Split[] splits;
    mapping(address => uint) userSplit;
    mapping(address => mapping( uint => uint)) ownership;
  }

  event SplitTransfer(address to, uint amount, uint balance);

  /*
self: a storage pointer

members: an array of addresses

ppms: an array of integers that should sum to 1 million.
Represents how much ether a user should get

refer: the address of a referral contract that referred this user.
Referral contract should be a claimable contract

   */
  function init(CSCStorage storage self,  address[] members, uint[] ppms, address refer, address owner) internal {
    uint shift_amt = self.dev_fee / members.length;
    uint remainder = self.dev_fee % members.length * members.length / 10;
    uint dev_total = self.dev_fee + remainder;
    self.deposits.push(0);
    if(refer != 0x0){
      addSplit(self, Split({to: self.developer, ppm: dev_total - self.refer_fee}), self.developer);
      addSplit(self, Split({to: refer, ppm: self.refer_fee}), refer);
    } else {
      addSplit(self, Split({to: self.developer, ppm: dev_total}), self.developer);
    }

    uint sum = 0;
    for(uint index = 0; index < members.length; index++) {
      sum += ppms[index];
      addSplit(self, Split({to: members[index], ppm: ppms[index] - shift_amt}), owner);
    }
    require(sum >= MILLION - 1 && sum < MILLION + 1 );
  }

  function addSplit(CSCStorage storage self, Split newSplit, address owner) internal {
    require(newSplit.ppm > 0);
    uint index = self.userSplit[newSplit.to];
    if(index > 0) {
      self.ownership[owner][index] += newSplit.ppm;
      newSplit.ppm += self.splits[index].ppm;
      self.splits[index] = newSplit;
    } else {
      self.userSplit[newSplit.to] = self.splits.length;
      self.lastUserClaim[newSplit.to] = self.deposits.length;
      self.ownership[owner][self.splits.length] = newSplit.ppm;
      self.splits.push(newSplit);
    }
  }

  function payAll(CSCStorage storage self) internal {
    for(uint index = 0; index < self.splits.length; index++) {
      uint value = (msg.value) * self.splits[index].ppm / MILLION;
      if(value > 0 ) {
        require(self.splits[index].to.call.gas(GASLIMIT).value(value)());
        emit SplitTransfer(self.splits[index].to, value, address(this).balance);
      }
    }
  }

  function getSplit(CSCStorage storage self, uint index) internal view returns (Split) {
    return self.splits[index];
  }

  function getSplitCount(CSCStorage storage self) internal view returns (uint count) {
    return self.splits.length;
  }

  function claimFor(CSCStorage storage self, address user) internal {
    require(self.isClaimable);
    uint sum = getClaimableBalanceFor(self, user);
    uint splitIndex = self.userSplit[user];
    self.lastUserClaim[user] = self.deposits.length;
    if(sum > 0) {
      require(self.splits[splitIndex].to.call.gas(GASLIMIT).value(sum)());
      emit SplitTransfer(self.splits[splitIndex].to, sum, address(this).balance);
    }
  }

  function claim(CSCStorage storage self)  internal {
    return claimFor(self, msg.sender);
  }

  function getClaimableBalanceFor(CSCStorage storage self, address user) internal view returns (uint balance) {
    uint splitIndex = self.userSplit[user];
    uint lastClaimIndex = self.lastUserClaim[user];
    uint unclaimed = 0;
    if(self.splits[splitIndex].to == user) {
      for(uint depositIndex = lastClaimIndex; depositIndex < self.deposits.length; depositIndex++) {
        uint value = self.deposits[depositIndex] * self.splits[splitIndex].ppm / MILLION;
        unclaimed += value;
      }
    }
    return unclaimed;
  }

  function getClaimableBalance(CSCStorage storage self)  internal view returns (uint balance) {
    return getClaimableBalanceFor(self, msg.sender);
  }

  function transfer(CSCStorage storage self, address newTo, uint ppmToTransfer, address newOwner, address owner, address toTransfer) internal {
    uint splitIndex = self.userSplit[toTransfer];
    require(splitIndex > 0);
    require(ppmToTransfer > 0);
    require(getClaimableBalanceFor(self, toTransfer ) == 0);
    require(getClaimableBalanceFor(self, newTo) == 0);
    // neither user can have a pending balance to use transfer
    require(self.splits[splitIndex].to == toTransfer);
    require(self.splits[splitIndex].ppm >= ppmToTransfer);
    require(self.ownership[owner][splitIndex] >= ppmToTransfer);

    self.splits[splitIndex].ppm -= ppmToTransfer;
    self.ownership[owner][splitIndex] -= ppmToTransfer;
    addSplit(self, Split({to: newTo, ppm: ppmToTransfer}), newOwner);
  }

  function pay(CSCStorage storage self) internal {
    if(self.isClaimable) {
      self.deposits.push(msg.value);
    } else {
      payAll(self);
    }
  }
}
