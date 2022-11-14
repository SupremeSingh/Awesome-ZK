%lang starknet

from starkware.cairo.common.uint256 import Uint256

from src.interfaces.IERC20 import IERC20

// ---------
// CONSTANTS
// ---------

const DECIMALS = 18;
const OWNER = 111;
const ADDRESS_TO_MINT = 222;
const NAME = 21806976760243566;
const SYMBOL = 5067851;
let INITIAL_SUPPLY = 1000; 

// ---------
// INTERFACES
// ---------

@contract_interface
namespace IEvaluator {
    func is_owner(player_address: felt) -> (status: felt) {
    }
}


// ---------
// TESTS
// ---------

@external
func __setup__() {
    %{ 
        context.erc20_original_address = deploy_contract("src/contracts/ERC20Custom.cairo", [100, 0, ids.OWNER]).contract_address
    %}
    return ();
}

@external
func test_erc20_original_deploy{syscall_ptr: felt*, range_check_ptr}() {

    tempvar erc20_original_address: felt;

    %{  
        ids.erc20_original_address = context.erc20_original_address
    %}

    let (name) = IERC20.name(contract_address=erc20_original_address);
    let (symbol) = IERC20.symbol(contract_address=erc20_original_address);
    let (decimals) = IERC20.decimals(contract_address=erc20_original_address);
    
    assert NAME = name;
    assert SYMBOL = symbol;
    assert DECIMALS = decimals;

    return ();
}

// Test minting an animal with certain characteristics and get back their characteristics
@external
func test_transfer_functionality{syscall_ptr: felt*, range_check_ptr}(){
    alloc_locals;
    tempvar erc20_original_address: felt;
    tempvar address_to_transfer: felt;

    // Mock evaluator contract to get ownership status
    tempvar external_contract_address = 123;

    %{ stop_mock = mock_call(ids.external_contract_address, "is_owner", [1]) %}
    let (is_owner) = IEvaluator.is_owner(external_contract_address, OWNER);
    %{ stop_mock() %}

    assert 1 = is_owner;

    // Get ERC721 contract address
    %{  
        ids.erc20_original_address = context.erc20_original_address
    %}

    // 
    %{ stop_prank_owner = start_prank(ids.OWNER, ids.erc20_original_address) %}
    let approval_status = IERC20.transfer(contract_address=erc20_original_address, recipient=ADDRESS_TO_MINT, amount=Uint256(50, 0));
    %{ stop_prank_owner() %}

    // Assert that the OWNER now has no token
    let sender_balance : Uint256 = IERC20.balanceOf(contract_address=erc20_original_address, account=OWNER);
    let receiver_balance : Uint256 = IERC20.balanceOf(contract_address=erc20_original_address, account=ADDRESS_TO_MINT);
    assert sender_balance = receiver_balance;

    return ();
}
