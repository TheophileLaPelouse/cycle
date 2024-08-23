# coding=utf-8

"""
string utility modules
"""

import re
import string
import unicodedata

def normalized_name(name, max_length=24, no_caps=True):
    '''removes accents, spaces and caps'''
    name = name.replace(u" ", u"_")
    if no_caps:
        name = name.lower()
    filter_ = string.ascii_letters+"_"+string.digits
    return ''.join(x for x in unicodedata.normalize('NFKD', name) \
            if x in filter_)[:max_length]

def normalized_model_name(model_name):
    '''removes accents and spaces and limit length'''
    max_length=16
    starting_digit_cleaned_name = re.sub(r'^\d+', '', model_name)
    return normalized_name(starting_digit_cleaned_name, max_length)

def list_to_sql_array(py_list):
    '''converts list to string formated as sql array'''
    return str(list(map(str, py_list))).replace('[', '{').replace(']', '}').replace('\'', '') if py_list else None

def isfloat(value):
    '''check if value can be converted to float'''
    try:
        float(value)
        return True
    except:
        return False

def isint(value):
    '''check if value can be converted to int [keeping the same value]'''
    try:
        int(value)
        assert float(value)==int(value)
        return True
    except:
        return False

def get_sql_float(value):
    '''converts to int or float if possible else None'''
    if isint(value):
        return int(value)
    elif isfloat(value):
        return float(value)
    else:
        return None

def get_nullable_sql_float(value):
    if get_sql_float(value) is None:
        return "null"
    return get_sql_float(value)

def get_str(value):
    ''' get a str from a value if possible, else return "" '''
    if value is None:
        return ""
    else:
        return str(value)

def quote(value):
    if (isinstance(value, str) and len(value)==0):
        return "null"
    elif isinstance(value, str) and value != "null" and value != "default" and value[0] != "'":
        return "'"+value+"'"
    else:
        return value

def get_body_from_sql(file, body_name):
    body_text = ''
    with open(file) as f:
        copy = False
        for line in f:
            if line.strip() == f"${body_name}$":
                copy = not copy
                continue
            elif copy:
                body_text += line
    return body_text