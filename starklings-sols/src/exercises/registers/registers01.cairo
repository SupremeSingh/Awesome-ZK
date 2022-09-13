%lang starknet

@external
func assert_is_42(n : felt):
    assert n = 42
    return (n)
end

@external
func sum(a : felt, b : felt) -> (s : felt):
    [ap] = [ap - 3] + [ap - 4]; ap++
    ret
end

#########
# TESTS #
#########

@external
func test_assert_is_42_ok():
    assert_is_42(42)
    return ()
end

@external
func test_assert_is_42_ko():
    %{ expect_revert() %}
    assert_is_42(21)
    return ()
end

@external
func test_sum():
    let (s) = sum(2, 3)
    assert s = 5
    return ()
end
