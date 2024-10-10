<h2 align=center>Deploy ERC20 Token Contract on Unichain Sepolia</h2>

## Prerequisites
- Must need to have $ETH on Unichain
   - You can get Unichain $ETH using faucet from [here](https://console.optimism.io/faucet) or by bridging using [superbridge](https://superbridge.app/unichain-sepolia)
   - I used bridge to get Unichain ETH
- Need to have terminal which support linux based terminal
   - You can use either local terminal (Ubuntu)
   - Or you can use Virtual IDE like [codespaces](https://github.com/codespaces)
 
## Installation
- You can use either this command
```bash
  [ -f "unichain.sh" ] && rm unichain.sh; wget -q https://raw.githubusercontent.com/zunxbt/unichain/refs/heads/main/unichain.sh && chmod +x unichain.sh && ./unichain.sh
```
- Or this command to run this script
```bash
[ -f "unichain.sh" ] && rm unichain.sh; curl -sSL -o unichain.sh https://raw.githubusercontent.com/zunxbt/unichain/refs/heads/main/unichain.sh && chmod +x unichain.sh && ./unichain.sh
```
