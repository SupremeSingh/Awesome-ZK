%lang starknet

func modulo(x : felt, n : felt) -> (mod : felt):
    alloc_locals
    local quotient
     local remainder
     %{
         q, r = divmod(ids.x, ids.n)
         ids.quotient = q
         ids.remainder = r
     %}
     assert x = quotient * n + remainder
     return (remainder)
 end

# Do not change the test
@external
func test_modulo{syscall_ptr : felt*}():
    const NUM_TESTS = 19

    %{ import random %}
    tempvar count = NUM_TESTS

    loop:
    %{
        x = random.randint(2, 2**99)
        n = random.randint(2, 2**50)
        if x < n:
            x,n = n,x
    %}
    tempvar x = nondet %{ x %}
    tempvar n = nondet %{ n %}
    tempvar res = nondet %{ x % n %}

    let (mod) = modulo(x, n)
    assert res = mod
    tempvar count = count - 1
    jmp loop if count != 0

    return ()
end
