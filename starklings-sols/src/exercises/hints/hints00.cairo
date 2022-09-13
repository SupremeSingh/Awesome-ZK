%lang starknet

func basic_hint() -> (value : felt):
    alloc_locals
    local res
    %{
        ids.res = 42
    %}
    return (res)
end

# Do not change the test
@external
func test_basic_hint{syscall_ptr : felt*}():
    let (value) = basic_hint()
    assert 41 = value - 1
    return ()
end
