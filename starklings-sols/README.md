# Starklings!

Only Dust is a great Cairo-focused think tank and study group. I highly recommend joining there discord through [here](https://www.onlydust.xyz/).  True to their reputation, they have made an awesome Cairo-based programming tutorial called [Starklings](https://github.com/onlydustxyz/starklings).  

Starklings goes through each major concept in Cairo programming step-by-step, checks your solutions in real time and even shows you the solutions! Here, I will be discussing these solutions and what we can take away from from them. 

## P1 - Syntax

Here, we will go through 5 simple exercises to get comfortable with Cairo syntax. Note that this is Cairo in the context of writing a StarkNet contract, not just vanilla Cairo. 

The **first** one familiarizes you with the flag needed to identify a Cairo program as a smart contract. The **second** one introduces you to the concept of built-ins. In this case, 

- `syscall_ptr`: Allows the contract to make low-level system calls
- `range_check_ptr`: Allows the program to compare integer values
- `pedersen_ptr`: Let's the program calculate a 252-bit Pedersen hash 

It may not be apparent why we are calling these imports when the program isn't necessarily using them. This is because the Cairo compiler saves storage variables in slots as per an algorithm. The contract requires these implicit arguments to compute the actual memory address of this variable if you ever try to retrieve it.

The **third** one talks about variable entry, and return values. And the **fifth** one discusses structs, which we spoke about at length in the Cairo playground solutions. 

The most interesting one is the **fourth**, because it introduces the concept of **namespaces**. Let's understand how Cairo stores our variables exactly - 

Local contract storage is a persistent space where you can  read, write and modify data. Storage is a map with  2²⁵¹ slots, where each slot is a felt and is initialized to 0. All temporary variables are simply assigned to one such slot, and retrieved later by the program using the slot's number. 

For storage variables, however, one which store the state of the contract - StarkNet maps their name and values to a unique address generate by a hashing algorithm called `sn_keccak`. (Make sense why we imported that hashing built-in earlier ?)

So the thing with namespaces is they allow us to containerize code from different contracts and libraries when are we inheriting or importing them from one place to another. For instance, I could have ... 

```
./libA.cairo

namespace LIBRARY_A:
	func increase_balance{
	syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
	range_check_ptr}(amount : felt):
		let (res) = balance.read()
		balance.write(res + amount)
		return ()
	end
end
```
and another library like ...
```
./libB.cairo

namespace LIBRARY_B:
	func increase_balance{
	syscall_ptr : felt*, pedersen_ptr : HashBuiltin*,
	range_check_ptr}(amount : felt):
		let (res) = balance.read()
		balance.write(res * amount)
		return ()
	end
end
```

Now, if, for some reason, I need both Libraries A and B in a contract, and they have this one function with the same name - that's going to cause a massive memory mess in Cairo. 

However, putting variables and functions in namespaces allow us to use them despite having the same identifiers by prefixing the name of the Namespace to them ... like -

```
LIBRARY_A.increase_balance(amount)
```

Read more about this concept [here](https://medium.com/coinmonks/storage-variable-clashing-in-starknet-ce5f28e60886). 

 ## P2 - Strings

Here, we will be working with short string literals in Cairo. Strings ?? I thought we didn't have anything but felts in Cairo. You are right - we don't. But we can always have more abstract data types that ultimately compile into felts. 

Short string literals (<= 31 characters) can be written into a contract as strings, hex code or literally as felts. To convert between all these data types, look for the `strings.py` file in the `utils` folder above. Essentially, this allows you to visualize one data type as another. 

Just remember, you see the string, not Cairo or StarkNet. They only see numbers, so you can even perform arithmetic operations on strings themselves as you can tell from the solutions. 

 ## P3 - Implicit Arguments

So far, we have discussed implicit parameters such as Pedersen hash pointers, which are required by certain Cairo functions. Interestingly, functions can also accept custom implicit parameters in Cairo !

Since felts are the default data type for everything in Cairo, if your custom implicit parameter is a felt you do not need to give it a type. Doing something like this is enough - 

```
func parent_function{a, b}() -> (result : felt):
```
However, a data type is certainly in order for anything else - 
```
func test_ok{syscall_ptr : felt*}():
```

It is useful to remember that if you wish to edit the value of an implicit parameter in a function, you have to instantiate it by the same name in the function itself. For instance, to change the value of `a` above - 

```
func parent_function{a, b}() -> (result : felt):
	let a = 2 
	return()
end
```

Finally, these parameters **must** be passed down to all the functions which  use the base function in which they are defined. 

 ## P4 - Storage

We have already chatted a bit about Storage in Cairo. First things first, Cairo doesn't (necessarily) have a concept of global, storage variables . A global variable is just a function which takes no arguments and returns exactly 1 value. 

Similarly, a mapping is a value which takes 1 input and, using some process, returns a corresponding output. Because of this, mappings in Cairo can be customized way more than traditional Solidity ones. 

As we covered, a storage variable can be declared using a specific flag - 

```
@storage_var 
func bool() -> (bool:felt):
end
```
and then StarkNet will basically generate a mapping under the hood between the variable name, it's value and a hash-generated address. 

The "key" for this mapping is created using a special variation of the much known Keccak 256 hashing function, called `starknet_keccak()`. So for instance, the access key/slot in memory where you can find the value bool will be `starknet_keccak(b'bool')`.

There is additional concept of a multi-variable mapping, which can be expressed as say - 

```
@storage_var 
func example_mapping(index:felt) -> (status:felt):
end
```

In this case, the slot a specific key/value pair maps to will vary based on the key. So, values are deterministically assigned numbers as - 

```
mapping_key = starknet_keccak(b'example_mapping')
location = format(pedersen_hash(mapping_key, 100)))
```

Where 100 is just a fictitious value for `index`.

Finally, there are 2 ways to access a storage variables in Cairo (so you don't have to bother with the above in practice) - 

- `.read()`: Allows you to get the data out of that function 
- `.write()`: Allows you to modify state

Do remember that a `write` operation must be done from an `external` function in the contract, since you do not want the contract to be able to change it's own state without external interaction. 

 - let - Refers to any reference in memory, can be given a [type](https://www.cairo-lang.org/docs/how_cairo_works/consts.html#typed-references)
 - local -  Stored in the frame pointer, may have a type and not revoked throughout program (see below). 
 - tempvar - Stored in the allocation pointer, can be [revoked](https://www.cairo-lang.org/docs/how_cairo_works/consts.html#revoked-references) by certain function calls. 

 ## P5 - Revoked References

We know that there are 3 kinds of pointers to memory in an Cairo program - 

- `fp`: points to the start of the current executable function 
- `ap`: points to the first slot of free memory in the program 
- `pc`: points to the current executable instruction in the trace

Any variable which is referenced with respect to the `ap` is hence dependent on the compiler being able to remember it's relative position with respect to the pointer. 

However, since the `ap` can change if the `pc` jumps to a different function or part of the program, we may just lose the value stored in a particular slot forever. Read more [here](https://www.cairo-lang.org/docs/how_cairo_works/consts.html). 

To solve this, we have to protect variables which are prone to being called across multiple functions from revocation. One such strategy is to reference the variable with respect to the frame pointer using the `local` keyword.  

```
alloc_locals
let (local x) = foo(10)
```
we are basically calling `foo(10)`, then setting that to x and making x a local variable so it [cannot be revoked](https://stackoverflow.com/questions/71738301/what-does-it-mean-to-declare-a-local-variable-inside-a-let?rq=1) across multiple function calls. 

In this problem, we learn that it isn't just variables which need protection though. 

Implicit arguments serve a dual purpose. Not only are they implicitly passed as a reference to any function that receives them, but they're also implicitly returned with any updates to the implicit arguments that happened in the called function. So, they can be revoked during inner function calls, unless they are rebound via the implicit return from the inner function or stored using local.

  ## P6 - Recursions 

One of the most common operations in all software is iterating over a data structure to get a piece of information. Unfortunately, since computation is payed for on-chain, we try to keep such operations to a minimum. However, sometimes just an O(n) operation is inevitable.
 
 In such cases, it is important to know you cannot just run a `for` or `while` loop on your code. This is Cairo. Any iteration is done using recursion, and preferable [tail recursion](https://stackoverflow.com/questions/33923/what-is-tail-recursion) since Cairo's compiler can optimize for that. 

The first one is self-explanatory, but we run into an interesting issue in the second problem. Remember how we talked about Cairo memory being immutable - you cannot just modify a variable and re-store it's new value in the same slot. You have to modify the function's [signature](https://developer.mozilla.org/en-US/docs/Glossary/Signature/Function). 
  
 At this point, you must also know you can make a dynamic array in Cairo as - 

```
let (dynamic_array: felt*) = alloc()
```

Interestingly, we notice here too that though Cairo is very restricted to felts, we can always create more complex data types on top of them. Rest assured, this section is more about your programming skills than anything else. Happy hacking !!

 ## P7 - Hints

So far, if you are anything like me, you might already be chewing your nails and cursing Cairo for being so counter-intuitive. But I bet you don't think so harshly of Python. So what if I told you, you could write Cairo code in Python, even in a Cairo file !!

Granted it is a little unsafe, `hints` allow you to create a section in your Cairo program to include Python code. You can even manipulate existing variables in the file. 

Hints look like so - 

```
    %{  
        ids.quotient = x / n
        ids.remainder = x % n
    %}
```

And are a useful way to outsource computation so Starknet can focus on what it does best - fast verification. 

However, hints are not part of the final Cairo bytecode. That is, when looking at bytecode, the part you put in a hint will be 'invisible' to an auditor or user. This opens the path for a malicious program to provide wrong results.

Note: You should always verify computations done inside hints. Eg. 

```
assert x = quotient * n + remainder
```

  ## P8 - Tricks 

It is useful to remember that Cairo us a non-deterministic programming language. In algorithm design, nondeterministic algorithms are often used when the problem solved by the algorithm inherently allows multiple outcomes (or when there is a single outcome with multiple paths by which the outcome may be discovered, each equally preferable). In this case, since there may always be better ways to prove the same outcome - Cairo allows us to pick a represetation that aligns most efficiently with it's instruction set and other constraints. 

There are some useful code optimizations and tricks worth familiarizing ourselves with in the Cairo language.

**Trick 1 - Single Line Conditionals**

Cairo can be cumbersome at times, but it is here that Cairo's limitation to only using felts also becomes a blessing. Since everything is a number, we can easily manipulate statements to our convenience using traditional math operations. 

Remember, `assert` statements can either save something in memory or check if it exists over there. You can run a simple `OR` gate in Cairo by saying -

```
func assert_and(x, y):
    assert 1 = x * y
    return ()
end
```

Basically, one presumes x and y already have some data (or are 0, which is still binary) - and this checks if both X and Y are true or not.

**Trick 2 - Inline Ternary Operators**

Conciseness is always a feature of good software. By making a simple helper function, we can recreate the convenience and readability of a ternary operator in Cairo too. 

Since everything is just a number over here, this is what a ternary function would look like - 

```
func if_then_else(cond : felt, val_true : felt, val_false) -> (res : felt):
    assert 0 = (cond - TRUE) * (cond - FALSE)
    let res = cond * val_true + (1 - cond) * val_false
    return (res)
end
```

**Trick 3 - Complex Conditionals Without If**

Here, we see how we can set up relatively complex conditionals using just computation and the `math_cmp` library provided by Starkware. 

Example 1 - 

Let's see if a given number is binary or not. This just means we are checking if a number we have is in the set {0, 1}.

```
func is_binary_no_if(x : felt) -> (res : felt):
    let (binary_status) = is_not_zero( (x - 0) * (x - 1))
    return (res = 1 - binary_status)
end
```

Example 2 - 

To generalize this approach, let's check if our number is in the set {1337, 69420} and then return a string based on that.
```
func is_cool(x : felt) -> (res : felt):
    let (cond) = is_not_zero((x - 1337) * (x - 69420) 
    let res = (1 - cond) * 'cool' + cond * 'meh'
    return (res)
end
```

Of course, this doesn't completely remove the need for iteration and is quite manual. Bit for short operations - there is no harm in using these tricks.

  ## P9 - Registers

Cairo memory is immutable, but Cairo does still allow users to perform functions and manipulate values. This means, there must be something "moving" or changing with each instruction in order to enable the next command to be executed. 

We already know about the 3 types of pointers to memory in Cairo - the `ap`, `fp ` and the `pc`. 	These are called "registers". They store the locations in memory, at which a certain function needs to be executed. 

For instance, the `fp` points to the frame of the current function in memory. The addresses of all the function’s arguments and local variables are relative to the value of this register. When a function starts, it is equal to `ap` (that is an empty place in memory where it can be successfully run).

However, `ap` changes as inner-functions are called and we make more complex operations. But unlike `ap`, the value of `fp` remains the same throughout the scope of a function. Meanwhile `pc` just records the current instruction in the execution trace that is being run. 

Remember, everything is math, so you can manipulate the address your register is pointing to using simple arithmetic operations such as - 

```
[ap] = [ap - 1] * [fp], ap++;
```
For a new function, initially, `fp` and `ap` are the exact same value. However, once we are in it, the function tends to follow this pattern - 

- The first argument given to the function is always in `[fp - 4]`
- The second argument is stored in `[fp -  3]` and son on ... 
- The last implicit argument is `[fp - 5]` and others are -6, -7 et al.
- You can call an inner function and set it's arguments with `ap`.

For instance to call function within another function, using the parent function's arguments, do something like - 

```
@external
func check_array{range_check_ptr}(array_len : felt, array : felt*) -> 
(sum : felt):
    [ap] = [ap - 5]; ap++ # The range_check_ptr
    [ap] = [fp - 4]; ap++
    [ap] = [fp - 3]; ap++
    [ap] = 0; ap++
    call rec_sum_array
    ret
end
```
There are several other assembly instructions you can refer to in Cairo, which I have included in the solutions. 

Finally, another interesting factoid is that - 

- `assert [ap] = 42` checks if `ap` stores 42 already, otherwise sets it's value to 42. 
- `assert 42 = [ap]` only checks if `ap` stores 42 already 


## P10 - Bitwise Operations 

[Bitwise operations](https://web.stanford.edu/class/archive/cs/cs107/cs107.1224/resources/bits-practice) are the cornerstone of a lot of math, particularly hard to implement with Cairo due to it's low level nature. Here we will be building a few example logical circuits which you can hopefully use in your code elsewhere. Notably, we will be depending quite a bit on the `bitwise` standard library from Cairo. 

The biggest takeaway here is how easy the library makes it for users to program logical operations in Cairo. For instance, to `OR` 2 variables, just do - 

```
let (or_val) = bitwise_xor(value, pow2n)
```

On the other hand, we can also use the `Bitwise` built-in along with the `bitwise_ptr` variable to perform these operations even more concisely -

```
assert bitwise_ptr.x = value
assert bitwise_ptr.y = pow2n

assert or_value = bitwise_ptr.x_or_y
```

We can also check a binary value against certain constraints, like not being null or being less than 251 bits as - 

```
with_attr error_message("Bad bitwise bounds"):
    assert_nn(value)
    assert_le(value, 250)
end
```
