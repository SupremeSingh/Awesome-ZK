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

const PRANK_USER = 123

# Setup a test with an active reserve for test_token
@view
func __setup__{syscall_ptr : felt*, range_check_ptr}():
    %{
        BASE_PATH = "../cairo-pools/"
        context.pool = deploy_contract(BASE_PATH+"contracts/src/Pool.cairo", [0]).contract_address

        context.test_token = deploy_contract(BASE_PATH+"contracts/src/ERC20.cairo", [1415934836,5526356,18,1000,0,ids.PRANK_USER]).contract_address 

        context.aToken = deploy_contract(BASE_PATH+"contracts/src/AToken.cairo", [418027762548,1632916308,18,0,0,context.pool,context.pool,context.test_token]).contract_address
    %}
    tempvar pool
    tempvar test_token
    tempvar aToken
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.aToken = context.aToken %}
    _init_reserve(pool, test_token, aToken)
    return ()
end

func get_contract_addresses() -> (
    contract_address : felt, test_token_address : felt, aToken_address : felt
):
    tempvar pool
    tempvar test_token
    tempvar aToken
    %{ ids.pool = context.pool %}
    %{ ids.test_token = context.test_token %}
    %{ ids.aToken = context.aToken %}
    return (pool, test_token, aToken)
end

# Verify that reserve was initialized correctly in __setup__ hook
@external
func test_init_reserve{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    let (reserve) = IPool.get_reserve(pool, test_token)
    assert reserve.aToken_address = aToken
    return ()
end

func _init_reserve{syscall_ptr : felt*, range_check_ptr}(
    pool : felt, test_token : felt, aToken : felt
):
    IPool.init_reserve(pool, test_token, aToken)
    return ()
end

@external
func test_supply{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    _supply(pool, test_token, aToken)
    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(900, 0)

    let (user_aTokens) = IAToken.balanceOf(aToken, PRANK_USER)
    assert user_aTokens = Uint256(100, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(100, 0)
    return ()
end

func _supply{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    # Prank test_token so that inside test_token, caller() is PRANK_USER
    %{ stop_prank_token = start_prank(ids.PRANK_USER, target_contract_address=ids.test_token) %}
    IERC20.approve(test_token, pool, Uint256(100, 0))

    # Stop previous prank (because we use test_token) as parameter
    # Start prank on pool so that in pool contract, pool caller is PRANK_USER
    %{
        stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool)
        stop_prank_token()
    %}
    IPool.supply(pool, test_token, Uint256(100, 0), PRANK_USER, 0)
    %{ stop_prank_pool() %}
    return ()
end

@external
func test_withdraw_fail_amount_too_high{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    # Prank pool so that inside the contract, caller() is PRANK_USER
    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    %{ expect_revert() %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)
    %{ stop_prank_pool() %}
    return ()
end

@external
func test_withdraw{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    _supply(pool, test_token, aToken)
    # Prank pool so that inside the contract, caller() is PRANK_USER
    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    IPool.withdraw(pool, test_token, Uint256(50, 0), PRANK_USER)

    %{ stop_prank_pool() %}

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(950, 0)

    let (user_aTokens) = IAToken.balanceOf(aToken, PRANK_USER)
    assert user_aTokens = Uint256(50, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(50, 0)

    return ()
end

@external
func test_borrow{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    _supply(pool, test_token, aToken)
    _borrow(pool, test_token, aToken)

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(910, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(90, 0)

    return ()
end

func _borrow{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    # Prank test_token so that inside test_token, caller() is PRANK_USER
    %{ stop_prank_pool= start_prank(ids.PRANK_USER, target_contract_address=ids.pool) %}
    IPool.borrow(pool, test_token, Uint256(10, 0), 0, 0, PRANK_USER)
    %{ stop_prank_pool() %}
    return ()
end

@external
func test_repay{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals
    let (local pool, local test_token, local aToken) = get_contract_addresses()
    _supply(pool, test_token, aToken)
    _borrow(pool, test_token, aToken)
    _repay(pool, test_token, aToken)

    let (user_tokens) = IERC20.balanceOf(test_token, PRANK_USER)
    assert user_tokens = Uint256(900, 0)

    let (pool_collat) = IERC20.balanceOf(test_token, aToken)
    assert pool_collat = Uint256(100, 0)

    return ()
end

func _repay{syscall_ptr : felt*, range_check_ptr}(pool : felt, test_token : felt, aToken : felt):
    # Prank test_token so that inside test_token, caller() is PRANK_USER
    %{ stop_prank_token = start_prank(ids.PRANK_USER, target_contract_address=ids.test_token) %}
    IERC20.approve(test_token, pool, Uint256(10, 0))

    # Stop previous prank (because we use test_token) as parameter
    # Start prank on pool so that in pool contract, pool caller is PRANK_USER
    %{
        stop_prank_pool = start_prank(ids.PRANK_USER, target_contract_address=ids.pool)
        stop_prank_token()
    %}
    IPool.repay(pool, test_token, Uint256(10, 0), 0, PRANK_USER)

    %{ stop_prank_pool() %}

    return ()
end