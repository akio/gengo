#!/usr/bin/env python
""""""
import genmsg.msgs


MSG_TYPE_TO_GO_TYPE = {
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


MSG_TYPE_TO_GO_ZERO_VALUE = {
    'byte': '0',
    'char': '0',
    'bool': '0',
    'uint8': '0',
    'int8': '0',
    'uint16': '0',
    'int16': '0',
    'uint32': '0',
    'int32': '0',
    'uint64': '0',
    'int64': '0',
    'float32': '0.0',
    'float64': '0.0',
    'string': '""',
    'time': 'NewTime()',
    'duration': 'NewDuration()'
}


def msg_type_to_go(package_context, _type):
    (base_type, is_array, array_len) = genmsg.msgs.parse_type(_type)
    if genmsg.msgs.is_builtin(base_type):
        go_type = MSG_TYPE_TO_GO_TYPE[base_type]
    elif len(base_type.split('/')) == 1:
        go_type = base_type
    else:
        pkg = base_type.split('/')[0]
        msg = base_type.split('/')[1]
        if package_context == pkg:
            go_type = msg
        else:
            go_type = '{0}.{1}'.format(pkg, msg)

    if is_array:
        if array_len is None:
            return '[]{0}'.format(go_type)
        else:
            return '[{0}]{1}'.format(array_len, go_type)
    else:
        return go_type

def field_name_to_go(field_name):
    return ''.join(x.capitalize() for x in field_name.split('_'))


def msg_type_to_go_zero_value(package_context, _type):
    (base_type, is_array, array_len) = genmsg.msgs.parse_type(_type)
    if genmsg.msgs.is_builtin(_type):
        return MSG_TYPE_TO_GO_ZERO_VALUE[base_type]
    elif len(base_type.split('/')) == 1:
        return 'Msg{0}.NewMessage()'.format(base_type)
    else:
        pkg = base_type.split('/')[0]
        msg = base_type.split('/')[1]
        if package_context == pkg:
            return 'Msg{0}.NewMessage()'.format(msg)
        else:
            return '{0}.Msg{1}.NewMessage()'.format(pkg, msg)






