var SplitCoinFactory = artifacts.require("./SplitCoinFactory.sol");
var SplitCoin = artifacts.require("./SplitCoin.sol");
module.exports = function(deployer) {
	/*
	 *let accounts = web3.eth.accounts;
   *const MILLION = 1000000;
   *let half = MILLION / 2;
	 */
	deployer.deploy(SplitCoinFactory, {gas: '0x2DC6C0', gasPrice: '0x4A817C800'});
  //deployer.deploy(SplitCoin, [accounts[0], accounts[1]], [half, half], "0x0");
};
