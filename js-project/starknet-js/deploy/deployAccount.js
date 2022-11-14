import fs from "fs";
import { askQuestion, getProvider } from "../scripts/helpers.js";
import { Account, ec, json, stark } from "starknet";

const provider = getProvider();

console.log("Reading OpenZeppelin Account Contract...");

const compiledOZAccount = json.parse(
  fs.readFileSync("builds/OZAccount.json").toString("ascii")
);

// Generate public and private key pair.
const privateKey = stark.randomAddress();

const starkKeyPair = ec.genKeyPair(privateKey);
const starkKeyPub = ec.getStarkKey(starkKeyPair);

// Log the Public and Private key pair.
console.log(`Private key: ${privateKey}`);
console.log(`Public key: ${starkKeyPub}`);

const ans1 = await askQuestion(
    "Did you save these keys somewhere safe? Hit enter if yes"
  );

const accountResponse = await provider.deployContract({
  contract: compiledOZAccount,
  constructorCalldata: [starkKeyPub],
  addressSalt: starkKeyPub,
});

console.log("Account address ", accountResponse.contract_address);

console.log(
  `See account on the explorer: https://goerli.voyager.online/contract/${accountResponse.contract_address}`
);

console.log(
  `Follow the tx status on: https://goerli.voyager.online/tx/${accountResponse.transaction_hash}`
);

await provider.waitForTransaction(accountResponse.transaction_hash);

console.log("Account contract deployed successfully!");

const ans2 = await askQuestion(
  "Did you add funds to your Account? Hit enter if yes"
);

console.log(
    `////////////////////////////////////////////////////////////////////////////////
      Congratulations, your account should now be deployed !!!!!!
     ////////////////////////////////////////////////////////////////////////////////`
  );
  


// Use your new account address
export const account = new Account(
  provider,
  accountResponse.contract_address,
  starkKeyPair
);

