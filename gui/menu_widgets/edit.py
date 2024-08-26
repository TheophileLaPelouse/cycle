# coding=utf-8

from qgis.PyQt import uic
from qgis.PyQt.QtCore import QCoreApplication
from qgis.PyQt.QtWidgets import QMenu, QMessageBox, QWidget
from qgis.PyQt.QtGui import QCursor
from .select_menu import SelectTool
from ...utility.tables_properties import TablesProperties

import importlib


def tr(msg):
    return QCoreApplication.translate("Cycle", msg)


class EditTool(SelectTool):
    def __init__(self, project, point=None, size=10, parent=None, iface=None, excluded_layers=[]):
        SelectTool.__init__(self, project, point, size, parent, excluded_layers=excluded_layers)
        EditTool.edit(project, self.table, self.id, size, iface)

    @staticmethod
    def edit(currentproject, table, id, size=10, iface=None):
        properties = TablesProperties.get_properties()

        if table is None:
            return

        if properties[table]['file']:
            module = importlib.import_module("cycle.gui.forms." + properties[table]['file'])
            form_class = getattr(module, properties[table]['class'])
            form_class(currentproject, None, id).exec_()
            return

        currentproject.log.error("Not implemented edition: {}".format(table))
