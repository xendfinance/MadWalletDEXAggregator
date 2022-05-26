const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("PolygonSwapRouter");
const tokenOwner = '0x72a53cdbbcc1b9efa39c834a540550e23463aacb';

const usdtABI = require('./abi/usdt');
const usdtAddress = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);
const usdcABI = require('./abi/usdc');
const usdcAddress = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

const busdABI = require('./abi/busd');
const busdAddress = "0xdAb529f40E671A1D4bF91361c21bf9f0C9712ab7";
const busdContract = new web3.eth.Contract(busdABI, busdAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
        await usdcContract.methods.transfer(admin, '5000000').send({from: tokenOwner, gas: 6000000, gasPrice: 4000000000});
    });
    
    it('test', async() => {
        let url = 'http://localhost:3333/networks/137/trades?destinationToken=0xc2132D05D31c914a87C6611C10748AEb04B58e8F&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=5000000000000000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        // let url = 'http://localhost:3333/networks/137/trades?destinationToken=0xdAb529f40E671A1D4bF91361c21bf9f0C9712ab7&sourceToken=0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174&sourceAmount=5000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        // let url = 'http://localhost:3333/networks/137/trades?destinationToken=0xc2132D05D31c914a87C6611C10748AEb04B58e8F&sourceToken=0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174&sourceAmount=5000000&slippage=3&timeout=10000&walletAddress='+admin+'&swapRouterContractAddress='+this.swapRouterContract.address;
        console.log(url)
        const res = await fetch(url);
          
        const swapData = await res.json();

        for(let i = 0; i < swapData.length; i ++){
            if(swapData[i].aggregator == 'airswapV3'){
                tradeData = swapData[i].trade.data;
            }
        }

        console.log(tradeData);

        await web3.eth.sendTransaction({
            from: admin,
            to: this.swapRouterContract.address,
            data: tradeData,
            value: '5000000000000000000',
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

        // let balance = await busdContract.methods.balanceOf(admin).call();
        // console.log('admin token balance : ', balance);

        // balance = await busdContract.methods.balanceOf(this.swapRouterContract.address).call();
        let balance = await usdtContract.methods.balanceOf(admin).call();
        console.log('admin token balance : ', balance);

        balance = await usdtContract.methods.balanceOf(this.swapRouterContract.address).call();
        console.log('swapContract token balance : ', balance);

        balance = await usdcContract.methods.balanceOf('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA').call();
        console.log('feeAddress token balance : ', balance);

        console.log('admin eth balance : ', await web3.eth.getBalance(admin))
        console.log('swapContract eth balance : ', await web3.eth.getBalance(this.swapRouterContract.address))
        console.log('feeAddress eth balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))
    })
})