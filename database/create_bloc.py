# Code qui permet la création d'un nouveau bloc dans la base de donnée en écrivant dans un fichier

import os 
import re
from . import autoconnection

_cycle_dir = os.path.join(os.path.expanduser('~'), '.cycle')
_custom_sql_dir = os.path.join(_cycle_dir, 'sql')

if not os.path.exists(_custom_sql_dir):
    os.makedirs(_custom_sql_dir) 

def write_sql_bloc(project_name, name, shape, entrees, sorties, default_values = {}, possible_values = {}, abbreviation = '', formula = [], formula_description = {}, path = os.path.join(_custom_sql_dir, 'custom_bloc.sql'), mode = 'a'):
    """
    Crée un nouveau bloc dans la base de donnée en écrivant de base dans un fichier sql local,
    sûrement que plus tard on pourra le faire sur une base de donnée en ligne 

    Args:
        bloc (str): Nom du bloc
        columns (list): Liste des colonnes du bloc
        default_values (list): Liste des valeurs par défaut des colonnes
        path (str): Chemin du fichier où écrire le bloc
    """
    # print("possible_values", possible_values)
    if project_name : 
        path = os.path.join(_cycle_dir, project_name, 'custom_blocs.sql')
    
    type_table = {'real' : 'real', 'integer' : 'integer', 'string' : 'varchar', 'list' : 'varchar[]'}
    
    rows = dict(entrees, **sorties)
    
    table_types = ''
    new_type = ''
    table_types_view = ''
    view_join = "additional_join => 'left"
    view_col = "additional_columns => '{"
    columns = ''
    for key, value in rows.items(): 
        # print("value", value)
        if value == "list" :
        # Dans le cas où on une liste de valeur, nous allons créer un nouveau tableau pour stocker les valeurs possibles
        # Donc on doit en plus ajouter une colonne qui y fait référence dans le bloc
        # Ainsi que les colonnes additionnelles et les jointures dans le bloc.
            table_types += f"create table ___.{key}_type_table(val ___.{key}_type primary key, FE real, description text);\n"
            new_type += f"create type ___.{key}_type as enum ("
            for k in possible_values[key] : 
                new_type += f"'{k}', "
                table_types += f"insert into ___.{key}_type_table(val) values ('{k}') ;\n"
            new_type = new_type[:-2] + ");\n"
            table_types_view += f"select template.basic_view('{key}_type_table') ;\n"
            
            view_col += f"{key}_type_table.FE as {key}_FE, {key}_type_table.description as {key}_description, "
            # à la fin on enlèvera la dernière virgule et on mettre une acolade fermante
            view_join += f" join ___.{key}_type_table on {key}_type_table.val = c.{key} "
            
            line = f"{key} ___.{key}_type not null default '{possible_values[key][0]}' references ___.{key}_type_table(val)"
        elif value not in type_table :
            line = f"{key} ___.{key}_type references ___.{key}_type_table(val)"
            view_col += f"{key}_type_table.FE as {key}_FE, {key}_type_table.description as {key}_description, "
            view_join += f" join ___.{key}_type_table on {key}_type_table.val = c.{key} "
        else : line = f"{key} {type_table[value]}"
        if default_values.get(key) : 
            line += f" default {default_values[key]}"
        line += ',\n'
        columns += line     
    
    if view_col[-1] == '{' : # si ça termine par {, c'est qu'on a pas de colonne additionnelle
        view_col = ''
    else :
        view_col = view_col[:-2] + "}'"
    if view_join[-5:] == "'left" : # Si ça termine par 'left, c'est qu'on a pas de jointure
        view_join = ''
    else : 
        view_join += "'"
    
    to_insert_entrees = "array"  + str([key for key in entrees]) + "::varchar[]"
    to_insert_sorties = "array"  + str([key for key in sorties]) + "::varchar[]"
    
    to_insert_formulas = ""
    for f in formula_description :
        to_insert_formulas += f"select api.add_new_formula('{formula_description[f][0]}'::varchar, '{f}'::varchar, {formula_description[f][2]}, '{formula_description[f][1]}'::text) ;\n"
    
    # print("bonjour", table_types)
    
    query = f"""

alter type ___.bloc_type add value '{name}' ;
commit ; 
insert into ___.input_output values ('{name}', {to_insert_entrees}, {to_insert_sorties}, array{[formula_description[f][0] for f in formula_description]}::varchar[]) ;

create sequence ___.{name}_bloc_name_seq ;     

{new_type}
{table_types}
{table_types_view}
create table ___.{name}_bloc(
id integer primary key,
shape ___.geo_type not null default '{default_values['shape']}',
geom geometry('{default_values['shape'].upper()}', 2154) not null check(ST_IsValid(geom)),
name varchar not null default ___.unique_name('{name}_bloc', abbreviation=>'{name + "_bloc" if not abbreviation else abbreviation}'),
formula varchar[] default array{formula}::varchar[],
formula_name varchar[] default array{[formula_description[f][0] for f in formula_description]}::varchar[],
{columns}
foreign key (id, name, shape) references ___.bloc(id, name, shape) on update cascade on delete cascade, 
unique (name, id)
);

create table ___.{name}_bloc_config(
    like ___.{name}_bloc,
    config varchar default 'default' references ___.configuration(name) on update cascade on delete cascade,
    foreign key (id, name) references ___.{name}_bloc(id, name) on delete cascade on update cascade,
    primary key (id, config)
) ; 

select api.add_new_bloc('{name}', 'bloc', '{shape}' 
    {','+view_col if view_col else ''}
    {','+view_join if view_join else ''}) ;

{to_insert_formulas}
"""
    # print(query)
    with open(path, mode) as f :
        f.write(query)
        f.write('\n\n')
    
    return query
    
def load_custom(project_name, query = '', path = os.path.join(_custom_sql_dir, 'custom_bloc.sql')):
    """
    Charge les blocs personnalisés dans la base de donnée

    Args:
        project_name (str): Nom du projet
        path (str): Chemin du fichier où se trouve les blocs personnalisés
    """
    path = os.path.join(_cycle_dir, project_name, 'custom_blocs.sql')
    
    if not query :
        with autoconnection(project_name) as con, con.cursor() as cur:
            with open(path, 'r') as f:
                cur.execute(f.read())
    else : 
        with autoconnection(project_name) as con, con.cursor() as cur:
            cur.execute(query)


def from_custom_to_main(project_name):
    """
    Transfert les blocs personnalisés dans la base de donnée principale
    """
    special_blocs =  set(['piptest', 'test'])
    with open(os.path.join(os.path.dirname(__file__), 'sql', 'special_blocs.sql')) as f:
        lines = f.readlines()
    for line in lines : 
        if line.startswith('alter type ___.bloc_type') :
            # alter type ___.bloc_type add value 'source' ; 
            b_name = re.search(r"'(.*?)'", line).group(1)
            special_blocs.add(b_name)
    
    custom_sql = os.path.join(_cycle_dir, project_name, 'custom_blocs.sql')
    if not os.path.exists(custom_sql):
        return
    with open(custom_sql) as f:
        file_text = f.readlines()
    table_bloc = {}
    table_type = {}
    with autoconnection(project_name) as con, con.cursor() as cur:
        cur.execute("select table_name, column_name, data_type, column_default from information_schema.columns where table_schema = 'api'")
        col_info = cur.fetchall()
        cur.execute("select * from api.input_output")
        input_output = cur.fetchall()
        input_output = {io[0]: io[1:] for io in input_output}
        cur.execute("select name, formula, detail_level, comment from api.formulas")
        formulas = cur.fetchall()
        formulas = {f[0] : [f[0], f[1], f[3], f[2]] for f in formulas}
        for col in col_info:
            table_name = col[0]
            if table_name not in table_type and table_name.endswith('_type_table'):
                cur.execute(f"select * from api.{table_name}")
                table_type[table_name] = cur.fetchall()
    # Y'a un truc qui se passe pas bien avec les formules faut regarder 
    for col in col_info:
        table_name = col[0]
        if table_name not in table_bloc and table_name.endswith('_bloc') and table_name[:-5] not in special_blocs:
            name = table_name[:-5]
            # print(table_name)
            shape = 'Polygon'
            entree = {}
            sorties = {}
            default_values = {}
            possible_values = {}
            abbreviation = table_name 
            formula = []
            formula_description = {}
            table_bloc[table_name] = [name, shape, entree, sorties, default_values, possible_values, abbreviation, formula, formula_description]
            # print(input_output[name])
        if table_name in table_bloc:
            table_name, column_name, data_type, column_default = col
            # print(table_name, column_name, column_default)
            if column_name == 'shape' : 
                shape_default = column_default.split('::')[0].replace("'", '')
                table_bloc[table_name][1] = shape_default
                table_bloc[table_name][4]['shape'] = shape_default
            if data_type=='USER-DEFINED' and column_name+'_type_table' in table_type:
                data_type = 'list'
                type_val = table_type[column_name + '_type_table']
                table_bloc[table_name][5][column_name] = [val[0] for val in type_val]
                column_default = ''
            if column_name in input_output[table_bloc[table_name][0]][0] :
                table_bloc[table_name][2][column_name] = data_type
                if column_default : 
                    table_bloc[table_name][4][column_name] = column_default
            if column_name in input_output[table_bloc[table_name][0]][1] :
                table_bloc[table_name][3][column_name] = data_type
                if column_default : 
                    table_bloc[table_name][4][column_name] = column_default
            
            if input_output[table_bloc[table_name][0]][2] and not table_bloc[table_name][7] :
                for f in input_output[table_bloc[table_name][0]][2] : 
                    try : 
                        table_bloc[table_name][7].append(formulas[f][1])
                        table_bloc[table_name][8][formulas[f][1]] = [formulas[f][0], formulas[f][2], formulas[f][3]]
                    except KeyError :
                        pass
                
    new_sql = os.path.join(os.path.dirname(__file__), 'sql', 'blocs.sql')
    old_sql = os.path.join(os.path.dirname(__file__), 'sql', 'blocs_old.sql')
    if os.path.exists(old_sql):
        os.remove(old_sql)
    os.rename(new_sql, old_sql)
    with open(new_sql, 'w') as f:
        f.write('')
    for bloc in table_bloc:
        print(bloc)
        write_sql_bloc(None, *table_bloc[bloc], path = new_sql)
    with open(new_sql, 'a') as f:
        for table_name in table_type : 
            for val in table_type[table_name] : 
                f.write(f"update api.{table_name} set fe = {val[1]}, description = '{val[2]}' where val = '{val[0]}' ;\n")
                
    return
            
if __name__ == '__main__':

    entrees = {"DBO5" : float, "Q" : float, "EH" : int}
    defaults={"DBO5" : "null", "Q" : "null", "EH" : "null", "shape" : "Polygon"}
    formula = ['Q = 2*EH']
    write_sql_bloc('test', 'Polygon', entrees, defaults, formula = formula, path = os.path.join(_custom_sql_dir, 'test.sql'))