// const { BN, ether, balance } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');
// const ForceSend = artifacts.require('ForceSend');
const {fetch} = require('cross-fetch');
const Test = artifacts.require("TestSwap");
const CallTest = artifacts.require("CallTest");
const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15';
const busdABI = require('./abi/busd');
const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

// const thgABI = require('./abi/thg');
// const thgAddress = "0x9fD87aEfe02441B123c3c32466cD9dB4c578618f";
// const thgContract = new web3.eth.Contract(thgABI, thgAddress);

// const zeroABI = require('./abi/zero');
// const zeroExRouter = "0xDef1C0ded9bec7F1a1670819833240f027b25EfF";
// const zeroExContract = new web3.eth.Contract(zeroABI, zeroExRouter);
// const tester = "0xda91066AAcE5be94d370d22088d733a4107716fe";

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.testContract = await Test.new({from: alice});
        this.swapRouterContract = await SwapRouter.new({from: alice});
        // this.callTestContract = await CallTest.new({from: alice});
        await busdContract.methods.transfer(admin, '500000').send({from: tokenOwner});
    });

    it('test', async() => {
        let url = 'https://api2.metaswap.codefi.network/networks/56/trades?destinationToken=0x55d398326f99059ff775485246999027b3197955&sourceToken=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        console.log(swapData[3].trade);
        let tradeData = swapData[3].trade.data;
        await busdContract.methods.approve(this.swapRouterContract.address, '500000').send({from: admin});
        await this.swapRouterContract.swap("pmmFeeDynamic", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", '500000', tradeData, {from: admin});
        let balance = await busdContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);

        // balance = await thcContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('balance : ', await web3.eth.getBalance(admin))
        
        // let data = await this.testContract.testCallFunction(this.callTestContract.address, thcAddress, 100000,{from: admin});
        // console.log("data : ", data.logs[0].args);
    })
})