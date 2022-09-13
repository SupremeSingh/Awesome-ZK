%lang starknet

from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bool import TRUE, FALSE

func if_then_else(cond : felt, val_true : felt, val_false) -> (res : felt):
    assert 0 = (cond - TRUE) * (cond - FALSE)
    let res = cond * val_true + (1 - cond) * val_false
    return (res)
end

@external
func test_ternary_conditional_operator():
    let (res) = if_then_else(FALSE, 911, 420)
    assert 420 = res
    let (res) = if_then_else(TRUE, 911, 'over 9000')
    assert 911 = res
    let (res) = if_then_else(FALSE, 69420, 1559)
    assert 1559 = res
    let (res) = if_then_else(TRUE, 'nice', 69)
    assert 'nice' = res
    %{ expect_revert() %}
    let (res) = if_then_else(69, 'nope', 911)
    return ()
end
