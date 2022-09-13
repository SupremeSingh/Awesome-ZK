%lang starknet

@external
func ret_42() -> (r : felt):
    return (r = 42)
end

@external
func ret_0_and_1() -> (zero : felt, one : felt):
    [ap] = 0; ap++
    [ap] = 1; ap++ 
    ret
end

#########
# TESTS #
#########

@external
func test_ret_42():
    let (r) = ret_42()
    assert r = 42

    return ()
end

@external
func test_0_and_1():
    let (zero, one) = ret_0_and_1()
    assert zero = 0
    assert one = 1

    return ()
end
