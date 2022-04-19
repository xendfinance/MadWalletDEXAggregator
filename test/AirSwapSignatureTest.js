const { UnsignedOrder } = require('@airswap/typescript')

const { ethers, providers } = require('ethers')
const { Registry, Swap } = require('@airswap/libraries')
const { chainNames } = require('@airswap/constants')
const HDWalletProvider = require('truffle-hdwallet-provider');

const SwapRouter = artifacts.require("SwapRouter");
// const AirSwapSignature = artifacts.require("BSCAirSwapSignature");
const tokenOwner = '0xE1530F9b20C6E20cE56aDd3164097584Ef90Ea30';
const usdcABI = require('./abi/usdc');
const usdcAddress = "0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const busdABI = require('./abi/busd');
const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

contract('AirSwapLight Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.SwapRouter = await SwapRouter.new({from: alice});
        // await usdcContract.methods.transfer(admin, '109484817855095221280').send({from: tokenOwner});
        // this.airSwapSignature = await AirSwapSignature.new({from: alice});
    });

    it('test', async() => {
        const quoteToken = '0x55d398326f99059ff775485246999027b3197955';
        const baseToken = '0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56';
        const chainId = 56;
        const baseTokenAmount = '5000000000000000000';
        // const provider = ethers.getDefaultProvider(chainNames[chainId].toLowerCase());
        // const provider = providers.Web3Provider;

        const baseProvider = new HDWalletProvider("", "https://bsc-dataseed.binance.org");
        const provider = new ethers.providers.Web3Provider(baseProvider);


        console.log(chainNames[chainId].toLowerCase());

        try{
            const servers = await new Registry(chainId, provider).getServers(
                quoteToken,
                baseToken,
            )
            console.log(servers.length);
            console.log(servers[0].supportsProtocol('request-for-quote'))
            const order = await servers[0].getSignerSideOrder(
                baseTokenAmount,
                quoteToken,
                baseToken,
                admin,
            )
            console.log(order)
        }
        catch(e){
            console.log(e)
        }

    })
}) 