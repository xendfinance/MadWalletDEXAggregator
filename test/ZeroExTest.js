const {fetch} = require('cross-fetch');
const SwapRouter = artifacts.require("SwapRouter");
const adaABI = require('./abi/ada');
const adaAddress = "0x3ee2200efb3400fabb9aacf31297cbdd1d435d47";
const adaContract = new web3.eth.Contract(adaABI, adaAddress);

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.swapRouterContract = await SwapRouter.deployed();
    });

    it('test', async() => {
        let url = 'https://stake.xend.tools/networks/56/trades?destinationToken=0x3ee2200efb3400fabb9aacf31297cbdd1d435d47&sourceToken=0x0000000000000000000000000000000000000000&sourceAmount=10000000000000000&slippage=3&timeout=10000&walletAddress='+admin;
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
        let balance = await adaContract.methods.balanceOf(admin).call();
        console.log('balance : ', balance);

        console.log('balance : ', await web3.eth.getBalance('0x5b3770699868c6A57cFA0B1d76e5b8d26f0e20DA'))

        console.log('balance : ', await web3.eth.getBalance(admin))
    })
})