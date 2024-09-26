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

class AddFormula(QDialog) : 
    def __init__(self, project_name, log_manager, parent = None) : 
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "add_formula.ui"), self)
        
        self.__log_manager = log_manager
        self.__project = Project(project_name, self.__log_manager)
        self.__project_name = project_name
        self.__qgs_project = QgsProject.instance()
        
        self.f_list = [] # servira pour faire le compléteur de description quand on le fera 
        self.completer_list = []
        
        self.add_formula.clicked.connect(self.__add_formula)
        self.warning_formula.setStyleSheet("color: orange")
        self.warning_formula.setText('Enter the formula in the form of "A = B [+-*/^] 10*C==\'elem of list\' ..." \n where A, B, C are the names of the input or output')
        self.completer = FormulaCompleter(self.completer_list)
        self.formula_text.setCompleter(self.completer)
        self.completer.setFilterMode(Qt.MatchContains)
        self.description.textChanged.connect(self.__named)
        
        layerlist = ['']+[layer.name() for layer in iface.mapCanvas().layers()]
        self.combobloc.addItems(layerlist)
        self.combobloc.setEditText('')
        self.combobloc.currentIndexChanged.connect(self.__layer_changed)
        self.add_formula.setEnabled(False)
        self.warning_formula.setText('Select a bloc')
        self.description.setEnabled(False)
        self.formula_text.setEnabled(False)
        self.detail_level.setEnabled(False)
        
        self.exec_()
        
    def __add_formula(self) : 
        formula = self.formula_text.text()
        description = self.description.text()
        detail = self.detail_level.value()
        comment = self.comment.toPlainText()
        layer = self.combobloc.currentText()
        b_type = normalized_name(layer)
        
        query = f"select api.add_new_formula('{description}'::varchar, '{formula}'::varchar, {detail}, '{comment}'::text) ;\n"
        self.__project.execute(query)
        query = f"update api.input_output set default_formulas = array_append(default_formulas, '{description}') where b_type = '{b_type}' ;"
        self.__project.execute(query)      
        
        self.__log_manager.notice('formula %s added' % description)
        # Faudra qu'on regarde si on peut savoir si la formula à bien été ajoutée
        
        self.close()
        
        # self.formula_text.clear()  
        # self.description.clear()
        # self.comment.clear()
        # self.add_formula.setEnabled(False)
        
        
        
    
    def __named(self) : 
        if self.description.text() and self.combobloc.currentText() :
            self.add_formula.setEnabled(True)
    
    def __layer_changed(self) :
        layer = self.combobloc.currentText()
        if layer : 
            if self.description.text() : 
                self.add_formula.setEnabled(True)
            self.warning_formula.setStyleSheet("color: orange")
            self.warning_formula.setText('Enter the formula in the form of "A = B [+-*/^] 10*C==\'elem of list\' ..." \n where A, B, C are the names of the input or output')
            self.description.setEnabled(True)
            self.formula_text.setEnabled(True)
            self.detail_level.setEnabled(True)
            
            
            b_type = normalized_name(layer)
            input = []
            output = []
            try : 
                inp_out = self.__project.fetchone(f"select inputs, outputs, default_formulas from api.input_output where b_type = '{b_type}'")
                print("bonjour", inp_out)
                input = list(inp_out[0])
                output = list(inp_out[1])
                self.f_list = list(inp_out[2])
            except :
                pass
            
            self.completer_list = input + output
            print(self.completer_list)
            self.completer.update_words(self.completer_list)
            
        else : 
            self.add_formula.setEnabled(False)
            self.warning_formula.setText('Select a bloc')
            self.description.setEnabled(False)
            self.formula_text.setEnabled(False)
            self.detail_level.setEnabled(False)