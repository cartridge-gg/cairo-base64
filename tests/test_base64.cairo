
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from contracts.base64 import Base64

@view
func test_base64_single{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    alloc_locals

    let (input) = alloc()
    assert input[0] = 'Man'

    let (encoded_str_len, encoded_str) = Base64.encode_single('Man')

    let a = encoded_str[0]
    assert a = 'TWFu'

    return ()
end

# @view
# func test_base64_array{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
#     alloc_locals

#     let (input) = alloc()
#     assert input[0] = 'M'
#     assert input[1] = 'a'
#     assert input[2] = 'n'

#     let (encoded_str_len, encoded_str) = Base64.encode_array(3, input)

#     let a = encoded_str[0]
#     assert a = 'TWFu'

#     return ()
# end
