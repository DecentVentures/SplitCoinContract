var SplitCoinFactory = artifacts.require('./SplitCoinFactory.sol');
var SplitCoin = artifacts.require('./ClaimableSplitCoin.sol');
var splitcoinJson = require('../build/contracts/ClaimableSplitCoin.json');

/*var TestRPC = require("ethereumjs-testrpc");*/
/*web3.setProvider(TestRPC.provider());*/

contract('ClaimableSplitCoin', (accounts) => {
  let splitCoinContractAddr = null;
  let splitCoinSplits = [];

  it("should be able to deploy a ClaimableSplitCoin via factory", () => {
    let factory = null;
    return SplitCoinFactory.deployed()
      .then((splitFactory) => {
        factory = splitFactory;
        let accounts = web3.eth.accounts;
        const MILLION = 1000000;
        let half = MILLION / 2;
        return factory.make([accounts[0], accounts[1]], [half, half], "0x0", true);
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
          splitCoinSplits.push(splitData);
          assert.equal(split != null, true, "There should be a split at index 1");
          assert.equal(splitData.to, accounts[index], "The contract should have the user at index 1");
          assert.equal(splitData.ppm < 1000000, true, "The user should get less than the whole amount (dev_fee)");
          assert.equal(splitData.ppm > 400000, true, "The user should get almost half");
        }
      });
  });

  it("should be cheap to send to this contract", () => {
    let amount = web3.eth.estimateGas({
      from: web3.eth.accounts[0],
      to: splitCoinContractAddr,
      amount: web3.toWei(1, "ether")
    });
    console.log('ClaimableSplitCoin gas estimate : ', amount);
    assert.equal(amount < 50000, true);
  });

  it("should be able to transfer some of the ownership", (done) => {
    let splitContract = web3.eth.contract(splitcoinJson.abi).at(splitCoinContractAddr);
    let ownershipBefore = Number(splitCoinSplits[0].ppm);
    let ownership2Before = Number(splitCoinSplits[1].ppm);
    console.log(ownershipBefore, ownership2Before);
    splitContract
      .transfer(accounts[1], ownershipBefore / 2, {
        from: accounts[0]
      })
      .then(() => splitContract.splits(1))
      .then((split) => assert.equal(Number(split[1].toFixed()), ownershipBefore / 2))
      .then(() => splitContract.splits(2))
      .then((split) => assert.equal(Number(split[1].toFixed()), ownership2Before + ownershipBefore / 2))
      .then(() => done());
  });


  it("should have a claimable balance for dev, acc1, acc2 equal to 1 ether", (done) => {
    let splitContract = SplitCoin.at(splitCoinContractAddr);
    let sendAmount = web3.toWei(1, "ether");
    return web3.eth.sendTransaction({
      from: accounts[3],
      to: splitCoinContractAddr,
      value: web3.toWei(1, "ether"),
    }, async (err, result) => {

      let claimable1 = await splitContract.getClaimableBalance({
        from: accounts[0]
      });
      let claimable2 = await splitContract.getClaimableBalance({
        from: accounts[1]
      });

      let developer = await splitContract.developer.call();
      let devCharge = await splitContract.getClaimableBalance({
        from: developer
      });

      assert.equal(claimable1.toNumber() + claimable2.toNumber() + devCharge.toNumber(), sendAmount);
      done();
    });
  });


  it("should send the ether to 2 accounts, acc1, acc2", (done) => {
    let splitContract = SplitCoin.at(splitCoinContractAddr);
    let splitEvent = SplitCoin.at(splitCoinContractAddr).SplitTransfer({
      fromBlock: "latest",
      to: "pending"
    });

    let found = [];
    let filter = splitEvent.watch((err, eventRes) => {
      console.log(`${eventRes.event}: ${eventRes.args.amount} to ${eventRes.args.to}`);
      for (let split of splitCoinSplits) {
        if (eventRes.args.to == split.to && found.indexOf(split.to) == -1) {
          found.push(split.to);
        }
      }
      if (found.length == 2) {
        assert.equal(true, true, "Should fire off transfers for the two users");
        filter.stopWatching();
        done();
      }
    });

    splitContract
      .claim({
        from: accounts[0]
      })
      .then(() => splitContract.claim({
        from: accounts[1]
      }));
  });



});
