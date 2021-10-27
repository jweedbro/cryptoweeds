module.exports = async ({ getNamedAccounts, deployments }) => {
  tryVerify = require("../utils/tryverify");

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const args = ["CryptoWeeds", "WEEDS", 2048];
  const nft = await deploy("CryptoWeeds", {
    from: deployer,
    args: args,
    log: true,
  });

  //да, я ебану таймер прямо так, твои действия?
  function x() {
    return new Promise(function (resolve, reject) {
      setTimeout(function () {
        resolve("anything");
      }, 5000);
    });
  }

  await x();

  await tryVerify(nft.address, args, "contracts/weeds.sol:CryptoWeeds");
};

module.exports.tags = ["MintTest"];
