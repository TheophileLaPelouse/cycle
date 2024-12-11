import re
import os 
from qgis.utils import iface
from qgis.core import QgsProject, QgsDefaultValue
from qgis.PyQt import uic 
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QGridLayout, QDialog, QWidget, QTableWidgetItem, QDialogButtonBox, QCompleter, QHeaderView
from ...qgis_utilities import tr, QGisProjectManager, Alias
from ...project import Project

class DefaultValues(QDialog):
    def __init__(self, project, parent=None):
        super(DefaultValues, self).__init__(parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'default_values.ui'), self)
        
        self.__project = project
        
        column_default = self.__project.fetchone('select api.get_all_value_columns()')[0]
        print(column_default)
        self.possible_inputs = column_default['columns']
        
        column_default = column_default['columns_with_default']
        self.type_alias  ={'integer' : 'entier', 'real' : 'réel', 'boolean' : 'booléen'}
        n = self.table_input.rowCount()
        for key in column_default : 
            self.table_input.insertRow(n)
            self.table_input.setItem(n, 0, QTableWidgetItem(key))
            self.table_input.setItem(n, 1, QTableWidgetItem(Alias.get(key)))
            
            value = column_default[key]
            if ':' in value :
                # values de la forme (val)::type
                value = value[1:].split(')')
                type_ = value[1][2:] 
                value = value[0]
            elif value == 'true' or value == 'false' :
                value = int(value == 'true')
                type_ = 'boolean'
            else : 
                type_ = 'real'
            self.table_input.setItem(n, 2, QTableWidgetItem(self.type_alias.get(type_) or 'réel'))
            self.table_input.setItem(n, 3, QTableWidgetItem(str(value)))

        self.completer = QCompleter(self.possible_inputs.keys())
        self.field_name.setCompleter(self.completer)
        self.field_name.textChanged.connect(self.change_combo)
        
        self.combo_type.addItems(['entier', 'réel', 'booléen', 'USER-DEFINED'])
        
        self.add_field_btn.clicked.connect(self.add_field)
        self.delete_input_btn.clicked.connect(self.delete_input)
        
        self.changes = {}
        
        self.ok_button = self.buttons.button(QDialogButtonBox.Ok)
        self.ok_button.clicked.connect(self.commit_changes)
        
        for k in range(4) : 
            self.table_input.horizontalHeader().setSectionResizeMode(k, QHeaderView.ResizeToContents)
        
        self.exec_()
    
    def change_combo(self):
        if self.field_name.text() in self.possible_inputs :
            self.combo_type.setEnabled(True)
            print(self.possible_inputs[self.field_name.text()])
            self.combo_type.setCurrentText(self.type_alias.get(self.possible_inputs[self.field_name.text()], 'réel'))
            self.combo_type.setEnabled(False)
            if self.possible_inputs[self.field_name.text()] == 'USER-DEFINED' : 
                self.default_val.setEnabled(False)
            else :
                self.default_val.setEnabled(True)
                
        
    def add_field(self):
        field_name = self.field_name.text()
        type_ = self.combo_type.currentText()
        value = self.default_val.text()
        if type_ == 'réel' : 
            try : value = float(value)
            except : 
                self.warning_label.setText(tr('Valeur invalide pour le type réel'))
                return
        else : 
            try : value = int(value)
            except :
                self.warning_label.setText(tr('Valeur invalide pour le type entier ou booléen (0 ou 1)')) 
                return
        if field_name not in self.possible_inputs : 
            self.warning_label.setText(tr('Nom de champ invalide'))
            return
        self.table_input.insertRow(self.table_input.rowCount())
        self.table_input.setItem(self.table_input.rowCount()-1, 0, QTableWidgetItem(field_name))
        self.table_input.setItem(self.table_input.rowCount()-1, 1, QTableWidgetItem(Alias.get(field_name)))
        self.table_input.setItem(self.table_input.rowCount()-1, 2, QTableWidgetItem(type_))
        self.table_input.setItem(self.table_input.rowCount()-1, 3, QTableWidgetItem(str(value)))
        
        self.field_name.clear()
        self.default_val.clear()
        
    def delete_input(self):
        items = self.table_input.selectedItems()
        selected_row = self.table_input.row(items[0])
        self.table_input.removeRow(selected_row)
            
            
    def commit_changes(self):
        values = {}
        for i in range(self.table_input.rowCount()) : 
            field_name = self.table_input.item(i, 0).text()
            type_ = self.table_input.item(i, 2).text()
            value = self.table_input.item(i, 3).text()
            values[field_name] = [field_name, str(int(value)) if type_ == 'entier' else 'null', 
                                  str(int(value)) if type_ == 'booléen' else 'null', 
                                  str(float(value)) if type_ == 'réel' else 'null']
            print(values[field_name], type_, value)
            
        query = f"""
        delete from api.default_values_config;
        insert into api.default_values_config (name, int_val, bool_val, real_val) values
        {', '.join(
            [f"('{field_name}', {str(values[field_name][1])}::integer, {str(values[field_name][2])}::boolean, {str(values[field_name][3])}::real)" 
            for field_name in values]
        )}  
        ;
        """
        # La requête est un peu bourrine mais en même tmeps ça va aller très vite 
        print(query)
        self.__project.execute(query)
        self.changes = self.__project.fetchone('select api.change_default()')[0]
        print("Le changement c'est maintenant", self.changes)
        # self.changes = {bloc_name : new_default_value}    
        layernames = QGisProjectManager.layers('self.__project.qgs')
        for name in layernames : 
            # print(layernames[name] in self.changes)
            print(name, layernames[name], layernames[name] in self.changes)
            if layernames[name] in self.changes : 
                layer = QgsProject.instance().mapLayersByName(name)[0]
                for col in self.changes[layernames[name]] :
                    index = layer.fields().indexFromName(col)
                    defval = QgsDefaultValue()
                    defval.setExpression(str(self.changes[layernames[name]][col]['val']))
                    print(index, defval, name)
                    layer.setDefaultValueDefinition(index, defval)
                    
        self.close()
                    
                    
            
        
    