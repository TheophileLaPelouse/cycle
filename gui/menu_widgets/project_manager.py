

import os
import shutil
import psycopg2
from datetime import datetime
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QFont
from qgis.PyQt.QtWidgets import QDialog, QFileDialog, QMessageBox, QTreeWidgetItem, QComboBox, QHBoxLayout, QLabel, QPushButton
from qgis.gui import QgsMessageBar
from ...database import get_projects_list, export_db, import_db, get_srid_from_file, remove_project
from ...project import Project, backup_directory
from ...database import __version__ as db_version, update_db, duplicate, version
from ...database import import_model, export_model
from .new_model_dialog import NewModelDialog
from .new_project_dialog import NewProjectDialog
from ...utility.log import LogManager
from ...qgis_utilities import MessageBarLogger, QGisProjectManager
from ...utility.string import normalized_name
from ...service import get_service, set_service, services
from qgis import processing
from qgis.core import QgsProject

_bold = QFont()
_bold.setWeight(QFont.Bold)

class ProjectManager(QDialog):
    def __init__(self, parent=None):
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "project_manager.ui"), self)
        #self.setWindowFlags(self.windowFlags() | Qt.WindowSystemMenuHint | Qt.WindowMinMaxButtonsHint)

        self.__message_bar = QgsMessageBar(self)
        self.__message_bar.setMaximumHeight(30)
        self.message_bar_layout.addWidget(self.__message_bar)

        self.__log_manager = LogManager(MessageBarLogger(self.__message_bar))

        self.service.addItems(services())
        self.service.setCurrentText(get_service())
        self.service.currentTextChanged.connect(self.__service_changed)

        self.buttonBox.accepted.connect(self.close)
        self.buttonBox.rejected.connect(self.close)
        self.btn_open_project.clicked.connect(self.open_project)
        self.btn_new_project.clicked.connect(self.new_project)
        self.btn_duplicate_project.clicked.connect(self.duplicate_project)
        self.btn_delete_project.clicked.connect(self.delete_project)
        self.btn_export_project.clicked.connect(self.export_project)
        self.btn_import_project.clicked.connect(self.import_project)
        # self.btn_update_project.clicked.connect(self.update_project)
        # self.btn_update_project.setToolTip(self.tr("If the project is up to date, database views and function will be reloaded"))
        self.btn_add_model.clicked.connect(self.add_model)
        self.btn_delete_model.clicked.connect(self.delete_model)
        self.btn_import_model.clicked.connect(self.import_model)
        # self.btn_import_model.setToolTip('\n'.join([
        #    self.tr("Import epanet model (*.inp) or legacy expresseau models (*.dat)."),
        #    "",
        #    self.tr("Note: in case of legacy import, the directory the .dat file is located in must contain:"),
        #    self.tr("- a .dat file where most information is stored"),
        #    self.tr("- a _CrbModulConso.Csv file for modulation curves (curves that are already in the project are ignored)"),
        #    self.tr("- a caracteristiques_materiaux.xlsx file"),
        #    self.tr("- a _Nod.Csv file"),
        #    self.tr("- a _CANA.Csv file")])) Faudra refaire en fonction de notre truc d'import
        self.btn_export_model.clicked.connect(self.export_model)

        self.tree_widget.itemSelectionChanged.connect(self.__refresh_buttons)
        self.tree_widget.itemDoubleClicked.connect(self.open_project)

        self.__refresh_tree()
        self.__refresh_buttons()

        self.setWindowState((self.windowState() & ~Qt.WindowMinimized) | Qt.WindowActive)
        self.raise_()  # for MacOS
        self.activateWindow() # for Windows

    def __service_changed(self, service):
        set_service(service)
        self.__refresh_tree()
        self.__refresh_buttons()

    def __refresh_tree(self):
        '''Clears the QTreeWidget then re-populates it with all cycle projects'''
        self.tree_widget.clear()
        for project_name in get_projects_list():
            if project_name != normalized_name(project_name):
                project_node = QTreeWidgetItem(self.tree_widget)
                project_node.setExpanded(False)
                project_node.setFont(0, _bold)
                project_node.setText(0, project_name)
                project_node.setText(2, f'project name should be {normalized_name(project_name)}')
                project_node.setForeground(0, Qt.red)
                project_node.setForeground(2, Qt.red)
            else:
                project = Project(project_name, self.__log_manager)
                try:
                    has_api = project.has_api
                except psycopg2.errors.InsufficientPrivilege:
                    continue

                project_node = QTreeWidgetItem(self.tree_widget)
                project_node.setExpanded(False)
                project_node.setFont(0, _bold)


                project_node.setText(0, project_name)
                project_node.setText(1, project.version)
                if project.version != db_version or not has_api:
                    project_node.setForeground(0, Qt.red)
                    project_node.setForeground(1, Qt.red)

                project_node.setText(3, project.directory)

                if has_api:
                    project_node.setText(2, str(project.srid))

                    for model in sorted(project.models, key=str.lower):
                        model_node = QTreeWidgetItem(project_node)
                        model_node.setText(0, model)
                else:
                    project_node.setText(2, 'missing api')
                    project_node.setForeground(2, Qt.red)

        for i in range(4):
            self.tree_widget.resizeColumnToContents(i)

    def __refresh_buttons(self):
        '''Sets some buttons as disabled if no project or model is selected but are needed to run the associated functions'''
        project_name, model_name = self.__get_selection()
        self.btn_open_project.setEnabled(project_name is not None)
        self.btn_duplicate_project.setEnabled(project_name is not None)
        self.btn_delete_project.setEnabled(project_name is not None)
        self.btn_export_project.setEnabled(project_name is not None)
        self.btn_update_project.setEnabled(project_name is not None)
        self.btn_add_model.setEnabled(project_name is not None)
        self.btn_delete_model.setEnabled(project_name is not None and model_name is not None)
        self.btn_import_model.setEnabled(project_name is not None)
        self.btn_export_model.setEnabled(project_name is not None and model_name is not None)

    def open_project(self):
        '''Closes project manager's UI and opens selected project in QGIS'''
        project_name, model_name = self.__get_selection()
        assert(project_name is not None)
        project = Project(project_name, self.__log_manager)

        # if project.version != db_version or not project.has_api:
        #     confirm = QMessageBox(QMessageBox.Warning,
        #         self.tr('Update project'), self.tr('Do you want to update project {} from version {} to version {} ?'
        #         ).format(project_name, project.version, db_version), QMessageBox.Ok | QMessageBox.Cancel).exec_()
        #     if confirm == QMessageBox.Ok:
        #         self.update_project()
        #     else:
        #         return

        QGisProjectManager.open_project(project.qgs, project.srid)
        
        raw_inp_out = project.fetchall('select * from api.input_output')
        input_output = {elem[0] : {'inp' : elem[1], 'out' : elem[2], 'concrete' : elem[-1]} for elem in raw_inp_out}
        query = """
        select jsonb_build_object(b_type, jsonb_object_agg(f.formula, f.detail_level)) 
        from api.input_output i_o 
        join api.formulas f on f.name = any(i_o.default_formulas) 
        group by b_type;
        """
        list_f_details = project.fetchall(query)
        f_details = {}
        for elem in list_f_details:
            if elem[0] : 
                for key, value in elem[0].items():
                    f_details[key] = value
        
        print(f_details)
        raw_f_inputs = project.fetchone("select api.select_default_input_output() ;")
        f_inputs = raw_f_inputs[0]
        QGisProjectManager.update_qml(QgsProject.instance(), project.qgs, f_details, input_output, f_inputs) 
        
        if model_name is not None:
            project.current_model = model_name

        self.close()

    def new_project(self):
        '''Creates a new project'''
        dialog = NewProjectDialog(self)
        ok = dialog.exec_()
        if ok == dialog.Accepted:
            Project.create_new_project(dialog.return_name(), dialog.return_srid(), dialog.return_directory(), self.__log_manager)
            self.__refresh_tree()
            self.__log_manager.notice(f'{dialog.return_name()} '+self.tr('created'))

    def duplicate_project(self):
        '''Creates a new project'''
        project_name, model_name = self.__get_selection()
        project = Project(project_name, self.__log_manager)
        dialog = NewProjectDialog(self, project_name=project_name, srid=project.srid)
        dialog.srid.setEnabled(False)
        ok = dialog.exec_()
        if ok == dialog.Accepted:
            duplicate(project.name, dialog.return_name())
            project = Project(project_name, self.__log_manager) # needed because duplicate(src, dst) terminates connections on src
            new_project = Project(dialog.return_name(), self.__log_manager)
            os.rmdir(new_project.directory)
            shutil.copytree(project.directory, new_project.directory)
            if os.path.exists(project.qgs):
                os.remove(os.path.join(new_project.directory, project.name+'.qgs'))
                with open(project.qgs) as src, open(new_project.qgs, 'w') as dst:
                    dst.write(src.read().replace(
                        f"dbname='{project.name}'",
                        f"dbname='{new_project.name}'"
                        ).replace(
                        f'<project type="QString">{project.name}</project>',
                        f'<project type="QString">{new_project.name}</project>'
                        ))
            self.__refresh_tree()
            self.__log_manager.notice(f'{project.name} '+self.tr('duplicated into')+' {new_project.name}')

    def delete_project(self):
        '''Deletes selected project'''
        project_name, model_name = self.__get_selection()
        assert(project_name is not None)
        msg_box = QMessageBox(self)
        msg_box.setWindowTitle(self.tr("Delete project"))
        msg_box.setText(self.tr('This will delete project ')+project_name+self.tr('. Proceed?'))
        msg_box.addButton(self.tr('Also delete project directory'), QMessageBox.AcceptRole)
        msg_box.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
        res = msg_box.exec_()
        if res in (QMessageBox.Ok, 0):
            if project_name == QGisProjectManager.project_name():
                QGisProjectManager.new_project()
            if res == 0:
                project = Project(project_name, self.__log_manager)
                shutil.rmtree(project.directory)
            remove_project(project_name)
            self.__refresh_tree()
            self.__log_manager.notice(project_name+self.tr(' deleted'))

    def export_project(self):
        '''Exports selected project to selected file'''
        project_name, model_name = self.__get_selection()
        assert(project_name is not None)
        file, __ = QFileDialog.getSaveFileName(self, self.tr("Select a file"), filter="SQL (*.sql)")
        if file:
            export_db(project_name, file)
            self.__log_manager.notice(project_name+self.tr(' exported to ')+file)

    # def update_project(self):
    #     '''Exports selected project to selected file'''
    #     project_name, model_name = self.__get_selection()
    #     assert(project_name is not None)
    #     QGisProjectManager.exit_edition()
    #     export_db(project_name, os.path.join(backup_directory(project_name), f'{datetime.now().strftime("%Y%m%d")}_{project_name}_{version(project_name)}.sql'))
    #     update_db(project_name)
    #     project = Project(project_name, self.__log_manager)
    #     if not os.path.exists(project.qgs):
    #         QGisProjectManager.create_project(project.qgs, project.srid)
    #     else:
    #         QGisProjectManager.update_project(project.qgs)
    #     self.__refresh_tree()
    #     self.__log_manager.notice(project_name+self.tr(' updated'))

    def import_project(self):
        '''Imports selected file in a new project'''
        file, __ = QFileDialog.getOpenFileName(self, self.tr("Select a file"), filter="File (*.sql *.inp);; SQL (*.sql);; EPANET (*.inp)")
        if file:
            if file.lower().endswith('.sql'):
                srid = get_srid_from_file(file)
                if srid is None:
                    self.__log_manager.error(self.tr("SRID not found in file ")+file)
                    return

                dialog = NewProjectDialog(self, project_name=os.path.basename(file.lower())[:-4])
                dialog.srid.setEnabled(False)
                dialog.srid.setText(get_srid_from_file(file))
                ok = dialog.exec_()
                if ok == dialog.Accepted:
                    import_db(dialog.return_name(), file)
                    self.__refresh_tree()
                    self.__log_manager.notice(dialog.return_name()+self.tr(' imported from ')+file)

            elif file.lower().endswith('.inp'):
                params = {
                    "file":file,
                    "project": normalized_name(os.path.basename(file)[:-4], 24)
                    }
                processing.execAlgorithmDialog('cycle:import inp', params)
                self.__refresh_tree()

    def export_model(self):
        project_name, model_name = self.__get_selection()
        project = Project(project_name, self.__log_manager)

        file_path, __ = QFileDialog.getSaveFileName(self, self.tr("Select a file to export ")+model_name, os.path.join(project.directory, model_name+'.sql'), filter="CYCLE (*.sql)")
        export_model(project_name, model_name, file_path)

    def add_model(self):
        '''Adds a model to selected project'''
        project_name, model_name = self.__get_selection()
        assert(project_name is not None)
        dialog = NewModelDialog(self)
        ok = dialog.exec_()
        if ok == dialog.Accepted:
            project = Project(project_name, self.__log_manager)
            project.add_new_model(dialog.return_name())
            project.current_model = dialog.return_name()
            self.__refresh_tree()

    def delete_model(self):
        ''' Deletes selected model'''
        project_name, model_name = self.__get_selection()
        assert(project_name is not None and model_name is not None)
        msg_box = QMessageBox(self)
        msg_box.setWindowTitle(self.tr("Delete model"))
        msg_box.setText(self.tr('This will delete model ')+model_name+self.tr(' in project ')+project_name+self.tr('. Proceed?'))
        msg_box.addButton(self.tr('Also delete delivery sectors and nodes'), QMessageBox.AcceptRole)
        msg_box.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
        res = msg_box.exec_()
        if res in (QMessageBox.Ok, 0):
            project = Project(project_name, self.__log_manager)
            project.delete_model(model_name)
            if res==0:
                project.execute("delete from api.water_delivery_point where pipe_link is null")
                project.execute("delete from api.water_delivery_sector s where (select count(1)=0 from api.user_node n where st_intersects(n.geom, s.geom))")
            self.__refresh_tree()

    def import_model(self):
        '''Imports model from files package from old expresseau.exe ou EPANET'''
        project_name, model_name = self.__get_selection()
        assert(project_name is not None)
        file, __ = QFileDialog.getOpenFileName(self, self.tr("Select a file"), filter="EPANET (*.inp);; EXPRESSEAU (*.sql)")
        # if file and file.lower().endswith('.dat'):
        #     path = os.path.dirname(file)
        #     dialog = NewModelDialog(self)
        #     ok = dialog.exec_()
        #     if ok == dialog.Accepted:
        #         project = Project(project_name, self.__log_manager)
        #         project.delete_model(dialog.return_name())
        #         project.add_new_model(dialog.return_name())
        #         with project.connect() as con, con.cursor() as cur:
        #             import_legacy(cur, dialog.return_name(), path)
        #             con.commit()
        #         project.current_model = dialog.return_name()
        #         self.__refresh_tree()
        # Je crois que y'en aura jamais besoin mais je me laisse encore douter une peu

        if file and file.lower().endswith('.inp'):
            project = Project(project_name, self.__log_manager)
            params = {
                "project": project.name,
                "project directory": project.directory[:-len(project.name)],
                "model": normalized_name(os.path.basename(file)[:-4], 16),
                "file": file
                }
            processing.execAlgorithmDialog('cycle:import inp', params)
            self.__refresh_tree()

        elif file and file.lower().endswith('.sql'):
            dialog = NewModelDialog(self)
            ok = dialog.exec_()
            if ok == dialog.Accepted:
                import_model(file, dialog.return_name(), project_name)
                self.__refresh_tree()


    def __get_selection(self):
        '''Utility function returning selected project name and selected model name depending on what is applicable'''
        selected_project = None
        selected_model = None

        selection = self.tree_widget.selectedItems()
        if len(selection) >0:
            selected_item = selection[0]
            if selected_item.parent() is not None:
                selected_project = selected_item.parent().text(0)
                selected_model = selected_item.text(0)
            else:
                selected_project = selected_item.text(0)
                selected_model = None
        return selected_project, selected_model

if __name__=="__main__":
    from qgis.core import QgsApplication

    qgs = QgsApplication([], False)
    qgs.initQgis()

    test_dialog = ProjectManager()
    test_dialog.exec_()
