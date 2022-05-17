## DOCUMENTATION

DEX Aggregator

## MadWallet DEX Aggregator on Binance Smart Chain:

### 1. Provided Swap Data
Gets Swap Data from Madwallet Swap Backend - https://stake.xend.tools/networks/56/trades?destinationToken=&sourceToken=&sourceAmount=&slippage=&timeout=&walletAddress=

Madwallet Swap Backend provides datas for swapping from 5 lending platforms.

Here are swap routers on lending platforms.
* AirSwapV3 - 0x132F13C3896eAB218762B9e46F55C9c478905849
* 1inchSwap - 0x1111111254fb6c44bAC0beD2854e76F90643097ds
* Paraswap - 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57
* ZeroEx - 0xDef1C0ded9bec7F1a1670819833240f027b25EfF

MadwalletApp selects one platform of them. It depends on the highest price on swapping.

### 2. Parse Data & Swap
Madwallet app provides Swap Data with bytes data type.

Here is some example for parsing bytes data.

https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/parse_datas

Swapping is doing with parsed data on selected swap router.

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

## Deployed Contracts
https://bscscan.com/address/0x32Dc22c7357F00E18Aa700674527A2a9BbBC77d9
