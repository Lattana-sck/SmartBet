# SmartBet

SmartBet - Plateforme de Pronostics sur les Matchs de Football

## Requirement 

NPM | Node.js | Hardhat

## How to install 

Clone this repository and install dependencies
```
Git clone https://github.com/Lattana-sck/SmartBet.git
Cd SmartBet
npm install
```

Create environnement file
```
Create an .env file with these two variable
PRIVATE_KEY=
INFURA_API_KEY=
```

Compile smart contract and deploy on sepolia network
```
npx hardhat compile
npx hardhat run scripts/deploySmartBet.js --network sepolia
```

## Authors

- [@lattana-sck](https://www.github.com/lattana-sck)

## Badges

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
