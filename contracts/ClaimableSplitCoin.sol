pragma solidity ^0.4.15;
import "./SplitCoin.sol";

contract ClaimableSplitCoin is SplitCoin {

  mapping(address => uint) lastUserClaim;
  uint[] deposits;

  bool isClaimable = false;

  function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable)
  SplitCoin(members, ppms, refer) public {
    isClaimable = claimable;
  }

  modifier claimableMode() {
    require(isClaimable == true);
    _;
  }

  function claim() claimableMode public {
    uint splitIndex = userSplit[msg.sender];
    if(splits[splitIndex].to == msg.sender) {
      uint lastClaimIndex = lastUserClaim[msg.sender];
      for(uint depositIndex = lastClaimIndex; depositIndex < deposits.length; depositIndex++) {
        uint value = deposits[depositIndex] * splits[splitIndex].ppm / 1000000.00;
        lastUserClaim[msg.sender] = depositIndex + 1;
        splits[splitIndex].to.transfer(value);
        SplitTransfer(splits[splitIndex].to, value, this.balance);
      }
    }
  }

  function getClaimableBalance() claimableMode public view returns (uint balance) {
    uint splitIndex = userSplit[msg.sender];
    uint lastClaimIndex = lastUserClaim[msg.sender];
    uint unclaimed = 0;
    if(splits[splitIndex].to == msg.sender) {
      for(uint depositIndex = lastClaimIndex; depositIndex < deposits.length; depositIndex++) {
        uint value = deposits[depositIndex] * splits[splitIndex].ppm / 1000000.00;
        unclaimed += value;
      }
    }
    return unclaimed;
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

