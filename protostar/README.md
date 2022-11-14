## P0 - Writing The Contract

Cairo programs are by default stateless, if we want to write contracts to run on Starknet we need additional context. This is provided by means of special "directives" using the StarknetOS. An example is, instead of saying `pragma`, our contracts here start by 
```
# SPDX-License-Identifier: MIT
%lang starknet
```
Moreover, to add storage and other functionality, we are obliged to use flags with our functions. Common examples include the `@storage` or `@event` flag and so on. 

**Constructors**

Constructors work much like Solidity here. Much like Solidity, they also cannot access the contract's state upon deployment. Moreover, because Cairo uses account abstraction, we cannot pass any account specific state in them either. 

So, for instance, if you want to use the equivalent of `msg.sender`- you'd have to add an additional address in the arguments and pass it upon deployment. Eg. - 
```
@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(owner: felt):
    ERC20.initializer('MyToken', 'MTK', 18)
    Ownable.initializer(owner)
    ERC20._mint(owner, Uint256(1000000000000000000000, 0))
    return ()
end
```

**State**

Interestingly, cairo smart contracts don't use different mechanisms to store variables, mappings, accounts and functions. They are ALL defined as functions. For instance, you would declare a variable as - 

```
@storage_var
func userBalance() -> (res : felt):
end
```
Once set, you have to use `userBalance.read()` to get the value and `.write()` to be able to modify it.  At this point, I will note that there isn't yet a style guide for Cairo. I personally just make my code look like OpenZeppelin's.

**Complex Data Structures**

Thanks to the commons library Uint256 data type, we are practically no longer limited to only felts in the language. However, there is still a gross shortage of data types to work with. For example - 

```
@view
func balanceOf{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance) = ERC20.balance_of(account)
    return (balance)
end
```

You can define Structs, and a very corrupted type of Enum in Cairo as well. Read about that [here](https://hackmd.io/@RoboTeddy/BJZFu56wF#StarkNetCairo-design-patterns-and-language-tricks). 

**Events**

Unlike a standalone cairo program, we don't have a main function, instead we can interact with any of the functions in the contract depending on their visibility. The flags we have for these are - 

```
@event func message_received(a : felt, b: felt):
end
```

and they can be used in function as 

```
message_received.emit(1, 2)
```

**Visibility**

Unlike a standalone cairo program, we don't have a main function, instead we can interact with any of the functions in the contract depending on their visibility. The flags we have for these are - 

```
@internal - default, no need to specify
@external 
@view
```
These words pretty much mean the same thing they do in a Solidity context, except (and this is funny to me) - the view flag basically doesn't work or do anything as of writing so it's basically the same thing as `@external`.

This works like - 

```
@view
func symbol{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end
```
**Dependencies**

You can install dependencies from other contracts in Cairo, like Solidity. It may take some pandering to whichever dev environment you are using.  However it doesn't really support overrides and many other forms of extensibility yet - so you might want to be cognizant of that. 

**Common Libraries**

You tend to use these libraries quite a bit in Cairo - 

 - [OpenZeppelin](https://github.com/OpenZeppelin/cairo-contracts)  
 - [Commons](https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/cairo/common)  

In `commons`, expect to use **Math**, **Uint256**, **Signature** and many more things just to be able to do the most basic things you can do without any import in Solidity. For instance, you have to make a library call to get 	`msg.sender` in Cairo. 	

**Closing Remarks**

Finally, I recommend you take a look at [this](https://hackmd.io/@RoboTeddy/BJZFu56wF) incredibly insightful article to get a sense of tips and tricks to get a sense of why we just did what we did and how we might have done it better. 

## P1 - Testing Contract Functionality

There are two major ways to test Cairo smart contracts - you can test them in Cairo itself, or in Python. I prefer the Cairo approach since it means I do not have to deploy contracts everytime I test them OR have to worry about using a new language here.

In this case, we can also benefit massively from the cheatcodes made available to us by Protostar. These are ways to make mock functionality for a smart contract without having to go through the bottlenecks of the real system. Please read more [here](https://docs.swmansion.com/protostar/docs/tutorials/testing/cheatcodes). 

To learn best practices for testing, I highly recommend you take a look at [this](https://github.com/msaug/starknet-cairo-repo/tree/master/testing-protostar) sample code, and also read [this tutorial](https://github.com/onlydustxyz/protostar-vs-nile/tree/master/docs/4_unit-testing).  
