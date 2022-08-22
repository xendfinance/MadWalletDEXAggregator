const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("SwapRouter");
const tokenOwner = '0x72a53cdbbcc1b9efa39c834a540550e23463aacb';
const ethABI = require('./abi/eth');
const ethAddress = "0x2170ed0880ac9a755fd29b2688956bd959f933f8";
const ethContract = new web3.eth.Contract(ethABI, ethAddress);

const busdABI = require('./abi/busd');
// const busdAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
const busdAddress = "0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

const swapRouterABI = require('./abi/swapRouter.json')
const swapRouterAddress = "0xe41f0FF3f4d90Bb1c4e32714532e064F9eA95F19";
const swapRouterContract = new web3.eth.Contract(swapRouterABI, swapRouterAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        // this.swapRouterContract = await SwapRouter.deployed();
        await ethContract.methods.transfer(admin, '63376811096236907').send({from: tokenOwner});
    });

    it('test', async() => {
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0xe9e7cea3dedca5984780bafc599bd69add087d56&sourceToken=0x2170ed0880ac9a755fd29b2688956bd959f933f8&sourceAmount=63376811096236907&slippage=3&timeout=10000&walletAddress='+admin

        // let url = 'http://localhost:3333/networks/56/trades?destinationToken=0xe9e7cea3dedca5984780bafc599bd69add087d56&sourceToken=0x2170ed0880ac9a755fd29b2688956bd959f933f8&sourceAmount=63376811096236907&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;

        // let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x24802247bD157d771b7EFFA205237D8e9269BA8A&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=500000&slippage=3&timeout=10000&walletAddress='+admin

        // let url = 'http://localhost:3333/networks/56/trades?destinationToken=0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=5000000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        // let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=5000000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();
        
        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'paraswap'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        await ethContract.methods.approve(this.swapRouterContract.address, '63376811096236907').send({from: admin});
        await web3.eth.sendTransaction({
            from: admin,
            // to: this.swapRouterContract.address,
            to: swapRouterAddress,
            data: tradeData,
            gas: 6000000, 
            gasPrice: 4000000000
        })
        // await web3.eth.sendTransaction({
        //     from: admin,
        //     to: this.swapRouterContract.address,
        //     data: tradeData,
        //     value: 5000000000000000000,
        //     gas: 6000000, 
        //     gasPrice: 4000000000
        // })

        // let balance = await busdContract.methods.balanceOf(admin).call();
        // console.log('balance : ', balance);

        // balance = await busdContract.methods.balanceOf(this.swapRouterContract.address).call();
        // console.log('balance : ', balance);

        // balance = await ethContract.methods.balanceOf('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA').call();
        // console.log('balance : ', balance);

        // console.log('balance : ', await web3.eth.getBalance(admin))

        // console.log('balance : ', await web3.eth.getBalance(admin))

        // console.log('balance : ', await web3.eth.getBalance(this.swapRouterContract.address))

        // console.log('balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))

        // balance = await busdContract.methods.balanceOf(admin).call();
        // console.log('balance : ', balance);

        // const eventResult = await this.swapRouterContract.getPastEvents('Swap', {
        const eventResult = await swapRouterContract.getPastEvents('Swap', {
            fromBlock:'latest',
            toBlock:'latest'
        });
        // console.log(JSON.stringify(eventResult[0]['args']))
        console.log(JSON.stringify(eventResult[0]['returnValues']))
    })
})