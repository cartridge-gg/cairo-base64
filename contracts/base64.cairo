from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import unsigned_div_rem, sqrt
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

namespace Base64:
    func encode_array{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(str_len: felt, str: felt*) -> (encoded_str_len: felt, encoded_str: felt*):
        alloc_locals

        let (encoded_str: felt*) = alloc()
        let (len) = _recursive_encode_array(str_len, str, 0, encoded_str)

        return (encoded_str_len=len, encoded_str=encoded_str)
    end

    func _recursive_encode_array{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(str_len: felt, str: felt*, encoded_str_len: felt, encoded_str: felt*) -> (len: felt):
        alloc_locals
        %{ print(ids.str_len, ids.encoded_str_len) %}
        if str_len == 0:
            return (encoded_str_len)
        end

        let (encoded_substr: felt*) = alloc()
        let part = str[0]
        let (offset, padding) = offset_padding(part)
        %{ print(ids.part, ids.str_len, ids.offset, ids.padding) %}
        let (len) = _recursive_encode3(part * offset, padding, 0, encoded_substr)

        if str_len == 1:
            %{ print(ids.len) %}
            memcpy(encoded_str + encoded_str_len, encoded_substr + 28 - len, len)
            %{ print("ah", ids.len) %}
            return _recursive_encode_array(str_len - 1, str + 1, encoded_str_len + len, encoded_str)
        else:
            %{ print(ids.len) %}
            memcpy(encoded_str + encoded_str_len, encoded_substr + 28 - len, len - padding)
            %{ print("ah", ids.len) %}
            return _recursive_encode_array(str_len - 1, str + 1, encoded_str_len + len - padding, encoded_str)
        end
    end

    func encode_single{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(str: felt) -> (encoded_str_len: felt, encoded_str: felt*):
        alloc_locals

        let (encoded_str: felt*) = alloc()
        let (offset, padding) = offset_padding(str)
        let (len) = _recursive_encode3(str * offset, padding, 0, encoded_str)

        return (encoded_str_len=len, encoded_str=encoded_str + 28 - len)
    end

    func _recursive_encode3{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(value: felt, padding: felt, encoded_str_len: felt, encoded_str: felt*) -> (len: felt):
        alloc_locals

        if value == 0:
            return (encoded_str_len)
        end

        let (q00, r00) = unsigned_div_rem(value, 256)
        let (q01, r01) = unsigned_div_rem(q00, 256)
        let (q02, r02) = unsigned_div_rem(q01, 256)

        let (c0, c1, c2, c3) = encode3(r00, r01, r02, encoded_str)

        if padding == 1:
            assert encoded_str[28 - encoded_str_len - 4] = c0
            assert encoded_str[28 - encoded_str_len - 3] = c1
            assert encoded_str[28 - encoded_str_len - 2] = c2
            assert encoded_str[28 - encoded_str_len - 1] = '='
            return _recursive_encode3(q02, 0, encoded_str_len + 4, encoded_str)
        end

        if padding == 2:
            assert encoded_str[28 - encoded_str_len - 4] = c0
            assert encoded_str[28 - encoded_str_len - 3] = c1
            assert encoded_str[28 - encoded_str_len - 2] = '='
            assert encoded_str[28 - encoded_str_len - 1] = '='
            return _recursive_encode3(q02, 0, encoded_str_len + 4, encoded_str)
        end

        assert encoded_str[28 - encoded_str_len - 4] = c0
        assert encoded_str[28 - encoded_str_len - 3] = c1
        assert encoded_str[28 - encoded_str_len - 2] = c2
        assert encoded_str[28 - encoded_str_len - 1] = c3
        return _recursive_encode3(q02, 0, encoded_str_len + 4, encoded_str)
    end

    func encode3{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(a0: felt, a1: felt, a2: felt, encoded_str: felt*) -> (c0: felt, c1: felt, c2: felt, c3: felt):
        alloc_locals

        let (r10) = leftshift(a2, 16)
        let (r11) = leftshift(a1, 8)
        let (n0) = bitwise_or(r10, r11)
        let (n) = bitwise_or(n0, a0)

        let (c00) = rightshift(n, 18)
        let (c01) = bitwise_and(c00, 63)

        let (c10) = rightshift(n, 12)
        let (c11) = bitwise_and(c10, 63)

        let (c20) = rightshift(n, 6)
        let (c21) = bitwise_and(c20, 63)

        let (c30) = bitwise_and(n, 63)

        let (c0) = lookup(c01)
        let (c1) = lookup(c11)
        let (c2) = lookup(c21)
        let (c3) = lookup(c30)

        return (c0=c0, c1=c1, c2=c2, c3=c3)
    end

    func lookup{range_check_ptr}(index: felt) -> (value: felt):
        let (is_index_le_63) = is_le(index, 63)

        assert is_index_le_63 = 1

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
        dw '+'
        dw '/'
    end

    func offset_padding{range_check_ptr}(n: felt) -> (offset: felt, padding: felt):
        let (le0) = is_le(n, 255)
        if le0 == 1:
            return (65536, 2)
        end

        let (le1) = is_le(n, 65536)
        if le1 == 1:
            return (256, 1)
        end

        let (le2) = is_le(n, 16777216)
        if le2 == 1:
            return (1, 0)
        end

        let (truncated) = rightshift(n, 24)
        return offset_padding(truncated)
    end

    func rightshift{range_check_ptr}(word : felt, n : felt) -> (word : felt):
        # Shift bits to the right and lose values
        #
        # Parameters:
        #    word: A 32-bits word
        #    n: The amount of bits to shift
        #
        # Returns:
        #    word: The word with the last n bits shifted.
        let (divisor) = pow2(n)
        let (p, _) = unsigned_div_rem(word, divisor)
        return (p)
    end

    func leftshift{range_check_ptr}(word: felt, n: felt) -> (word: felt):
        # Shift bits to the left and lose values
        #
        # Parameters:
        #    word: A 32-bits word
        #    n: The amount of bits to shift
        #
        # Returns:
        #    word: The word with the first n bits shifted.
        alloc_locals
        let (divisor) = pow2(32 - n)
        let (_, r) = unsigned_div_rem(word, divisor)
        let (multiplicator) = pow2(n)
        return (multiplicator * r)
    end

    func pow2{range_check_ptr}(i) -> (res):
        # optimized pow2 stolen from warp source code
        let (data_address) = get_label_location(data)
        return ([data_address + i])

        data:
        dw 0x1
        dw 0x2
        dw 0x4
        dw 0x8
        dw 0x10
        dw 0x20
        dw 0x40
        dw 0x80
        dw 0x100
        dw 0x200
        dw 0x400
        dw 0x800
        dw 0x1000
        dw 0x2000
        dw 0x4000
        dw 0x8000
        dw 0x10000
        dw 0x20000
        dw 0x40000
        dw 0x80000
        dw 0x100000
        dw 0x200000
        dw 0x400000
        dw 0x800000
        dw 0x1000000
        dw 0x2000000
        dw 0x4000000
        dw 0x8000000
        dw 0x10000000
        dw 0x20000000
        dw 0x40000000
        dw 0x80000000
        dw 0x100000000
        dw 0x200000000
        dw 0x400000000
        dw 0x800000000
        dw 0x1000000000
        dw 0x2000000000
        dw 0x4000000000
        dw 0x8000000000
        dw 0x10000000000
        dw 0x20000000000
        dw 0x40000000000
        dw 0x80000000000
        dw 0x100000000000
        dw 0x200000000000
        dw 0x400000000000
        dw 0x800000000000
        dw 0x1000000000000
        dw 0x2000000000000
        dw 0x4000000000000
        dw 0x8000000000000
        dw 0x10000000000000
        dw 0x20000000000000
        dw 0x40000000000000
        dw 0x80000000000000
        dw 0x100000000000000
        dw 0x200000000000000
        dw 0x400000000000000
        dw 0x800000000000000
        dw 0x1000000000000000
        dw 0x2000000000000000
        dw 0x4000000000000000
        dw 0x8000000000000000
        dw 0x10000000000000000
        dw 0x20000000000000000
        dw 0x40000000000000000
        dw 0x80000000000000000
        dw 0x100000000000000000
        dw 0x200000000000000000
        dw 0x400000000000000000
        dw 0x800000000000000000
        dw 0x1000000000000000000
        dw 0x2000000000000000000
        dw 0x4000000000000000000
        dw 0x8000000000000000000
        dw 0x10000000000000000000
        dw 0x20000000000000000000
        dw 0x40000000000000000000
        dw 0x80000000000000000000
        dw 0x100000000000000000000
        dw 0x200000000000000000000
        dw 0x400000000000000000000
        dw 0x800000000000000000000
        dw 0x1000000000000000000000
        dw 0x2000000000000000000000
        dw 0x4000000000000000000000
        dw 0x8000000000000000000000
        dw 0x10000000000000000000000
        dw 0x20000000000000000000000
        dw 0x40000000000000000000000
        dw 0x80000000000000000000000
        dw 0x100000000000000000000000
        dw 0x200000000000000000000000
        dw 0x400000000000000000000000
        dw 0x800000000000000000000000
        dw 0x1000000000000000000000000
        dw 0x2000000000000000000000000
        dw 0x4000000000000000000000000
        dw 0x8000000000000000000000000
        dw 0x10000000000000000000000000
        dw 0x20000000000000000000000000
        dw 0x40000000000000000000000000
        dw 0x80000000000000000000000000
        dw 0x100000000000000000000000000
        dw 0x200000000000000000000000000
        dw 0x400000000000000000000000000
        dw 0x800000000000000000000000000
        dw 0x1000000000000000000000000000
        dw 0x2000000000000000000000000000
        dw 0x4000000000000000000000000000
        dw 0x8000000000000000000000000000
        dw 0x10000000000000000000000000000
        dw 0x20000000000000000000000000000
        dw 0x40000000000000000000000000000
        dw 0x80000000000000000000000000000
        dw 0x100000000000000000000000000000
        dw 0x200000000000000000000000000000
        dw 0x400000000000000000000000000000
        dw 0x800000000000000000000000000000
        dw 0x1000000000000000000000000000000
        dw 0x2000000000000000000000000000000
        dw 0x4000000000000000000000000000000
        dw 0x8000000000000000000000000000000
        dw 0x10000000000000000000000000000000
        dw 0x20000000000000000000000000000000
        dw 0x40000000000000000000000000000000
        dw 0x80000000000000000000000000000000
        dw 0x100000000000000000000000000000000
        dw 0x200000000000000000000000000000000
        dw 0x400000000000000000000000000000000
        dw 0x800000000000000000000000000000000
        dw 0x1000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000000000000000000
        dw 0x800000000000000000000000000000000000000000000000000000000000
        dw 0x1000000000000000000000000000000000000000000000000000000000000
        dw 0x2000000000000000000000000000000000000000000000000000000000000
        dw 0x4000000000000000000000000000000000000000000000000000000000000
        dw 0x8000000000000000000000000000000000000000000000000000000000000
        dw 0x10000000000000000000000000000000000000000000000000000000000000
        dw 0x20000000000000000000000000000000000000000000000000000000000000
        dw 0x40000000000000000000000000000000000000000000000000000000000000
        dw 0x80000000000000000000000000000000000000000000000000000000000000
        dw 0x100000000000000000000000000000000000000000000000000000000000000
        dw 0x200000000000000000000000000000000000000000000000000000000000000
        dw 0x400000000000000000000000000000000000000000000000000000000000000
    end
end