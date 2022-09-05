# Cairo Playground!

This is a series of solutions for the recent [Cairo Playground](https://www.cairo-lang.org/playground/) series by the StarkWare Foundation. Cairo Playground is a way for developers to try their hand on some introductory exercises and gain familiarity with the system. Here, we cover the solutions for all the problems, as of the time of writing, along with helpful resources and concepts. 

## P1 - Hello Playground

Here, we are not expected to make any modifications to the code but just run the various commands in the playground UI to better visualize the system.  It is important to know that - 

`Builtins` are predefined optimized low-level execution units which are added to the Cairo CPU board to perform predefined computations which are expensive to perform in vanilla Cairo (e.g., range-checks, Pedersen hash, ECDSA, …). Read more [here](https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#:~:text=Builtins%20are%20predefined%20optimized%20low,hash,%20ECDSA,%20%E2%80%A6%29.). 

In this code, we are using 
```
%builtins output
```
to specify that the program will be spitting out certain values on our console. Note that the second time, output appears in `{}` in the main function definition. This is called an implicit argument, which is basically a system-level pointer to some functionality in the memory. 

Moreover, `main()` is essentially the compiler's entry point into any Cairo file - much like Javascript or C. Every Cairo file must have this function if it is to be utilized as a standalone unit by another piece of software. 

Another thing - we are using the `serialize` command to print these outputs out in a user friendly way. `serialize()` here is just about the same thing as `console.log()`.

Further, notice the word `felt` - which refers to **field type** - the only primitive data type in Cairo. I recommend [reading](https://www.cairo-lang.org/docs/hello_cairo/intro.html#:~:text=The%20primitive%20type%20-%20field%20element%20%28felt%29&text=In%20the%20context%20of%20Cairo,number%20with%2076%20decimal%20digits%29.) on felts. Notably, felts do act (kinda) like unsigned integers except for division - felt division is a whole different hell.

Finally, the exercise expects you to run through the various steps of the program and track the registers executing it. Yes, the Cairo virtual machine, despite mostly working on top of the EVM - implements a register-based CPU not a stack-based one. There are 3 registers you need to remember in Cairo - 

 - Allocation Pointer - Points to the where unused memory starts. 
 - Frame Pointer -  Points to current function and it's parameters.
 - Program Counter - Gives location of the current instruction.

 ## P2 - Output 

This is simply a run down of the console logging we did in the previous exercise. Go ahead and make that edit so we can print out `400` to the console as well. 

 ## P3 - Function  

Here, we will define our first helper function in Cairo. You already know we can only use `felts` or structures of `felts` as arguments. We also need implicit arguments, and have to handle the memory ourselves.  

Another thing to note is how rigid Cairo is about variable names. For instance, in the solution, replace the values of `x` and `y` in Cairo. Shouldn't make a difference in any other programing language right. 

But since Cairo's memory is non-deterministic and read-only - we need to be consistent about how we name our variables throughout the execution - if a function takes in `x` as input - you ought to pass it a variable named x and nothing else. 
 
 For more familiar, and secure math, take a look at [this](https://perama-v.github.io/cairo/cairo-common-library/) library too. 
 
  ## P4 - Variables 

There are 3 common ways to declare a variable in Cairo - 

 - let - Refers to any reference in memory, can be given a [type](https://www.cairo-lang.org/docs/how_cairo_works/consts.html#typed-references)
 - local -  Stored in the frame pointer, may have a type and not revoked throughout program (see below). 
 - tempvar - Stored in the allocation pointer, can be [revoked](https://www.cairo-lang.org/docs/how_cairo_works/consts.html#revoked-references) by certain function calls. 

  ## P5 - Revoked References

As we read, local variables are defined using the keyword `local`. Cairo places local variables relative to the frame pointer, and thus their values will not be revoked.

Any function that uses a local variable must have the `alloc_locals` statement, usually at the beginning of the function. This statement is responsible for allocating the memory cells used by the local variables within the function’s scope.

Most relevant to us though, it allows the compiler to allocate local variables for references that would have otherwise been revoked. So we simply add this statement to the beginning of our main and observe the magic. 

So, over here,
```
alloc_locals
let (local x) = foo(10)
```
we are basically calling `foo(10)`, then setting that to x and making x a local variable so it [cannot be revoked](https://stackoverflow.com/questions/71738301/what-does-it-mean-to-declare-a-local-variable-inside-a-let?rq=1) across multiple function calls. 

  ## P6 - Dynamic Allocation 

Despite all the syntactic hell we have just seen - know that we can actually define more [complicated](https://www.cairo-lang.org/docs/reference/common_library.html) data structures in Cairo. An example is a dynamic array. 

Another thing is the `assert` statement - which performs 2 functions - 

 - Stores a certain value at a place in memory, if it is already empty 
 - If not, checks if that slot holds the value you have given it

Here, we will basically allocate a new temporary array to store the computed value, then make it a local variable so it does not get revoked, and return it to the calling function with the expected identifier. 

  ## P7 - Recursion 

Given Cairo's low level nature, as well as the fact that you are still paying gas fees, albeit cheaper ones, we prefer recursion over any iteration scheme in this langauge. 

The best practice is to run [tail-recursion](https://www.geeksforgeeks.org/tail-recursion/), since the compiler can optimize for it and save you a lot of money and time. Test yourself, does the solution in the playground use tail recursion itself ? No - but why ?

  ## P8 - Field Elements 1

Remember how I had mentioned Field sets have some properties that kinda resemble integers. Here, we get to try that out first hand.

  ## P9 - Field Elements 2

And now to resolve that pesky division problem - we actually have a library in Cairo that allows us to perform division. Note that `unsigned_div_rem()` does not work for negative numbers, but you can always get the result and multiply with -1.

  ## P10 - Bitwise Operations 

[Bitwise operations](https://web.stanford.edu/class/archive/cs/cs107/cs107.1224/resources/bits-practice) are the cornerstone of a lot of math, and other logical operations that make up any piece of software. I highly recommend you read up on them here. This is particularly nice since a lot of `safe` math in Cairo uses higher and lower level bit operations. 

  ## P11 - Address Of Locals

Let us understand how addresses of local variables are stored in more detail. Remember that `&x` , where  `x`  is an expression, represents the address of the expression  `x`. Conversely,  `&[x]`  is  `x`.

When performing any operation where you need to retrieve the value of the frame pointer in the program, you need to call a certain variable tagged `__fp__`. This can be done with the library call - 

```
from starkware.cairo.common.registers import get_fp_and_pc
```
  ## P12 - Structs

Time to go back to your freshman year data structures class !! As I said, though we only have felts as our primitive data type in Cairo, we can actually implement more complicated data types on top of that. Here is an example of a linked list, with some functions that we have to implement on top of it. 

Notice the use of recursion as opposed to iterating. 

  ## P13 - Pedersen

If you are a veteran to the world of web3, chances are you have heard of the common `SHA` hashing scheme. Unfortunately, we cannot use it here since felts are 252-bit items, not 256 bits. In it's place, we must use 252- bit [Pedersen](https://docs.starkware.co/starkex-docs-v2-deprecated/crypto/pedersen-hash-function) hashes instead. Cairo provides a neat library to calculated Pedersen hashes in a recursive way, as we have implemented in the code. 

It is critical you note that when we call the function recursively, we still have to provide it with the requisite implicit parameter from the parent. 

  ## P14 - Hints 

Cairo is a non-deterministic programming language, it allows external programs to interact with the execution of a Cairo program.

Hints are snippets of python code that allow us to add more complex functionality into our Cairo programs. You can insert a hint into a Cairo script by placing it between the `%{ ... %{` parentheses. Do remember that - 

 - Hints are considered a security concern with Cairo smart contracts
 - They are transparent to verifiers, i.e, verifiers can't see the code 

Hence, if you use a hint to compute something, you must assert the computation in the function before returning the final value to assure the verifier it has been done right. 

  ## P15 - SHARP 
  
Cairo, as opposed to ZK SNARK solutions, use a decentralized prover called SHARP. SHARP collects several programs on the STARKNet L2 and creates a proof that they ran successfully. Such a batch of programs is called a "train".

Note that it may take a while until a train is created, as the service waits
to collect enough programs (after a certain amount of time passes however, the train will be dispatched, even if it's not full). This entire process can be visualized as - 

![starkware](https://news.coincu.com/wp-content/uploads/2022/08/image-298.png)

Here, the verifier is basically a Solidity smart contract registered on the Ethereum mainnet. It maintains a "registry" of all the proofs that have been created by the SHARP. These items, stored in the contract, are called facts. Clearly, there is one fact corresponding to every proof in the system. 

For each job the corresponding fact is computed as follows:
```
keccak(program_hash, keccak(program_output))
```
where:
`program_hash` is the hash of the compiled program, which you can find in the output pane (32 bytes).
`program_output` is the output of the program as a list of 32-byte elements.

I recommend being patient with this, STARK Net's Alpha test chain is definitely not the fastest workhorse out there. 

  ## Additional - 

Once you go through all this content, I highly recommend diving a tad deeper through another similar program called [Starklings](https://github.com/onlydustxyz/starklings). 

