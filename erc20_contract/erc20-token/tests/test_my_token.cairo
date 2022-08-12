%lang starknet
from protostar.asserts import (
    assert_eq, assert_not_eq, assert_signed_lt, assert_signed_le, assert_signed_gt,
    assert_unsigned_lt, assert_unsigned_le, assert_unsigned_gt, assert_signed_ge,
    assert_unsigned_ge)
from starkware.cairo.common.uint256 import (
    uint256_add,
    uint256_sub,
    Uint256, 
)
from src.MyToken import owner_to_balance, transfer, transferFrom, approve, increaseAllowance, decreaseAllowance, transferOwnership, renounceOwnership, mint
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE

#
# Testing
#

@view
func test_mint{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    alloc_locals
    
    let (sender) = get_caller_address()
    local token_balance:Uint256 = Uint256(low=0,high=1000000)

    with_attr error_message(
            "Ownable: caller is not the owner"):
        mint(sender, token_balance)  # Added the mocked provided value

    return ()
end

