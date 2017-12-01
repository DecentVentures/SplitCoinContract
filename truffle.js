module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 3000000,
    },
    main: {
      host: "localhost",
      port: 8545,
      network_id: "1",
      gas: 3000000,
    },
    srvmain: {
      host: "192.168.0.12",
      port: 8545,
      network_id: "1",
      gas: 3000000,
    },
    ropsten: {
      host: "localhost",
      port: 8546,
      network_id: "3",
      gas: 3000000,
    },
    srvropsten: {
      host: "192.168.0.12",
      port: 8546,
      network_id: "3",
      gas: 3000000,
    }
  }
};
