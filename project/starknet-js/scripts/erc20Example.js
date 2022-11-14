import fs from "fs";
import dotenv from "dotenv";
import { getAccountFromPk, getProvider } from "../scripts/helpers.js";
import { Contract, json, number } from "starknet";

dotenv.config();

//-------------- Devnet deployement addresses
const erc20Address = "0x51fdf7f48a0f5436b4d85fbf03aca4d910a7a207194897108cb470826143160";
const devnetAddr1 = "0x69b49c2cc8b16e80e86bfc5b0614a59aa8c9b601569c7b80dde04d3f3151b79";
const devnetAddr0 = "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a"
const devnetPK = "0xe3e70682c2094cac629f6fbed82c07cd"


/*-------------- Goerli deployement addresses
const goerliAddress = process.env.GOERLI_ACCOUNT_ADDRESS;
const goerliPK = process.env.GOERLI_PRIVATE_KEY;   
const erc20Address = "0x7a7daef82e3afed06ce295d48c3f66a9c6de13e9d48f318dc28cc6d49516b3f";
*/

let provider = getProvider();
let account = getAccountFromPk(devnetAddr0, devnetPK, provider);

console.log(account)

console.log("Reading ERC20 Contract...\n");
const compiledErc20 = json.parse(
  fs.readFileSync("builds/ERC20.json").toString("ascii")
);

let erc20 = new Contract(compiledErc20.abi, erc20Address, provider);

erc20.connect(account);

// Check balance -
console.log(`Calling StarkNet for account balance...\n`);

const initialBalance = await erc20.balance_of(account.address);

console.log(
  `account Address ${account.address} has: \n`,
  number.toBN(initialBalance.res, 16).toString()
);

let account_nonce_bn = await account.getNonce();

const account_nonce = number.toBN(account_nonce_bn).toNumber();
console.log(`Account has a nonce of ${account_nonce}`);

// Minting tokens to address
const { mint_transaction_hash } = await erc20.mint(
  account.address,
  "500",
  {
    maxFee: "999999995330000",
    nonce: account_nonce + 100000,
  }
);

// Wait for the invoke transaction to be accepted on StarkNet
console.log(
  `////////////////////////////////////////////////////////////////////////////////
    Waiting for Tx to be Accepted on Starknet - Mint...
  ////////////////////////////////////////////////////////////////////////////////\n`
  );
  
  await provider.waitForTransaction(mint_transaction_hash);

// Check balance after Mint - should be 500
console.log(`Calling StarkNet for account balance...\n`);
const balanceAfterMint = await erc20.balance_of(account.address);

console.log(
  `account Address ${account.address} has a balance of:`,
  number.toBN(balanceAfterMint.res, 16).toString()
);

console.log(
  `////////////////////////////////////////////////////////////////////////////////
    Estimating gas costs for the user now ...
  ////////////////////////////////////////////////////////////////////////////////\n`
  );

const { overall_fee } = await account.estimateInvokeFee({
  contractAddress: erc20Address,
  entrypoint: 'transfer',
  calldata: [devnetAddr1, "500"],
});

console.log(`It will cost you around ${overall_fee} to run this transaction`)

console.log(
`////////////////////////////////////////////////////////////////////////////////
  Transferring 500 tokens to ${devnetAddr1}...
////////////////////////////////////////////////////////////////////////////////\n`
);

// Execute transfer of ERC20 tokens
const { code, transfer_transaction_hash } = await account.execute(
  {
    contractAddress: erc20Address,
    entrypoint: 'transfer',
    calldata: [devnetAddr1, "500"],
  },
  undefined,
  {
    maxFee: "999999995330000",
    nonce: account_nonce + 1
  }
);

// Wait for the invoke transaction to be accepted on StarkNet
console.log(
`////////////////////////////////////////////////////////////////////////////////
  Waiting for Tx to be Accepted on Starknet - Transfer...
////////////////////////////////////////////////////////////////////////////////\n`
);

await provider.waitForTransaction(transfer_transaction_hash);

// Check balance after transfer - should be lower by 500 again
console.log(`Calling StarkNet for account balance...\n`);
const balanceAfterTransfer = await erc20.balance_of(account.address);

console.log(
  `account Address ${account.address} has a balance of:`,
  number.toBN(balanceAfterTransfer.res, 16).toString()
);
