const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("SwapRouter");
const thcABI = require('./abi/thc');
const thcAddress = "0x24802247bD157d771b7EFFA205237D8e9269BA8A";
const thcContract = new web3.eth.Contract(thcABI, thcAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
    });

    it('test', async() => {
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x24802247bD157d771b7EFFA205237D8e9269BA8A&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'oneInch'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        await this.swapRouterContract.swap("oneInchV4FeeDynamic", "0x0000000000000000000000000000000000000000", 500000, tradeData, {from: admin, value: 500000});
        let balance = await thcContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);

        console.log('balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))

        console.log('balance : ', await web3.eth.getBalance(admin))
    })
})