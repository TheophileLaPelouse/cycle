# -*- coding: utf-8 -*-
"""
Created on Tue Nov  5 09:52:26 2024

@author: theophile.mounier
"""
#%%
import pandas as pd
import formules_flemmes as ff
# Juste un petit test pour commit
# Load the Excel file
# file_path = r'Z:\Commun\_Toutes-Agences\6_INGENIEURS&CITOYENS\P1_impact_projets\GES - Etudes\emission GES _ traitement.xlsx'
file_path = '/Users/theophilemounier/Documents/stage_hydra2/emission GES _ traitement.xlsx'
xls = pd.ExcelFile(file_path)
#%%
# Load the specific sheet
df = pd.read_excel(xls, 'Recap_formule', header=None, dtype=str)
df.fillna('', inplace=True)
# Extract the relevant data (from line 28 to the end, columns H to P)
data_f_inp = df.iloc[30:, 7:17]
data_global = df.iloc[30:, 1:5]
#%%
# Initialize a dictionary to store the separated tables
def dico_f_inp(data) : 
    dico = {}
    
    # Iterate through the rows and separate data based on object description
    current_f = {}
    formula_name = {}
    current_inp = {}
    flag_ref = []
    name = None 
    shape = ''
    for index, row in data.iterrows():
        # print(index)
        # row [7] = first value
        if row[8] and row[7]: 
            current_f[row[7].strip()] = row[8].strip()
        if row[11] : 
            print(row[11], '=',  [row[12].strip(), row[13].strip(), row[14].strip()])
            
            current_inp[row[11].strip()] = [row[12].strip(), row[13].strip(), row[14].strip()] # default val, lvl, type
        if row[7] and row[7].strip().startswith('ref') : 
            ref = row[7].strip()[4:].strip()
            if ref in dico : 
                flag_ref.append(ref)
            else : 
                raise Exception('Ma ref est dégueu %s : ligne %d' % (ref, index))
            
        if row[7] and all(row[i] == '' for i in range(8,16)) :
    
            while flag_ref :
                ref = flag_ref.pop()
                if name == 'Clarificateur': print('REF', ref)
                for key in dico[ref]['f'] : 
                    
                    if key not in current_f : 
                        if name == 'Clarificateur': print(key)
                        current_f[key] = dico[ref]['f'][key]
                for key in dico[ref]['inp'] : 
                    # if key=='d_vie' : 
                        # print(current_inp['d_vie'])
                    if key not in current_inp : 
                        current_inp[key] = dico[ref]['inp'][key]
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
    
    while flag_ref :
        ref = flag_ref.pop()
        print('REF', ref)
        for key in dico[ref]['f'] : 
            print(key)
            if key not in current_f : 
                current_f[key] = dico[ref]['f'][key]
        for key in dico[ref]['inp'] : 
            # if key=='d_vie' : 
                # print(current_inp['d_vie'])
            if key not in current_inp : 
                current_inp[key] = dico[ref]['inp'][key]
    if name : 
        dico[name] = {'f' : current_f, 'inp' : current_inp, 'shape' : shape}
    
    return dico
    

def global_values(data) :         
    dico = {}
    for index, row in data.iterrows() : 
        if row[1].strip() : 
            try : 
                value = float(row[2].replace(',', '.'))
            except : 
                print('\n', index, row)
                value = None
            try : 
                incertitude = float(row[3].replace(',', '.'))
            except : 
                incertitude = 0
                print('\n', index, row)
            dico[row[1]] = [value, incertitude, row[4]] # value, incertitude, comment
    return dico

    
#%%
dico_bloc = dico_f_inp(data_f_inp)
dico_global = global_values(data_global)
dico_formules = {}
# specifiques_bloc = set(['Général', 'Général eau', 'Bassin cylindrique', 'Clarificateur'])
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
            if key in dico_bloc[bloc]['inp'] : 
                f_gas[key] = dico_bloc[bloc]['f'][key]
            hypo[key] = dico_bloc[bloc]['f'][key]
    
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
    # app = QApplication(sys.argv)
    dialog = ValuePickerDialog(values, formula_definition)
    if dialog.exec_() == QDialog.Accepted:
        return dialog.selected_value
    return None

# {trad.get(f, f)} elec {norm_name} {max_lvl}
def formula_string(expr, val, norm_name, max_lvl) : 
    if 'Welec' in expr : 
        return f"{trad.get(val, val)} elec {norm_name} {max_lvl}"
    elif re.search('\bq_\w*\b', expr) :
        return f"{trad.get(val, val)} re.search('\bq_\w*\b', expr)[0] {norm_name} {max_lvl}"
    else : 
        return f"{trad.get(val, val)} {norm_name} {max_lvl}"

#%%

import string
import unicodedata
from sympy.parsing.sympy_parser import parse_expr
from formula import read_formula
import re

inp_and_out = set(['TBentrant'])

def normalized_name(name, max_length=24, no_caps=True):
    '''removes accents, spaces and caps'''
    name = name.replace(u" ", u"_")
    if no_caps:
        name = name.lower()
    filter_ = string.ascii_letters+"_"+string.digits
    return ''.join(x for x in unicodedata.normalize('NFKD', name) \
            if x in filter_)[:max_length]

def is_almost_equal(expr1, expr2, dico):
    nb_diff = 0
    n1 = len(expr1)
    n2 = len(expr2)
    if n1 == n2:
        return expr1 == expr2
    else :
        args1 = read_formula(expr1, dico)
        args2 = read_formula(expr2, dico)
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
types = {'réel' : 'real', 'entier' : 'integer', 'booléen' : 'integer', 'texte' : 'text', 'list' : 'list'}

formula_name = {}
formula_description = {}

args_bloc = {}

for bloc in dico_formules : 
    formula_tab = []
    inputs = {}
    outputs = {}
    default_values = {}
    possible_values = {}
    args_bloc[bloc] = {'inputs' : {}, 'outputs' : {}, 'default_values' : {}, 'possible_values' : {}, 'formula' : [], 'formula_description' : {}}
    
    norm_name = normalized_name(bloc)
    args_bloc[bloc]['norm_name'] = norm_name
    print('\n', bloc)
    d = dico_bloc[bloc]
    print('BONJOUR', d)
    shape = d['shape']
    args_bloc[bloc]['shape'] = shape
    res = dico_formules[bloc].results
    inps = set()
    outs = set()
    for inp in d['inp'] : 
        print('INP', inp)
        if inp[-2:] == '_e' : 
            inps.add(inp)
            type_ = types.get(d['inp'][inp][2], 'real')
            if default : 
                default = d['inp'][inp][0]
            inputs[inp] = type_
            default_values[inp] = default
        elif inp[-2:] == '_s' : 
            print('In OUT !')
            type_ = types.get(d['inp'][inp][2], 'real')
            default = d['inp'][inp][0]
            outputs[inp] = type_
            if default : 
                default_values[inp] = default
            outs.add(inp)
    
    for lvl in res : 
        for f in res[lvl] : 
            max_lvl = 0
            args = read_formula(res[lvl][f], d['inp'])
            print('ARGS', args)
            for arg in args : 
                print('arg', arg)
                if arg in d['inp'] : 
                    if arg[-2:] != '_s' :
                        inps.add(arg)
                    if arg in inp_and_out : 
                        outs.add(arg)
                    current_lvl = d['inp'][arg][1]
                    if current_lvl : 
                        current_lvl = current_lvl.split(',')
                        current_max = max([int(l.strip()[0]) for l in current_lvl])
                        if current_max > max_lvl : 
                            max_lvl = current_max
                    
                    default = d['inp'][arg][0]
                    type_ = types.get(d['inp'][arg][2], 'real')
                    if type_ == 'list' : 
                        for val in dico_global : 
                            if val.startswith(arg) and '(' in val: 
                                print(val)
                                val = val.split('(')[1].split(')')[0]
                                if not possible_values.get(arg) : 
                                    possible_values[arg] = []
                                possible_values[arg].append(val)
                    if arg in inps : 
                        inputs[arg] = type_ 
                    elif arg in outs : 
                        outputs[arg] = type_
                    
                    if default :
                        default_values[arg] = default
                    # Finit avec les inputs et outputs
                    print(max_lvl)
            args_bloc[bloc]['inputs'] = inputs
            args_bloc[bloc]['outputs'] = outputs
            args_bloc[bloc]['default_values'] = default_values
            args_bloc[bloc]['possible_values'] = possible_values
            
            expr = res[lvl][f]
            flag = False
            for formula in formula_name : 
                if is_almost_equal(expr, formula, d['inp']) :
                    flag = True 
                    formula_name[formula].add(formula_string(expr, trad.get(f, f), norm_name, max_lvl))  
                    break 
            if not flag :
                formula_name[expr] = set() 
                formula_name[expr].add(formula_string(expr, trad.get(f, f), norm_name, max_lvl)) 
                args_bloc[bloc]['formula'].append(expr)  
                
priority = {'general' : 0, 'bassin_cylindrique' : 1, 'general_eau' : 1}

for f in formula_name : 
    formula_tab.append(str(f))
    if len(formula_name[f]) > 1 : 
        selected_value = None
        prio = 1000
        for val in priority : 
            for names in formula_name[f] :
                print(val, names, val in names)
                if val in names : 
                    if prio > priority[val] : 
                        print ('ON L a FAIT')
                        prio = priority[val]
                        selected_value = names
        if not selected_value :  
            selected_value = pick_value(formula_name[f])
            if selected_value not in formula_name[f] :
                formula_name[f].add(selected_value, f)
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
from cycle.database.create_bloc import write_sql_bloc
import os 

for bloc in args_bloc : 
    for f in args_bloc[bloc]['formula'] : 
        args_bloc[bloc]['formula_description'][f] = formula_description[f]

specials_bloc = set(['Canalisation'])
for bloc in args_bloc : 
    print(bloc)
    if bloc not in specials_bloc :
        write_sql_bloc(None, args_bloc[bloc]['norm_name'], args_bloc[bloc]['shape'], 
                       args_bloc[bloc]['inputs'], args_bloc[bloc]['outputs'], args_bloc[bloc]['default_values'], 
                       args_bloc[bloc]['possible_values'], formula = args_bloc[bloc]['formula'], 
                       formula_description = args_bloc[bloc]['formula_description'], 
                       path = os.path.join(os.path.dirname(__file__), 'excel_bloc.sql'))
    
    
    
            
                 
    
    
    
