const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("MainnetSwapRouter");
const tokenOwner = '0x72a53cdbbcc1b9efa39c834a540550e23463aacb';
const usdcABI = require('./abi/usdc');
const usdcAddress = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const usdtABI = require('./abi/usdt');
const usdtAddress = "0xdac17f958d2ee523a2206206994597c13d831ec7";
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
        // await usdtContract.methods.transfer(admin, '10948481785509522128000').send({from: tokenOwner, gas: 6000000, gasPrice: 4000000000});
    });
    it('test', async() => {
        let url = 'http://localhost:3333/networks/1/trades?destinationToken=0xdac17f958d2ee523a2206206994597c13d831ec7&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=5000000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
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
        let balance = await usdtContract.methods.balanceOf(admin).call();
        console.log('admin token balance : ', balance);

        balance = await usdcContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('swapContract token balance : ', balance);

        balance = await usdcContract.methods.balanceOf('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA').call();
        console.log('feeAddress token balance : ', balance);

        console.log('admin eth balance : ', await web3.eth.getBalance(admin))
        console.log('swapContract eth balance : ', await web3.eth.getBalance(this.swapRouterContract.address))
        console.log('feeAddress eth balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))
    })
})