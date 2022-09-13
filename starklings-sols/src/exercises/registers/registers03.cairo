%lang starknet
from starkware.cairo.common.math_cmp import is_le

@external
func sum_array(array_len : felt, array : felt*) -> (sum : felt):
    return rec_sum_array(array_len, array, 0)
end

func rec_sum_array(array_len : felt, array : felt*, sum : felt) -> (sum : felt):
    jmp continue if [fp - 5] != 0

    stop:
    [ap] = [fp - 3]; ap++
    jmp done

    continue:
    [ap] = [[fp - 4]]; ap++
    [ap] = [fp - 5] - 1; ap++
    [ap] = [fp - 4] + 1; ap++
    [ap] = [ap - 3] + [fp - 3]; ap++
    call rec_sum_array

    done:
    ret
end

@external
func max{range_check_ptr}(a : felt, b : felt) -> (max : felt):
    [ap] = [fp - 5]; ap++
    [ap] = [fp - 4]; ap++
    [ap] = [fp - 3]; ap++
    call is_le
    [ap] = [ap - 2]; ap++

    jmp b_is_more if [ap - 2] != 0

    a_is_more: 
    [ap] = [fp - 4]; ap++
    jmp done 

    b_is_more:
    [ap] = [fp - 3]; ap++
    jmp done 

    ret
end

#########
# TESTS #
#########

from starkware.cairo.common.alloc import alloc

@external
func test_max{range_check_ptr}():
    let (m) = max(21, 42)
    assert m = 42
    let (m) = max(42, 21)
    assert m = 42
    return ()
end

@external
func test_sum():
    let (array) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 3
    assert array[3] = 4
    assert array[4] = 5
    assert array[5] = 6
    assert array[6] = 7
    assert array[7] = 8
    assert array[8] = 9
    assert array[9] = 10

    let (s) = sum_array(10, array)
    assert s = 55

    return ()
end
