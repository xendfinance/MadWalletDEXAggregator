// const { BN, ether, balance } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');
// const ForceSend = artifacts.require('ForceSend');
const {fetch} = require('cross-fetch');
const Test = artifacts.require("TestSwap");
const CallTest = artifacts.require("CallTest");
const SwapRouter = artifacts.require("SwapRouter");
const abi = require('ethereumjs-abi')
const tokenOwner = '0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15';
const busdABI = require('./abi/busd');
const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

const usdtABI = require('./abi/usdt');
const usdtAddress = "0x55d398326f99059ff775485246999027b3197955";
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

const swapRouterABI = require('./abi/swapRouter')
const swapRouterAddress = "0x0005ab46e48c054db5227a44d0b6264e4c134b7d"
const swapRouterContract = new web3.eth.Contract(swapRouterABI, swapRouterAddress)

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.testContract = await Test.new({from: alice});
        this.swapRouterContract = await SwapRouter.new({from: alice});
        // this.callTestContract = await CallTest.new({from: alice});
        await busdContract.methods.transfer(admin, '5000000000000').send({from: tokenOwner});
    });

    it('test', async() => {
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=5000000000000&slippage=2&timeout=10000&swapAddress='+this.swapRouterContract.address+'&walletAddress='+admin;
        // console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        console.log(swapData[3].trade);
        let tradeData = swapData[3].trade.data;
        // await busdContract.methods.approve(this.swapRouterContract.address, '5000000000000').send({from: admin});
        await this.swapRouterContract.swap("pmmFeeDynamic", "0x0000000000000000000000000000000000000000", '5000000000000', tradeData, {from: admin,gasPrice: 10000000000,gas: 300000});
        // await swapRouterContract.methods.swap("pmmFeeDynamic", "0x0000000000000000000000000000000000000000", '5000000000000', tradeData).send({from: admin,gasPrice: 10000000000,gas: 300000});
        let balance = await busdContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);
        console.log('balance : ', await web3.eth.getBalance(admin))
        
        // let tmpTradeData;
        // if(tradeData.startsWith('0x5f575529')){
        //     tmpTradeData = tradeData.substring(1226, tradeData.length)
        // }
        // else{
        //     tmpTradeData = tradeData.substring(770, tradeData.length)
        // }
        // console.log(tmpTradeData);
        // let parseData = web3.eth.abi.decodeParameters(
        //     ['address','address','address','address','uint256','uint256','uint256','uint256','uint256','bytes32','bytes32','bytes32','bytes32','bytes4'],
        //     tmpTradeData
        // )
        // // let parseData = abi.rawDecode(
        // //     ['address','address','address','address','uint256','uint256','uint256','uint256','uint256','bytes32','bytes32','bytes32','bytes32','bytes4'],
        // //     tmpTradeData
        // // )
        // console.log('parseData : ', parseData);
        // let approveString = '0x095ea7b30000000000000000000000001a1ec25dc08e98e5e93f1104b5e5cdd298707d31ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
        // approveString = approveString.substring(10);
        // console.log(approveString);
        // let approveData = web3.eth.abi.decodeParameters(
        //     [
        //         'address','uint256',            
        //     ],
        //     approveString
        // );
        // console.log(approveData);
    })
})