pragma solidity ^0.4.15;
import "./ClaimableSplitCoin.sol";

contract SplitCoinFactory {
  mapping(address => address[]) public contracts;
  mapping(address => uint) public referralContracts;
  mapping(address => address) public referredBy;
  mapping(address => address[]) public referrals;
  address[] public deployed;
  event Deployed (
    address _deployed
  );


  function make(address[] users, uint[] ppms, address refer, bool claimable) public returns (address) {
    address referContract = referredBy[msg.sender];
    if(refer != 0x0 && referContract == 0x0 && contracts[refer].length > 0 ) {
      uint referContractIndex = referralContracts[refer] - 1;
      if(referContractIndex >= 0 && refer != msg.sender) {
        referContract = contracts[refer][referContractIndex];
        referredBy[msg.sender] = referContract;
        referrals[refer].push(msg.sender);
      }
    }
    address sc = new ClaimableSplitCoin(users, ppms, referContract, claimable);
    contracts[msg.sender].push(sc);
    deployed.push(sc);
    Deployed(sc);
    return sc;
  }

  function generateReferralAddress(address refer) public returns (address) {
    uint[] memory ppms = new uint[](1);
    address[] memory users = new address[](1);
    ppms[0] = 1000000;
    users[0] = msg.sender;

    address referralContract = make(users, ppms, refer, true);
    if(referralContract != 0x0) {
      uint index = contracts[msg.sender].length;
      referralContracts[msg.sender] = index;
    }
    return referralContract;
  }
}
