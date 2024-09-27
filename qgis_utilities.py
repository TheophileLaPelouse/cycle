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
from qgis.core import Qgis, QgsProject, QgsCoordinateReferenceSystem, QgsVectorLayer, QgsApplication, QgsRelation, QgsRelationContext, QgsSettings, QgsSnappingConfig, QgsTolerance, qgsfunction, QgsMessageLog, QgsMeshLayer, QgsAttributeEditorContainer, QgsAttributeEditorField as attrfield, QgsDefaultValue
from qgis.utils import iface
from qgis.gui import QgsEditorWidgetFactory, QgsEditorWidgetWrapper, QgsEditorConfigWidget
from qgis.PyQt.QtCore import QObject, QSettings, QCoreApplication, QFile
from qgis.PyQt.QtWidgets import QWidget
from qgis.PyQt.QtXml import QDomDocument
from .service import get_service
from .database.version import __version__ 
from .utility.json_utils import open_json, save_to_json, get_propertie, add_dico, get_all_properties
from .utility.formula import read_formula

def tr(msg):
    return QCoreApplication.translate('@default', msg)

if QgsApplication.prefixPath() == '':
    QgsApplication.setPrefixPath(os.environ['QGIS_PREFIX_PATH']) # avoid warnings when not in qgis

_svg_dir = os.path.normpath(os.path.join(os.path.dirname(__file__), 'ressources', 'svg'))
_qml_dir = os.path.join(os.path.dirname(__file__), 'ressources', 'qml')
_custom_qml_dir = os.path.join(os.path.expanduser('~'), '.cycle', 'qml')

Alias = {'ngl' : 'NGL (kgNGL/an)', 'oxi' : 'Oxygène du milieu', 'dco' : 'DCO (kgDCO/an)', 'milieu' : 'Milieu', 
         'q' : 'Débit (m3/s)', 'eh' : 'Equivalent Habitants', 'tbhaut' : 'Tonne de boue en amont (t/an)', 'eh_fe' : ' ', 'w' : 'Welec (kWh/an)',
         'dco_elim' : 'DCO éliminée (kgDCO/an)'}

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
    def layers(project_filename):
        layertree = QGisProjectManager.layertree()
        layertree_custom = QGisProjectManager.layertree_custom(project_filename)
        blocs = get_all_properties("bloc", layertree)[0]
        try : blocs +=  get_all_properties("bloc", layertree_custom)[0]
        except : pass
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
    def update_project(project_filename, project = None):
        
        if not project : 
            project = QgsProject()
            project.clear()
            project.read(project_filename)
            # if project.readEntry('cycle', 'version', '')[0] != __version__:
            project_name = project.baseName()
            project.writeEntry('cycle', 'project', project_name)
            project.writeEntry('cycle', 'version', __version__)
            project.writeEntry('cycle', 'service', get_service())
        project_name = project.baseName()
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
            if len(grps) > 1 : 
                grps = grps[:-2]
            print(grps)
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

        # add table layer and their relations
        try :
            properties = layertree['Properties']
        except KeyError:
            properties = {}
        try : 
            properties_custom = layertree_custom['Properties']
        except KeyError:
            properties_custom = {}
        for key, val in properties_custom.items():
            if key not in properties:
                properties[key] = val
        print(properties)
        for field in properties : 
            if not field.endswith('__ref') and properties.get(field+'__ref') :
                prop_layers = project.mapLayersByName(properties[field][0])
                if not prop_layers:
                    layer_name, sch, tbl, key = properties[field]
                    uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"'''
                    prop_layer = QgsVectorLayer(uri, layer_name, "postgres")
                    prop_layer.setDisplayExpression('val')
                    project.addMapLayer(prop_layer, False)
                    
                    root = project.layerTreeRoot()
                    g = root.findGroup('Properties') or root.insertGroup(-1, 'Properties')
                    g.addLayer(prop_layer)
                    if not prop_layer.isValid():
                        raise RuntimeError(f'layer {layer_name} is invalid')
                else : 
                    prop_layer = prop_layers[0]
                name, referencedField, referencingLayer, referencingField = properties[field+'__ref']
                referencedLayer = prop_layer.id()
                print(referencingLayer)
                referencingLayer = project.mapLayersByName(referencingLayer)[0].id()
                relation = QgsRelation(QgsRelationContext(project))
                relation.setName(name)
                relation.setReferencedLayer(referencedLayer)
                relation.setReferencingLayer(referencingLayer)
                relation.addFieldPair(referencingField, referencedField)
                relation.setStrength(QgsRelation.Association)
                relation.updateRelationStatus()
                relation.generateId()
                assert(relation.isValid())
                project.relationManager().addRelation(relation)
        
        g = root.findGroup(tr('Formulas')) or root.insertGroup(-1, tr('Formulas'))
        layer_name, sch, tbl, key = tr('Bloc recap'), 'api', 'input_output', 'b_type'
        if not len(project.mapLayersByName(layer_name)):
            uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"'''
            layer = QgsVectorLayer(uri, layer_name, "postgres")
            project.addMapLayer(layer, False)
            g.addLayer(layer)
            config = layer.editFormConfig()
            c = 0
            for f in layer.fields() : 
                if f.name() != 'default_formulas' :  
                    config.setReadOnly(c, True)
                c+=1
            layer.setEditFormConfig(config)
        
        layer_name, sch, tbl, key = tr('Formulas'), 'api', 'formulas', 'id'
        if not len(project.mapLayersByName(layer_name)):
            uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"'''
            layer = QgsVectorLayer(uri, layer_name, "postgres")
            project.addMapLayer(layer, False)
            g.addLayer(layer)
            config = layer.editFormConfig()
            c = 0
            for f in layer.fields() : 
                if f.name() in ['id', 'name'] :
                    config.setReadOnly(c, True)
                c+=1
            layer.setEditFormConfig(config)
        
        QGisProjectManager.load_qml(project, project_filename)
        project.write()
        
    @staticmethod
    def load_qml(project, project_filename):
        locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        lang = '' if locale == 'en' else '_fr'
        lang = ''
        for layer_name, tbl in QGisProjectManager.layers(project_filename).items():
            found_layers = project.mapLayersByName(layer_name)
            if len(found_layers):
                layer = found_layers[0]
                qml_basename = tbl+lang+'.qml'
                qml = os.path.join(_custom_qml_dir, qml_basename)
                if not os.path.exists(qml):
                    print('qml not found', qml)
                    qml = os.path.join(_qml_dir, qml_basename)
                print('founded qml', qml)
                layer.loadNamedStyle(qml)
    
    @staticmethod
    def update_qml(project, project_filename, f_details, inp_outs) : 
        import time 
        tic = time.time()
        # Pour l'instant on appelle à chaque ouverture de projet mais on pourrait vouloir ne pas toujours l'appeler
        locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        lang = '' if locale == 'en' else '_fr'
        lang = ''
        for layer_name, tbl in QGisProjectManager.layers(project_filename).items():
            found_layers = project.mapLayersByName(layer_name)
            if len(found_layers):
                layer = found_layers[0]
                qml_basename = tbl+lang+'.qml'
                qml = os.path.join(_custom_qml_dir, qml_basename)
                if not os.path.exists(qml):
                    print('qml not found', qml)
                    qml = os.path.join(_qml_dir, qml_basename)
            
                if tbl.endswith('_bloc') : 
                    b_types = tbl[:-5]
                    if f_details.get(b_types) :
                        config = layer.editFormConfig()
                        input_tab = None
                        output_tab = None
                        for tab in config.tabs() :
                            if re.match('Donnée.*so', tab.name()) :
                                output_tab = tab 
                            elif re.match('Donnée.*en', tab.name()) :
                                input_tab = tab
                        print(layer.name())
                        print('inp et out', input_tab, output_tab)
                        if input_tab and output_tab :
                            input_tab.clear()
                            output_tab.clear()
                            in2tab = {'inp' : {k : False for k in range(6)}, 'out' : {k : False for k in range(6)}}
                            level_container = {'inp' : {k : QgsAttributeEditorContainer('Niveau de détail %d' % k, input_tab) for k in range(6)}, 
                                            'out' : {k : QgsAttributeEditorContainer('Niveau de détail %d' % k, output_tab) for k in range(6)}}
                            level_container_children = {'inp' : {k : [] for k in range(6)}, 'out' : {k : [] for k in range(6)}}
                            fieldnames = [f.name() for f in layer.fields()]
                            field_fe = {}
                            for name in fieldnames :
                                if name.endswith('_fe') :
                                    field_fe[name[:-3]] = True

                            def treat_formula(formulas, lvl, in_or_out) :
                                sides = formulas.split('=')
                                if len(sides) == 2 : 
                                    group_field = read_formula(sides[1],  inp_outs[b_types][in_or_out])
                                for val in group_field : 
                                    idx = layer.fields().indexFromName(val)
                                    if field_fe.get(val) :
                                        container = QgsAttributeEditorContainer(val.upper(), level_container[in_or_out][lvl])
                                        container.setColumnCount(2)
                                        container.addChildElement(attrfield(val, idx, container))
                                        fe_idx = layer.fields().indexFromName(val+'_fe')
                                        container.addChildElement(attrfield(val+"_fe", fe_idx, container))
                                        # alias 
                                        layer.setFieldAlias(fe_idx, Alias.get(val+"_fe", ''))
                                        layer.setFieldAlias(idx, Alias.get(val, ''))
                                        
                                        # default value
                                        defval = QgsDefaultValue()
                                        prop_layer = project.mapLayersByName(val)[0]
                                        default_fe = layer.defaultValueDefinition(fe_idx)
                                        default_fe = default_fe.expression()
                                        #  f"attribute(get_feature(layer:='{prop_layer.id()}', attribute:='val', value:=coalesce(\"{fieldname}\", '{default}')), 'fe')"
                                        
                                        default_fe = re.sub("layer:='[^']+'", f"layer:='{prop_layer.id()}'", default_fe)
                                        defval.setExpression(default_fe)
                                        defval.setApplyOnUpdate(True)
                                        layer.setDefaultValueDefinition(fe_idx, defval)
                                        # indexOf = indexFromName d'après la doc
                                        # On va faire un test pas opti : 
                                        if val.upper() not in level_container_children[in_or_out][lvl] :
                                            level_container[in_or_out][lvl].addChildElement(container)
                                            level_container_children[in_or_out][lvl].append(val.upper())  
                                    else :    
                                        if val not in level_container_children[in_or_out][lvl] :
                                            level_container[in_or_out][lvl].addChildElement(attrfield(val, idx, level_container[in_or_out][lvl]))
                                            level_container_children[in_or_out][lvl].append(val)
                                            layer.setFieldAlias(idx, Alias.get(val, ''))
                                    in2tab[in_or_out][lvl] = True
                                return
                            print(f_details)
                            for formulas, lvl in f_details[b_types].items() : 
                                treat_formula(formulas, lvl, 'inp')
                                treat_formula(formulas, lvl, 'out')
                            
                            for in_or_out in in2tab : 
                                for lvl in in2tab[in_or_out] : 
                                    if in2tab[in_or_out][lvl] :
                                        if in_or_out == 'inp' :
                                            input_tab.addChildElement(level_container[in_or_out][lvl])
                                        else :
                                            output_tab.addChildElement(level_container[in_or_out][lvl])
                            print(layer.name(), config.tabs()[-1].children())
                            layer.setEditFormConfig(config)
                            layer.saveNamedStyle(qml)
        print('temps', time.time()-tic)
                        
                            
                    
                    
                    
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

        if _svg_dir not in QSettings().value('svg/searchPathsForSVG', []):
            path = QSettings().value('svg/searchPathsForSVG', []) + [_svg_dir]
            QSettings().setValue('svg/searchPathsForSVG', path)

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
        # project.setTrustLayerMetadata(True)

        QGisProjectManager.update_project(project_filename, project)

    @staticmethod
    def save_custom_qml(project_filename):
        if not os.path.isdir(_custom_qml_dir):
            os.mkdir(_custom_qml_dir)

        locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        lang = '' if locale == 'en' else '_fr'

        for layer_name, tbl in QGisProjectManager.layers(project_filename).items():
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
