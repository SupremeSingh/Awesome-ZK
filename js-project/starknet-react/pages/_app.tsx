import type { AppProps } from "next/app";
import { ChakraProvider } from "@chakra-ui/react";
import { InjectedConnector, StarknetConfig } from "@starknet-react/core";

function MyApp({ Component, pageProps }: AppProps) {
  const connectors = [
    new InjectedConnector({ options: { id: "argentX" } }),
    new InjectedConnector({ options: { id: "braavos" } }),
  ];

  return (
    <ChakraProvider>
      <StarknetConfig connectors={connectors}>
        <Component {...pageProps} />
      </StarknetConfig>
    </ChakraProvider>
  );
}

export default MyApp;
