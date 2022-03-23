// const { BN, ether, balance } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');
// const ForceSend = artifacts.require('ForceSend');
const {fetch} = require('cross-fetch');
const Test = artifacts.require("TestSwap");
const CallTest = artifacts.require("CallTest");
const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0x85Cf05F35b6D542aC1d777d3F8cfde57578696fc';
const thcABI = require('./abi/thc');
const thcAddress = "0x24802247bD157d771b7EFFA205237D8e9269BA8A";
const thcContract = new web3.eth.Contract(thcABI, thcAddress);

const thgABI = require('./abi/thg');
const thgAddress = "0x9fD87aEfe02441B123c3c32466cD9dB4c578618f";
const thgContract = new web3.eth.Contract(thgABI, thgAddress);

const zeroABI = require('./abi/zero');
const zeroExRouter = "0xDef1C0ded9bec7F1a1670819833240f027b25EfF";
const zeroExContract = new web3.eth.Contract(zeroABI, zeroExRouter);
const tester = "0xda91066AAcE5be94d370d22088d733a4107716fe";

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.testContract = await Test.new({from: alice});
        this.swapRouterContract = await SwapRouter.new({from: alice});
        // this.callTestContract = await CallTest.new({from: alice});
        // await thcContract.methods.transfer(admin, '100000').send({from: tokenOwner});
    });

    it('test', async() => {
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x24802247bD157d771b7EFFA205237D8e9269BA8A&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        // console.log(swapData[1].trade);
        let tradeData = swapData[1].trade.data;
        // await thcContract.methods.approve(this.swapRouterContract.address, '1000000000').send({from: admin});
        await this.swapRouterContract.swap("oneInchV4FeeDynamic", "0x0000000000000000000000000000000000000000", 500000, tradeData, {from: admin, value: 500000});
        let balance = await thcContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);

        // balance = await thcContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('balance : ', await web3.eth.getBalance(admin))
        
        // let data = await this.testContract.testCallFunction(this.callTestContract.address, thcAddress, 100000,{from: admin});
        // console.log("data : ", data.logs[0].args);
    })
})