const FeeVault = artifacts.require("FeeVault");

module.exports = async function (deployer, network, accounts) {
  deployer.deploy(FeeVault);
};
