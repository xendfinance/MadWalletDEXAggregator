const FeeVault = artifacts.require("FeeVault");

contract("FeeVault", async accounts => {
    it("Should return the owner wallet address", async () => {
        console.log("Owner account",accounts[0])
    })
})
