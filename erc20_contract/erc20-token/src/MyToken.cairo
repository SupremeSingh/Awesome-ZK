# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import (
    uint256_add,
    uint256_sub,
    Uint256, 
)

from starkware.cairo.common.bool import TRUE

from openzeppelin.token.erc20.library import ERC20
from openzeppelin.access.ownable.library import Ownable

#
# Storage
#

@storage_var
func owner_to_balance(public_key: felt) -> (balance: Uint256):
end

#
# Events
#

@event
func tokens_minted(recipient : felt, amount: Uint256):
end

@event
func value_transferred(sender: felt, recipient : felt, amount: Uint256):
end

@event
func spender_approved(approver: felt, spender : felt, amount: Uint256):
end


@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(owner: felt, amount: Uint256):
    ERC20.initializer('MyToken', 'MTK', 18)
    Ownable.initializer(owner)
    ERC20._mint(owner, amount)
    return ()
end

#
# Getters
#

@view
func name{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (name: felt):
    let (name) = ERC20.name()
    return (name)
end

@view
func symbol{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (symbol: felt):
    let (symbol) = ERC20.symbol()
    return (symbol)
end

@view
func totalSupply{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (totalSupply: Uint256):
    let (totalSupply) = ERC20.total_supply()
    return (totalSupply)
end

@view
func decimals{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (decimals: felt):
    let (decimals) = ERC20.decimals()
    return (decimals)
end

@view
func balanceOf{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(account: felt) -> (balance: Uint256):
    let (balance) = ERC20.balance_of(account)
    return (balance)
end

@view
func allowance{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(owner: felt, spender: felt) -> (remaining: Uint256):
    let (remaining) = ERC20.allowance(owner, spender)
    return (remaining)
end

#
# Externals
#

@external
func transfer{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(recipient: felt, amount: Uint256) -> (success: felt):
    alloc_locals
    let (sender) = get_caller_address()
    value_transferred.emit(sender=sender, recipient=recipient, amount=amount)

    let (sender_balance) = owner_to_balance.read(public_key=sender)
    let (recipient_balance) = owner_to_balance.read(public_key=recipient)

    let (local add_low : Uint256, local add_high : felt) = uint256_add(recipient_balance, amount)
    let (local sub_low : Uint256) = uint256_sub(sender_balance, amount)
    
    owner_to_balance.write(public_key=sender, value=sub_low)
    owner_to_balance.write(public_key=recipient, value=add_low)
    
    ERC20.transfer(recipient, amount)
    return (TRUE)
end

@external
func transferFrom{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(sender: felt, recipient: felt, amount: Uint256) -> (success: felt):
    alloc_locals
    value_transferred.emit(sender=sender, recipient=recipient, amount=amount)
    ERC20.transfer_from(sender, recipient, amount)

    let (sender_balance) = owner_to_balance.read(public_key=sender)
    let (recipient_balance) = owner_to_balance.read(public_key=recipient)

    let (local add_low : Uint256, local add_high : felt) = uint256_add(recipient_balance, amount)
    let (local sub_low : Uint256) = uint256_sub(sender_balance, amount)
    
    owner_to_balance.write(public_key=sender, value=sub_low)
    owner_to_balance.write(public_key=recipient, value=add_low)

    return (TRUE)
end

@external
func approve{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(spender: felt, amount: Uint256) -> (success: felt):
    let (approver) = get_caller_address()
    spender_approved.emit(approver=approver, spender=spender, amount=amount)
    ERC20.approve(spender, amount)
    return (TRUE)
end

@external
func increaseAllowance{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(spender: felt, added_value: Uint256) -> (success: felt):
    ERC20.increase_allowance(spender, added_value)
    return (TRUE)
end

@external
func decreaseAllowance{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(spender: felt, subtracted_value: Uint256) -> (success: felt):
    ERC20.decrease_allowance(spender, subtracted_value)
    return (TRUE)
end

@external
func transferOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(newOwner: felt):
    Ownable.transfer_ownership(newOwner)
    return ()
end

@external
func renounceOwnership{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }():
    Ownable.renounce_ownership()
    return ()
end

@external
func mint{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(to: felt, amount: Uint256):
    alloc_locals
    Ownable.assert_only_owner()
    tokens_minted.emit(to, amount)

    let (recipient_balance) = owner_to_balance.read(public_key=to)
    let (local add_low : Uint256, local add_high : felt) = uint256_add(recipient_balance, amount)
    owner_to_balance.write(public_key=to, value=add_low)

    ERC20._mint(recipient=to, amount=amount)
    return ()
end