import pytest
import pytest_asyncio
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.compiler.compile import compile_starknet_files

def str_to_felt(text):
    b_text = bytes(text, 'ASCII')
    return int.from_bytes(b_text, "big")

def felt_to_str(value):
    return chr(value)

@pytest_asyncio.fixture(scope="module")
async def starknet():
    return await Starknet.empty()

@pytest_asyncio.fixture(scope='module')
async def test_base64(starknet):
    contract_class = compile_starknet_files(
        ["contracts/fixtures/base64.cairo"], debug_info=True, disable_hint_validation=True)

    # Deploy the contract.
    base64 = await starknet.deploy(
        contract_class=contract_class,
    )

    return base64

@pytest.mark.asyncio
async def test_base64_encode(test_base64):

    svg = '<svg xmlns = "http://www.w3.org/2000/svg" width = "30" height = "30" viewBox = "0 0 30 30" stroke = "#DAE5EF" fill = "none" stroke-width = "3" stroke-linecap = "round" stroke-linejoin = "round" class = "feather feather-search" > <circle cx = "11" cy = "11" r = "8" > </circle > <line x1 = "21" y1 = "21" x2 = "16.65" y2 = "16.65" > </line> </svg>'

    cases = [
        (['Man'], "TWFu"),
        (['Ma'], "TWE="),
        (['M'], "TQ=="),
        (['abcd'], "YWJjZA=="),
        (['abcde'], "YWJjZGU="),
        (['abcdef'], "YWJjZGVm"),
        (['abcdefg'], "YWJjZGVmZw=="),
        (['abcdefgh'], "YWJjZGVmZ2g="),
        (['abcdefghi'], "YWJjZGVmZ2hp"),
        (['abcdefghij'], "YWJjZGVmZ2hpag=="),
        (['abcdefghijk'], "YWJjZGVmZ2hpams=")
        # (['Many hands make '], "TWFueSBoYW5kcyBtYWtlIA==")
    ]

    for (input, want) in cases:
        input_string_array = list(map(lambda str: str_to_felt(
            str), input))

        print("Input String: {}".format(input_string_array))

        execution_info = await test_base64.test_encode_single(input_string_array[0]).call()
        print("Execution Info:  {}".format(
            execution_info.result))

        got = "".join(map(lambda value: felt_to_str(
            value), execution_info.result.encoded_str))

        # print("Want: {}, Got: {}".format(want, got))
        if got != want:
            raise Exception("Want: {}, Got: {}".format(want, got))