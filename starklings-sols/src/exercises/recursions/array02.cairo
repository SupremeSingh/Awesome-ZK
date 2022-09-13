%lang starknet

from starkware.cairo.common.alloc import alloc

func square(array : felt*, array_len : felt, output_array : felt*):
    if array_len == 0:
        return ()
    end

    let squared_item = array[0] * array[0]
    assert [output_array] = squared_item

    return square(array + 1, array_len - 1, output_array + 1)
end

# You can update the test if the function signature changes.
@external
func test_square{syscall_ptr : felt*}():
    alloc_locals
    let (local array : felt*) = alloc()

    assert [array] = 1
    assert [array + 1] = 2
    assert [array + 2] = 3
    assert [array + 3] = 4

    let (dynamic_array: felt*) = alloc()

    square(array, 4, dynamic_array)

    assert [dynamic_array] = 1
    assert [dynamic_array + 1] = 4
    assert [dynamic_array + 2] = 9
    assert [dynamic_array + 3] = 16

    return ()
end
