const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const FeeVault = artifacts.require("FeeVault");
const ForceSend = artifacts.require('ForceSend');
const mimABI = require('./abi/mim');
const mimAddress = "0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3";
const mimContract = new web3.eth.Contract(mimABI, mimAddress);
const mimOwner = "0x5a6A4D54456819380173272A5E8E9B9904BdF41B";

const usdcABI = require('./abi/usdc');
const usdcAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

// const swapRouterABI = require('./abi/swapRouter');
// const swapRouterAddress = "0x1a1ec25dc08e98e5e93f1104b5e5cdd298707d31";
// const swapRouterContract = new web3.eth.Contract(swapRouterABI, swapRouterAddress);

contract('test FeeVault', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.feeVaultContract = await FeeVault.new("0x881D40237659C251811CEC9c364ef91dC08D300C", {from: alice});
        const forceSend = await ForceSend.new();
        // await forceSend.go(mimOwner, { value: ether('1') });
        // await web3.eth.sendTransaction({
        //     from: admin, 
        //     to: mimOwner,
        //     value: ether('1')
        // });
        await forceSend.go("0xb346d2A76C0A911f4dd65ABa21C1B66004954902", { value: ether('1') });
        await mimContract.methods.transfer("0xb346d2A76C0A911f4dd65ABa21C1B66004954902", '17591915237248426359410').send({from: mimOwner});
        // await mimContract.methods.transfer(alice, '17591915237248426359410').send({from: mimOwner});
    });

    it('fee test', async() => {
        // await this.feeVaultContract.setFee(100);
        await this.feeVaultContract.setFeeAddress("0x67926b0C4753c42b31289C035F8A656D800cD9e7");
        // let mimBalance = await mimContract.methods.balanceOf("0xb346d2a76c0a911f4dd65aba21c1b66004954902").call();
        let mimBalance = await mimContract.methods.balanceOf(alice).call();
        console.log('before mim balance: ', mimBalance.toString());
        let usdcBalance = await usdcContract.methods.balanceOf("0xb346d2a76c0a911f4dd65aba21c1b66004954902").call();
        // usdcBalance = await usdcContract.methods.balanceOf(alice).call();
        console.log('before usdc balance: ', usdcBalance.toString());
        const result = await this.feeVaultContract.swap(
            "oneInchV4FeeDynamic",
            "0x99D8a9C45b2ecA8864373A26D1459e3Dff1e17F3",
            "1759191523724842635941",
            "0x00000000000000000000000099d8a9c45b2eca8864373a26d1459e3dff1e17f3000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000005f5dafca3b496a12a50000000000000000000000000000000000000000000000000000000065d290d900000000000000000000000000000000000000000000000000000000000001200000000000000000000000000000000000000000000000000000000000eacaa70000000000000000000000002acf35c9a3f4c5c3f4c78ef5fb64c3ee82f07c45000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a8e449022e00000000000000000000000000000000000000000000005f5dafca3b496a12a50000000000000000000000000000000000000000000000000000000066b8a95e00000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000001000000000000000000000000298b7c5e0770d151e4c5cf6cca4dae3a3ffc8e27ab4991fe000000000000000000000000000000000000000000000000",
            {
                from : "0xb346d2a76c0a911f4dd65aba21c1b66004954902"
            }
        );
        // 52775745711745279078230
        // 1759191523724842635941
        // 134439500000000000
        // 29961762130332841
        mimBalance = await mimContract.methods.balanceOf("0xb346d2a76c0a911f4dd65aba21c1b66004954902").call();
        // mimBalance = await mimContract.methods.balanceOf(alice).call();
        console.log('after mim balance: ', mimBalance.toString());
        usdcBalance = await usdcContract.methods.balanceOf("0xb346d2a76c0a911f4dd65aba21c1b66004954902").call();
        // usdcBalance = await usdcContract.methods.balanceOf(alice).call();
        console.log('after usdc balance: ', usdcBalance.toString());
        console.log('result: ',result.logs[0]);
        mimBalance = await mimContract.methods.balanceOf("0x67926b0C4753c42b31289C035F8A656D800cD9e7").call();
        console.log('fee balance: ', mimBalance.toString());
    })
})
