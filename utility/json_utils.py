import json 
import os 


def open_json(path) : 
    with open(path) as f : 
        return json.load(f)

def get_propertie(name, dico):
    if len(dico) == 0:
        return None

    stack = [dico]

    while stack:
        current_dico = stack.pop()
        if name in current_dico:
            return current_dico[name]
        for key in current_dico:
            if isinstance(current_dico[key], dict):
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

def add_dico(dico1, dico2) : 
    # Servira pour rentrer le custom json dans l'admin json
    for key in dico2 : 
        if key not in dico1 : 
            dico1[key] = dico2[key]
        else : 
            dico1[key] = add_dico(dico1[key], dico2[key])
    return dico1

def save_to_json(dico, path) : 
    with open(path, 'w') as f : 
        json.dump(dico, f)
        
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