const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');
const ForceSend = artifacts.require('ForceSend');
const Test = artifacts.require("TestSwap");
const tokenOwner = '0x61B2109bb57EA6B2BCAF0336b23252939e98EB2A';
const thcABI = require('./abi/thc');
const thcAddress = "0x24802247bD157d771b7EFFA205237D8e9269BA8A";
const thcContract = new web3.eth.Contract(thcABI, thcAddress);

const thgABI = require('./abi/thg');
const thgAddress = "0x9fD87aEfe02441B123c3c32466cD9dB4c578618f";
const thgContract = new web3.eth.Contract(thgABI, thgAddress);

const zeroABI = require('./abi/zero');
const zeroExRouter = "0xDef1C0ded9bec7F1a1670819833240f027b25EfF";
const zeroExContract = new web3.eth.Contract(zeroABI, zeroExRouter);
const tester = "0xda91066AAcE5be94d370d22088d733a4107716fe";

contract('test Test', async([alice, bob, admin, dev, minter]) => {
    before(async () => {
        this.testContract = await Test.new({from: alice});
        await thcContract.methods.transfer(admin, '106570362666683402623').send({from: tokenOwner});
        const forceSend = await ForceSend.new();
        await forceSend.go(tester, { value: ether('10') });
    });

    it('test', async() => {
        await thcContract.methods.approve(this.testContract.address, '106570362666683402623').send({from: admin});
        console.log(await thgContract.methods.balanceOf(admin).call());
        // console.log(await web3.eth.getBalance(tester));
        let result = await this.testContract.swap("0x415565b000000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a0000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f000000000000000000000000000000000000000000000005ba051ce26fcee023000000000000000000000000000000000000000000000000145df9d54a9de91b00000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000005400000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000004a00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a0000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f0000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000046000000000000000000000000000000000000000000000000000000000000004600000000000000000000000000000000000000000000000000000000000000420000000000000000000000000000000000000000000000005ba051ce26fcee02300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000250616e63616b65537761705632000000000000000000000000000000000000000000000000000005493fcbe4b5fa05c500000000000000000000000000000000000000000000000012ccc263f430b57e000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000010ed43c718714eb63d5aa57b78b54704e256024e0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000200000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a0000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f0000000000000000000000000000000250616e63616b6553776170563200000000000000000000000000000000000000000000000000000070c550fdb9d4da5f00000000000000000000000000000000000000000000000001913771566d339d000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000010ed43c718714eb63d5aa57b78b54704e256024e0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000300000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a00000000000000000000000055d398326f99059ff775485246999027b31979550000000000000000000000009fd87aefe02441b123c3c32466cd9db4c578618f0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000024802247bd157d771b7effa205237d8e9269ba8a000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000869584cd00000000000000000000000011ededebf63bef0ea2d2d071bdf88f71543ec6fb0000000000000000000000000000000000000000000000eaa18a951b6201b7f5000000000000000000000000000000000000000000000000",
        {from: admin});
        // console.log(await web3.eth.getBalance(tester));
        // console.log('result: ', result);
        console.log(await thcContract.methods.balanceOf(admin).call());
        console.log(await thcContract.methods.balanceOf(this.testContract.address).call());
        // await zeroExContract.methods.sellToPancakeSwap(['0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56', '0x55d398326f99059fF775485246999027B3197955'], '80000000000000000000', '77393503097778831600', 0).send({from: admin});
        console.log(await thcContract.methods.balanceOf(admin).call());

        console.log(await thgContract.methods.balanceOf(admin).call());
        console.log(await thgContract.methods.balanceOf(this.testContract.address).call());

    })
})