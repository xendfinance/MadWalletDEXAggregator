## DOCUMENTATION

DEX Aggregator

## MadWallet DEX Aggregator on Binance Smart Chain:

### 1. Provided Swap Data
Gets Swap Data from Madwallet Swap Backend - https://stake.xend.tools/networks/56/trades?destinationToken=&sourceToken=&sourceAmount=&slippage=&timeout=&walletAddress=

Madwallet Swap Backend provides datas for swapping from 5 lending platforms.

Here are swap routers on lending platforms.
* AirSwap - 0xc98314a5077DBa8F12991B29bcE39F834E82e197
* 1inchSwap - 0x1111111254fb6c44bAC0beD2854e76F90643097ds
* Paraswap - 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57
* Pmmswap (old version of zeroEx) - 0x3F93C3D9304a70c9104642AB8cD37b1E2a7c203A
* ZeroEx - 0xDef1C0ded9bec7F1a1670819833240f027b25EfF

MadwalletApp selects one platform of them. It depends on the highest price on swapping.

### 2. Parse Data & Swap
Madwallet app provides Swap Data with bytes data type.

Here is some example for parsing bytes data.

https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/parse_datas

Swapping is doing with parsed data on selected swap router.

## Fork mainnet for testing

#### 1. AirSwapLight
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/AirSwapLightTest.js

#### 2. OneInchSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/OneInchSwapTest.js

#### 3. ParaSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 -u 0x0B25a50F0081c177554e919EeFf192Cfe9EfDe15 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/ParaswapTest.js 

#### 4. PmmSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/PmmTest.js

#### 5. ZeroExSwap
ganache-cli -f https://bsc.getblock.io/mainnet/?api_key=API_KEY -m "hidden moral pulp timber famous opinion melt any praise keen tissue aware" -l 100000000 -i 1 --allowUnlimitedContractSize
https://github.com/xendfinance/MadWalletDEXAggregator/tree/main/test/ZeroExTest.js

## Deployed Contracts
https://bscscan.com/address/0x32Dc22c7357F00E18Aa700674527A2a9BbBC77d9
