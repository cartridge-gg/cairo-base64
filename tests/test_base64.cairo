
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.invoke import invoke
from starkware.cairo.common.alloc import alloc

from contracts.base64 import Base64

@view
func test_base64_single{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}():
    alloc_locals

    let (e0) = Base64.encode_single('Man')
    assert e0 = 'TWFu'

    let (e1) = Base64.encode_single('Ma')
    assert e1 = 'TWE='

    let (e2) = Base64.encode_single('M')
    assert e2 = 'TQ=='

    let (e3) = Base64.encode_single('abcd')
    assert e3 = 'YWJjZA=='

    let (e4) = Base64.encode_single('abcde')
    assert e4 = 'YWJjZGU='

    let (e5) = Base64.encode_single('abcdef')
    assert e5 = 'YWJjZGVm'

    let (e6) = Base64.encode_single('abcdefg')
    assert e6 = 'YWJjZGVmZw=='

    let (e7) = Base64.encode_single('abcdefgh')
    assert e7 = 'YWJjZGVmZ2g='

    let (e8) = Base64.encode_single('abcdefghi')
    assert e8 = 'YWJjZGVmZ2hp'

    let (e9) = Base64.encode_single('abcdefghij')
    assert e9 = 'YWJjZGVmZ2hpag=='

    let (e10) = Base64.encode_single('abcdefghijk')
    assert e10 = 'YWJjZGVmZ2hpams='

    # let (e11) = Base64.encode_single('Many hands make ')
    # assert e11 = 'TWFueSBoYW5kcyBtYWtlIA=='

    return ()
end
