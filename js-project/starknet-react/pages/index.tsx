import { Box, Heading, VStack } from "@chakra-ui/react";
import type { NextPage } from "next";
import Head from "next/head";
import { BlockSection } from "../components/BlockSection";
import { ConnectWallet } from "../components/ConnectWallet";
import { CurrentBalance } from "../components/CurrentBalance";
import { TransactionBuilder } from "../components/TransactionBuilder";
import { TransactionStatus } from "../components/TransactionStatus";

const Home: NextPage = () => {
  return (
    <>
      <Head>
        <title>ERC20 Interactions</title>
      </Head>
      <VStack w="full">
        <Box mx="auto">
          <Heading>My Token Demo</Heading>
        </Box>
        <ConnectWallet />
        <BlockSection />
        <CurrentBalance />
        <TransactionBuilder />
        <TransactionStatus />
      </VStack>
    </>
  );
};

export default Home;
