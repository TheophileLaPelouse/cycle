# Code qui permet la création d'un nouveau bloc dans la base de donnée en écrivant dans un fichier

import os 
from . import autoconnection

_cycle_dir = os.path.join(os.path.expanduser('~'), 'cycle')
_custom_sql_dir = os.path.join(_cycle_dir, 'sql')

if not os.path.exists(_custom_sql_dir):
    os.makedirs(_custom_sql_dir) 

def create_bloc(name, shape, entrees, default_values = {}, abbreviation = '', formula = [], path = os.path.join(_custom_sql_dir, 'custom_bloc.sql')):
    """
    Crée un nouveau bloc dans la base de donnée en écrivant de base dans un fichier sql local,
    sûrement que plus tard on pourra le faire sur une base de donnée en ligne 

    Args:
        bloc (str): Nom du bloc
        columns (list): Liste des colonnes du bloc
        default_values (list): Liste des valeurs par défaut des colonnes
        path (str): Chemin du fichier où écrire le bloc
    """
    type_table = {float : 'real', int : 'integer', str : 'varchar', list : 'varchar[]'}
    
    columns = ''
    for key, value in entrees.items(): 
        line = f"{key} {type_table[value]}"
        if default_values.get(key) : 
            line += f" default {default_values[key]}"
        line += ',\n'
        columns += line     
    
    query = f"""
    create if not exists table ___.{name}_bloc(
    id serial primary key,
    shape ___.geo_type not null default '{default_values['shape']}',
    name varchar not null default ___.unique_name('{name}_bloc', abbreviation=>'{name + "_bloc" if not abbreviation else abbreviation}'),
    formula varchar[] default array{formula}::varchar[],
    {columns}
    foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
    unique (name, id)
    );
    
    select api.add_new_bloc('{name}', 'bloc', '{shape}') ;
    """
    
    print(query)
    
    
    
    with open(path, 'a') as f :
        f.write(query)
        f.write('\n\n')
    
def load_custom(project_name, path = os.path.join(_custom_sql_dir, 'custom_bloc.sql')):
    """
    Charge les blocs personnalisés dans la base de donnée

    Args:
        project_name (str): Nom du projet
        path (str): Chemin du fichier où se trouve les blocs personnalisés
    """
    with autoconnection(project_name) as cur:
        with open(path, 'r') as f:
            cur.execute(f.read())
            
            
if __name__ == '__main__':

    entrees = {"DBO5" : float, "Q" : float, "EH" : int}
    defaults={"DBO5" : "null", "Q" : "null", "EH" : "null", "shape" : "Polygon"}
    formula = ['Q = 2*EH']
    create_bloc('test', 'Polygon', entrees, defaults, formula = formula, path = os.path.join(_custom_sql_dir, 'test.sql'))