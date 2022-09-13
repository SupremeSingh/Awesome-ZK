%lang starknet

func crash():
    tempvar x = 42
    assert x = 42
    assert x = 21
end

func assert_42(number : felt):
    [fp - 3] = 42
    ret
end

func assert_pointer_42(p_number : felt*):
    assert [p_number] = 42
    return ()
end

func assert_pointer_42_no_set(p_number : felt*):
    assert 42 = [p_number]
    return ()
end

#########
# TESTS #
#########

from starkware.cairo.common.alloc import alloc

@external
func test_crash():
    %{ expect_revert() %}
    crash()

    return ()
end

@external
func test_assert_42():
    assert_42(42)

    %{ expect_revert() %}
    assert_42(21)

    return ()
end

@external
func test_assert_pointer_42_initialized():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert mem_zone[1] = 21

    assert_pointer_42(mem_zone)

    %{ expect_revert() %}
    assert_pointer_42(mem_zone + 1)

    return ()
end

@external
func test_assert_pointer_42_not_initialized_ok():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert_pointer_42(mem_zone)

    assert_pointer_42(mem_zone + 1)
    assert mem_zone[1] = 42

    return ()
end

@external
func test_assert_pointer_42_not_initialized_revert():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert_pointer_42(mem_zone)

    assert_pointer_42(mem_zone + 1)
    %{ expect_revert() %}
    assert mem_zone[1] = 21

    return ()
end

@external
func test_assert_pointer_42_no_set():
    let (mem_zone : felt*) = alloc()
    assert mem_zone[0] = 42
    assert mem_zone[1] = 21

    assert_pointer_42_no_set(mem_zone)

    %{ expect_revert() %}
    assert_pointer_42_no_set(mem_zone + 1)

    return ()
end

@external
func test_assert_pointer_42_no_set_crash():
    let (mem_zone : felt*) = alloc()

    %{ expect_revert() %}
    assert_pointer_42_no_set(mem_zone)

    return ()
end
