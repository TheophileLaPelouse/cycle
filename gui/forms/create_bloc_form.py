import re
import os 
from qgis.PyQt import uic 
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QGridLayout, QDialog, QWidget, QTableWidgetItem, QDialogButtonBox, QCompleter
from qgis.core import QgsAttributeEditorField as attrfield, Qgis, QgsProject, QgsVectorLayer, QgsDefaultValue
from ...service import get_service
from ...database.version import __version__
from ...database.create_bloc import write_sql_bloc, load_custom
from ...qgis_utilities import tr
from ...project import Project
from ...utility.json_utils import open_json, get_propertie, save_to_json

Formules_de_base = ['CO2 = CO2']
Input_de_base = {'co2' : 'real'}

class CreateBlocWidget(QDialog):
    
    def __init__(self, project_name, log_manager, parent=None):
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "create_bloc.ui"), self)
        
        self.__log_manager = log_manager
        self.__project = Project(project_name, self.__log_manager)
        self.__project_name = project_name
        
        self.geom.addItems(['Point', 'LineString', 'Polygon'])
        types = ['real', 'integer', 'string', 'list'] # On pourra ajouter les types de la base de donnée aussi       
        self.entree_type.addItems(types)
        # 2 = output
        self.sortie_type.addItems(types)
        self.possible_values.setEnabled(False)
        self.possible_values_2.setEnabled(False)
        
        self.input = Input_de_base
        self.output = {}
        self.formula = Formules_de_base
        self.formula_description = {}
        self.default_values = {}
        self.possible_values = {}
        
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
        self.warning_formula.setText('Enter the formula in the form of "A = B [+-*/^] 10*C==\'elem of list\' ..." \n where A, B, C are the names of the input or output')
        self.delete_formula.clicked.connect(self.__delete_formula)
        self.completer_list = list(self.input.keys()) + list(self.output.keys())
        self.completer = WordCompleter(self.completer_list)
        self.formula_text.setCompleter(self.completer)
        self.completer.setFilterMode(Qt.MatchContains)
        
        
        # Ok button
        self.bloc_name.textChanged.connect(self.enable_ok_button)
        self.ok_button = self.buttons.button(QDialogButtonBox.Ok)
        self.ok_button.setEnabled(False)   
        self.ok_button.clicked.connect(self.__create_bloc)
        
        self.exec_()
    
    def __add_formula(self):
        formula = self.formula_text.text()
        if self.verify_formula(formula):
            self.table_formula.setRowCount(len(self.formula))
            self.table_formula.setItem(len(self.formula)-1, 0, QTableWidgetItem(formula))
            self.table_formula.setItem(len(self.formula)-1, 1, QTableWidgetItem(self.description.text()))
            self.formula.append(formula)
            self.formula_description[formula] = [self.description.text(), self.comment.text()]
            self.formula_text.clear()
            self.description.clear()
            self.comment.clear()
    
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
        default_value = self.entree_default_value.text()
        if self.entree_type.currentText() == 'list':
            possible_values = self.possible_values.text()
            self.possible_values[name] = possible_values
        else : possible_values = ''
        name, type_, default_value, possible_values, verified = self.verify_input(name, type_, default_value, possible_values)
        if verified:
            self.completer_list.append(name)
            self.completer.update_words(self.completer_list)
            self.input[name] = type_
            self.default_values[name] = default_value
            self.possible_values[name] = possible_values
            
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
        # Faudra vérifier le format des données rentrées pour éviter tout problème 
        return name.strip().lower(), type_, default_value, possible_values, True
    
    
    def __delete_input(self):
        items = self.table_input.selectedItems()
        if len(items)>0:
            selected_row = self.table_input.row(items[0])
            del self.input[self.table_input.item(selected_row, 0).text()]
            self.completer_list.remove(self.table_input.item(selected_row, 0).text())
            self.completer.update_words(self.completer_list)
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
        self.output[name.strip.lower()] = type_
        default_value = self.sortie_default_value.text()
        if self.sortie_type.currentText() == 'list':
            possible_values = self.possible_values_2.text()
        else : possible_values = ''
        name, type_, default_value, possible_values, verified = self.verify_input(name, type_, default_value, possible_values)
        if verified:
            self.completer_list.append(name)
            self.completer.update_words(self.completer_list)
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
            self.completer_list.remove(self.table_output.item(selected_row, 0).text())
            self.completer.update_words(self.completer_list)
            self.table_output.removeRow(selected_row)
    
    def enable_ok_button(self) : 
        bloc_name = self.bloc_name.text()
        bloc_exists = self.__project.fetchone(f"select exists(select 1 from information_schema.tables where table_name='{bloc_name}_bloc' and table_schema='api')")
        if bloc_exists[0]:
            self.warning_bloc.setText('This bloc already exists')
            self.warning_bloc.setStyleSheet("color: red")
            self.ok_button.setEnabled(False)    
        elif bloc_name != '' : 
            self.warning_bloc.clear()
            self.ok_button.setEnabled(True)
        elif bloc_name == '' : 
            self.warning_bloc.setText('Enter a name for the bloc')
            self.warning_bloc.setStyleSheet("color: orange")
            self.ok_button.setEnabled(False)
      
          
    def normalize_name(self, name):
        # Faudra normaliser le nom pour éviter les problèmes
        char_to_remove = ["'", '"', '(', ')', '[', ']', '{', '}', '<', '>', '!', '?', '.', ',', ';', ':', '/', '\\', '|', '@', '#', '$', '%', '^', '&', '*', '+', '=', '~', '`']
        #return name.lower().replace(' ', '_').translate(None, ''.join(char_to_remove))
        rx = '[' + re.escape(''.join(char_to_remove)) + ']'
        return re.sub(rx, '', name).strip().lower().replace(' ', '_')
    
    def __create_bloc(self):
        # Pour que ce soit plus jolie faudra différencier layer_name et layer_name_bloc.
        self.default_values['shape'] = self.geom.currentText()
        
        layer_name = self.bloc_name.text()
        
        norm_name = self.normalize_name(self.bloc_name.text())
        
        # create db bloc and load it
        
        query = write_sql_bloc(self.__project_name, layer_name, self.geom.currentText(), self.input, self.output, self.default_values, 
                       self.possible_values, f'{norm_name}_bloc', self.formula, self.formula_description)
        print("bonjour1")
        load_custom(self.__project_name, query=query)
        print("bonjour 2")
        
        # add layer to qgis
        # Faudra tester tout ça dans un script à part je pense 
        project = QgsProject.instance()
        root = project.layerTreeRoot()
        
        grp_path = self.group.text()
        grps = grp_path.split('/')
        grp = ''
        while grp == '' and grps:
            grp = grps.pop(-1)
        
        if grps : root = root.findGroup(grps[-1]) 
        
        if grp == '' : g = root
        else : g = root.findGroup(grp) or root.insertGroup(0, grp) # On changera sûrement l'index plus tard
        
        sch, tbl, key = "api", f'{norm_name}_bloc', 'name'
        uri = f'''dbname='{self.__project_name}' service={get_service()} sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}" ''' + (' (geom)' if grp != tr('Settings') and layer_name!=tr('Measure') else '')
        print(uri)
        layer = QgsVectorLayer(uri, layer_name, "postgres")
        project.addMapLayer(layer, False)
        g.addLayer(layer)
        if not layer.isValid():
            raise RuntimeError(f'layer {layer_name} is invalid')
        
        # load qml styling file to the layer and rearrange the style with the entrees and sorties
        qml_dir = os.path.join(os.path.dirname(__file__), '..', '..', 'ressources', 'qml')
        if self.geom.currentText() == 'Point':
            qml_file = os.path.join(qml_dir, 'point.qml')
        elif self.geom.currentText() == 'LineString':
            qml_file = os.path.join(qml_dir, 'linestring.qml')
        elif self.geom.currentText() == 'Polygon':
            qml_file = os.path.join(qml_dir, 'polygon.qml')

        layer.loadNamedStyle(qml_file)
        
        fields = layer.fields()
        config = layer.editFormConfig()
        config.setLayout(config.EditorLayout(1))
        tabs = config.tabs()
        input_tab = tabs[-2]
        output_tab = tabs[-1]
        idx = 0
        for field in fields:
            defval = QgsDefaultValue()
            fieldname = field.name()
            default_query = self.__project.fetchone(f"select column_default from information_schema.columns where table_schema='api' and table_name='{layer_name}_bloc' and column_name='{fieldname}';")
            print(default_query)
            default = self.__project.fetchone('select ' + str(default_query[0])) if default_query[0] else [None]
            # Amélioration possible tout faire dans une seule query
            defval.setExpression(str(default[0]))
            if fieldname.strip().lower() == 'model' : 
                defval.setExpression('@current_model')
            layer.setDefaultValueDefinition(idx, defval)
            if fieldname.strip().lower() in self.input:
                input_tab.addChildElement(attrfield(field.name(), idx, input_tab)) # à vérifier sur la doc si c'est bien comme ça
            elif fieldname.strip().lower() in self.output:
                output_tab.addChildElement(attrfield(field.name(), idx, output_tab))
            idx+=1
        layer.setEditFormConfig(config)
        
        custom_qml_dir = os.path.join(self.__project.directory, 'qml')
        if not os.path.exists(custom_qml_dir):
            os.makedirs(custom_qml_dir)
        qml_path = os.path.join(custom_qml_dir, f'{norm_name}_bloc.qml')
        # Faudra vérifier que les noms sont cohérents avec qgies utilities 
        layer.saveNamedStyle(qml_path)
        
        # add bloc in the custom layertree json
        path_layertree = os.path.join(self.__project.directory, 'layertree_custom.json')
        try :
            layertree = open_json(path_layertree)
        except FileNotFoundError : 
            layertree = {}

        branch = get_propertie(grp, layertree)
        if not branch:
            branch = layertree
            grp_final = grp
            for grp in grps:
                try : 
                    branch = branch[grp]
                except KeyError :
                    branch[grp] = {}
            branch[grp_final] = {"bloc" : [layer_name, "api", f'{norm_name}_bloc', "name"]}
        else:
            branch[layer_name] = {'bloc' : [layer_name, "api", f'{norm_name}_bloc', "name"]}
        
        save_to_json(layertree, path_layertree)
        # Faudra vérifier qu'il ne se passe pas de dingz avec le fait que le json soit pas le même que l'autre non custom.
        
        self.__log_manager.notice(f"bloc {layer_name} created")
        
class WordCompleter(QCompleter):
    def __init__(self, words, parent=None):
        super().__init__(words, parent)
        self.setFilterMode(Qt.MatchContains)
        self.setCompletionMode(QCompleter.PopupCompletion)
        self.pattern = '[' + re.escape('+-/*^= ()') + ']'
        self.mod = self.model()

    def splitPath(self, path):
        # Split the input text into words
        return [re.split(self.pattern, path)[-1]]

    def pathFromIndex(self, index):
        # Get the current text from the widget
        current_text = self.widget().text()
        # Split the current text into words
        last = re.split(self.pattern, current_text)[-1]
        if len(current_text) > len(last) + 1: 
            symbol = current_text[-len(last)-1]
        else : 
            symbol = ''
        # Replace the last word with the completion
        new_last = index.data()
        # Join the words back into a single string
        if len(current_text) > len(last) + 1:
            return current_text[:-len(last)-1] + symbol + new_last
        else :
            return new_last
        
    def update_words(self, new_words):
        # Update the model with the new list of words
        self.mod.setStringList(new_words)
        self.setModel(self.mod)
                
if __name__ == '__main__':
    app = CreateBlocWidget()