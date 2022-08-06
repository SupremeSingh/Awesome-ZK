# So, let's get started!
# 1. Click on the "Debug" button to run the code below.
# 2. You should see the output of the run in the "output" panel below.
# 3. After clicking "Debug", the playground enters "debug" mode,
#    where you can follow the execution of the program.
# 4. Click on the buttons with the right and left arrows located at the
#    top-right corner of the "Memory" panel to respectively advance or rewind
#    the steps of the program execution.
#    You may also press 's' to move forward and 'S' (shift+s) to move backward.
# 5. Take a look at the "Watch" panel (located at the bottom right),
#    where you can see the values of the variables in the current context.
# 6. The "Memory" panel enables you to examine the lower-level details of
#    the run.
# 7. Find the value of output_ptr in the "Watch" panel. This value is a pointer
#    to the memory. Find the memory row with that address and verify that you
#    see the 3 output values in the right column.
#
# See you in the next challenge!

# Use the output builtin.
%builtins output

# Import the serialize_word() function.
from starkware.cairo.common.serialize import serialize_word

func main{output_ptr : felt*}():
    tempvar x = 10
    tempvar y = x + x
    tempvar z = y * y + x
    serialize_word(x)
    serialize_word(y)
    serialize_word(z)
    return ()
end
