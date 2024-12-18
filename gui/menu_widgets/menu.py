
"""
Main cycle menu
"""

import os
import webbrowser
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QIcon, QFont
from qgis.PyQt.QtWidgets import QMenu, QFileDialog, QMessageBox, QInputDialog
from ...project import Project
from ...qgis_utilities import QGisProjectManager
from ...database import get_projects_list
from .project_manager import ProjectManager
from .results import AllResults
from .new_project_dialog import NewProjectDialog
from .new_model_dialog import NewModelDialog
#from .scenario_manager import ScenarioManager pour plus tard les scénarios
from qgis.PyQt.QtGui import QIcon, QPixmap
from qgis.core import QgsProject, QgsRasterLayer

_current_dir = os.path.dirname(__file__)

class CycleMenu(QMenu):
    def __init__(self, log_manager, parent=None):
        QMenu.__init__(self, "&Lieges", parent)
        self.__log_manager = log_manager
        self.setIcon(QIcon(os.path.join(_current_dir, '..', 'ressources', 'images', 'cycle_logo.png')))
        self.aboutToShow.connect(self.__refresh)
        # self.__refresh()
        self.pm = None
        self.res_widget = None

    def __refresh(self):
        self.clear()
        self.addAction(self.tr("&Gérer les projets")).triggered.connect(self.__manage_projects)
        self.addAction(self.tr("&Nouveau Projet")).triggered.connect(self.__project_new)

        if QGisProjectManager.project_name() != '':
            project = Project(QGisProjectManager.project_name(), self.__log_manager)
            current_model = QGisProjectManager.get_qgis_variable('current_model')

            '''returns the model menu, creates it if needed'''
            model_menu = self.addMenu(self.tr("&Scenario"))
            set_current_menu = model_menu.addMenu(self.tr("&Sélectionner scénario courant"))
            for model in project.models:
                action = set_current_menu.addAction(model)
                action.triggered.connect(self.__set_current_model)
                if model == current_model:
                    f = action.font()
                    f.setBold(True)
                    action.setFont(f);

            model_menu.addAction(self.tr("&Ajouter scénario")).triggered.connect(self.__add_model)
            model_menu.addAction(self.tr("&Supprimer scénario courant")).triggered.connect(self.__delete_current_model)

        # Pour l'instant tout ce qui s'appelle modèle dans le code va s'appeler scénario dans l'interface, peut être que c'est un choix que l'on ne voudra pas garder
        # Notamment si couplage avec hydra et Express'eau.

        self.addAction(self.tr("Montrer les résultats")).triggered.connect(self.__show_results)
        self.addAction(self.tr("Sauvegarder les couches customisées")).triggered.connect(self.__save_layer_styles)
        self.addAction(self.tr("&Aide")).triggered.connect(self.__help)
        # self.addAction(self.tr("A propos")).triggered.connect(self.__about)

    def __help(self):
        webbrowser.open('https://github.com/TheophileLaPelouse/LIEGES', new=0)

    def __save_layer_styles(self):
        confirm = QMessageBox(QMessageBox.Question, self.tr("Save custom layers styles"), self.tr("This will overwrite all your custom layer styles"), QMessageBox.Ok | QMessageBox.Cancel).exec_()
        if confirm == QMessageBox.Ok:
            if QGisProjectManager.project_name() != '':
                project = Project(QGisProjectManager.project_name(), self.__log_manager)
                QGisProjectManager.save_custom_qml(project.qgs)

    def __manage_projects(self):
        self.pm and self.pm.setParent(None)
        project_list = get_projects_list()
        self.pm = ProjectManager(project_list, self.parent())
        self.pm.show()

    def __project_new(self):
        dialog = NewProjectDialog(self.parent())
        if dialog.Accepted == dialog.exec_():
            project = Project.create_new_project(dialog.return_name(), dialog.return_srid(), dialog.return_directory(), self.__log_manager)
            QGisProjectManager.open_project(project.qgs, project.srid)
            
            project.create_index()
            input_output, f_details, f_inputs = project.get_values4qml()
            QGisProjectManager.update_qml(QgsProject.instance(), project.qgs, f_details, input_output, f_inputs) 
            project.post_traitement()

    def __set_current_model(self):
        QGisProjectManager.set_qgis_variable('current_model', self.sender().text())

    def __add_model(self):
        dialog = NewModelDialog(self)
        ok = dialog.exec_()
        if ok == dialog.Accepted:
            project = Project(QGisProjectManager.project_name(), self.__log_manager)
            project.add_new_model(dialog.return_name())

    def __delete_current_model(self):
        current_model = QGisProjectManager.get_qgis_variable('current_model')
        confirm = QMessageBox(QMessageBox.Question, self.tr("Delete model"), self.tr("This will delete model ")+current_model+self.tr(". Proceed?"), QMessageBox.Ok | QMessageBox.Cancel).exec_()
        if confirm == QMessageBox.Ok:
            project = Project(QGisProjectManager.project_name(), self.__log_manager)
            project.delete_model(current_model)

    def __show_results(self):
        project = Project(QGisProjectManager.project_name(), self.__log_manager)
        self.res_widget and self.res_widget.setParent(None)
        self.res_widget = AllResults(project, self.parent())
        self.res_widget.show()
        
    # def __scenario_manager(self):
    #     project = Project(QGisProjectManager.project_name(), self.__log_manager)
    #     ScenarioManager(project).exec_()


    def __about(self):
        # build_info = get_build().split('\n')
        # version =  build_info[1].split(':')[1]
        # date_ = datetime.fromtimestamp(os.stat(build_file).st_ctime).strftime("%Y-%m-%d")

        # about_pic = QPixmap(os.path.join(_current_dir, '..', 'ressources', 'images', 'cycle_logo.png')).scaledToHeight(32, Qt.SmoothTransformation)

        # about_text = f"<b>cycle version {version} {date_}</b><br><br>"
        # about_file = os.path.join(_current_dir, '..', 'license_short.txt')
        # with open(about_file, 'r') as f:
        #     about_text += f.read()
        # about_text += f"<br><br><b>Build info</b><br>{'<br>'.join([line.replace('    ', '- ') for line in build_info])}"
        # about_text += f"<br><b>Serial number</b><br>{get_serial()}"

        about_box = QMessageBox()
        about_box.setWindowTitle(self.tr('About Cycle'))
        # about_box.setIconPixmap(about_pic)
        about_box.setTextFormat(Qt.RichText)
        # about_box.setText(about_text)
        about_box.exec_()