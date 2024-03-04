// scripts/deploySmartBet.js

const hre = require("hardhat");

async function main() {
  // Récupère le contrat à déployer
  const SmartBet = await hre.ethers.getContractFactory("SmartBet");

  // Déploie le contrat
  const smartBet = await SmartBet.deploy();

  await smartBet.deployed();

  console.log("SmartBet deployed to:", smartBet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
