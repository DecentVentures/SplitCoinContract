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
    uint splitIndex = userSplit[user];
    if(splits[splitIndex].to != 0x0) {
      uint lastClaimIndex = lastUserClaim[user];
      for(uint depositIndex = lastClaimIndex; depositIndex < deposits.length; depositIndex++) {
        uint value = deposits[depositIndex] * splits[splitIndex].ppm / 1000000.00;
        lastUserClaim[user] = depositIndex + 1;
        splits[splitIndex].to.transfer(value);
        SplitTransfer(splits[splitIndex].to, value, this.balance);
      }
    }
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
    if(getClaimableBalance() > 0) {
      claim();
    }
    super.transfer(to, ppm);
  }

  function pay() public payable {
    if(isClaimable) {
      deposits.push(msg.value);
    } else {
      super.pay();
    }
  }
}

