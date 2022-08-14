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
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE

const SAMPLE_USER = 0x01167aeDFe6B998852601c657181e16166762E9622E28373CDEbae80c8749190

# Setup a test with an active reserve for test_token
@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        BASE_PATH = "../erc20_contract/erc20-token/"
        context.test_token = deploy_contract(BASE_PATH+"src/MyToken.cairo", [ids.SAMPLE_USER]).contract_address 
    %}

    return ()
end

# Helper Method 1
func get_contract_addresses() -> (
   test_token_address : felt
):
    tempvar test_token
    %{ ids.test_token = context.test_token %}
    return (test_token)
end

# Test 1 - Verify that reserve was initialized correctly in __setup__ hook
@external
func test_init_reserve{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local expected) = Uint256(1000000000000000000000, 0)
    let (local received) = IERC20.balanceOf(SAMPLE_USER)
    assert received = expected
    return ()
end

