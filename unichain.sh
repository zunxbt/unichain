#!/bin/bash

curl -s https://raw.githubusercontent.com/zunxbt/logo/main/logo.sh | bash
sleep 5

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit

read -p "Enter your Private Key: " PRIVATE_KEY
read -p "Enter the token name (e.g., Zun Token): " TOKEN_NAME
read -p "Enter the token symbol (e.g., ZUN): " TOKEN_SYMBOL

mkdir -p "$SCRIPT_DIR/token_deployment"
cat <<EOL > "$SCRIPT_DIR/token_deployment/.env"
PRIVATE_KEY="$PRIVATE_KEY"
TOKEN_NAME="$TOKEN_NAME"
TOKEN_SYMBOL="$TOKEN_SYMBOL"
EOL

source "$SCRIPT_DIR/token_deployment/.env"

CONTRACT_NAME="ZunXBT"

if [ ! -d ".git" ]; then
    show "Initializing Git repository..." "progress"
    git init
fi

if ! command -v forge &> /dev/null; then
    show "Foundry is not installed. Installing now..." "progress"
    source <(wget -O - https://raw.githubusercontent.com/zunxbt/installation/main/foundry.sh)
fi

if [ ! -d "$SCRIPT_DIR/lib/openzeppelin-contracts" ]; then
    show "Installing OpenZeppelin Contracts..." "progress"
    git clone https://github.com/OpenZeppelin/openzeppelin-contracts.git "$SCRIPT_DIR/lib/openzeppelin-contracts"
else
    show "OpenZeppelin Contracts already installed."
fi

if [ ! -f "$SCRIPT_DIR/foundry.toml" ]; then
    show "Creating foundry.toml and adding Unichain RPC..." "progress"
    cat <<EOL > "$SCRIPT_DIR/foundry.toml"
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

[rpc_endpoints]
unichain = "https://sepolia.unichain.org"
EOL
else
    show "foundry.toml already exists."
fi

show "Creating ERC-20 token contract using OpenZeppelin..." "progress"
mkdir -p "$SCRIPT_DIR/src"
cat <<EOL > "$SCRIPT_DIR/src/$CONTRACT_NAME.sol"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract $CONTRACT_NAME is ERC20 {
    constructor() ERC20("$TOKEN_NAME", "$TOKEN_SYMBOL") {
        _mint(msg.sender, 100000 * (10 ** decimals()));
    }
}
EOL

show "Compiling the contract..." "progress"
forge build

if [[ $? -ne 0 ]]; then
    show "Contract compilation failed." "error"
    exit 1
fi

show "Deploying the contract to Unichain..." "progress"
DEPLOY_OUTPUT=$(forge create "$SCRIPT_DIR/src/$CONTRACT_NAME.sol:$CONTRACT_NAME" \
    --rpc-url unichain \
    --private-key "$PRIVATE_KEY")

if [[ $? -ne 0 ]]; then
    show "Deployment failed." "error"
    exit 1
fi


CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oP 'Deployed to: \K(0x[a-fA-F0-9]{40})')
show "Token deployed successfully at address: https://sepolia.uniscan.xyz/address/$CONTRACT_ADDRESS"
