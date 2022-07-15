# cario-base64

A library for base64 encoding multi character ascii felts.

```sh
'Man' => "TWFu"
'Ma' => "TWE="
'M' => "TQ=="
'abcd' => "YWJjZA=="
'abcde' => "YWJjZGU="
'abcdef' => "YWJjZGVm"
'abcdefg' => "YWJjZGVmZw=="
'abcdefgh' => "YWJjZGVmZ2g="
'abcdefghi' => "YWJjZGVmZ2hp"
'abcdefghij' => "YWJjZGVmZ2hpag=="
'abcdefghijk' => "YWJjZGVmZ2hpams=
```

TODO: Support felt arrays.