import dotenv from "dotenv";
import { Provider, ec, Account} from "starknet";
import readline from "readline";

dotenv.config();

export function getProvider() {
    // Initialize provider
    const INFURA_ID = process.env.INFURA_ID;
    const USE_DEVNET = process.env.USE_DEVNET;

    if (USE_DEVNET == "true") {
        return new Provider({
          sequencer: {
            baseUrl: 'http://localhost:5050',
            feederGatewayUrl: 'feeder_gateway',
            gatewayUrl: 'gateway',          
          }
        })
    }
    return new Provider({
        rpc: {
          nodeUrl: "https://starknet-goerli.infura.io/v3/" + INFURA_ID,
        },
      });
} 

export function getAccountFromPk(accountAddress, privateKey, provider) {
  const starkKeyPair = ec.getKeyPair(privateKey);
  return new Account(provider, accountAddress, starkKeyPair);
}

export function askQuestion(query) {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });
  
    return new Promise((resolve) =>
      rl.question(query, (ans) => {
        rl.close();
        resolve(ans);
      })
    );
  }
  