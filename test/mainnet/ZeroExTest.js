const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("MainnetSwapRouter");
const usdtABI = require('./abi/usdt');
const usdtAddress = "0xdac17f958d2ee523a2206206994597c13d831ec7";
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
    });

    it('test', async() => {
        let url = 'http://localhost:3333/networks/1/trades?destinationToken=0xdac17f958d2ee523a2206206994597c13d831ec7&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=10000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'zeroEx'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        await this.swapRouterContract.swap("0xFeeDynamic", "0x0000000000000000000000000000000000000000", '10000000000000000', tradeData, {from: admin, value: '10000000000000000'});

        let balance = await usdtContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);
        
        balance = await usdtContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('balance : ', balance);

        console.log('balance : ', await web3.eth.getBalance(admin))

        console.log('balance : ', await web3.eth.getBalance(this.swapRouterContract.address))

        console.log('balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))
    })
})