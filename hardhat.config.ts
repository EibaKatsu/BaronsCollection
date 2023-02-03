import { task } from 'hardhat/config'
import '@nomiclabs/hardhat-waffle';
import { HardhatArguments, HardhatRuntimeEnvironment } from 'hardhat/types'

task("accounts", "Prints the list of accounts", async (args: HardhatArguments, hre: HardhatRuntimeEnvironment):Promise<void> => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.address);
  }
});

module.exports = {
  solidity: "0.8.17",
};