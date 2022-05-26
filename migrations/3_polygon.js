const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const SwapRouter = artifacts.require("PolygonSwapRouter");

module.exports = async function (deployer) {
    deployer.then(async () => {
        const swapRouter  = await deployProxy(
            SwapRouter,
            [],
            {
                deployer,
                initializer: 'initialize'
            }
        );
        console.log("swapRouter ", swapRouter.address);        
    }).catch((err) => {
        console.error("ERROR", err)
    });
}