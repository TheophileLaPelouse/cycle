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
        
        self.ok_button = self.buttons.button(QDialogButtonBox.Ok)
        self.ok_button.setEnabled(False)
        self.ok_button.clicked.connect(self.__edit_bloc)
        
        b_types = self.__project.fetchall("select b_type from api.input_output group by b_type")
        b_types = [b_type[0] for b_type in b_types]
        self.bloc_select.addItems([''] + b_types)
        self.bloc_select.currentIndexChanged.connect(self.__bloc_changed)
        
        self.input_i = {}
        self.output_i = {}
        
        
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
        return normalized_name(name).strip(), type_, default_value, possible_values, True
    
    def __bloc_changed(self) : 
        b_type = self.bloc_select.currentText()
        query = """
        with inp_out as (select input, output from api.input_output where b_type = '{b_type}')
        select 
        """
        values = self.__project.execute(query)