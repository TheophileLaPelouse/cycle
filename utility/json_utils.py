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
    layertree = open_json('..\layertree.json')
    blocs, paths = get_all_properties("bloc", layertree)