pragma solidity ^0.4.15;
import "./SplitCoin.sol";

contract ClaimableSplitCoin is SplitCoin {

  mapping(address => uint) lastUserClaim;
  uint[] deposits;

  bool public isClaimable = false;

  function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable)
  SplitCoin(members, ppms, refer) public {
    isClaimable = claimable;
  }

  modifier claimableMode() {
    require(isClaimable == true);
    _;
  }

  function claimFor(address user) claimableMode public {
    uint sum = getClaimableBalanceFor(user);
    uint splitIndex = userSplit[user];
    lastUserClaim[user] = deposits.length;
    require(splits[splitIndex].to.call.gas(60000).value(sum)());
    SplitTransfer(splits[splitIndex].to, sum, this.balance);
  }

  function claim() claimableMode public {
    return claimFor(msg.sender);
  }

  function getClaimableBalanceFor(address user) claimableMode public view returns (uint balance) {
    uint splitIndex = userSplit[user];
    uint lastClaimIndex = lastUserClaim[user];
    uint unclaimed = 0;
    if(splits[splitIndex].to == user) {
      for(uint depositIndex = lastClaimIndex; depositIndex < deposits.length; depositIndex++) {
        uint value = deposits[depositIndex] * splits[splitIndex].ppm / 1000000.00;
        unclaimed += value;
      }
    }
    return unclaimed;
  }

  function getClaimableBalance() claimableMode public view returns (uint balance) {
    return getClaimableBalanceFor(msg.sender);
  }

  function transfer(address to, uint ppm) public {
    uint splitIndex = userSplit[msg.sender];
    if(splitIndex > 0 && splits[splitIndex].to == msg.sender && splits[splitIndex].ppm > ppm) {
      claimFor(to);
      claimFor(msg.sender);
      // neither user can have a pending balance to use transfer
      lastUserClaim[to] = lastUserClaim[msg.sender];
      splits[splitIndex].ppm -= ppm;
      addSplit(Split({to: to, ppm: ppm}));
    }
  }

  function pay() public payable {
    if(isClaimable) {
      deposits.push(msg.value);
    } else {
      super.pay();
    }
  }
}

