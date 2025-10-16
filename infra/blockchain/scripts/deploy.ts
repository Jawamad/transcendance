import { ethers } from "hardhat";

async function main(): Promise<void> {
  // On récupère le "factory" du smart contract
  const ScoreStorage = await ethers.getContractFactory("ScoreStorage");

  // On déploie le contrat
  const scoreStorage = await ScoreStorage.deploy();

  // On attend que le déploiement soit terminé
  await scoreStorage.deployed();

  console.log("ScoreStorage deployed to:", scoreStorage.address);
}

// Gestion des erreurs
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
