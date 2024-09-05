import os 
from qgis.PyQt import uic 
from qgis.PyQt.QtWidgets import QGridLayout, QDialog, QWidget, QTableWidgetItem
from qgis.core import QgsAttributeEditorField as attrfield, Qgis, QgsProject, QgsVectorLayer
from ...service import get_service
from ...database.version import __version__

Formules_de_base = ['CO2 = CO2']
Input_de_base = {'CO2' : 'real'}

class CreateBlocWidget(QDialog):
    
    def __init__(self, project_filename, parent=None):
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "create_bloc.ui"), self)
        
        self.__project_filename = project_filename
        
        self.geom.addItems(['Point', 'Line', 'Polygon'])
        types = ['real', 'integer', 'string', 'list'] # On pourra ajouter les types de la base de donnée aussi 
        self.entree_type.addItems(types)
        # 2 = output
        self.sortie_type.addItems(types)
        self.possible_values.setEnabled(False)
        self.possible_values_2.setEnabled(False)
        
        self.input = Input_de_base
        self.output = {}
        self.formula = Formules_de_base
        
        """
        En terme de design on a : 
        bloc name et geometryr type où ça change rien pour le moment 
        puis un tabWidget avec 3 onglets : Input, Output, Formula
        
        Dans Input et Output, on rentre name, type, default value et si type = list, on rentre les valeurs de la liste dans possible_values 
        Puis on appuie sur le bouton add pour ajouter la colonne à la table
        
        Dans Formula, on rentre la formule, on vérifie si elle est correcte et on l'ajoute à la table
        """
        
        # Input tab
        self.entree_type.currentIndexChanged.connect(self.__update_entree_type)
        self.add_input.clicked.connect(self.__add_input)
        self.delete_input.clicked.connect(self.__delete_input)
        
        self.table_input.setRowCount(len(self.input))
        i = 0
        for key, value in self.input.items():
            self.table_input.setItem(i, 0, QTableWidgetItem(key))
            self.table_input.setItem(i, 1, QTableWidgetItem(value))
            self.table_input.setItem(i, 2, QTableWidgetItem('Null'))
            i+=1

        # Output tab
        self.sortie_type.currentIndexChanged.connect(self.__update_sortie_type)
        self.add_output.clicked.connect(self.__add_output)
        self.delete_output.clicked.connect(self.__delete_output)
        
        # Formula tab
        self.add_formula.clicked.connect(self.__add_formula)
        self.warning_formula.setStyleSheet("color: orange")
        self.warning_formula.setText('Enter the formula in the form of "A = B [+-*/^] 10*C==\'elem of list\' ..." where A, B, C are the names of the input or output')
        self.delete_formula.clicked.connect(self.__delete_formula)
        
        # Ok button
        self.ok_button.clicked.connect(self.__create_bloc)
        
        self.exec_()
    
    def __add_formula(self):
        formula = self.formula_text.text()
        if self.verify_formula(formula):
            self.table_formula.setRowCount(len(self.formula))
            self.table_formula.setItem(len(self.formula)-1, 0, QTableWidgetItem(formula))
            self.formula.append(formula)
            self.formula_text.clear()
    
    def verify_formula(self, formula):
        # Faudra vérifier les formules sur le point de vue synthax et le point de vue sécurité.
        return True
    
    def __delete_formula(self):
        items = self.table_formula.selectedItems()
        if len(items)>0:
            selected_row = self.table_formula.row(items[0])
            del self.formula[selected_row]
            self.table_formula.removeRow(selected_row)
    
    def __update_entree_type(self):
        if self.entree_type.currentText() == 'list':
            self.possible_values.setEnabled(True)
            self.warning_input.setText('Enter the possible values separated by a semicolon')
            self.warning_input.setStyleSheet("color: orange; font-weight: bold")
        else:
            self.possible_values.setEnabled(False)
            self.warning_input.clear()
            
    def __add_input(self):
        name = self.entree_name.text()
        type_ = self.entree_type.currentText()
        self.input[name] = type_
        default_value = self.entree_default_value.text()
        if self.entree_type.currentText() == 'list':
            possible_values = self.possible_values.text()
        else : possible_values = ''
        name, type_, default_value, possible_values, verified = self.verify_input(name, type_, default_value, possible_values)
        if verified:
            self.table_input.setRowCount(len(self.input))
            self.table_input.setItem(len(self.input)-1, 0, QTableWidgetItem(name))
            self.table_input.setItem(len(self.input)-1, 1, QTableWidgetItem(type_))
            self.table_input.setItem(len(self.input)-1, 2, QTableWidgetItem(default_value))
            self.table_input.setItem(len(self.input)-1, 3, QTableWidgetItem(possible_values))
        
            # clear the input fields
            self.entree_name.clear()
            self.entree_default_value.clear()
            self.possible_values.clear()
    
    def verify_input(self, name, type_, default_value, possible_values):
        # Faudra vérifier le format des données rentrées pour éviter tout problème de sécurité genre injection sql
        return name, type_, default_value, possible_values, True
    
    
    def __delete_input(self):
        items = self.table_input.selectedItems()
        if len(items)>0:
            selected_row = self.table_input.row(items[0])
            del self.input[self.table_input.item(selected_row, 0).text()]
            self.table_input.removeRow(selected_row)

    def __update_sortie_type(self):
        if self.sortie_type.currentText() == 'list':
            self.possible_values_2.setEnabled(True)
            self.warning_output.setText('Enter the possible values separated by a semicolon')
            self.warning_output.setStyleSheet("color: orange; font-weight: bold")
        else:
            self.possible_values_2.setEnabled(False)
            self.warning_output.clear()
    
    def __add_output(self):
        name = self.sortie_name.text()
        type_ = self.sortie_type.currentText()
        self.output[name] = type_
        default_value = self.sortie_default_value.text()
        if self.sortie_type.currentText() == 'list':
            possible_values = self.possible_values_2.text()
        else : possible_values = ''
        name, type_, default_value, possible_values, verified = self.verify_input(name, type_, default_value, possible_values)
        if verified:
            self.table_output.setRowCount(len(self.output))
            self.table_output.setItem(len(self.output)-1, 0, QTableWidgetItem(name))
            self.table_output.setItem(len(self.output)-1, 1, QTableWidgetItem(type_))
            self.table_output.setItem(len(self.output)-1, 2, QTableWidgetItem(default_value))
            self.table_output.setItem(len(self.output)-1, 3, QTableWidgetItem(possible_values))
        
            # clear the input fields
            self.sortie_name.clear()
            self.sortie_default_value.clear()
            self.possible_values_2.clear()
    
    def __delete_output(self):
        items = self.table_output.selectedItems()
        if len(items)>0:
            selected_row = self.table_output.row(items[0])
            del self.output[self.table_output.item(selected_row, 0).text()]
            self.table_output.removeRow(selected_row)
            
    def __create_bloc(self):
        
        layer_name = self.bloc_name.text()
        
        # create db bloc and load it
        
        # add layer to qgis
        # Faudra tester tout ça dans un script à part je pense 
        project = QgsProject()
        project.clear()
        project.read(self.__project_filename)
        if project.readEntry('cycle', 'version', '')[0] != __version__:
            project_name = project.baseName()
            project.writeEntry('cycle', 'project', project_name)
            project.writeEntry('cycle', 'version', __version__)
            project.writeEntry('cycle', 'service', get_service())
        
        root = project.layerTreeRoot()
        
        uri = f'''dbname='{project_name}' service={get_service()} sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}" ''' + (' (geom)' if grp != tr('Settings') and layer_name!=tr('Measure') else '')
        layer = QgsVectorLayer(uri, layer_name, "postgres")
        root.addLayer(layer)
        if not layer.isValid():
                    raise RuntimeError(f'layer {layer_name} is invalid')
        
        # load qml styling file to the layer and rearrange the style with the entrees and sorties
        fields = layer.fields()
        config = layer.editFormConfig()
        config.setLayout(config.EditorLayout(1))
        tabs = config.tabs()
        input_tab = tabs[-2]
        output_tab = tabs[-1]
        idx = 0
        for field in fields:
            if field.name() in self.input:
                attrfield(field.name(), idx, input_tab) # à vérifier sur la doc si c'est bien comme ça
            elif field.name() in self.output:
                attrfield(field.name(), idx, output_tab)
            idx+=1
        
        
if __name__ == '__main__':
    app = CreateBlocWidget()