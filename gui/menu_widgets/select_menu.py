from builtins import str
# coding=utf-8

import os
import json
from functools import partial
from qgis.PyQt import uic
from qgis.PyQt.QtCore import QCoreApplication
from qgis.PyQt.QtWidgets import QMenu, QMessageBox, QWidget
from qgis.PyQt.QtGui import QCursor
from ...utility.tables_properties import TablesProperties
from ...qgis_utilities import QGisProjectManager

def tr(msg):
    return QCoreApplication.translate("Cycle", msg)

class SelectMenu(QWidget):
    def __init__(self, project, list_objects, parent=None):
        QWidget.__init__(self, parent)
        self.__currentproject = project
        current_dir = os.path.dirname(__file__)

        self.__schema = None
        self.__table = None
        self.__id = None
        self.__name = None

        self.__properties = TablesProperties.get_properties()
        multiple_objects = True
        # check if any object in selection :
        if not list(list_objects.keys()):
            (self.__schema, self.__table, self.__id, self.__name) = (None, None, 0, None)
            multiple_objects = False
        # check if only one object from 1 table in selection :
        elif len(list(list_objects.keys())) == 1:
            key = list(list_objects.keys())[0]
            if len(list_objects[key][0])==1:
                (self.__schema, self.__table) = key
                self.__id = list_objects[key][0][0][0]
                self.__name = list_objects[key][0][0][1]
                multiple_objects = False
        if multiple_objects:
            menu = QMenu()
            pos = self.mapFromGlobal(QCursor.pos())
            menu.move(pos.x(), pos.y())
            for key in list(list_objects.keys()):
                tmp_menu = menu.addMenu(tr(self.__properties[key[1]]['name']))
                for value in list_objects[key][0]:
                    tmp_menu.addAction(str(value[0]) + ": " + str(value[1])).triggered.connect(partial(self.__tool,key[1]))
            menu.exec_()

    def __tool(self, table):
        self.__id = self.sender().text().split(": ",1)[0]
        self.__name = self.sender().text().split(": ",1)[1]
        self.__schema = self.__currentproject.get_current_model().name
        self.__table = table

    def get_action(self):
        return (self.__table, self.__schema, self.__id, self.__name)

class SelectTool(QWidget):
    def __init__(self, project, point, size=10, parent=None, subset=None, excluded_layers=[]):
        QWidget.__init__(self, parent)
        self.excluded_layers = [] + excluded_layers # Faudra sûrement faire cette liste un jour
        self.currentproject = project
        self.list_objects = {k: v
                for k,v in self.get_objects(point, size).items()
                if subset is None or k in subset}
        self.table, self.schema, self.id, self.name = SelectMenu(project, self.list_objects, parent).get_action()

    def get_objects(self, point, size):
        x1 = str(point[0]-size)
        x2 = str(point[0]+size)
        y1 = str(point[1]-size)
        y2 = str(point[1]+size)
        polygon =  x1 + " "+ y1 +","+ x1 + " "+ y2 +","+ x2 + " "+ y2 +","+ x2 + " "+ y1 +","+ x1 + " "+ y1
        properties = TablesProperties.get_properties()
        results = {}

        layermap_project = QGisProjectManager.layertree()
        self.__select_tool_layermap_process(layermap_project['objects'], properties, results, polygon, 'project') # Voir les histoires de schema
        # faudra changer ce layermap_project['objects'] parce que faudra descendre dans l'arborescence pas sûr en fait parce que y'a une récurence dans la fonction d'après

        # Pour l'instant on fait sans la couche sur les modèles en se disant pas besoin mais peut êre que ce sera utile plus tard

        return results

    def __select_tool_layermap_process(self, items, properties, results, polygon, schema_name):
        for object in items:
            if (object['type']=="layer") and (object['table'] not in self.excluded_layers):

                sql = """
                        select id, name from {}.{}
                        where ST_Intersects('srid={}; POLYGON(({}))'::geometry, {})
                        """.format(schema_name, str(object['table']),
                                   self.currentproject.srid, polygon, str(properties[object['table']]['geom']))
                result = self.currentproject.execute(sql).fetchall()
                if len(result)>0:
                    results[schema_name, str(object['table'])]= (result, "id")

            if object['type']=="group":
                self.__select_tool_layermap_process(object['objects'], properties, results, polygon, schema_name)

    def get_table(self):
        return self.table
