%lang starknet

from starkware.cairo.common.math_cmp import is_not_zero

func is_binary_if(x : felt) -> (res : felt):
    if x == 0:
        return (1)
    end
    if x == 1:
        return (1)
    end
    return (0)
end

func is_binary_no_if(x : felt) -> (res : felt):
    let (binary_status) = is_not_zero( (x - 0) * (x - 1))
    return (res = 1 - binary_status)
end

func is_cool(x : felt) -> (res : felt):
    let (cond) = is_not_zero((x - 1337) * (x - 69420) * (x - 42))
    let res = (1 - cond) * 'cool' + cond * 'meh'
    return (res)
end

# Do not change the test
@external
func test_is_binary{syscall_ptr : felt*}():
    let (eval_if) = is_binary_if(0)
    let (eval_no_if) = is_binary_no_if(0)
    assert (eval_if, eval_no_if) = (1, 1)

    let (eval_if) = is_binary_if(1)
    let (eval_no_if) = is_binary_no_if(1)
    assert (eval_if, eval_no_if) = (1, 1)

    let (eval_if) = is_binary_if(13)
    let (eval_no_if) = is_binary_no_if(37)
    assert (eval_if, eval_no_if) = (0, 0)
    return ()
end

@external
func test_is_cool{syscall_ptr : felt*}():
    let (is_1337_cool) = is_cool(1337)
    let (is_69420_cool) = is_cool(69420)
    let (is_42_cool) = is_cool(42)
    let (is_0_cool) = is_cool(0)
    let (is_911_cool) = is_cool(911)
    let results = ('cool', 'cool', 'cool', 'meh', 'meh')
    assert (is_1337_cool, is_69420_cool, is_42_cool, is_0_cool, is_911_cool) = results
    return ()
end
