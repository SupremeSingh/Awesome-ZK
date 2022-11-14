import {
  Button,
  Heading,
  HStack,
  NumberInput,
  NumberInputField,
  Text,
  VStack,
} from "@chakra-ui/react";
import {
  useStarknetExecute,
  useTransactionManager,
} from "@starknet-react/core";
import { useMemo, useReducer, useState } from "react";
import { ERC20Address } from "../lib/addressRegistry";


export function TransactionBuilder() {
  const [state, dispatch] = useReducer(reducer, { transactions: [] });
  const [amount, setAmount] = useState(0);

  const calls = useMemo(() => {
    return state.transactions.map((address, amount) => ({
      contractAddress: ERC20Address,
      entrypoint: "mint",
      calldata: [address, amount]
    }));
  }, [state.transactions]);

  const { execute, reset } = useStarknetExecute({
    calls,
  });

  const { addTransaction } = useTransactionManager();

  const handleAmountChange = (_: string, value: number) => {
    setAmount(value);
  };

  const handleSubmit = async () => {
    const response = await execute();
    addTransaction({
      hash: response.transaction_hash,
      metadata: {
        name: `Mint Tokens: ${state.transactions}`,
      },
    });
    reset();
  };

  return (
    <VStack>
      <Heading fontSize="xl">Mint New Tokens</Heading>
      <VStack>
        {state.transactions.map((amount, index) => (
          <HStack key={index}>
            <Text>Amount = {amount}</Text>
            <Button onClick={() => dispatch({ type: "remove", index })}>
              Remove
            </Button>
          </HStack>
        ))}
      </VStack>
      <HStack>
        <NumberInput value={amount} onChange={handleAmountChange}>
          <NumberInputField />
        </NumberInput>
        <Button onClick={() => dispatch({ type: "add", amount })}>
          Mint
        </Button>
      </HStack>
      <Button onClick={handleSubmit}>Submit</Button>
    </VStack>
  );
}

interface State {
  transactions: number[];
}

interface Add {
  type: "add";
  amount: number;
}

interface Remove {
  type: "remove";
  index: number;
}

type Action = Add | Remove;

export function reducer(state: State, action: Action): State {
  switch (action.type) {
    case "add": {
      return {
        transactions: [...state.transactions, action.amount],
      };
    }
    case "remove": {
      const transactions = state.transactions.filter(
        (_, index) => index !== action.index
      );
      return {
        transactions,
      };
    }
    default:
      return state;
  }
}
