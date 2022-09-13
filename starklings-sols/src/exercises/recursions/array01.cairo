%lang starknet

# Arrays can be passed as function arguments in the form of a pointer and a length.

from starkware.cairo.common.alloc import alloc

func contains(needle : felt, haystack : felt*, haystack_len : felt) -> (result : felt):
    if haystack_len == 0: 
        return (0)
    end
    if needle == haystack[0]: 
        return (1)
    end
    let (index) = contains(needle, hasytack + 1, haystack_len - 1)
    return (index)
end

# Do not change the test
@external
func test_contains{syscall_ptr : felt*}():
    let (haystack1 : felt*) = alloc()
    assert [haystack1] = 1
    assert [haystack1 + 1] = 2
    assert [haystack1 + 2] = 3
    assert [haystack1 + 3] = 4

    let (contains3) = contains(3, haystack1, 4)
    assert contains3 = 1

    let (haystack2 : felt*) = alloc()
    assert [haystack2] = 1
    assert [haystack2 + 1] = 2
    let (contains5) = contains(5, haystack2, 2)
    assert contains5 = 0
    return ()
end
