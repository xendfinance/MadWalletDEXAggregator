// const { BN, ether, balance } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');
// const ForceSend = artifacts.require('ForceSend');
const {fetch} = require('cross-fetch');
const Test = artifacts.require("TestSwap");
const CallTest = artifacts.require("CallTest");
const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0x5a52e96bacdabb82fd05763e25335261b270efcb';
const usdcABI = require('./abi/usdc');
const usdcAddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const busdABI = require('./abi/busd');
const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.testContract = await Test.new({from: alice});
        this.swapRouterContract = await SwapRouter.new({from: alice});
        // this.callTestContract = await CallTest.new({from: alice});
        await usdcContract.methods.transfer(admin, '1090484817855095221280').send({from: tokenOwner});
    });
    it('test', async() => {
        // admin = '0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15';
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0xe9e7cea3dedca5984780bafc599bd69add087d56&sourceToken=0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d&sourceAmount=109484817855095221280&slippage=3&timeout=10000&walletAddress='+admin;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        console.log(swapData[0].trade);
        let tradeData = swapData[0].trade.data;
        await usdcContract.methods.approve(this.swapRouterContract.address, '109484817855095221280').send({from: admin});
        await this.swapRouterContract.swap("airswapLightFeeDynamic", "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56", '109484817855095221280', tradeData, {from: admin, value: '109484817855095221280'});
        let balance = await busdAddress.methods.balanceOf(admin).call();
        console.log('balance : ', balance);

        console.log('balance : ', await web3.eth.getBalance(admin))
    })
})