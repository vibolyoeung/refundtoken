require("dotenv").config(); // Load environment variables from .env file
const { ethers } = require("ethers");

// interact.js

const PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
const CONTRACT_ADDRESS = process.env.CONTACT_ADDRESS;

const contract = require("../artifacts/contracts/ChildNaming.sol/ChildNaming.json");

// provider - Alchemy
const alchemyProvider = new ethers.AlchemyProvider(
  "sepolia",
  ALCHEMY_API_KEY
);
console.log(alchemyProvider);

// signer - you
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// contract instance
const childNaming = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

async function main() {
  const name = await childNaming.getNames();
  console.log("The name is: " + name);

  console.log("Updating the name...");
  const tx = await childNaming.addName("vibol");
  await tx.wait();

  const newname = await childNaming.getNames();
  console.log("The new name is: " + newname);
}

main();
