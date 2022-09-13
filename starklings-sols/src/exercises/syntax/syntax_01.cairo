# All Starknet files must start with a specific line indicating the file is a smart contract,
# not just a regular Cairo file

%lang starknet

# You can ignore what follows for now
@external
func test_ok():
    return ()
end
