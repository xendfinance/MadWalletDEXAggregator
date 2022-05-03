const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0x72a53cdbbcc1b9efa39c834a540550e23463aacb';
const usdcABI = require('./abi/usdc');
const usdcAddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const usdtABI = require('./abi/usdt');
const usdtAddress = "0x55d398326f99059ff775485246999027b3197955";
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
        // await usdtContract.methods.transfer(admin, '10948481785509522128000').send({from: tokenOwner, gas: 6000000, gasPrice: 4000000000});
    });
    it('test', async() => {
        // let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0xe9e7cea3dedca5984780bafc599bd69add087d56&sourceToken=0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d&sourceAmount=109484817855095221280&slippage=3&timeout=10000&walletAddress='+admin;
        // let url = 'http://localhost:3333/networks/56/trades?destinationToken=0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d&sourceToken=0x55d398326f99059ff775485246999027b3197955&sourceAmount=10948481785509522128000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        let url = 'http://localhost:3333/networks/56/trades?destinationToken=0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=5000000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();

        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'airswapV3'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        // await usdtContract.methods.approve(this.swapRouterContract.address, '10948481785509522128000').send({from: admin});
        await this.swapRouterContract.swap("airswapV3FeeDynamic", "0x0000000000000000000000000000000000000000", '5000000000000000000', tradeData, {from: admin, value: '5000000000000000000', gas: 6000000, gasPrice: 4000000000});
        // await this.swapRouterContract.swap("airswapV3FeeDynamic", "0x55d398326f99059ff775485246999027b3197955", '10948481785509522128000', tradeData, {from: admin, gas: 6000000, gasPrice: 4000000000});
        let balance = await usdcContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);

        balance = await usdtContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('balance : ', balance);

        balance = await usdtContract.methods.balanceOf('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA').call();
        console.log('balance : ', balance);

        console.log('balance : ', await web3.eth.getBalance(admin))
    })
})