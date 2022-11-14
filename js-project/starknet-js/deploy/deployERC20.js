import dotenv from "dotenv";
import fs from "fs";
import { getProvider } from "../scripts/helpers.js";
import { Contract, json } from "starknet";

dotenv.config();

let provider = getProvider();

console.log("Reading ERC20 Contract...");
const compiledErc20 = json.parse(
  fs.readFileSync("builds/ERC20.json").toString("ascii")
);

// Deploy an ERC20 contract and wait for it to be verified on StarkNet.
console.log("Deployment Tx - ERC20 Contract to StarkNet...");
const erc20Response = await provider.deployContract({
  contract: compiledErc20,
  // constructorCalldata: [account.address],
});

console.log("Contract address ", erc20Response.contract_address);

console.log(
  `See account on the explorer: https://goerli.voyager.online/contract/${erc20Response.contract_address}`
);

console.log(
  `Follow the tx status on: https://goerli.voyager.online/tx/${erc20Response.transaction_hash}`
);

// Wait for the deployment transaction to be accepted on StarkNet
console.log("Waiting for Tx to be Accepted on Starknet - ERC20 Deployment...");
await provider.waitForTransaction(erc20Response.transaction_hash);

// Get the erc20 contract address
const erc20Address = erc20Response.contract_address;
console.log("ERC20 Address: ", erc20Address);

// Create a new erc20 contract object
export const erc20 = new Contract(compiledErc20.abi, erc20Address, provider);
