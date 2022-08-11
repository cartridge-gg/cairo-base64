from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

from src.library import encode3, _encode3_inner, calc_offset_padding

namespace Base64URL:
    func encode_single{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(str: felt) -> (encoded_str: felt):
        alloc_locals

        let (cb) = get_label_location(lookup)

        let (offset, padding) = calc_offset_padding(str)
        let (encoded_str) = _encode3_inner(str * offset, padding, 0, 0, cb)

        return (encoded_str=encoded_str)
    end

    func encode3{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(value: felt) -> (c0: felt, c1: felt, c2: felt, c3: felt, r: felt):
        alloc_locals
        let (cb) = get_label_location(lookup)
        return encode3(value, cb)
    end

    func lookup{range_check_ptr}(index: felt) -> (value: felt):
        let (table) = get_label_location(BASE64)
        return ([table + index])

        BASE64:
        dw 'A'
        dw 'B'
        dw 'C'
        dw 'D'
        dw 'E'
        dw 'F'
        dw 'G'
        dw 'H'
        dw 'I'
        dw 'J'
        dw 'K'
        dw 'L'
        dw 'M'
        dw 'N'
        dw 'O'
        dw 'P'
        dw 'Q'
        dw 'R'
        dw 'S'
        dw 'T'
        dw 'U'
        dw 'V'
        dw 'W'
        dw 'X'
        dw 'Y'
        dw 'Z'
        dw 'a'
        dw 'b'
        dw 'c'
        dw 'd'
        dw 'e'
        dw 'f'
        dw 'g'
        dw 'h'
        dw 'i'
        dw 'j'
        dw 'k'
        dw 'l'
        dw 'm'
        dw 'n'
        dw 'o'
        dw 'p'
        dw 'q'
        dw 'r'
        dw 's'
        dw 't'
        dw 'u'
        dw 'v'
        dw 'w'
        dw 'x'
        dw 'y'
        dw 'z'
        dw '0'
        dw '1'
        dw '2'
        dw '3'
        dw '4'
        dw '5'
        dw '6'
        dw '7'
        dw '8'
        dw '9'
        dw '-'
        dw '_'
    end
end