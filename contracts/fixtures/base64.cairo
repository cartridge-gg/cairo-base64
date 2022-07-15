%lang starknet

from contracts.base64 import Base64
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func test_encode_single{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(str: felt) -> (
        encoded_str_len: felt, encoded_str: felt*):
    return Base64.encode_single(str=str)
end
