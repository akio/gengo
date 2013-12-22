#!/usr/bin/env python
""""""
import genmsg.msgs


MSG_TYPE_TO_GO = {
    'byte': 'int8',
    'char': 'uint8',
    'bool': 'bool',
    'uint8': 'uint8',
    'int8': 'int8',
    'uint16': 'uint16',
    'int16': 'int16',
    'uint32': 'uint32',
    'int32': 'int32',
    'uint64': 'uint64',
    'int64': 'int64',
    'float32': 'float32',
    'float64': 'float64',
    'string': 'string',
    'time': 'ros.Time',
    'duration': 'ros.Duration'
}


def msg_type_to_go(_type):
    (base_type, is_array, array_len) = genmsg.msgs.parse_type(_type)
    if genmsg.msgs.is_builtin(base_type):
        go_type = MSG_TYPE_TO_GO[base_type]
    elif len(base_type.split('/')) == 1:
        pass
    else:
        pkg = base_type.split('/')[0]
        msg = base_type.split('/')[1]
        go_type = '{0}.{1}'.format(pkg, msg)

    if is_array:
        if array_len is None:
            return '[]{0}'.format(go_type)
        else:
            return '[{0}]{1}'.format(array_len, go_type)
    else:
        return go_type
