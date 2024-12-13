# -*- coding: utf-8 -*-
"""
Created on Tue Nov  5 09:52:26 2024

@author: theophile.mounier
"""
#%%
import pandas as pd

# Load the Excel file
file_path = r'Z:\Commun\_Toutes-Agences\6_INGENIEURS&CITOYENS\P1_impact_projets\GES - Etudes\emission GES _ traitement.xlsx'
# file_path = '/Users/theophilemounier/Documents/stage_hydra2/emission GES _ traitement.xlsx'
xls = pd.ExcelFile(file_path)
#%%
# Load the specific sheet
df = pd.read_excel(xls, 'Recap_formule', header=None, dtype=str)
df.fillna('', inplace=True)
# Extract the relevant data (from line 28 to the end, columns H to P)
data_f_inp = df.iloc[30:, 7:17]
data_global = df.iloc[29:, 1:5]
#%%
# Initialize a dictionary to store the separated tables
def dico_f_inp(data) : 
    dico = {}
    
    # Iterate through the rows and separate data based on object description
    current_f = {}
    formula_name = {}
    current_inp = {}
    flag_ref = {}
    name = None 
    shape = ''
    for index, row in data.iterrows():
        # print(index)
        # row [7] = first value
        if row[8] and row[7]: 
            if not current_f.get(row[7].strip()) :
                current_f[row[7].strip()] = set()
            current_f[row[7].strip()].add(row[8].strip())
        if row[11] : 
            print(row[11], '=',  [row[12].strip(), row[13].strip(), row[14].strip()])
            
            current_inp[row[11].strip()] = [row[12].strip(), row[13].strip(), row[14].strip()] # default val, lvl, type
        if row[7] and row[7].strip().startswith('ref') : 
            ref = row[7].strip()[4:].strip()
            print('refr', ref)
            if not flag_ref.get(name) and name :
                flag_ref[name] = []
            flag_ref[name].append(ref)
            # else : 
            #     raise Exception('Ma ref est dégueu %s : ligne %d' % (ref, index))
            
        elif not row[7].strip().startswith('ref') and row[7] and all(row[i] == '' for i in range(8,16)) :
            
            if name : 
                dico[name] = {'f' : current_f, 'inp' : current_inp, 'shape' : shape}
            name = row[7].strip()
            shape = row[16].strip()
            print('\n')
            print(shape)
            print(name, index)
            # print(current_f)
            # print(current_inp)
            current_f = {}
            current_inp = {}
    
    if name : 
        dico[name] = {'f' : current_f, 'inp' : current_inp, 'shape' : shape}
    
    print('flag_ref', flag_ref)
    for name, refs in flag_ref.items() :
        if name == 'Filière eau': print('REF', refs)
        while refs :
            ref = refs.pop()
            
            for key in dico[ref]['f'] : 
                
                if key not in dico[name]['f'] : 
                    if name == 'Filière eau': print(key)
                    dico[name]['f'][key] = set()
                    flag = True
                else :
                    flag = False
                    if key.endswith('_e') or key.endswith('_c') :
                        flag = True
                if flag :
                    dico[name]['f'][key] = dico[name]['f'][key].union(dico[ref]['f'][key])
            for key in dico[ref]['inp'] : 
                # if key=='d_vie' : 
                if name == 'Filière eau': print(key, key not in dico[name]['inp'])
                if key not in dico[name]['inp'] : 
                    dico[name]['inp'][key] = dico[ref]['inp'][key]

    
    
    return dico
    

def global_values(data) :         
    dico = {}
    for index, row in data.iterrows() : 
        if row[1].strip() : 
            try : 
                value = float(row[2].replace(',', '.'))
            except : 
                # print('\n', index, row)
                value = None
            try : 
                incertitude = float(row[3].replace(',', '.'))/100
            except : 
                incertitude = 0
                # print('\n', index, row)
            dico[row[1]] = [value, incertitude, row[4]] # value, incertitude, comment
    return dico

dico_bloc = dico_f_inp(data_f_inp)
dico_global = global_values(data_global)
    
#%%

dico_formules = {}

import formules_flemmes as ff
# specifiques_bloc = ['Général', 'Général eau', 'Bassin cylindrique', "BRM"]
# specifiques_bloc = ["Général boue", "Général", "Déchets", "Dessableur-Dégraisseur"]
# specifiques_bloc = ["Pompe", "Poste de refoulement"]
# specifiques_bloc = ["Tamis", 'Déchets']
inp_and_out = set(['TBentrant'])
specifiques_bloc = None
if not specifiques_bloc : 
    specifiques_bloc = set(dico_bloc.keys())
for bloc in specifiques_bloc : 
    print(bloc)
    var = [set() for k in range(6)]
    defaults = set()
    for key in dico_bloc[bloc]['inp'] : 
        default = dico_bloc[bloc]['inp'][key][0]
        lvl = dico_bloc[bloc]['inp'][key][1].strip()
        if lvl : 
            lvl = lvl.split(',')
            for l in lvl : 
                l = l.strip()
                l = int(l[0])
                var[l-1].add(key)
        elif default : 
            defaults.add(key)
    
    for lvl in range(6) : 
        var[lvl] = var[lvl].union(defaults)
    print('var', var)
    f_gas = {}
    hypo = {}
    for key in dico_bloc[bloc]['f'] : 
        if key.endswith('_e') or key.endswith('_c') : 
            f_gas[key] = dico_bloc[bloc]['f'][key]
        else : 
            if key.endswith('_s') or key in inp_and_out : 
                f_gas[key] = dico_bloc[bloc]['f'][key]
            hypo[key] = list(dico_bloc[bloc]['f'][key])[0]
    
    dico_formules[bloc] = ff.formula(f_gas, hypo, var)
    
#%%

import sys
from PyQt5.QtWidgets import QApplication, QDialog, QVBoxLayout, QListWidget, QPushButton, QHBoxLayout, QLineEdit, QLabel

class ValuePickerDialog(QDialog):
    def __init__(self, values, formula_definition, parent=None):
        super().__init__(parent)
        self.values = values
        self.formula_definition = formula_definition
        self.selected_value = None
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Pick a Value')
        self.layout = QVBoxLayout()

        self.formula_label = QLabel(self.formula_definition)
        self.layout.addWidget(self.formula_label)

        self.list_widget = QListWidget()
        for value in self.values:
            self.list_widget.addItem(value)
        self.layout.addWidget(self.list_widget)

        self.input_field = QLineEdit()
        self.input_field.setPlaceholderText('Or enter your own value')
        self.layout.addWidget(self.input_field)
        
        self.button_layout = QHBoxLayout()
        self.ok_button = QPushButton('OK')
        self.cancel_button = QPushButton('Cancel')
        self.button_layout.addWidget(self.ok_button)
        self.button_layout.addWidget(self.cancel_button)
        self.layout.addLayout(self.button_layout)

        self.setLayout(self.layout)

        self.ok_button.clicked.connect(self.accept)
        self.cancel_button.clicked.connect(self.reject)

    def accept(self):
        selected_items = self.list_widget.selectedItems()
        if selected_items:
            self.selected_value = selected_items[0].text()
        elif self.input_field.text():
            self.selected_value = self.input_field.text()
        super().accept()

    def reject(self):
        self.selected_value = None
        super().reject()

def pick_value(values, formula_definition):
    app = QApplication(sys.argv)
    dialog = ValuePickerDialog(values, formula_definition)
    if dialog.exec_() == QDialog.Accepted:
        return dialog.selected_value
    return None

# {trad.get(f, f)} elec {norm_name} {max_lvl}
def formula_string(expr, val, norm_name, max_lvl) : 
    if 'Welec' in expr : 
        return f"{trad.get(val, val)} elec {norm_name} {max_lvl}"
    elif re.search(r'\bq_\w*\b', expr) :
        if len(re.findall(r'\bq_\w*\b', expr)) > 1 :
            to_write = 'intrant'
        else :
            to_write = re.search(r'\bq_\w*\b', expr)[0]
        return f"{trad.get(val, val)} {to_write} {norm_name} {max_lvl}"
    else : 
        return f"{trad.get(val, val)} {norm_name} {max_lvl}"

#%%

import string
import unicodedata
from formula import read_formula
import re


def normalized_name(name, max_length=24, no_caps=True):
    '''removes accents, spaces and caps'''
    name = name.replace(u" ", u"_")
    if no_caps:
        name = name.lower()
    filter_ = string.ascii_letters+"_"+string.digits
    return ''.join(x for x in unicodedata.normalize('NFKD', name) \
            if x in filter_)[:max_length]

def is_almost_equal(expr1, expr2):
    nb_diff = 0
    n1 = len(expr1)
    n2 = len(expr2)
    if n1 == n2:
        return expr1 == expr2
    else :
        args1 = read_formula(expr1.split('=')[1], {})
        args2 = read_formula(expr2.split('=')[1], {})
        # print(args1)
        # print(args2)
        if args1 == args2 :
            pattern = r'\d+\.?\d*|\.\d+'
            numb1 = re.findall(pattern, expr1)
            numb2 = re.findall(pattern, expr2)
            if len(numb1) == len(numb2) :
                for i in range(len(numb1)) :
                    if abs(float(numb1[i]) - float(numb2[i])) > 1e-6 :
                        return False
                return True
    return False

trad = {'co2_c' : 'CO2 construction', 'co2_e' : 'CO2 exploitation', 'ch4_c' : 'CH4 construction',
        'ch4_e' : 'CH4 exploitation', 'n2o_c' : 'N2O construction', 'n2o_e' : 'N2O exploitation'}
types = {'réel' : 'real', 'entier' : 'integer', 'booléen' : 'boolean', 'texte' : 'text', 'list' : 'list'}

formula_name = {}
formula_description = {}

args_bloc = {}
import time

global_type_table = {}

dico_global2 = {}
for val in dico_global : 
    if len(val.split('(')) == 1 : 
        dico_global2[val.lower()] = dico_global[val]

for bloc in dico_formules : 
    if not bloc in ['Général', 'Général eau']:
        
        formula_tab = []
        inputs = {}
        outputs = {}
        default_values = {}
        possible_values = {}
        args_bloc[bloc] = {'inputs' : {}, 'outputs' : {}, 'default_values' : {}, 'possible_values' : {}, 'formula' : set(), 'formula_description' : {}}
        
        norm_name = normalized_name(bloc)
        args_bloc[bloc]['norm_name'] = norm_name
        print('\n', bloc)
        d = dico_bloc[bloc]
        # print('BONJOUR', d)
        shape = d['shape']
        default_values['shape'] = shape
        args_bloc[bloc]['shape'] = shape
        res = dico_formules[bloc].results
        res2 = {}
        for lvl in res : 
            res2[lvl] = {}
            for key in res[lvl] :
                res2[lvl][key.lower()] = set()
                for f in res[lvl][key] : 
                    res2[lvl][key.lower()].add(key.lower()+"="+f.lower()) 
                # res2[lvl][key.lower()] = key.lower() +"="+res[lvl][key].lower()
        res = res2
                
                
        inps = set()
        outs = set()
        dico_inp = {}
        for inp in d['inp'] :
            dico_inp[inp.lower()] = d['inp'][inp]
        d['inp'] = dico_inp
        # print("DINP", d['inp'])
        for inp in d['inp'] : 
            # print('INP', inp)
            if inp[-2:] == '_e' : 
                inps.add(inp)
                type_ = types.get(d['inp'][inp][2], 'real')
                if default : 
                    default = d['inp'][inp][0]
                if type_ == 'list' : 
                    for val in dico_global : 
                        if val.lower().startswith(inp) and '(' in val: 
                            # print(val)
                            val_tot = val
                            val = val_tot.split('(')[1].split(')')[0]
                            gen_val = val_tot.split('(')[0].strip().lower()
                            if not possible_values.get(inp) : 
                                possible_values[inp] = set()
                            possible_values[inp].add(val)
                            if not global_type_table.get(gen_val) : 
                                global_type_table[gen_val] = set()
                            fe, incertitude, comment = dico_global[val_tot]
                            global_type_table[gen_val].add((val, fe, incertitude, comment))
                inputs[inp] = type_
                default_values[inp] = default
            elif inp[-2:] == '_s' : 
                # print('In OUT !')
                type_ = types.get(d['inp'][inp][2], 'real')
                default = d['inp'][inp][0]
                outputs[inp] = type_
                if default : 
                    default_values[inp] = default
                outs.add(inp)
            
            elif inp in inp_and_out : 
                inps.add(inp)
                outs.add(inp)
                type_ = types.get(d['inp'][inp][2], 'real')
                default = d['inp'][inp][0]
                inputs[inp] = type_
                outputs[inp] = type_
                if default : 
                    default_values[inp] = default
            elif inp == 'd_vie' : 
                inps.add(inp)
                type_ = types.get(d['inp'][inp][2], 'real')
                default = d['inp'][inp][0]
                inputs[inp] = type_
                if default : 
                    default_values[inp] = default
        
        for lvl in res : 
            for key in res[lvl] :
                for f in res[lvl][key] : 
                    if f not in args_bloc[bloc]['formula'] : 
                        max_lvl = 0
                        
                        print("---------")
                        args = set(read_formula(f.split('=')[1], d['inp']))
                        args2 = set(read_formula(f.split('=')[1], {}))
                        flag = True
                        print(bloc)
                        print('args', args)
                        print('args2', args2)
                        for arg in args2 : 
                            if arg and arg not in args :  
                                if arg not in dico_global2 : 
                                    if arg.endswith('_e') :
                                        inps.add(arg)
                                        type_ = types.get(d['inp'][arg][2], 'real')
                                        inputs[arg] = type_
                                    elif arg.endswith('_s') :
                                        outs.add(arg)
                                        type_ = types.get(d['inp'][arg][2], 'real')
                                        outputs[arg] = type_
                                    else :
                                        print(d['inp'])
                                        flag = False
                                        print('arg raté', arg)
                                        print("CETTE FORMULE EST FAUSSE", key, f)
                                    break
                        if flag :
                            # print(d['inp'])
                            print(key, f)
                            print('ARGS', args)
                            print(bloc)
                            for arg in args : 
                                arg = arg.lower()
                                print('arg', arg)
                                print('default', d['inp'][arg][0])
                                if arg in d['inp'] : 
                                    if arg[-2:] != '_s' :
                                        inps.add(arg)
                                    if arg in inp_and_out : 
                                        outs.add(arg)
                                    current_lvl = d['inp'][arg][1]
                                    print('max_lvl avt', max_lvl)
                                    if current_lvl : 
                                        current_lvl = current_lvl.split(',')
                                        current_max = max([int(l.strip()[0]) for l in current_lvl])
                                        print('current_max', current_max)
                                        if current_max > max_lvl and (not d['inp'][arg][0] or current_max == 6): 
                                            max_lvl = current_max
                                    
                                    default = d['inp'][arg][0]
                                    type_ = types.get(d['inp'][arg][2], 'real')
                                    if type_ == 'list' : 
                                        for val in dico_global : 
                                            if val.lower().startswith(arg) and '(' in val: 
                                                # print(val)
                                                val_tot = val
                                                val = val_tot.split('(')[1].split(')')[0]
                                                gen_val = val_tot.split('(')[0].strip().lower()
                                                if not possible_values.get(arg) : 
                                                    possible_values[arg] = set()
                                                possible_values[arg].add(val)
                                                if not global_type_table.get(gen_val) : 
                                                    global_type_table[gen_val] = set()
                                                fe, incertitude, comment = dico_global[val_tot]
                                                global_type_table[gen_val].add((val, fe, incertitude, comment))
                                    if arg in inps : 
                                        inputs[arg] = type_ 
                                    elif arg in outs : 
                                        outputs[arg] = type_
                                    
                                    if default :
                                        default_values[arg] = default
                                    # Finit avec les inputs et outputs
                                    # print(max_lvl)
                            
                            flag = False
                            for formula in formula_name : 
                                if is_almost_equal(f, formula) :
                                    # print()
                                    # print('Expr, f, equal')
                                    # print(expr)
                                    # print(formula)
                                    # print(is_almost_equal(expr, formula))
                                    # print()
                                    flag = True 
                                    formula_name[formula].add(formula_string(f, trad.get(key, key), norm_name, max_lvl))  
                                    break 
                            if not flag :
                                formula_name[f] = set() 
                                formula_name[f].add(formula_string(f, trad.get(key, key), norm_name, max_lvl)) 
                                args_bloc[bloc]['formula'].add(f)
                            else : 
                                args_bloc[bloc]['formula'].add(formula)
        args_bloc[bloc]['inputs'] = inputs
        args_bloc[bloc]['outputs'] = outputs
        args_bloc[bloc]['default_values'] = default_values
        print()
        print('Bonchour, ', bloc, possible_values)
        print()
        args_bloc[bloc]['possible_values']= {key : list(possible_values[key]) for key in possible_values}
    
                
priority = {'general' : 0, 'bassin_cylindrique' : 1, 'general_eau' : 1}
#%%

Names = {'co2_e=feelec*welec':'CO2 elec 6'}

for f in formula_name : 
    formula_tab.append(str(f))
    if len(formula_name[f]) > 1 : 
        selected_value = Names.get(f)
        prio = 1000
        if not selected_value :
            for val in priority : 
                for names in formula_name[f] :
                    print(val, names, val in names)
                    if val in names : 
                        if prio > priority[val] : 
                            print ('ON L a FAIT')
                            prio = priority[val]
                            selected_value = names
        if not selected_value :  
            selected_value = pick_value(formula_name[f], f)
            # Ne pas hésiter à spammer click entrée pour ne pas choisir de nom pertinent pour les formules 
            # Après c'est possible de choisr des noms pertinents aussi...
            if selected_value not in formula_name[f] :
                formula_name[f].add(selected_value)
            if not selected_value :
                print("STOP STOP STOP")
                break
    elif len(formula_name[f]) == 1 : 
        selected_value = list(formula_name[f])[0]
    else :
        print("STOP STOP STOP")
        break
    formula_description[str(f)] = [selected_value, '', int(selected_value[-1])]     


#%%
import os 

for bloc in args_bloc : 
    for f in args_bloc[bloc]['formula'] : 
        args_bloc[bloc]['formula_description'][f] = formula_description[f]
    
            
        
_cycle_dir = os.path.join(os.path.expanduser('~'), '.cycle')

def write_sql_bloc(project_name, name, shape, entrees, sorties, default_values = {}, possible_values = {}, abbreviation = '', formula = [], formula_description = {}, path = '', mode = 'a'):
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
    
    type_table = {'real' : 'real', 'integer' : 'integer', 'string' : 'varchar', 'boolean' : 'boolean'}
    
    rows = dict(entrees, **sorties)
    
    table_types = ''
    new_type = ''
    table_types_view = ''
    view_join = "additional_join => 'left"
    view_col = "additional_columns => '{"
    columns = ''
    with open(path, 'r') as f : 
        precedent = f.read()
    for key, value in rows.items(): 
        # print("value", value)
        if value == "list" :
        # Dans le cas où on une liste de valeur, nous allons créer un nouveau tableau pour stocker les valeurs possibles
        # Donc on doit en plus ajouter une colonne qui y fait référence dans le bloc
        # Ainsi que les colonnes additionnelles et les jointures dans le bloc.
            if not f"create table ___.{key}_type_table" in precedent :
                table_types += f"create table ___.{key}_type_table(val ___.{key}_type primary key, FE real, incert real default 0, description text);\n"
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
            if value in type_table : 
                line += f" default {default_values[key]}::{type_table[value]}"
            else : line += f" default {default_values[key]}"
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
name varchar not null default ___.unique_name('{name}_bloc', abbreviation=>'{name if not abbreviation else abbreviation}'),
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
    with open(path, mode, encoding='utf-8') as f :
        f.write(query)
        f.write('\n\n')
    
    return query
                 
with open(os.path.join(os.path.dirname(__file__), '..', 'database', 'sql', 'blocs.sql'), 'w') as f :
    f.write('')

specials_bloc = set(['Canalisation'])
for bloc in args_bloc : 
    print(bloc)
    if bloc not in specials_bloc and args_bloc[bloc]['default_values'].get('shape'):
        write_sql_bloc(None, args_bloc[bloc]['norm_name'], args_bloc[bloc]['shape'], 
                       args_bloc[bloc]['inputs'], args_bloc[bloc]['outputs'], args_bloc[bloc]['default_values'], 
                       args_bloc[bloc]['possible_values'], formula = list(args_bloc[bloc]['formula']), 
                       formula_description = args_bloc[bloc]['formula_description'], 
                       path = os.path.join(os.path.dirname(__file__), '..', 'database', 'sql', 'blocs.sql'))
    

#%% Construction du layertree

from json_utils import json_map, save_to_json

layertree = {
    'Usine' : '',
    'Filière traitement' : {
        'Filière eau' : '',
        'File eau' : {
            'Tamis' : '',
            'Dégrilleur' : '',
            'Clarificateur' : '',
            'Bassin biologique' : '',
            'MBBR' : '',
            'BRM' : '',
            'Décanteur lamellaire' : '',
            'Dessableur-Dégraisseur' : '',
            'Bassin d\'orage' : '',
            'Dégazage' : '',
            'FPR' : '',
            'Lagunage' : ''
        }, 
        'Filière boue' : '',
        'File boue' : {
            'Stockage Boue' : '',
            'Conditionnement chimique' : '',
            'Conditionnement thermique' : '',
            'Tables d\'égouttage' : '',
            'Grilles d\'égouttage' : '',
            'Epaississement statique' : '',
            'Flottateur' : '',
            'Centrifugeuse pour épaississement' : '',
            'Centrifugeuse pour déshydratation' : '',
            'Filtre à bande' : '',
            'Filtre à presse' : '',
            'LSPR' : '',
            'Digesteur / Méthaniseur' : '',
            'Digesteur aérobie' : '',
            'Chaulage' : '',
            'Compostage' : '',
            'Séchage thermique' : '',
            'Séchage solaire' : ''
        }, 
        'Rejets':'',
    },
    'Réseau' : {
        'Canalisation' : '', 
        'Pompe' : '',
        'Station de pompage' : ''
    },
    'Eau Potable' : {
        'Chateau d\'eau' : '',
        'Poste de refoulement' : ''
    }, 
    'Construction autre' : {
        'Excavation' : '',
        'Bâtiment d\'exploitation' : '',
        'Voirie' : '',
        'Clôture' : '', 
        'Déconstruction' : ''
    }
}
# layertree = {"Dessableur-Dégraisseur" : ''}

def replace_key(key, string) : 
    if isinstance(string, str) :
        return {"bloc" : [key, "api", args_bloc[key]['norm_name']+"_bloc", "name"]}

layertree = json_map(layertree, replace_key)

properties =  {}
for bloc in args_bloc : 
    norm_name = args_bloc[bloc]['norm_name']
    if args_bloc[bloc]['possible_values'] and args_bloc[bloc]['default_values'].get('shape') : 
        for val in args_bloc[bloc]['possible_values'] : 
            properties[val] = [val, 'api', f"{val}_type_table", "val"]
            if not properties.get(f"{val}__ref") : 
                properties[f"{val}__ref"] = []
            properties[f"{val}__ref"].append([f'ref_{val}_{norm_name}', 'val', bloc, f'{val}'])
    
        # qml_dir = os.path.join(os.path.dirname(__file__), '..', 'ressources', 'qml')
        # if args_bloc[bloc]['default_values'].get('shape') == 'Point':
        #     qml_file = os.path.join(qml_dir, 'point.qml')
        # elif args_bloc[bloc]['default_values'].get('shape') == 'LineString':
        #     qml_file = os.path.join(qml_dir, 'linestring.qml')
        # elif args_bloc[bloc]['default_values'].get('shape') == 'Polygon':
        #     qml_file = os.path.join(qml_dir, 'polygon.qml')
        # new_qml_file = os.path.join(qml_dir, f'{norm_name}_bloc.qml')
        # with open(qml_file, 'r') as f :
        #     qml = f.read()
        # whith open()
layertree['Properties'] = properties
abstract = {}
abstract['Lien'] = {"bloc": ["Lien", "api", "lien_bloc", "name"]}
abstract['Sur bloc'] = {"bloc": ["Sur bloc", "api", "sur_bloc_bloc", "name"]}
abstract['Source'] = {"bloc": ["Source", "api", "source_bloc", "name"]}
layertree['Blocs abstraits'] = abstract
save_to_json(layertree, os.path.join(os.path.dirname(__file__), '..', 'layertree.json'))

#%% PLus que les global values 

queries = set()
queries_global = set()
for val in dico_global : 
    val2 = val.split('(')
    if len(val2) > 1 : 
        val = val2[0].strip().lower()
        
        if val in global_type_table : 
            for value in global_type_table[val] :
                if value[1] : 
                    queries.add(f"update ___.{val}_type_table set fe = {value[1]}, incert = {value[2]}, description = '{value[3]}' where val = '{value[0]}' ;\n")
    else : 
        if dico_global[val][0] : 
            queries_global.add(f"insert into ___.global_values(name, val, incert, comment) values ('{val.strip().lower()}', {dico_global[val][0]}, {dico_global[val][1]}, '{dico_global[val][2].replace("'", "''")}') ;\n")
        
with open(os.path.join(os.path.dirname(__file__), '..', 'database', 'sql', 'blocs.sql'), 'a', encoding='utf-8') as f :
    for q in queries : 
        f.write(q)
    f.write('\n\n')
    for q in queries_global : 
        f.write(q)
                