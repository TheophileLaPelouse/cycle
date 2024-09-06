"""
Main cycle menu
"""

import os
from pathlib import Path
from qgis.PyQt.QtGui import QIcon
from qgis.PyQt.QtCore import QCoreApplication
from qgis.PyQt.QtWidgets import QToolBar, QToolButton, QPushButton, QMenu, QCheckBox, QLabel, QAction
from ...project import Project
from ...qgis_utilities import QGisProjectManager
from ..forms.create_bloc_form import CreateBlocWidget
from ...database import reset_project
#from qgis.core import (
#    QgsProcessingContext,
#    QgsProcessingAlgRunnerTask,
#    QgsProcessingFeedback,
#    QgsApplication,
#)
#
# why this is here ? https://github.com/qgis/QGIS/issues/38583#issuecomment-692517863
#context = QgsProcessingContext()
#feedback = QgsProcessingFeedback()

def tr(msg):
    return QCoreApplication.translate('@default', msg)

_plugin_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, os.pardir))
_icons_dir = os.path.join(_plugin_dir, "ressources", "svg")

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

        self.__config_menu = QToolButton()
        self.__config_menu.setMenu(QMenu())
        self.__config_menu.menu().aboutToShow.connect(self.__refresh_config_menu)
        self.__config_menu.setPopupMode(QToolButton.MenuButtonPopup)
        self.__config_menu.setToolTip(self.tr("Current configuration"))

        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        self.__config_menu.setText(project.current_config or self.tr('Default'))
        
        self.__add_bloc_button = self.__add_action_button(tr('Add bloc'), 'add_bloc.svg', self.__add_bloc)
        self.__reset_db_button = self.__add_action_button(tr('Reset database'), 'reset_db.svg', self.__reset_db)

        # self.__scn_menu = QToolButton()
        # self.__scn_menu.setMenu(QMenu())
        # self.__scn_menu.menu().aboutToShow.connect(self.__refresh_scn_menu)
        # self.__scn_menu.setPopupMode(QToolButton.MenuButtonPopup)
        # self.__scn_menu.setToolTip(self.tr("Current scenario"))

        # self.__run_button = QPushButton(self.tr('Run computation'), self)
        # self.__run_button.clicked.connect(self.__run)

        # self.__postprocess = QCheckBox(self.tr('Postprocess'))
        # self.__postprocess.setChecked(False)
        # self.__postprocess.setToolTip(self.tr('If checked, post-processing is run automatically after computation, you can also check to launch post-processing for the current scenario.'))
        # self.__postprocess.toggled.connect(self.__postprocess_toggled)

        self.addWidget(QLabel(self.tr('Configuration:')))
        self.addWidget(self.__config_menu)
        self.addWidget(QLabel(self.tr('Current model:')))
        self.addWidget(self.__model_menu)
        # self.addWidget(QLabel(self.tr('Current scenario:')))
        # self.addWidget(self.__scn_menu)
        # self.addWidget(self.__run_button)
        # self.addWidget(self.__postprocess)

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

    def __refresh_config_menu(self):
        menu = self.__config_menu.menu()
        menu.clear()
        action = menu.addAction(self.tr('Default'))
        action.triggered.connect(self.__set_curent_config)
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        for config in project.configurations:
            if config != self.__config_menu.text():
                action = menu.addAction(config)
                action.triggered.connect(self.__set_curent_config)

    def __set_curent_config(self):
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        project.current_config = self.sender().text() if self.sender().text() != self.tr('Default') else None
        self.__config_menu.setText(project.current_config or self.tr('Default'))
        QGisProjectManager.refresh_layers()

    def __add_bloc(self):
        CreateBlocWidget(QGisProjectManager.project_name(), self.__log_manager)
    
    def __reset_db(self):
        reset_project(QGisProjectManager.project_name(), 2154)