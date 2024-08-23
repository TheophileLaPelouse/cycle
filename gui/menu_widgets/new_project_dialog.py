

import os
from qgis.PyQt import uic
from qgis.PyQt.QtWidgets import QDialog, QMessageBox, QFileDialog, QDialogButtonBox
from qgis.gui import QgsProjectionSelectionDialog
from ...utility.string import normalized_name
from ...database import get_projects_list
from ...service import get_service, set_service, services

_cycle_dir = os.path.join(os.path.expanduser('~'), ".cycle")

class NewProjectDialog(QDialog):
    def __init__(self, parent=None, project_name='', srid='2154'):
        QDialog.__init__(self, parent)
        current_dir = os.path.dirname(__file__)
        uic.loadUi(os.path.join(current_dir, "new_project_dialog.ui"), self)

        self.service.addItems(services())
        self.service.setCurrentText(get_service())
        self.service.currentTextChanged.connect(self.__service_changed)

        self.existing_db = get_projects_list(all_db=True)
        self.info.text=''

        self.project_name.textChanged.connect(self.__project_name_changed)
        self.project_name.setText(project_name)

        self.srid.setText(str(srid))
        self.btn_epsg.clicked.connect(self.__select_epsg)

        self.directory.setText(_cycle_dir)
        self.btn_dir.clicked.connect(self.__select_dir)

    def __service_changed(self, service):
        set_service(service)

    def __project_name_changed(self):
        project_name = str(self.project_name.text())
        new_project_name = normalized_name(project_name)
        self.buttonBox.button(QDialogButtonBox.Ok).setEnabled(new_project_name not in self.existing_db)
        self.info.setText(f"{new_project_name if project_name!=new_project_name else ''} {'name already taken' if new_project_name in self.existing_db else ''}""")

    def __select_epsg(self):
        projSelector = QgsProjectionSelectionDialog()
        projSelector.exec_()
        authId = projSelector.crs().authid()
        if authId[:5]=='EPSG:':
            self.srid.setText(authId[5:])
        else:
            QMessageBox(QMessageBox.Warning, 'Not a valid SRID', 'Please select a SRID with code starting with "ESPG:..."', QMessageBox.Ok).exec_()

    def __select_dir(self):
        dir_name = QFileDialog.getExistingDirectory(None, 'Select working dir path:', self.directory.text())
        if dir_name:
            self.directory.setText(dir_name)

    def return_name(self):
        return normalized_name(str(self.project_name.text()))

    def return_srid(self):
        return int(self.srid.text())

    def return_directory(self):
        return self.directory.text()
