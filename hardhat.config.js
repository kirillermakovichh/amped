require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require('solidity-coverage');

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.20", 
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
      }],
    },
  mocha: {
    timeout: 100000000
  },
  // networks: {
  //     hardhat: {
  //       forking: {
  //         url: "https://polygon-rpc.com",
  //         blockNumber: 41360191,
  //       }
  //     },
  //     goerli: {
  //       url: "https://rpc.ankr.com/eth_goerli",
  //       accounts: [process.env.SECRET_KEY],
  //     }
  //   },
  //   etherscan: {
  //     apiKey: [process.env.ETHERSCAN_KEY],
  //   },
    
};