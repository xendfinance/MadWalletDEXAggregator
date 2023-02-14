## DOCUMENTATION

DEX Aggregator allows users to swap their token for another asset on the same blockchain, for the lowest fees. 
It does this using an off-chain aggregator(Madwallet Backend) that checks for the current swap fees across multiple DEXES and performs the swap on the DEX with the lowest fee.

It works with 4 swap aggregators, and selects the best among them. These include: Airswap, Paraswap, 0x swap, oneInch swap.

## HOW TO SWAP

Users can perform a simple swap on this Dex Aggregator using the steps below.
They only need to interact with the off-chain aggregator which returns the DEX with the current lowest fee, amongst other details.

### 1. Request For Swap Data
User gets Swap Data from the off-chain aggregator - https://stake.xend.tools/networks/56/trades?destinationToken=&sourceToken=&sourceAmount=&slippage=&timeout=&walletAddress=

The backend-server provides the data needed for swapping on the 4 swap protocols.
The user now selects one of them. 

*Nb: For the Madwallet client, we select the protocol with the least fee by default.*

### 2. Parse Data & Swap
Madwallet backend server returns Swap Data with `bytes` data type.

Here is some example for parsing bytes data.
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/parse_datas

Pass in the parsed data to the function below when swapping.

### 3. Performing a swap
 Call the function below and pass in the required arguments.

```

    /**
    * @notice Performs a swap
    * @param aggregatorId Selected Dex for swapping
    * @param tokenFrom Address of source token to be swapped
    * @param amount Amount of source token
    * @param data Encoded data for swapping
    */ 

    function swap(string memory aggregatorId, address tokenFrom, uint256 amount, bytes memory data) 
```

## Fork mainnet for testing

#### 1. AirSwapV3
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --chainId 56 -u 0x72a53cdbbcc1b9efa39c834a540550e23463aacb --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/AirSwapV3Test.js

#### 2. OneInchSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --chainId 56 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/OneInchSwapTest.js

#### 3. ParaSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --chainId 56 -u 0x72a53cdbbcc1b9efa39c834a540550e23463aacb --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/ParaswapTest.js 

#### 4. ZeroExSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --chainId 56 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/ZeroExTest.js


## DEPLOYED CONTRACTS FOR THE MADWALLET SWAP ROUTERS
* ETHEREUM: [0x2B1eAD015dbab6618760ACee5e72148b95B95980](https://etherscan.io/address/0x2B1eAD015dbab6618760ACee5e72148b95B95980#code)<br>
* BSC: [0xe41f0FF3f4d90Bb1c4e32714532e064F9eA95F19](https://bscscan.com/address/0xe41f0FF3f4d90Bb1c4e32714532e064F9eA95F19#code)<br>
* POLYGON: [0x2F34767898CbCb2cd24F86AC4E61C785D49B2df7](https://polygonscan.com/address/0x2F34767898CbCb2cd24F86AC4E61C785D49B2df7#code)

## DEPLOYED CONTRACTS FOR THE SUPPORTED DEXES
Here are the swap routers on BSC.
* AirSwapV3 - 0x132F13C3896eAB218762B9e46F55C9c478905849
* 1inchSwap - 0x1111111254fb6c44bAC0beD2854e76F90643097ds
* Paraswap - 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57
* ZeroEx - 0xDef1C0ded9bec7F1a1670819833240f027b25EfF

