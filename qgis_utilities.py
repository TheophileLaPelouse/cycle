# coding=utf-8

################################################################################################
##                                                                                            ##
##     This file is part of HYDRA, a QGIS plugin for hydraulics                               ##
##     (see <http://hydra-software.net/>).                                                    ##
##                                                                                            ##
##     Copyright (c) 2017 by HYDRA-SOFTWARE, which is a commercial brand                      ##
##     of Setec Hydratec, Paris.                                                              ##
##                                                                                            ##
##     Contact: <contact@hydra-software.net>                                                  ##
##                                                                                            ##
##     You can use this program under the terms of the GNU General Public                     ##
##     License as published by the Free Software Foundation, version 3 of                     ##
##     the License.                                                                           ##
##                                                                                            ##
##     You should have received a copy of the GNU General Public License                      ##
##     along with this program. If not, see <http://www.gnu.org/licenses/>.                   ##
##                                                                                            ##
################################################################################################

"""
QGisUIManager manage iface interactions with gqis
"""

import os
from pathlib import Path
import re
import tempfile
from qgis.core import Qgis, QgsProject, QgsCoordinateReferenceSystem, QgsVectorLayer, QgsApplication, QgsRelation, QgsRelationContext, QgsSettings, QgsSnappingConfig, QgsTolerance, qgsfunction, QgsMessageLog, QgsMeshLayer
from qgis.utils import iface
from qgis.gui import QgsEditorWidgetFactory, QgsEditorWidgetWrapper, QgsEditorConfigWidget
from qgis.PyQt.QtCore import QObject, QSettings, QCoreApplication, QFile
from qgis.PyQt.QtWidgets import QWidget
from qgis.PyQt.QtXml import QDomDocument
from .service import get_service
from .database.version import __version__ 
from .utility.json_utils import open_json, save_to_json, get_propertie, add_dico, get_all_properties

def tr(msg):
    return QCoreApplication.translate('@default', msg)

if QgsApplication.prefixPath() == '':
    QgsApplication.setPrefixPath(os.environ['QGIS_PREFIX_PATH']) # avoid warnings when not in qgis

_svg_dir = os.path.normpath(os.path.join(os.path.dirname(__file__), 'ressources', 'svg'))
_qml_dir = os.path.join(os.path.dirname(__file__), 'ressources', 'qml')
_custom_qml_dir = os.path.join(os.path.expanduser('~'), '.cycle', 'qml')


class MessageBarLogger:
    def __init__(self, message_bar):
        self.message_bar = message_bar

    def error(self, title, message):
        self.message_bar.pushMessage(title, message.replace('\n', ' '), level=Qgis.Critical)

    def warning(self, title, message):
        self.message_bar.pushMessage(title, message.replace('\n', ' '), level=Qgis.Warning)

    def notice(self, title, message):
        self.message_bar.pushMessage(title, message.replace('\n', ' '), level=Qgis.Info, duration=3)

class MessageLogger:
    def error(self, title, message):
        QgsMessageLog.logMessage(message, level=Qgis.Critical)

    def warning(self, title, message):
        QgsMessageLog.logMessage(message, level=Qgis.Warning)

    def notice(self, title, message):
        QgsMessageLog.logMessage(message, level=Qgis.Info)


class QGisLogger(MessageBarLogger):
    def __init__(self, iface):
        super().__init__(iface.messageBar())

class QGisProjectManager(QObject):
    """A bunch of static methods to interact with QgsProject instance and iface"""

    @staticmethod
    def layertree():
        # this is a function, not calss static variable because othierwise translation is initialize after creation
        return(open_json(os.path.join(os.path.dirname(__file__), 'layertree.json')))
    # Faudra remettre le fait que ça trad dans l'ouverture du json mais on va sûrement le faire différemment de dans Expresseau.
    # Et du coup pour l'efficacité ce sera une variable statique initialisée dans la classe
    
    @staticmethod
    def layertree_custom(project_filename):
        try:
            return open_json(os.path.join(os.path.dirname(project_filename), 'layertree_custom.json'))
        except FileNotFoundError:
            return {}
    
    @staticmethod
    def layers():
        layertree = QGisProjectManager.layertree()
        blocs = get_all_properties("bloc", layertree)[0]
        return {bloc[0] : bloc[2] for bloc in blocs}

    @staticmethod
    def new_project():
        if iface is not None:
            iface.newProject() # will open save dialog if project needs saving
        else:
            QgsProject.instance().clear()

    @staticmethod
    def open_project(project_filename, srid):
        QGisProjectManager.new_project()
        is_new_project = not os.path.exists(project_filename)
        if is_new_project:
            QGisProjectManager.create_project(project_filename, srid)
        else:
            QGisProjectManager.update_project(project_filename)

        if iface is not None:
            iface.addProject(project_filename)
            if is_new_project:
                iface.zoomFull()

        # adds connection to database if not already existing
        dbname = QgsProject.instance().baseName()
        settings = QSettings()
        # check if connection settings for the opened project are set
        if settings.value(f'/PostgreSQL/connections/{dbname}/database') != dbname:
            # if not set, writes them
            settings.setValue(f'/PostgreSQL/connections/{dbname}/database', dbname)
            settings.setValue(f'/PostgreSQL/connections/{dbname}/service', get_service())
            # refresh QGIS data browser to display the project's DB
            if iface is not None:
                iface.mainWindow().findChildren(QWidget, 'Browser')[0].refresh()
                iface.mainWindow().findChildren(QWidget, 'Browser2')[0].refresh()

    @staticmethod
    def set_qgis_variable(var_name, value):
        cv = QgsProject.instance().customVariables()
        cv[var_name] = value
        QgsProject.instance().setCustomVariables(cv)
        if var_name=='current_model':
            QGisProjectManager.refresh_layers()

    @staticmethod
    def refresh_layers():
        if iface is not None:
            for layer in iface.mapCanvas().layers():
                layer.triggerRepaint()

    # @staticmethod
    # def get_layer(table):
    #     for grp, layers in QGisProjectManager.layertree():
    #         for name, sch, tbl, key in layers:
    #             if table == tbl:
    #                 layer = QgsProject.instance().mapLayersByName(name)
    #                 return layer[0] if len(layer) else None
    #     return None

    @staticmethod
    def get_qgis_variable(var_name):
        cv = QgsProject.instance().customVariables()
        return cv[var_name] if var_name in cv and cv[var_name] != '' else None

    @staticmethod
    def exit_edition():
        for layer in QgsProject.instance().mapLayersByName(tr('All nodes')):
            layer.commitChanges()


    @staticmethod
    def update_project(project_filename):
        project = QgsProject()
        project.clear()
        project.read(project_filename)
        # if project.readEntry('cycle', 'version', '')[0] != __version__:
        project_name = project.baseName()
        project.writeEntry('cycle', 'project', project_name)
        project.writeEntry('cycle', 'version', __version__)
        project.writeEntry('cycle', 'service', get_service())

        # todo vérifier que les layers et les relations sont déjà là sinon les ajouter

        # add layers if they are not already there
        root = project.layerTreeRoot()
        name_id_map = {layer.name(): layer.layerId() for layer in root.findLayers()}
        
        layertree = QGisProjectManager.layertree()
        layertree_custom = QGisProjectManager.layertree_custom(project_filename)
        print("layertree : ", layertree_custom)
        properties, paths = get_all_properties("bloc", layertree)
        print(get_all_properties("bloc", layertree_custom))
        prop2, paths2 = get_all_properties("bloc", layertree_custom) if layertree_custom else ([], [])
        print("bonjour")
        print(properties, paths, prop2, paths2) 
        properties += prop2
        paths += paths2
        for bloc, path in zip(properties, paths):
            grps = path.split('/')
            g = root
            for grp in grps:
                if grp != '':
                    g = g.findGroup(grp) or g.insertGroup(-1, grp)
            
            
            layer_name, sch, tbl, key = bloc
            uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"''' + (' (geom)' if (grp != tr('Settings') and layer_name!=tr('Measure')) else '')
            print(uri)
            if not len(project.mapLayersByName(layer_name)):
                layer = QgsVectorLayer(uri, layer_name, "postgres")
                project.addMapLayer(layer, False)
                n = g.addLayer(layer)
                name_id_map[layer_name] = layer.id()
                if not layer.isValid():
                    raise RuntimeError(f'layer {layer_name} is invalid')
            else:
                # check and fix uri
                layer = project.mapLayersByName(layer_name)[0]
                if uri != layer.dataProvider().dataSourceUri():
                    layer.setDataSource(uri, layer_name, "postgres")


            QGisProjectManager.load_qml(project)
            project.write()



    @staticmethod
    def load_qml(project):
        # all_nodes_layer_id = project.mapLayersByName(tr('All nodes'))[0].id()
        # sector_layer_id = project.mapLayersByName(tr('Water delivery sector'))[0].id()
        # material_layer_id = project.mapLayersByName(tr('Material'))[0].id()
        # fluid_layer_id = project.mapLayersByName(tr('Fluid properties'))[0].id()

        # locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        # lang = '' if locale == 'en' else '_fr'
        lang = ''
        for layer_name, tbl in QGisProjectManager.layers().items():
            found_layers = project.mapLayersByName(layer_name)
            if len(found_layers):
                layer = found_layers[0]
                qml_basename = tbl+lang+'.qml'
                qml = os.path.join(_custom_qml_dir, qml_basename)
                if not os.path.exists(qml):
                    qml = os.path.join(_qml_dir, qml_basename)
                if os.path.exists(qml):
                    # we need to update expressions and relational references

                    doc = QDomDocument()
                    doc.setContent(QFile(qml))
                    root = doc.documentElement()
                    referencedLayers = root.firstChildElement('referencedLayers')
                    # remove relations
                    while referencedLayers.childNodes().count():
                        referencedLayers.removeChild(referencedLayers.firstChild())
                    # adds necessary relation
                    # relation_field_id_map = {}
                    # for n, r in project.relationManager().relations().items():
                    #     if r.name() in layer_relations:
                    #         r.writeXml(referencedLayers, doc)
                    #         relation_field_id_map[layer_relations[r.name()]] = r
                    # fieldConfiguration = root.firstChildElement('fieldConfiguration')
                    # for i in range(fieldConfiguration.childNodes().count()):
                    #     field = fieldConfiguration.childNodes().item(i).toElement().attribute('name')
                    #     config = fieldConfiguration.childNodes().item(i).toElement().firstChildElement('editWidget').firstChildElement('config').firstChildElement('Option')
                    #     # Comme des xpath quand on vole des données sur internet
                    #     for j in range(config.childNodes().count()):
                    #         e = config.childNodes().item(j).toElement()
                    #         if e.attribute('name') == 'Relation':
                    #             e.setAttribute('value', relation_field_id_map[field].id())
                    #         if e.attribute('name') == 'ReferencedLayerName':
                    #             e.setAttribute('value', relation_field_id_map[field].referencedLayer().name())
                    #         if e.attribute('name') == 'ReferencedLayerDataSource':
                    #             e.setAttribute('value', relation_field_id_map[field].referencedLayer().dataProvider().dataSourceUri())
                    #         if e.attribute('name') == 'ReferencedLayerId':
                    #             e.setAttribute('value', relation_field_id_map[field].referencedLayer().id())
                    #         #if e.attribute

                    # change referenced layers in default values expressions
                    # defaults = root.firstChildElement('defaults')
                    # for i in range(defaults.childNodes().count()):
                    #     e = defaults.childNodes().item(i).toElement()
                    #     if e.attribute('expression').find('layer:=') != -1:
                    #         field = e.attribute('field')
                    #         if field == '_model':
                    #             e.setAttribute('expression',
                    #                     re.sub("layer:='[^']+'",
                    #                     f"layer:='{all_nodes_layer_id}'",
                    #                     e.attribute('expression')))
                    #         elif field == '_sector':
                    #             e.setAttribute('expression',
                    #                     re.sub("layer:='[^']+'",
                    #                     f"layer:='{sector_layer_id}'",
                    #                     e.attribute('expression')))
                    #         elif field in ('_roughness_mm', '_elasticity_n_m2'):
                    #             e.setAttribute('expression',
                    #                     re.sub("layer:='[^']+'",
                    #                     f"layer:='{material_layer_id}'",
                    #                     e.attribute('expression')))
                    #         elif field == '_celerity':
                    #             e.setAttribute('expression',
                    #                     re.sub("layer:='[^']+'",
                    #                     f"layer:='{fluid_layer_id}'",
                    #                     e.attribute('expression')))
                    #         else:
                    #             e.setAttribute('expression',
                    #                     re.sub("layer:='[^']+'",
                    #                     f"layer:='{relation_field_id_map[field].referencedLayer().id()}'",
                    #                     e.attribute('expression')))
                    # On enlèvera le commentaire le jour où on aura des expressions intéressantes dans cetaines tables.
                    # En gros faut définir les références qui nous seront utiles avant ça.

                    # save to tmp file
                    tmp_qml = os.path.join(tempfile.gettempdir(), qml_basename)
                    with open(tmp_qml, 'w', encoding='utf-8') as o:
                        o.write(doc.toString(2))


                    #with open(qml) as src, open(tmp_qml, 'w') as dst:
                    #    data = src.read()
                    #    for n, i in layer_id.items():
                    #        data = re.sub(f"layer:='{n}_[^']+'", f"layer:='{i}'", data, flags=re.IGNORECASE)
                    #    dst.write(data)

                    layer.loadNamedStyle(tmp_qml)

    @staticmethod
    def create_project(project_filename, srid):
        project = QgsProject()
        project.clear()
        project.setFileName(project_filename)
        project_name = project.baseName()
        project.setAutoTransaction(True)
        project.setEvaluateDefaultValues(True)
        project.writeEntry('cycle', 'project', project_name)
        project.writeEntry('cycle', 'version', __version__)
        project.writeEntry('cycle', 'service', get_service())
        root = project.layerTreeRoot()

        name_id_map = {}

        # create layertree
        layertree = QGisProjectManager.layertree()
        properties, paths = get_all_properties("bloc", layertree)
        for bloc, path in zip(properties, paths):
            grps = path.split('/')
            g = root
            for grp in grps:
                if grp != '':
                    g = g.findGroup(grp) or g.insertGroup(-1, grp)

            layer_name, sch, tbl, key = bloc
            uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"''' + (' (geom)' if (grp != tr('Settings') and layer_name!=tr('Measure')) else '')
            if not len(project.mapLayersByName(layer_name)):
                layer = QgsVectorLayer(uri, layer_name, "postgres")
                project.addMapLayer(layer, False)
                n = g.addLayer(layer)
                name_id_map[layer_name] = layer.id()
                if not layer.isValid():
                    raise RuntimeError(f'layer {layer_name} is invalid')
            else:
                # check and fix uri
                layer = project.mapLayersByName(layer_name)[0]
                if uri != layer.dataProvider().dataSourceUri():
                    layer.setDataSource(uri, layer_name, "postgres")

        if _svg_dir not in QSettings().value('svg/searchPathsForSVG', []):
            path = QSettings().value('svg/searchPathsForSVG', []) + [_svg_dir]
            QSettings().setValue('svg/searchPathsForSVG', path)

        QGisProjectManager.load_qml(project)

        snap_config = QgsSnappingConfig()
        snap_config.setEnabled(True)
        snap_config.setType(QgsSnappingConfig.Vertex)
        snap_config.setMode(QgsSnappingConfig.AllLayers)
        snap_config.setUnits(QgsTolerance.Pixels)
        snap_config.setTolerance(12)
        snap_config.setIntersectionSnapping(True)
        project.setSnappingConfig(snap_config)
        # I guess on laisse ça mais faudra regarder si ça nous intéresse de changer ça dans le design 

        # set crs
        target_crs = QgsCoordinateReferenceSystem()
        target_crs.createFromString(f'EPSG:{srid}')
        project.setCrs(target_crs)

        # speed up loading by not checking extend and pk unicity
        project.setTrustLayerMetadata(True)

        project.write()

    @staticmethod
    def save_custom_qml():
        if not os.path.isdir(_custom_qml_dir):
            os.mkdir(_custom_qml_dir)

        locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        lang = '' if locale == 'en' else '_fr'

        for grp, layers in QGisProjectManager.layertree():
            for layer_name, sch, tbl, key in layers:
                for layer in QgsProject.instance().mapLayersByName(layer_name):
                    layer.saveNamedStyle(os.path.join(_custom_qml_dir, tbl+lang+'.qml'))

    @staticmethod
    def is_cycle_project():
        return QgsProject.instance().readEntry('cycle', 'project', '')[0] != ''

    @staticmethod
    def project_name():
        return QgsProject.instance().readEntry('cycle', 'project', '')[0]

if __name__=='__main__':
    import sys
    from qgis.PyQt.QtCore import QTranslator
    from qgis.core import QgsApplication

    qgs = QgsApplication([], False)
    qgs.initQgis()

    if len(sys.argv) > 1 and sys.argv[1] == 'fr':
        QgsSettings().setValue('locale/userLocale', 'fr_FR')
        # initialize locale
        locale_path = os.path.join(os.path.dirname(__file__), '..', 'i18n', 'fr.qm')
        translator = QTranslator()
        translator.load(locale_path)
        QCoreApplication.installTranslator(translator)
    else:
        QgsSettings().setValue('locale/userLocale', 'en_US')

    if len(sys.argv) > 1 and sys.argv[-1].endswith('.qgs'):
        qgis_project = sys.argv[-1]
    else:
        qgis_project = None

    for r in QGisProjectManager.relations():
        print('\t'.join(r))

    if qgis_project:
        QGisProjectManager.create_project(qgis_project, 2154)
        #project = QgsProject()
        #project.read(qgis_project)
        #QGisProjectManager.load_qml(project)
