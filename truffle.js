module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 3000000,
    },
    main: {
      host: "192.168.0.12",
      port: 8545,
      network_id: "1",
      gas: 3000000,
    },
    ropsten: {
      host: "192.168.0.12",
      port: 8546,
      network_id: "3",
      gas: 3000000,
    }
  }
};
