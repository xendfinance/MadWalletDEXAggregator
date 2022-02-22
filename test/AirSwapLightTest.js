const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0xE1530F9b20C6E20cE56aDd3164097584Ef90Ea30';
const usdcABI = require('./abi/usdc');
const usdcAddress = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const busdABI = require('./abi/busd');
const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

contract('AirSwapLight Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.SwapRouter = await SwapRouter.new({from: alice});
        await usdcContract.methods.transfer(admin, '109484817855095221280').send({from: tokenOwner});
    });

    it('test', async() => {
        await usdcContract.methods.approve(this.SwapRouter.address, '109484817855095221280').send({from: admin});
        let result = await this.SwapRouter.swap("airswapLightFeeDynamic", "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d", "109484817855095221280", "0x0000000000000000000000000000000000000000000000000000000061fa409c0000000000000000000000000000000000000000000000000000000061fa4155000000000000000000000000945bcf562085de2d5875b9e2012ed5fd5cfab927000000000000000000000000e9e7cea3dedca5984780bafc599bd69add087d56000000000000000000000000000000000000000000000005ea9d448f1293db400000000000000000000000008ac76a51cc950d9822d68b83fe1ad97b32cd580d000000000000000000000000000000000000000000000005ead94e2db1a44701000000000000000000000000000000000000000000000000000000000000001b72a3e736d8e40f8ec7ac0386e2ccfc7e5048bc91b4195a16525c10e9cbcfb15f7e56c1690d3b097d5150853ca21f89c94fb65313fa16e88b45eac4fed2f00ed4000000000000000000000000000000000000000000000000048ee795d5a7651f000000000000000000000000f636776acfca2132e019e714a1fc881124b3bafc0000000000000000000000000000000000000000000000000000000000000000",
        {from: admin});
        console.log(await busdContract.methods.balanceOf(this.SwapRouter.address).call());
    })
})