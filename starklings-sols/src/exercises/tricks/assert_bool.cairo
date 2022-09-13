%lang starknet

func assert_or(x, y):
    assert 0 = (x - 1) * (y - 1)
    return ()
end

func assert_and(x, y):
    assert 1 = x * y
    return ()
end

func assert_nor(x, y):
    assert 0 = x + y
    return ()
end

func assert_xor(x, y):
    assert 1 = x + y
    return ()
end

# Do not modify the tests
@external
func test_assert_or():
    assert_or(0, 1)
    assert_or(1, 0)
    assert_or(1, 1)
    return ()
end

@external
func test_assert_or_ko():
    %{ expect_revert() %}
    assert_or(0, 0)
    return ()
end

@external
func test_assert_and():
    assert_and(1, 1)
    return ()
end

@external
func test_assert_and_ko1():
    %{ expect_revert() %}
    assert_and(0, 0)
    return ()
end

@external
func test_assert_and_ko2():
    %{ expect_revert() %}
    assert_and(0, 1)
    return ()
end

@external
func test_assert_and_ko3():
    %{ expect_revert() %}
    assert_and(1, 0)
    return ()
end

@external
func test_assert_nor():
    assert_nor(0, 0)
    return ()
end

@external
func test_assert_nor_ko1():
    %{ expect_revert() %}
    assert_nor(0, 1)
    return ()
end

@external
func test_assert_nor_ko2():
    %{ expect_revert() %}
    assert_nor(1, 0)
    return ()
end

@external
func test_assert_nor_ko3():
    %{ expect_revert() %}
    assert_nor(1, 1)
    return ()
end

@external
func test_assert_xor():
    assert_xor(0, 1)
    assert_xor(1, 0)
    return ()
end

@external
func test_assert_xor_ko():
    %{ expect_revert() %}
    assert_xor(0, 0)
    return ()
end

@external
func test_assert_xor_ko2():
    %{ expect_revert() %}
    assert_xor(1, 1)
    return ()
end
