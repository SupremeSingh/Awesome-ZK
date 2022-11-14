import { Text, Alert } from "@chakra-ui/react";
import { useContract, useAccount, useStarknetCall } from "@starknet-react/core";
import { Abi } from "starknet";
import { ERC20Address } from "../lib/addressRegistry";
import { stringToFelt } from "../lib/utils";

import erc20Abi from "../builds/ERC20.json";

export function CurrentBalance() {
  let { address } = useAccount();

  if (!address) {
    address = "123";
    <Alert status="error">Please Connect Wallet</Alert>;
  }


  const { contract } = useContract({
    abi: erc20Abi.abi as Abi,
    address: ERC20Address,
  });

  const { data, loading, error } = useStarknetCall({
    contract,
    method: "balance_of",
    args: [address],
  });

  console.log(data);

  let userBalance = typeof data === "undefined" || data == null ? [0] : data;

  return (
     <Text>Current Balance: {userBalance[0].toString()}</Text>
  );
}
