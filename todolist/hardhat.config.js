require("@nomicfoundation/hardhat-toolbox");
// require("dotenv").config();
// const hre = require("hardhat")

const ALCHEMY_API_KEY = vars.get("ALCHEMY_API_KEY", "");
const PRIVATE_KEY = vars.get("PRIVATE_KEY", "");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    hardhat: {},
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/" + ALCHEMY_API_KEY,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  },
};

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});