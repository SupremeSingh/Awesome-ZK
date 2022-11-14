# Simple ERC20!

Congratulations on finishing the tutorials. Hopefully you feel somewhat comfortable with the Cairo and Starknet ecosystem by now. In this tutorial, we will go over writing cairo contracts, testing them and interacting with deployed contracts using JS. 

I have split this section into 3 segments - 

 - Contract Development  
 - JS Interactions  
 - Front-End Development

Just about everything you need to know to get rolling and create your own zkApp !!

## P0 - Setting Up 

I highly recommend using [Protostar](https://docs.swmansion.com/protostar/docs/tutorials/introduction) - essentially Cairo's version of Foundry, for your projects. I have found [Gitpods](https://www.gitpod.io/) to provide reasonable performance over here and it certainly saves you from the hassle of having to work with a Linux/Mac only. 

In case you wish to set up locally, I recommend following the [official guide](https://starknet.io/docs/quickstart.html) - along with this [cheat sheet](https://docs.google.com/document/d/1U1whWsdBk-QaBar-Va9B5Qlf5wyWk23csg2xbydHCts/edit) that I wrote for it. 

Additionally, before you start typing out your new contract - I highly recommend using this [OpenZeppelin Wizard](https://wizard.openzeppelin.com/cairo) to get a feel for how the contracts are made. And make sure to sock up on gas over [here](https://faucet.goerli.starknet.io/). 

## P1 -Tooling 

We have already established Protostar as the framework of choice for Solidity development. To interact with our contracts in a node environment, I highly suggest you use [starknet-js](https://www.starknetjs.com/). And finally, do checkout the amazing [starknet-react](https://github.com/apibara/starknet-react) toolkit for all your react-ish front end needs. 

#### Disclaimer: I have written this code to learn myself, and it is very much work in progress. If something breaks - please be kind enough to let me know or push a PR with a fix. 