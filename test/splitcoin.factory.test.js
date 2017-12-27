var SplitCoinFactory = artifacts.require('./SplitCoinFactory.sol');
var SplitCoin = artifacts.require('./ClaimableSplitCoin.sol');
var splitcoinJson = require('../build/contracts/ClaimableSplitCoin.json');

/*var TestRPC = require("ethereumjs-testrpc");*/
/*web3.setProvider(TestRPC.provider());*/

contract('SplitCoinFactory', (accounts) => {
  let splitCoinSplits = [];

  it("should deploy a contract with two splits", () => {
    let factory = null;
    return SplitCoinFactory.deployed()
      .then(async (splitFactory) => {
        factory = splitFactory;
        let accounts = web3.eth.accounts;
        const MILLION = 1000000;
        let half = MILLION / 2;
        let gas = await factory.make.estimateGas([accounts[0], accounts[1]], [half, half], "0x0", false);
        console.log('Deploying takes', gas, 'gas');
        assert.equal(gas <= 1360000, true, "Deploying should take < 1.36 Mil Gas");
      })
  });


  it("should deploy a contract with two splits", () => {
    let factory = null;
    return SplitCoinFactory.deployed()
      .then((splitFactory) => {
        factory = splitFactory;
        let accounts = web3.eth.accounts;
        const MILLION = 1000000;
        let half = MILLION / 2;
        return factory.make([accounts[0], accounts[1]], [half, half], "0x0", false);
      })
      .then((tx) => {
        return tx.logs[0].args._deployed;
      })
      .then((splitCoinAddr) => {
        return web3.eth.contract(splitcoinJson.abi).at(splitCoinAddr);
      })
      .then(async (splitCoin) => {
        assert.equal(splitCoin != null, true, "The splitCoin should be defined");
        return Promise.all([await splitCoin.splits(1), await splitCoin.splits(2)])
      })
      .then((splits) => {
        for (let index = 0; index < splits.length; index++) {
          let splitData = {
            to: '',
            ppm: 0
          };
          let split = splits[index];
          splitData.to = split[0];
          splitData.ppm = split[1].toFixed();
          splitCoinSplits.push(splitData);
          assert.equal(split != null, true, "There should be a split at index 1");
          assert.equal(splitData.to, accounts[index], "The contract should have the user at index 1");
          assert.equal(splitData.ppm < 1000000, true, "The user should get less than the whole amount (dev_fee)");
          assert.equal(splitData.ppm > 400000, true, "The user should get almost half");
        }
      });
  });


  it("Should be able to generate a referal address", () => {
    let factory = null;
    return SplitCoinFactory.deployed()
      .then((splitFactory) => {
        factory = splitFactory;
        return factory.generateReferralAddress('0x0');
      })
      .then((tx) => {
        return tx.logs[0].args._deployed;
      })
      .then(async(splitCoinAddr) => {
        return web3.eth.contract(splitcoinJson.abi).at(splitCoinAddr);
      })
      .then(async (splitCoin) => {
        assert.equal(splitCoin != null, true, "The splitCoin should be defined");
        return splitCoin.splits(1);
      })
      .then((split) => {
        let splitData = {
          to: '',
          ppm: 0
        };
        splitData.to = split[0];
        splitData.ppm = split[1].toFixed();
        assert.equal(split != null, true, "There should be a split at index 1");
        assert.equal(splitData.to, accounts[0], "The contract should have the user at index 1");
        assert.equal(splitData.ppm < 1000000, true, "The user should get less than the whole amount (dev_fee)");
        assert.equal(splitData.ppm > 900000, true, "The user should get more than 90%");
      });
  });
});
