pragma solidity ^0.4.15;
import "./ClaimableSplitCoin.sol";

contract SplitCoinFactory {
  mapping(address => address[]) public contracts;
  mapping(address => uint) public referralContracts;
  event Deployed (
    address _deployed
  );

  function make(address[] users, uint[] ppms, address refer, bool claimable) public returns (address) {
    address sc = 0x0;
    address referContract = 0x0;
    if(refer != 0x0 && contracts[refer].length > 0) {
      uint referContractIndex = referralContracts[refer] - 1;
      if(referContractIndex >= 0) {
        referContract = contracts[refer][referContractIndex];
      }
    }
    sc = new ClaimableSplitCoin(users, ppms, referContract, claimable);
    contracts[msg.sender].push(sc);
    Deployed(sc);
    return sc;
  }

  function generateReferralAddress() public returns (address) {
    uint[] memory ppms = new uint[](1);
    address[] memory users = new address[](1);
    ppms[0] = 1000000;
    users[0] = msg.sender;

    address referralContract = make(users, ppms, 0x0, true);
    if(referralContract != 0x0) {
      uint index = contracts[msg.sender].length;
      referralContracts[msg.sender] = index;
    }
    return referralContract;
  }
}
