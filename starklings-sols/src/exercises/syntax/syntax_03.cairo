%lang starknet

# Functions can take arguments and return results


func takes_two_arguments_and_returns_one(a: felt, b: felt) -> (sum: felt):
    return (a + b)  # Do not change
end

# You could be tempted to change the test to make it pass, but don't?
@external
func test_sum{syscall_ptr : felt*}():
    let (sum) = takes_two_arguments_and_returns_one(1, 2)
    assert sum = 3
    return ()
end
