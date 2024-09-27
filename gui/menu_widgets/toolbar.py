"""
Main cycle menu
"""

import os
import warnings
from pathlib import Path
from qgis.PyQt.QtGui import QIcon
from qgis.PyQt.QtCore import QCoreApplication
from qgis.PyQt.QtWidgets import QToolBar, QToolButton, QPushButton, QMenu, QCheckBox, QLabel, QAction
from qgis.utils import iface
from ...project import Project
from ...qgis_utilities import QGisProjectManager
from ..forms.create_bloc_form import CreateBlocWidget
from ..forms.add_formula import AddFormula
from ...database import reset_project
from ...compute.bloc import get_sur_blocs, get_links, Bloc
from ...utility.json_utils import save_to_json, add_dico

def tr(msg):
    return QCoreApplication.translate('@default', msg)

_plugin_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, os.pardir))
_icons_dir = os.path.join(_plugin_dir, "ressources", "svg")

def is_comitting() : 
    layer = iface.activeLayer()
    if layer and layer.editBuffer() : 
        return layer.editBuffer().isModified()
    else :
        return False

class CycleToolbar(QToolBar):
    
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

        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        
        self.__add_bloc_button = self.__add_action_button(tr('Add bloc'), 'add_bloc.svg', self.__add_bloc)
        self.__reset_db_button = self.__add_action_button(tr('Reset database'), 'reset_db.svg', self.__reset_db)
        self.__run_button = self.__add_action_button(tr('Run computation'), 'run.svg', self.__run)
        self.__add_formula_button = self.__add_action_button(tr('Add formula'), 'add_formula.svg', self.__add_formula)
        self.__add_input_button = self.__add_action_button(tr('Add input'), 'add_input.svg', self.__add_input)
        # admin buttons
        self.__print_sur_blocs_button = None
        self.__print_links_button = None
        self.__edit_bloc_button = None
        self.__from_custom_to_solid_button = None
        self.__add_admin_mode_button = self.__add_action_button(tr('Admin mode'), 'admin_mode.svg', self.__to_admin_mode)

        self.addWidget(QLabel(self.tr('Current model:')))
        self.addWidget(self.__model_menu)

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
        print("Work in progress")
    
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
        dico_sur_bloc, names, Formules, Entrees, Sorties = get_sur_blocs(project)
        links = get_links(project)
        for elem in links : 
            if links[elem] : 
                links[elem] = [names[Id] for Id in links[elem]]
        bloc = Bloc(project, model, name, True)
        bloc.add_from_sur_bloc(dico_sur_bloc, names, Formules, Entrees, Sorties, links)
        result = bloc.calculate()
        print(result)
        
    def __to_admin_mode(self) : 
        self.__print_sur_blocs_button = self.__add_action_button(tr('Print sur_blocs'), 'sur_blocs.svg', self.__print_sur_blocs)
        self.__print_links_button = self.__add_action_button(tr('Print links'), 'links.svg', self.__print_links)
        self.__from_custom_to_solid_button = self.__add_action_button(tr('From custom to solid'), 'from_custom_to_solid.svg', self.__from_custom_to_solid)
        
    def __from_custom_to_solid(self) :
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        custom_layertree = QGisProjectManager.layertree_custom(project.qgs)
        layertree = QGisProjectManager.layertree()
        new_layertree = add_dico(layertree, custom_layertree)
        save_to_json(new_layertree, os.path.join(os.path.dirname(__file__), '..', '..', 'layertree.json'))
        save_to_json(layertree, os.path.join(os.path.dirname(__file__), '..', '..', 'layertree_old.json'))