import { Button, HStack, Text } from "@chakra-ui/react";
import { useAccount, useConnectors } from "@starknet-react/core";


function Connected() {
  const { address } = useAccount();
  return <Text>Wallet - {address}</Text>;
}

function Connect() {
  const { connectors, connect } = useConnectors();
  return (
    <HStack>
      {connectors.map((connector) => (
        <Button key={connector.id()} onClick={() => connect(connector)}>
          Connect {connector.id()}
        </Button>
      ))}
    </HStack>
  );
}

export function ConnectWallet() {
  const { address } = useAccount();

  return address ? <Connected /> : <Connect />;
}
