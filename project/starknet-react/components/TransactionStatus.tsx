import { Box, Heading, VStack } from "@chakra-ui/react";
import {
  useTransactionManager,
  useTransactionReceipt,
} from "@starknet-react/core";
import { Loader } from "./Loader";

function Status({ hash, metadata }: { hash: string, metadata?: any }) {
  const { data, loading, error } = useTransactionReceipt({ hash });

  const name = metadata?.name ?? hash
  return (
    <Loader isLoading={loading} error={error} data={data}>
      {(data) => (
        <Box>
          {name}: {data.status}
        </Box>
      )}
    </Loader>
  );
}

export function TransactionStatus() {
  const { transactions } = useTransactionManager();
  return (
    <VStack>
      <Heading fontSize="xl">Transactions</Heading>
      {transactions.map(({hash, metadata}) => (
        <Status key={hash} hash={hash} metadata={metadata} />
      ))}
    </VStack>
  );
}
