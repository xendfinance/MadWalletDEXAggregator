const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("SwapRouter");
const thcABI = require('./abi/thc');
const thcAddress = "0x24802247bD157d771b7EFFA205237D8e9269BA8A";
const thcContract = new web3.eth.Contract(thcABI, thcAddress);
const swapRouterABI = require('./abi/swapRouter.json')
const swapRouterAddress = "0xe41f0FF3f4d90Bb1c4e32714532e064F9eA95F19";
const swapRouterContract = new web3.eth.Contract(swapRouterABI, swapRouterAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
    });

    it('test', async() => {
        // let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x24802247bD157d771b7EFFA205237D8e9269BA8A&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin
        // let url = 'http://localhost:3333/networks/56/trades?destinationToken=0x24802247bD157d771b7EFFA205237D8e9269BA8A&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x24802247bD157d771b7EFFA205237D8e9269BA8A&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'oneInch'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        await web3.eth.sendTransaction({
            from: admin,
            // to: this.swapRouterContract.address,
            to: swapRouterAddress,
            data: tradeData,
            value: 500000,
            gas: 6000000, 
            gasPrice: 4000000000
        })
        // let balance = await thcContract.methods.balanceOf(admin).call();
        // console.log('balance : ', balance);

        // balance = await thcContract.methods.balanceOf(this.swapRouterContract.address).call();
        // console.log('balance : ', balance);

        // console.log('balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))

        // console.log('balance : ', await web3.eth.getBalance(admin))

        // const eventResult = await this.swapRouterContract.getPastEvents('Swap', {
        const eventResult = await swapRouterContract.getPastEvents('Swap', {
            fromBlock:'latest',
            toBlock:'latest'
        });
        // console.log(JSON.stringify(eventResult[0]['args']))
        console.log(JSON.stringify(eventResult[0]['returnValues']))
    })
})