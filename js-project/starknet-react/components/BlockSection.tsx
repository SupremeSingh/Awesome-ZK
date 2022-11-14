import { Box } from "@chakra-ui/react";
import { useBlock } from "@starknet-react/core";
import { Loader } from "./Loader";

export function BlockSection() {
  const { data, isLoading, error } = useBlock();

  return (
    <Box mx="auto">
      <Loader isLoading={isLoading} error={error} data={data}>
        {(data) => (
          <Box>
            Current StarkNet Block: {data.block_number}
          </Box>
        )}
      </Loader>
    </Box>
  );
}
