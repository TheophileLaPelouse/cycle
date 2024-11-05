# -*- coding: utf-8 -*-
"""
Created on Tue Nov  5 09:52:26 2024

@author: theophile.mounier
"""
#%%
import pandas as pd
import formules_flemmes as ff
# Load the Excel file
file_path = r'Z:\Commun\_Toutes-Agences\6_INGENIEURS&CITOYENS\P1_impact_projets\GES - Etudes\emission GES _ traitement.xlsx'
xls = pd.ExcelFile(file_path)
#%%
# Load the specific sheet
df = pd.read_excel(xls, 'Recap_formule', header=None, dtype=str)
df.fillna('', inplace=True)
# Extract the relevant data (from line 28 to the end, columns H to P)
data_f_inp = df.iloc[30:, 7:16]
data_global = df.iloc[30:, 1:5]
#%%
# Initialize a dictionary to store the separated tables
def dico_f_inp(data) : 
    dico = {}
    
    # Iterate through the rows and separate data based on object description
    current_f = {}
    current_inp = {}
    flag_ref = []
    name = None 
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
                for key in dico[ref]['f'] : 
                    if key not in current_f : 
                        current_f[key] = dico[ref]['f'][key]
                for key in dico[ref]['inp'] : 
                    # if key=='d_vie' : 
                        # print(current_inp['d_vie'])
                    if key not in current_inp : 
                        current_inp[key] = dico[ref]['inp'][key]
            if name : 
                dico[name] = {'f' : current_f, 'inp' : current_inp}
            name = row[7].strip()
            print('\n')
            print(name, index)
            # print(current_f)
            # print(current_inp)
            current_f = {}
            current_inp = {}
    
    while flag_ref :
        ref = flag_ref.pop()
        for key in dico[ref]['f'] : 
            if key not in current_f : 
                current_f[key] = dico[ref]['f'][key]
        for key in dico[ref]['inp'] : 
            # if key=='d_vie' : 
                # print(current_inp['d_vie'])
            if key not in current_inp : 
                current_inp[key] = dico[ref]['inp'][key]
    if name : 
        dico[name] = {'f' : current_f, 'inp' : current_inp}
    
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
for bloc in dico_bloc : 
    var = [set() for k in range(6)]
    defaults = set()
    for key in dico_bloc[bloc]['inp'] : 
        default = dico_bloc[bloc]['inp'][key][0]
        lvl = dico_bloc[bloc]['inp'][key][1]
        if lvl : 
            lvl = int(lvl[0])
            var[lvl-1].add(key)
        elif default : 
            defaults.add(key)
    for lvl in range(6) : 
        var[lvl] = var[lvl].union(defaults)
    
    f_gas = {}
    hypo = {}
    for key in dico_bloc[bloc]['f'] : 
        if key.endswith('_e') or key.endswith('_c') : 
            f_gas[key] = dico_bloc[bloc]['f'][key]
        else : 
            hypo[key] = dico_bloc[bloc]['f'][key]
    
    dico_formules[bloc] = ff.formula(f_gas, hypo, var)
    
    
            
