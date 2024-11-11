import json 
import os 
from copy import deepcopy


def open_json(path) : 
    with open(path) as f : 
        return json.load(f)

def get_propertie(name, dico):
    if len(dico) == 0:
        return None

    stack = [dico]

    while stack:
        print(stack)
        current_dico = stack.pop()
        if name in current_dico:
            return current_dico[name]
        for key in current_dico:
            print('hmm')
            if isinstance(current_dico[key], dict):
                print("et bas ?")
                stack.append(current_dico[key])

    return None

def get_all_properties(name, dico):
    if len(dico) == 0:
        return []

    stack = [dico]
    stack_path = ['/']
    properties = []
    paths = []

    while stack:
        current_dico = stack.pop()
        current_path = stack_path.pop()
        
        if name in current_dico:
            paths.append(current_path)
            properties.append(current_dico[name])
        for key in current_dico:
            if isinstance(current_dico[key], dict):
                stack.append(current_dico[key])
                stack_path.append(current_path+key+'/')

    return properties, paths

def json_map(dico, func) : 
    new = {}
    for key in dico : 
        if isinstance(dico[key], dict) and key != 'bloc' and key != 'properties' : 
            new[key] = json_map(dico[key], func)
        else : 
            new[key] = func(key, dico[key])
    return new

def add_dico(dico, dico_to_add):
    if not isinstance(dico, dict):
        return dico_to_add
    if not isinstance(dico_to_add, dict):
        return dico
    dico_key = {key : '/' for key in dico}
    new = deepcopy(dico)
    def fill_dico_key(dico, path = '/') :
        for key in dico : 
            if isinstance(dico[key], dict) : 
                if key in dico_key : 
                    new_key = path.split('/')[-2] + '/' + key
                    dico_key[new_key] = path + key + '/' # Pour l'instant on va pas le faire fonctionner et on veut avoir que des clés uniques
                dico_key[key] = path + key + '/'
                fill_dico_key(dico[key], path + key + '/')
    fill_dico_key(dico)
    for key in dico_to_add : 
        if key in dico_key : 
            path = dico_key[key].split('/')[1:-1]
            if path :
                d = new[path.pop(0)]
                while path : 
                    val = path.pop(0)
                    if val : 
                        d = d[val]
                for key_to_add in dico_to_add[key] : 
                    if key_to_add not in d : 
                        d[key_to_add] = dico_to_add[key][key_to_add]
                    else :
                        d[key_to_add] = add_dico(d[key_to_add], dico_to_add[key][key_to_add])  # dégueu mais ça marche
        else : 
            new[key] = dico_to_add[key]
    return new
                
     

# def add_dico(dico1, dico2) : 
#     # Servira pour rentrer le custom json dans l'admin json
#     if not isinstance(dico2, dict) :
#         return dico1
#     if not isinstance(dico1, dict) : 
#         return dico2
#     for key in dico2 : 
#         if key not in dico1 : 
#             dico1[key] = dico2[key]
#         else : 
#             dico1[key] = add_dico(dico1[key], dico2[key])
#     return dico1

def save_to_json(dico, path) : 
    with open(path, 'w') as f : 
        json.dump(dico, f, indent=4, sort_keys=True)
        
if __name__ == '__main__' : 
    import unittest
    from json_utils import add_dico
    
    class TestAddDico(unittest.TestCase):
        def test_add_dico_non_overlapping(self):
            dico1 = {'a': 1, 'b': 2}
            dico2 = {'c': 3, 'd': 4}
            expected = {'a': 1, 'b': 2, 'c': 3, 'd': 4}
            result = add_dico(dico1, dico2)
            self.assertEqual(result, expected)
    
        def test_add_dico_overlapping(self):
            dico1 = {'a': 1, 'b': {'x': 10}}
            dico2 = {'b': {'y': 20}, 'c': 3}
            expected = {'a': 1, 'b': {'x': 10, 'y': 20}, 'c': 3}
            result = add_dico(dico1, dico2)
            self.assertEqual(result, expected)
    
        def test_add_dico_nested(self):
            dico1 = {'a': {'b': {'c': 1}}}
            dico2 = {'a': {'b': {'d': 2}}}
            expected = {'a': {'b': {'c': 1, 'd': 2}}}
            result = add_dico(dico1, dico2)
            self.assertEqual(result, expected)
    
        def test_add_dico_empty(self):
            dico1 = {}
            dico2 = {'a': 1}
            expected = {'a': 1}
            result = add_dico(dico1, dico2)
            self.assertEqual(result, expected)
    
    unittest.main()