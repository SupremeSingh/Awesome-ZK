%lang starknet

# As with many other languages, you can describe object structures with the struct keyword.

struct Currency:
    member name: felt
    member number: felt
end


# Do not change the test
@external
func test_currency_sum{syscall_ptr : felt*}():
    alloc_locals
    local euro : Currency = Currency('Euro', 2)
    assert euro.name = 'Euro'
    return ()
end
