import re
import os 
from qgis.utils import iface
from qgis.core import QgsProject
from qgis.PyQt import uic 
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QGridLayout, QDialog, QWidget, QTableWidgetItem, QDialogButtonBox, QCompleter
from ...qgis_utilities import tr
from ...project import Project
from .create_bloc_form import FormulaCompleter
from ...utility.string import normalized_name

class EditInputOutput(QDialog) : 
    def __init__(self, project_name, log_manager, parent = None) :
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "edit_input.ui"), self)
        
        self.__log_manager = log_manager
        self.__project = Project(project_name, self.__log_manager)
        self.__project_name = project_name
        self.__qgs_project = QgsProject.instance()
        
        self.type_list = self.__project.fetchall("select table_name from information_schema.tables where table_schema = 'api' and table_name like '%_type_table'")
        for k in range(len(self.type_list)) : 
            self.type_list[k] = self.type_list[k][0].replace('_type_table', '')
        self.type_list = ['real', 'integer', 'list'] + self.type_list
        self.entree_type.addItems(self.type_list)
        self.sortie_type.addItems(self.type_list)
        
        self.ok_button = self.buttons.button(QDialogButtonBox.Ok)
        self.ok_button.setEnabled(False)
        self.ok_button.clicked.connect(self.__edit_bloc)
        
        b_types = self.__project.fetchall("select b_type from api.input_output group by b_type")
        b_types = [b_type[0] for b_type in b_types]
        self.bloc_select.addItems([''] + b_types)
        self.bloc_select.currentIndexChanged.connect(self.__bloc_changed)
        
        self.input_i = {}
        self.output_i = {}
        self.default_values = {}
        self.possible_values = {}
        
        
        # Input tab
        self.entree_type.currentIndexChanged.connect(self.__update_entree_type)
        self.add_input.clicked.connect(self.__add_input)
        self.delete_input.clicked.connect(self.__delete_input)
        
        # Output tab
        self.sortie_type.currentIndexChanged.connect(self.__update_sortie_type)
        self.add_output.clicked.connect(self.__add_output)
        self.delete_output.clicked.connect(self.__delete_output)
        
        self.exec_()
        
    def verify_input(self, name, type_, default_value, possible_values):
        # Faudra vérifier le format des données rentrées pour éviter tout problème 
        if possible_values :
            possible_values = possible_values.split(';')
            possible_values = [value.strip() for value in possible_values]
            type_ = name + '_type'
        return normalized_name(name).strip(), type_, default_value, possible_values, not(name == '' or name in self.input)
    
    def verify_output(self, name, type_, default_value, possible_values):
        # Faudra vérifier le format des données rentrées pour éviter tout problème 
        if possible_values :
            possible_values = possible_values.split(';')
            possible_values = [value.strip() for value in possible_values]
        return normalized_name(name).strip(), type_, default_value, possible_values, not(name == '' or name in self.output)
    
    def __bloc_changed(self) : 
        b_type = self.bloc_select.currentText()
        if b_type != '' : 
            self.ok_button.setEnabled(True)
        else :
            self.ok_button.setEnabled(False)
            
        
        query_inp = f"""
        with inp_out as (select inputs, outputs from api.input_output 
        where b_type = '{b_type}')
        select data_type as inp_type, column_name as inp_col from information_schema.columns, inp_out
        where table_schema = 'api' and table_name='{b_type}_bloc'
        and column_name = any(inp_out.inputs)
        """
        query_out = f"""
        with inp_out as (select inputs, outputs from api.input_output 
        where b_type = '{b_type}')
        select data_type as out_type, column_name as out_col from information_schema.columns, inp_out
        where table_schema = 'api' and table_name='{b_type}_bloc'
        and column_name = any(inp_out.outputs)
        """
        values_inp = self.__project.fetchall(query_inp)
        values_out = self.__project.fetchall(query_out)
        print("values_inp", values_inp)
        print("values_out", values_out)
        self.input = {val[1]: val[0] for val in values_inp}
        self.output = {val[1]: val[0] for val in values_out}
        for key in self.type_list : 
            if key in self.input : 
                self.input[key] = key + '_type'
            if key in self.output :
                self.output[key] = key + '_type'
        # On pourrait vouloir remplir les valeurs possible des list mais flemme pour le moment (pas si utile) 
        
        self.input_i = {key : self.input[key] for key in self.input}
        self.output_i = {key : self.output[key] for key in self.output}
        
        n_input = len(self.input)
        self.table_input.setRowCount(n_input)
        k = 0
        for key in self.input_i : 
            self.table_input.setItem(k, 0, QTableWidgetItem(key))
            self.table_input.setItem(k, 1, QTableWidgetItem(self.input_i[key]))
            k+=1
        
        n_output = len(self.output)
        self.table_output.setRowCount(n_output)
        k = 0 
        for key in self.output_i : 
            self.table_output.setItem(k, 0, QTableWidgetItem(key))
            self.table_output.setItem(k, 1, QTableWidgetItem(self.output_i[key]))
            k+=1    
        
    def __update_entree_type(self):
        if self.entree_type.currentText() == 'list':
            self.possible_values_text.setEnabled(True)
            self.warning_input.setText('Enter the possible values separated by a semicolon')
            self.warning_input.setStyleSheet("color: orange; font-weight: bold")
        else:
            self.possible_values_text.setEnabled(False)
            self.warning_input.clear()
            
    def __add_input(self):
        name = self.entree_name.text()
        type_ = self.entree_type.currentText()
        default_value = self.entree_default_value.text()
        if self.entree_type.currentText() == 'list':
            possible_values = self.possible_values_text.text()
        else : possible_values = ''
        name, type_, default_value, possible_values, verified = self.verify_input(name, type_, default_value, possible_values)
        if verified:
            self.input[name] = type_
            self.default_values[name] = default_value
            self.possible_values[name] = possible_values
            
            self.table_input.setRowCount(len(self.input))
            self.table_input.setItem(len(self.input)-1, 0, QTableWidgetItem(name))
            self.table_input.setItem(len(self.input)-1, 1, QTableWidgetItem(type_))
            self.table_input.setItem(len(self.input)-1, 2, QTableWidgetItem(default_value))
            self.table_input.setItem(len(self.input)-1, 3, QTableWidgetItem(str(possible_values)))
        
            # clear the input fields
            self.entree_name.clear()
            self.entree_default_value.clear()
            self.possible_values_text.clear()
            self.warning_input.clear()
        else : 
            self.warning_input.setText('Name already exists or is empty')
            self.warning_input.setStyleSheet("color: red")
            
    def __delete_input(self):
        items = self.table_input.selectedItems()
        if len(items)>0:
            selected_row = self.table_input.row(items[0])
            del self.input[self.table_input.item(selected_row, 0).text()]
            self.table_input.removeRow(selected_row)
            
    def __update_sortie_type(self):
        if self.sortie_type.currentText() == 'list':
            self.possible_values_text2.setEnabled(True)
            self.warning_output.setText('Enter the possible values separated by a semicolon')
            self.warning_output.setStyleSheet("color: orange; font-weight: bold")
        else:
            self.possible_values_text2.setEnabled(False)
            self.warning_output.clear()
    
    def __add_output(self):
        name = self.sortie_name.text()
        type_ = self.sortie_type.currentText()
        default_value = self.sortie_default_value.text()
        if self.sortie_type.currentText() == 'list':
            possible_values = self.possible_values_text2.text()
        else : possible_values = ''
        name, type_, default_value, possible_values, verified = self.verify_input(name, type_, default_value, possible_values)
        if verified:
            
            self.default_values[name] = default_value
            self.possible_values[name] = possible_values
            self.output[name] = type_
            
            self.table_output.setRowCount(len(self.output))
            self.table_output.setItem(len(self.output)-1, 0, QTableWidgetItem(name))
            self.table_output.setItem(len(self.output)-1, 1, QTableWidgetItem(type_))
            self.table_output.setItem(len(self.output)-1, 2, QTableWidgetItem(default_value))
            self.table_output.setItem(len(self.output)-1, 3, QTableWidgetItem(str(possible_values)))
        
            # clear the input fields
            self.sortie_name.clear()
            self.sortie_default_value.clear()
            self.possible_values_text2.clear()
            self.warning_output.clear()
        else :
            self.warning_output.setText('Name already exists or is empty')
            self.warning_output.setStyleSheet("color: red")
            
    def __delete_output(self):
        items = self.table_output.selectedItems()
        if len(items)>0:
            selected_row = self.table_output.row(items[0])
            del self.output[self.table_output.item(selected_row, 0).text()]
            self.table_output.removeRow(selected_row)
            
    def __edit_bloc(self):
        b_type = self.bloc_select.currentText()
        query = ""
        
        for key in self.default_values :
            if self.default_values[key] == '' :
                self.default_values[key] = 'null'
        
        for key in self.input : 
            if key in self.input_i and self.input[key] != self.input_i[key] : 
                if self.input[key].endswith('_type') :
                    self.__create_type_table(key, self.input[key])
                query += f"\nselect api.insert_inp_out('{b_type}', '{key}', '{self.input[key]}', '{self.default_values.get(key, 'null')}', 'modif', 'input') ;"
                
            elif key not in self.input_i :
                if self.input[key].endswith('_type') :
                    self.__create_type_table(key, self.input[key])
                query += f"\nselect api.insert_inp_out('{b_type}', '{key}', '{self.input[key]}', '{self.default_values.get(key, 'null')}', 'added', 'input') ;"
        for key in self.input_i :
            if key not in self.input : 
                query += f"\nselect api.insert_inp_out('{b_type}', '{key}', '{self.input_i[key]}', '{self.default_values.get(key, 'null')}', 'remove', 'input') ;"
        
        for key in self.output : 
            if key in self.output_i and self.output[key] != self.output_i[key] : 
                if self.output[key].endswith('_type') :
                    self.__create_type_table(key, self.output[key])
                query += f"\nselect api.insert_inp_out('{b_type}', '{key}', '{self.output[key]}', '{self.default_values.get(key, 'null')}', 'modif', 'output') ;"
                
            elif key not in self.output_i :
                if self.output[key].endswith('_type') :
                    self.__create_type_table(key, self.output[key])
                query = f"\nselect api.insert_inp_out('{b_type}', '{key}', '{self.output[key]}', '{self.default_values.get(key, 'null')}', 'added', 'output') ;"
        for key in self.output_i :
            if key not in self.output : 
                query = f"\nselect api.insert_inp_out('{b_type}', '{key}', '{self.output_i[key]}', '{self.default_values.get(key, 'null')}', 'remove', 'output') ;"
        print(query)
        print(self.default_values)
        
        query = f"drop view if exists api.{b_type}_bloc ;\n" + query
        self.__project.execute(query)
        
        
        with open(os.path.join(os.path.dirname(__file__), '..', '..', 'database', 'sql', 'blocs.sql'), 'r') as f :
            lines  = f.readlines()
        n_lines = len(lines)
        flag = False
        # Il faut redéfinir la vue du bloc donc on va chercher sa définition
        for k in range(n_lines) :
            line = lines[k] 
            if line.startswith(f"select api.add_new_bloc('{b_type}'") : 
                bloc_view = '\n'.join(lines[k:k+3])
                flag = True
                break
            
        if not flag :
            with open(os.path.join(self.__project.directory,  'custom_blocs.sql'), 'r') as f :
                lines  = f.readlines()
            n_lines = len(lines)
            for k in range(n_lines) :
                line = lines[k] 
                if line.startswith(f"select api.add_new_bloc('{b_type}'") : 
                    bloc_view = '\n'.join(lines[k:k+3])
                    break

        print(bloc_view)
        self.__project.execute(bloc_view)    
            
        
        with open(os.path.join(self.__project.directory, 'custom_blocs.sql'), 'a') as f :
            f.write(query+'\n')
            f.write(bloc_view)
            
        # Il faut aussi update la layer mais du coup comme les formules faudra recharger l'application pour le moment 