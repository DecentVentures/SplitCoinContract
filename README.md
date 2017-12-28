# SplitCoin Contracts
This repo houses all of the contracts used by SplitCoin

## Design
The SplitCoinFactory deploys ClaimableSplitCoin contracts which use the SplitCoinLibrary.

## Deploying SplitCoin contracts
The factory has a make method that takes in an array of addresses and an array of uints.

Each user address is associated with the uint at the same index.

Each user should receive N/1000000, where N is their corresponding uint.

Each deployed contract can have a referrer. The referrer receives a portion of the dev fee.

Each contract can be claimable, or not. 

Claimable contracts follow the withdraw pattern, and the user must make a call to receive their funds

Non-Claimable contracts receive the funds as soon as the contract receives the funds.

## Examples
```
// A 50/50 split where each user must claim their funds

SplitCoinFactory.make(["0x123", "0x124"], [500000, 500000], "0x0", true);


// A 50/50 split where each user receives the funds as soon as the contract receives them

SplitCoinFactory.make(["0x123", "0x124"], [500000, 500000], "0x0", false);

```
