const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("MainnetSwapRouter");
const tokenOwner = '0x72a53cdbbcc1b9efa39c834a540550e23463aacb';
const usdtABI = require('./abi/usdt');
const usdtAddress = "0xdac17f958d2ee523a2206206994597c13d831ec7";
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

const usdcABI = require('./abi/usdc');
const usdcAddress = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const swapRouterABI = require('./abi/swapRouter.json')
const swapRouterAddress = "0x2B1eAD015dbab6618760ACee5e72148b95B95980";
const swapRouterContract = new web3.eth.Contract(swapRouterABI, swapRouterAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.swapRouterContract = await SwapRouter.deployed();
        await usdcContract.methods.transfer(admin, '5000000').send({from: tokenOwner, gas: 6000000, gasPrice: 4000000000});
    });

    it('test', async() => {
        // let url = 'http://localhost:3333/networks/1/trades?destinationToken=0xdac17f958d2ee523a2206206994597c13d831ec7&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=10000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        // let url = 'http://localhost:3333/networks/1/trades?destinationToken=0xdac17f958d2ee523a2206206994597c13d831ec7&sourceToken=0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48&sourceAmount=5000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        // let url = 'https://stake.xend.tools/networks/1/trades?destinationToken=0xdac17f958d2ee523a2206206994597c13d831ec7&sourceToken=0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48&sourceAmount=5000000&slippage=3&timeout=10000&walletAddress='+admin
        let url = 'https://stake.xend.tools/networks/1/trades?destinationToken=0xdac17f958d2ee523a2206206994597c13d831ec7&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=10000000000000000&slippage=3&timeout=10000&walletAddress='+admin
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'zeroEx'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        await web3.eth.sendTransaction({
            from: admin,
            // to: this.swapRouterContract.address,
            to: swapRouterAddress,
            data: tradeData,
            value: '10000000000000000',
            gas: 6000000, 
            gasPrice: 4000000000
        })
        // await usdcContract.methods.approve(this.swapRouterContract.address, '5000000').send({from: admin});
        // await web3.eth.sendTransaction({
        //     from: admin,
        //     to: this.swapRouterContract.address,
        //     data: tradeData,
        //     gas: 6000000, 
        //     gasPrice: 4000000000
        // })

        // let balance = await usdtContract.methods.balanceOf(admin).call();
        // console.log('admin token balance : ', balance);

        // balance = await usdtContract.methods.balanceOf(this.swapRouterContract.address).call();
        // console.log('swapContract token balance : ', balance);

        // balance = await usdcContract.methods.balanceOf('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA').call();
        // console.log('feeAddress token balance : ', balance);

        // console.log('admin eth balance : ', await web3.eth.getBalance(admin))
        // console.log('swapContract eth balance : ', await web3.eth.getBalance(this.swapRouterContract.address))
        // console.log('feeAddress eth balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))
        // const eventResult = await this.swapRouterContract.getPastEvents('Swap', {
        const eventResult = await swapRouterContract.getPastEvents('Swap', {
            fromBlock:'latest',
            toBlock:'latest'
        });
        // console.log(JSON.stringify(eventResult[0]['args']))
        console.log(JSON.stringify(eventResult[0]['returnValues']))
    })
})