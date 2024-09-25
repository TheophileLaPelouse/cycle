import re
import os 
from qgis.PyQt import uic 
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QGridLayout, QDialog, QWidget, QTableWidgetItem, QDialogButtonBox, QCompleter
from qgis.core import QgsAttributeEditorField as attrfield, Qgis, QgsProject, QgsVectorLayer, QgsDefaultValue, QgsAttributeEditorContainer, QgsRelation, QgsRelationContext
from ...service import get_service
from ...database.version import __version__
from ...database.create_bloc import write_sql_bloc, load_custom
from ...qgis_utilities import tr
from ...project import Project
from ...utility.json_utils import open_json, get_propertie, save_to_json

Formules_de_base = []
Input_de_base = {}
_custom_qml_dir = os.path.join(os.path.expanduser('~'), '.cycle', 'qml')
if not os.path.exists(_custom_qml_dir):
    os.makedirs(_custom_qml_dir)

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
        self.possible_values_text.setEnabled(False)
        self.possible_values_text2.setEnabled(False)
        
        self.input = {key : Input_de_base[key] for key in Input_de_base}
        self.output = {}
        self.formula = Formules_de_base[:]
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
        
        # Group line edit
        path_layertree = os.path.join(self.__project.directory, 'layertree_custom.json')
        try :
            layertree = open_json(path_layertree)
            self.group_completer = GrpCompleter(list(layertree.keys()), layertree)
            self.group.setCompleter(self.group_completer)
            self.group.textChanged.connect(lambda : self.group_completer.update_completions(self.group.text()))
        except FileNotFoundError : 
            pass
        
        
        # Ok button
        self.bloc_name.textChanged.connect(self.enable_ok_button)
        self.ok_button = self.buttons.button(QDialogButtonBox.Ok)
        self.ok_button.setEnabled(False)   
        self.ok_button.clicked.connect(self.__create_bloc)
        print(self.__dict__)
        self.exec_()
    
    def __add_formula(self):
        formula = self.formula_text.text()
        description = self.description.text()
        detail = self.detail_level.value()
        if self.verify_formula(formula):
            self.formula.append(formula)
            self.formula_description[formula] = [self.description.text(), self.comment.toPlainText(), detail]
            self.table_formula.setRowCount(len(self.formula))
            print(formula, description)
            self.table_formula.setItem(len(self.formula)-1, 0, QTableWidgetItem(formula))
            self.table_formula.setItem(len(self.formula)-1, 1, QTableWidgetItem(str(detail)))
            self.table_formula.setItem(len(self.formula)-1, 2, QTableWidgetItem(description))
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
            self.completer_list.append(name)
            self.completer.update_words(self.completer_list)
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
    
    def verify_input(self, name, type_, default_value, possible_values):
        # Faudra vérifier le format des données rentrées pour éviter tout problème 
        if possible_values :
            possible_values = possible_values.split(';')
            possible_values = [value.strip() for value in possible_values]
        return name.lower().strip(), type_, default_value, possible_values, True
    
    
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
            self.completer_list.append(name)
            self.completer.update_words(self.completer_list)
            
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
        #return name.replace(' ', '_').translate(None, ''.join(char_to_remove))
        rx = '[' + re.escape(''.join(char_to_remove)) + ']'
        return re.sub(rx, '', name).strip().replace(' ', '_')
    
    def __create_bloc(self):
        # Pour que ce soit plus jolie faudra différencier layer_name et layer_name_bloc.
        self.default_values['shape'] = self.geom.currentText()
        
        layer_name = self.bloc_name.text()
        
        norm_name = self.normalize_name(self.bloc_name.text())
        
        # create db bloc and load it
        
        query = write_sql_bloc(self.__project_name, norm_name, self.geom.currentText(), self.input, self.output, self.default_values, 
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
        uri = f'''dbname='{self.__project_name}' service={get_service()} sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}" ''' + ' (geom)'
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
        default_values = self.__project.fetchone(f"select jsonb_object_agg(column_name, column_default) from information_schema.columns where table_schema='api' and table_name='{norm_name}_bloc'")[0]
        dico_ref = {}
        for field in fields:
            defval = QgsDefaultValue()
            fieldname = field.name()
            if fieldname.strip() == 'model' : 
                defval.setExpression('@current_model')
                layer.setDefaultValueDefinition(idx, defval) 
                
            if fieldname.strip() in self.input:
                if fieldname.strip() in self.possible_values and self.possible_values[fieldname.strip()]:
                    dico_ref[fieldname] = self.add_list_container(layer, input_tab, fieldname, idx, fields, default_values)
                else :
                    input_tab.addChildElement(attrfield(field.name(), idx, input_tab)) # à vérifier sur la doc si c'est bien comme ça
            elif fieldname.strip() in self.output :
                if fieldname.strip() in self.possible_values and self.possible_values[fieldname.strip()]:
                    dico_ref[fieldname] = self.add_list_container(layer, output_tab, fieldname, idx, fields, default_values)
                else : 
                    print("on y passe ?")
                    output_tab.addChildElement(attrfield(field.name(), idx, output_tab))
            idx+=1
        layer.setEditFormConfig(config)
        
        qml_path = os.path.join(_custom_qml_dir, f'{norm_name}_bloc.qml')
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
            if not branch.get(grp_final):
                branch[grp_final] = {}
            branch[grp_final][layer_name] = {"bloc" : [layer_name, "api", f'{norm_name}_bloc', "name"]}
        else:
            branch[layer_name] = {'bloc' : [layer_name, "api", f'{norm_name}_bloc', "name"]}
        
        if not layertree.get('Properties'):
            layertree['Properties'] = {}
        for fieldname in dico_ref:
            layertree['Properties'][fieldname] = dico_ref[fieldname][0]
            layertree['Properties'][fieldname+'__ref'] = dico_ref[fieldname][1]
        save_to_json(layertree, path_layertree)
        # Faudra vérifier qu'il ne se passe pas de dingz avec le fait que le json soit pas le même que l'autre non custom.
        
        self.__log_manager.notice(f"bloc {layer_name} created")
        
    def add_list_container(self, layer, tab, fieldname, idx, fields, default_values):
        # Create the container in the attribute form
        container = QgsAttributeEditorContainer(fieldname.upper(), tab)
        container.setColumnCount(2)
        container.addChildElement(attrfield(fieldname, idx, container))
        container.addChildElement(attrfield(fieldname+"_fe", fields.indexOf(fieldname+"_fe"), container))
        defval = QgsDefaultValue()
        default = self.__project.fetchone(f"select {default_values[fieldname]}") 
        if default : default = default[0]
        defval.setExpression(str(default))
        layer.setDefaultValueDefinition(idx, defval) 
        # The first part will be saved in the qml file
        
        # Add the propertie layer to the project 
        project = QgsProject.instance()
        root = project.layerTreeRoot()
        g = root.findGroup('Properties') or root.insertGroup(-1, 'Properties')
        
        sch, tbl, key = "api", f'{fieldname}_type_table', 'val'
        layer_name = f'{fieldname}'
        uri = f'''dbname='{self.__project_name}' service={get_service()} sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}" '''
        prop_layer = QgsVectorLayer(uri, layer_name, "postgres")
        prop_layer.setDisplayExpression('val')
        project.addMapLayer(prop_layer, False)
        g.addLayer(prop_layer)
        if not prop_layer.isValid():
            raise RuntimeError(f'layer {layer_name} is invalid')
        
        default_fe = f"attribute(get_feature(layer:='{prop_layer.id()}', attribute:='val', value:=coalesce(\"{fieldname}\", '{default}')), 'fe')"
        defval.setExpression(default_fe)
        defval.setApplyOnUpdate(True)
        layer.setDefaultValueDefinition(fields.indexOf(fieldname+"_fe"), defval) # saved in the qml file
        
        tab.addChildElement(container)
        name = 'ref_' + fieldname
        referencedLayer, referencedField = prop_layer.id(), 'val'
        referencingLayer, referencingField = layer.id(), fieldname
        relation = QgsRelation(QgsRelationContext(project))
        relation.setName(name)
        relation.setReferencedLayer(referencedLayer)
        relation.setReferencingLayer(referencingLayer)
        relation.addFieldPair(referencingField, referencedField)
        relation.setStrength(QgsRelation.Association)
        relation.updateRelationStatus()
        relation.generateId()
        # assert(relation.isValid())
        project.relationManager().addRelation(relation)
        
        return ([prop_layer.name(), sch, tbl, key], [name, 'val', layer.name(), referencingField])
        
        
            
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

class GrpCompleter(QCompleter):
    def __init__(self, words, layertree, parent=None):
        print("init", words)
        super().__init__(words, parent)
        self.layertree = layertree
        self.setFilterMode(Qt.MatchContains)
        self.setCompletionMode(QCompleter.PopupCompletion)
        self.mod = self.model()
        self.mod.setStringList(words)
        self.setModel(self.mod)
            
    def splitPath(self, path):
        print("split", path)
        print(self.model().stringList())
        return path.split('/')
    
    def pathFromIndex(self, index) :
        current_text = self.widget().text()
        parts = current_text.split('/')
        completed = index.data()
        if len(parts) > 1:
            return '/'.join(parts[:-1]) + '/' + completed
        else:
            return completed
        
    def update_completions(self, path):
        parts = path.split('/')
        if len(parts) > 1:
            branch = get_propertie(parts[-2], self.layertree)
            if isinstance(branch, dict):
                completions = list(branch.keys())
            else:
                completions = []
            self.mod.setStringList(completions)
            print("bonjour", completions)


if __name__ == '__main__':
    app = CreateBlocWidget()