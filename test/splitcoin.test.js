var SplitCoinFactory = artifacts.require('./SplitCoinFactory.sol');
var SplitCoin = artifacts.require('./ClaimableSplitCoin.sol');
var splitcoinJson = require('../build/contracts/ClaimableSplitCoin.json');

/*var TestRPC = require("ethereumjs-testrpc");*/
/*web3.setProvider(TestRPC.provider());*/

contract('SplitCoin', (accounts) => {
  let splitCoinContractAddr = null;
  let splitCoinContract = null;
  let splitCoinSplits = [];

  it("should be able to deploy a SplitCoin via factory", () => {
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
        return tx.logs[0].args.deployed;
      })
      .then((splitCoinAddr) => {
        splitCoinContractAddr = splitCoinAddr;
        return web3.eth.contract(splitcoinJson.abi).at(splitCoinAddr);
      })
      .then(async (splitCoin) => {
        deployedSplitcoin = splitCoin;
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
  it("should send the ether to 3 accounts, dev, acc1, acc2", (done) => {
    let sendAmount = web3.toWei(1, "ether");
    return web3.eth.sendTransaction({
      from: accounts[3],
      to: splitCoinContractAddr,
      value: sendAmount
    }, (err, result) => {
      let splitEvent = SplitCoin.at(splitCoinContractAddr).SplitTransfer({
        fromBlock: "latest",
        to: "pending"
      });
      let found = [];
      let sumSent = 0;
      let filter = splitEvent.watch((err, eventRes) => {
        console.log(`${eventRes.event}: ${eventRes.args.amount} to ${eventRes.args.to}`);
        sumSent += eventRes.args.amount.toNumber();
        for (let split of splitCoinSplits) {
          if (eventRes.args.to == split.to && found.indexOf(split.to) == -1) {
            found.push(split.to);
          }
        }
        if (found.length == 2) {
          assert.equal(found.length, 2, "Should fire off transfers for the two users");
          assert.equal(sumSent, sendAmount, "The total amount of Ether should be accounted for");
          filter.stopWatching();
          done();
        }
      });
    });
  });

});
