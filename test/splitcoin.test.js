var SplitCoinFactory = artifacts.require('./SplitCoinFactory.sol');
var SplitCoin = artifacts.require('./SplitCoin.sol');
var splitcoinJson = require('../build/contracts/SplitCoin.json');

/*var TestRPC = require("ethereumjs-testrpc");*/
/*web3.setProvider(TestRPC.provider());*/

contract('SplitCoin', (accounts) => {
  let splitCoinContractAddr = null;
  function printBalances() {
    for (let account of accounts) {
      web3.eth.getBalance(account, undefined, (err, balance) => {
        //let ether = web3.fromWei(balance, "ether").toString();
        let ether = balance.toNumber();
        console.log(account, ether);
      });
    }
  }
  it("should have first two accounts as splits", () => {
    let factory = null;
    return SplitCoinFactory.deployed()
      .then((splitFactory) => {
        factory = splitFactory;
        let accounts = web3.eth.accounts;
        const MILLION = 1000000;
        let half = MILLION / 2;
        return factory.make([accounts[0], accounts[1]], [half, half], "0x0");
      })
      .then((tx) => {
        return factory.contracts(accounts[0], 0);
      })
      .then((splitCoinAddr) => {
        splitCoinContractAddr = splitCoinAddr;
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
					console.log(splitData);
          assert.equal(split != null, true, "There should be a split at index 1");
          assert.equal(splitData.to, accounts[index], "The contract should have the user at index 1");
          assert.equal(splitData.ppm < 1000000, true, "The user should get less than the whole amount (dev_fee)");
          assert.equal(splitData.ppm > 400000, true, "The user should get almost half");
        }
      });
  });
  it("should split the ether", (done) => {
    return web3.eth.sendTransaction({
      from: accounts[3],
      to: splitCoinContractAddr,
      value: web3.toWei(1, "ether")
    }, (result) => {
      printBalances();
      setTimeout(() => {
        assert.equal(true, false, "This test should work");
        done();
      }, 1000);
    });
  });
});
