"""
Main cycle menu
"""

import os
import warnings
from pathlib import Path
import qgis
from qgis.PyQt.QtGui import QIcon
from qgis.PyQt.QtCore import QCoreApplication, pyqtSignal
from qgis.PyQt.QtWidgets import QToolBar, QToolButton, QPushButton, QMenu, QCheckBox, QLabel, QAction, QLineEdit, QDockWidget, QWidget, QSizePolicy, QComboBox
from qgis.utils import iface
from qgis.core import QgsProject, QgsVectorLayer
from ...project import Project
from .results import AllResults
from ...qgis_utilities import QGisProjectManager
from ..forms.create_bloc_form import CreateBlocWidget
from ..forms.add_formula import AddFormula
from ..forms.edit_input import EditInputOutput
from ...database import reset_project
from ...database.create_bloc import from_custom_to_main
from ...compute.bloc import get_sur_blocs, get_links, Bloc
from ...utility.json_utils import save_to_json, add_dico
import time 

def tr(msg):
    return QCoreApplication.translate('@default', msg)

_plugin_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, os.pardir))
_icons_dir = os.path.join(_plugin_dir, "ressources", "svg")

def is_comitting() : 
    project = QgsProject.instance()
    layers = project.mapLayers()
    flag = False 
    for layer in layers.values() :
        if layer and isinstance(layer, QgsVectorLayer) and layer.editBuffer() : 
            flag = layer.editBuffer().isModified()
            if flag :
                break
    return flag
class CycleToolbar(QToolBar):
    model_updated = pyqtSignal(str)
    
    def __add_action_button(self, name, icon, action, togglable = False):
        action_button = QAction(QIcon(os.path.join(_icons_dir, icon)), tr(name), self)
        action_button.triggered.connect(action)
        self.addAction(action_button)
        action_button.setCheckable(togglable)
        return action_button
    
    def __init__(self, log_manager, parent=None):
        QToolBar.__init__(self, tr("Cycle toolbar"), parent)
        self.__parent = parent
        self.__log_manager = log_manager

        self.__model_menu = QToolButton()
        self.__model_menu.setMenu(QMenu())
        self.__model_menu.menu().aboutToShow.connect(self.__refresh_model_menu)
        self.__model_menu.setPopupMode(QToolButton.MenuButtonPopup)
        self.__model_menu.setToolTip(self.tr("Current model"))
        self.res_widget = None
        
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        self.addWidget(QLabel(self.tr('Edition blocs')))
        self.__add_bloc_button = self.__add_action_button(tr('Ajouter un bloc'), 'add_bloc.svg', self.__add_bloc)
        # self.__run_button = self.__add_action_button(tr('Run computation'), 'run.svg', self.__run)
        self.__add_formula_button = self.__add_action_button(tr('Ajouter une formule'), 'add_formula.svg', self.__add_formula)
        self.__add_input_button = self.__add_action_button(tr('Edition bloc'), 'add_input.svg', self.__add_input)
        self.addSeparator()
        
        self.spacer = QLabel('')
        self.spacer.setFixedWidth(10)
        self.addWidget(self.spacer)
            
        # self.addWidget(QLabel(self.tr('Propriétés du modèle')))
        self.addWidget(QLabel(self.tr('Modèle courant')))
        self.addWidget(self.__model_menu)
        self.spacer4 = QLabel('')
        self.spacer4.setFixedWidth(5)
        self.addWidget(self.spacer4)
        self.addWidget(QLabel(self.tr("Temps d'étude")))
        self.study_time = QLineEdit()
        self.study_time.setFixedWidth(30)
        self.addWidget(self.study_time)
        self.addWidget(QLabel(self.tr("ans")))
        
        self.study_time.setText('1')
        self.study_time.textChanged.connect(self.__set_study_time)
        
        self.spacer2 = QLabel('')
        self.spacer2.setFixedWidth(10)
        self.addWidget(self.spacer2)
        self.addSeparator()
        self.spacer3 = QLabel('')
        self.spacer3.setFixedWidth(10)
        self.addWidget(self.spacer3)
        
        self.addWidget(QLabel(self.tr('Résultats')))
        self.__add_resume_result_dock_button = self.__add_action_button(tr('Résumer résultats'), 'resume_results.svg', self.__add_resume_result_dock)
        self.__show_all_results_button = self.__add_action_button(tr('Afficher tous les résultats'), 'show_all_results.svg', self.__show_all_results)
        self.addSeparator()
        self.spacer6 = QLabel('')
        self.spacer6.setFixedWidth(10)
        self.addWidget(self.spacer6)
        
        
        self.addWidget(QLabel(self.tr("Taille des blocs")))
        self.combo_scale = QComboBox()
        self.combo_scale.setEditable(True)  # Make the combo box editable
        self.combo_scale.addItems(["1:500", "1:1000", "1:2500", "1:5000", "1:10000", "1:25000", "1:50000", "1:100000"])  # Add some default values
        self.combo_scale.setCurrentIndex(2)
        self.__zoom_to_scale()
        self.combo_scale.currentTextChanged.connect(self.__zoom_to_scale)
        self.addWidget(self.combo_scale)
        
        self.spacer5 = QLabel('')
        self.spacer5.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Preferred)
        self.addWidget(self.spacer5)
        # admin buttons
        self.__reset_db_button = None
        self.__print_sur_blocs_button = None
        self.__print_links_button = None
        self.__edit_bloc_button = None
        self.__from_custom_to_solid_button = None
        self.__add_admin_mode_button = self.__add_action_button(tr('Admin mode'), 'admin_mode.svg', self.__to_admin_mode)

        # self.addWidget(QLabel(self.tr('Current model:')))
        # self.addWidget(self.__model_menu)

        # self.__model
        
        self.variables_changed()
        self.__log_manager.notice(self.tr("toolbar created"))

    def variables_changed(self):
        # project = Project(QGisProjectManager.project_name(), self.__log_manager)
        self.__model_menu.setText(QGisProjectManager.get_qgis_variable('current_model') or '')

    def __refresh_model_menu(self):
        menu = self.__model_menu.menu()
        menu.clear()
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        for model in project.models:
            if model != self.__model_menu.text():
                action = menu.addAction(model)
                action.triggered.connect(self.__set_curent_model)

    def __set_curent_model(self):
        QGisProjectManager.set_qgis_variable('current_model', self.sender().text() or '')
        # self.model_updated.emit("")
        
    def __add_bloc(self):
        if is_comitting() : 
            warnings.warn("You must save your edits before adding a bloc")
            return
        CreateBlocWidget(QGisProjectManager.project_name(), self.__log_manager)
    
    def __add_formula(self):
        if is_comitting() : 
            warnings.warn("You must save your edits before adding a formula")
            return
        AddFormula(QGisProjectManager.project_name(), self.__log_manager)
    
    def __add_input(self) : 
        if is_comitting() : 
            warnings.warn("You must save your edits before adding an input")
            return
        EditInputOutput(QGisProjectManager.project_name(), self.__log_manager)
    
    def __reset_db(self):
        reset_project(QGisProjectManager.project_name(), 2154)
    
    def __print_sur_blocs(self):
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        print("bonjour")
        print(get_sur_blocs(project))
        
    def __print_links(self):
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        print(get_links(project))
        
    def __run(self) : 
        if is_comitting() : 
            warnings.warn("You have not saved your edits")
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        model = project.current_model
        name = QGisProjectManager.project_name()
        tic = time.time()
        dico_sur_bloc, names, Formules, Entrees, Sorties = get_sur_blocs(project)
        links = get_links(project)
        tac = time.time()
        print("get db", tac-tic)
        for elem in links : 
            if links[elem] : 
                links[elem] = [names[Id] for Id in links[elem]]
        bloc = Bloc(project, model, name, True)
        bloc.add_from_sur_bloc(dico_sur_bloc, names, Formules, Entrees, Sorties, links)
        tic = time.time()
        print("add from sur_bloc", tic-tac)
        result = bloc.calculate()
        tac = time.time()
        # print(result)
        print("calculate", tac-tic)
        bloc.show_results()
        tic = time.time()
        print("show results", tic-tac)
        
    def __to_admin_mode(self) : 
        # self.__print_sur_blocs_button = self.__add_action_button(tr('Print sur_blocs'), 'sur_blocs.svg', self.__print_sur_blocs)
        # self.__print_links_button = self.__add_action_button(tr('Print links'), 'links.svg', self.__print_links)
        self.__from_custom_to_solid_button = self.__add_action_button(tr('From custom to solid'), 'from_custom_to_solid.svg', self.__from_custom_to_solid)
        self.__save_properties_button = self.__add_action_button(tr('Save properties'), 'save_properties.svg', self.__save_properties)
        self.__reset_db_button = self.__add_action_button(tr('Reset database'), 'reset_db.svg', self.__reset_db)
    
    def __save_properties(self) : 
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        custom_sql = os.path.join(project.directory, 'custom_blocs.sql') 
        type_tables = project.fetchall("select table_name from information_schema.tables where table_schema = 'api' and table_name like '%_type_table';")
        for table in type_tables :
            table = table[0]
            val_descr = project.fetchall(f"select * from api.{table};") #val, fe, description
            with open(custom_sql, 'a') as f :
                for val in val_descr :
                    f.write(f"update api.{table} set description = '{val[2] if val[2] else ''}', fe = {val[1]} where val = '{val[0]}';\n")
        print("done")
        
        
    def __from_custom_to_solid(self) :
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        custom_layertree = QGisProjectManager.layertree_custom(project.qgs)
        layertree = QGisProjectManager.layertree()
        new_layertree = add_dico(layertree, custom_layertree)
        # properties = new_layertree['Properties']
        # import json 
        # print(json.dumps(new_layertree, indent=4))
        # properties_custom = custom_layertree['Properties']
        # for key in properties_custom :
        #     if key.endswith('__ref') : 
        #         properties[key] += properties_custom[key] 
        
        if os.path.exists(os.path.join(os.path.dirname(__file__), '..', '..', 'layertree_old.json')):
            os.remove(os.path.join(os.path.dirname(__file__), '..', '..', 'layertree_old.json'))
        os.rename(os.path.join(os.path.dirname(__file__), '..', '..', 'layertree.json'), os.path.join(os.path.dirname(__file__), '..', '..', 'layertree_old.json'))
        save_to_json(new_layertree, os.path.join(os.path.dirname(__file__), '..', '..', 'layertree.json'))
        
        QGisProjectManager.save_qml2ressource(QgsProject.instance(), new_layertree)
        from_custom_to_main(QGisProjectManager.project_name())
        self.__log_manager.notice(tr("Les blocs personnalisés ont été sauvegardés définitivement"))

    def __set_study_time(self) :
        # self.__log_manager.notice(tr("Temps d'étude fixé à") + self.study_time.text()+", lol en fait non")
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        project.execute(f"update ___.global_values set val = {self.study_time.text()} where name = 'study_time';")
        
    def __add_resume_result_dock(self) : 
        rr = iface.mainWindow().findChildren(QDockWidget, "resume_result")
        if rr : 
            rr = rr[-1]
            rr.show()
    
    def __show_all_results(self) :
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        self.res_widget and self.res_widget.setParent(None)
        self.res_widget = AllResults(project, self.parent())
        self.res_widget.show()
        
    def __zoom_to_scale(self) :
        layers = iface.mapCanvas().layers()
        print("Bonjour")
        for layer in layers : 
            
            if isinstance(layer, qgis._core.QgsVectorLayer) and int(layer.geometryType()) in (0,1,2) : # Si la couche et vectorielle et c'est un point 
                print(layer.name())
                print(layer.renderer().referenceScale())
                r = layer.renderer()
                r.setReferenceScale(float(self.combo_scale.currentText().split(':')[1]))
                layer.setRenderer(r)
                layer.triggerRepaint()