pragma solidity ^0.4.15;
import "./ClaimableSplitCoin.sol";

contract SplitCoinFactory {
  mapping(address => address[]) public contracts;
  event Deployed (
    address _deployed
  );
  function make(address[] users, uint[] ppms, address refer, bool claimable) public returns (address) {
    address sc = 0x0;
    sc = new ClaimableSplitCoin(users, ppms, refer, claimable);
    contracts[msg.sender].push(sc);
    Deployed(sc);
    return sc;
  }
}
