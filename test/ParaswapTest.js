// const { BN, ether, balance } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');
// const ForceSend = artifacts.require('ForceSend');
const {fetch} = require('cross-fetch');
const Test = artifacts.require("TestSwap");
const CallTest = artifacts.require("CallTest");
const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0x61B2109bb57EA6B2BCAF0336b23252939e98EB2A';
const thcABI = require('./abi/thc');
const thcAddress = "1ce0c2827e2ef14d5c4f29a091d735a204794041";
const thcContract = new web3.eth.Contract(thcABI, thcAddress);

const busdABI = require('./abi/thg');
const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

const zeroABI = require('./abi/zero');
const zeroExRouter = "0xDef1C0ded9bec7F1a1670819833240f027b25EfF";
const zeroExContract = new web3.eth.Contract(zeroABI, zeroExRouter);
const tester = "0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15";

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.testContract = await Test.new({from: alice});
        this.swapRouterContract = await SwapRouter.new({from: alice});
        // this.callTestContract = await CallTest.new({from: alice});
        // await busdContract.methods.transfer(admin, '100000').send({from: tokenOwner});
    });

    it('test', async() => {
        let url = 'https://api2.metaswap.codefi.network/networks/56/trades?destinationToken=0x1ce0c2827e2ef14d5c4f29a091d735a204794041&sourceToken=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56&sourceAmount=1000000000000000000&slippage=3&timeout=10000&walletAddress=0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15';
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        console.log(swapData[2].trade);
        let tradeData = swapData[2].trade.data;
        await busdContract.methods.approve(this.swapRouterContract.address, '1000000000000000000').send({from: tester});
        let balance = await busdContract.methods.balanceOf(tester).call();
        console.log('balance : ', balance);
        // await this.swapRouterContract.swap("paraswapV5FeeDynamic", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", '1000000000000000000', tradeData, {from: tester, value: '1000000000000000000'});
        await this.swapRouterContract.swap("paraswapV5FeeDynamic", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", '1000000000000000000', tradeData, {
            from: tester,
            gasPrice: 10000000000,
            gas: 300000
        });
        balance = await thcContract.methods.balanceOf(tester).call();
        console.log('balance : ', balance);

        // balance = await thcContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('balance : ', await web3.eth.getBalance(tester))
        
        // let data = await this.testContract.testCallFunction(this.callTestContract.address, thcAddress, 100000,{from: admin});
        // console.log("data : ", data.logs[0].args);
    })
})