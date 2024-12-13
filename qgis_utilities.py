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
import time
import os
from pathlib import Path
import re
import tempfile
from qgis.core import Qgis, QgsProject, QgsCoordinateReferenceSystem, QgsVectorLayer, QgsApplication, QgsRelation, QgsRelationContext, QgsSettings, QgsSnappingConfig, QgsTolerance, qgsfunction, QgsMessageLog, QgsMeshLayer, QgsAttributeEditorContainer, QgsAttributeEditorField as attrfield, QgsDefaultValue, QgsRasterLayer, QgsExpression, QgsOptionalExpression
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
_columns_to_hide = set(['shape', 'formula', 'b_type', 'geom_ref'])
Alias = {'ngl' : 'NGL (kgNGL/an)', 'ngl_s' : 'NGL sortant (kgNGL/an)', 'fen2o_oxi' : 'Oxygène du milieu', 'dco' : 'DCO (kgDCO/an)', 'dco_s' : 'DCO sortant (kgDCO/an)', 
         'fech4_mil' : 'Milieu', 
         'qe' : 'Débit entrant (m3/j)', 'eh' : 'Equivalent Habitants', 'tbentrant' : 'Tonne de boue en amont de la filière boue (tMS/an)', 'eh_fe' : ' ', 'welec' : 'Welec (kWh/an)',
         'dco_elim' : 'DCO éliminée (kgDCO/an)', 'tsejour' : 'Temps de séjour', 'tjour' : 'Stockage en jour', 'h' : 'Hauteur (m)', 'long' : 'Longueur (m)',
         'larg' : 'Largeur (m)', 'vit' : 'Vitesse (m/h)', 'tbsortant' : 'Tonne de boue entrant (tMS/an)', 
         'tbsortant_s' : 'Tonne de boue sortant (tMS/an)', 'e' : 'Epaisseur de voile (m)', 
         'taur' : 'Taux de recirculation', 'tauenterre' : 'Taux d\'enterrement', 'prop_l' : 'rapport longueur/largeur', 'vu' : 'Volume utile (m3)', 
         'vbiogaz' : 'Volume de biogaz produit (m3/an)', 'cad' : 'Cadence pelleteuse (m3/h)', 'gros' : 'Dégrillage supérieur à 20mm', 
         'compd' : 'Avec ou sans compactage', 'compt' : 'Avec ou sans compactage', 'qe_s' : 'Débit sortant (m3/j)', 
         'munite_tamis' : 'Masse du tamis (kg)', 'munite_degrilleur' : 'Masse du dégrilleur (kg)', 'qmax' : 'Débit maximal (m3/j)', 
         'qdechet' : 'Méthode de compactage', 'qdechet_fe':'Volume de déchet (L/EH/an)','dbo5' : 'DBO5 (kgDBO5/an)', 'dbo5elim' : 'DBO5 éliminée (kgDBO5/an)', 
         'w_dbo5_eau' : 'Consommation électrique en fonction de la DBO5 (kWh/an/DBO5)', 's_geom_eh' : 'Surface en fonction des EH (m2/EH)',
         'tsables' : 'Tonne de sable (t/an)', 'tgraisses' : 'Tonne de graisses (t/an)', 'charge_bio' : 'Taux de charge', 'charge_bio_fe' : 'Valeur (kgDBO5/m3/j)',
         'siccite_e' : 'Siccité de la boue entrante', 'siccite_s' : 'Siccité de la boue sortante', 'tee' : "Tonne d'eau évaporée (t/an)",
         'festock' : 'Taille du stockage', 'q_poly' : 'Quantité de polymère (kg/an)', 'transp_poly' : "Distance d'approxivisionnement du polymère (km)",
         'q_chaux' : 'Quantité de chaux (kg/an)', 'transp_chaux' : "Distance d'approxivisionnement de la chaux (km)",
         'q_fecl3' : 'Quantité de FeCl3 (kg/an)', 'transp_fecl3' : "Distance d'approxivisionnement du FeCl3 (km)",
         'vboue' : 'Volume de boue entrante (m3/an)', 'q_anio' : "Quantité de réactif anionique (kg/an)", 'transp_anio' : "Distance d'approxivisionnement du réactif anionique (km)",
         'q_catio' : "Quantité de réactif cationique (kg/an)", 'transp_catio' : "Distance d'approxivisionnement du réactif cationique (km)", 
         'ml' : 'Mètre linéaire', 's' : 'Surface (m2)', 'ebit' : 'Epaisseur de bitume (m)', 'vterre' : 'Volume de terre excavée (m3)', 
         'fecc' : 'Taille de la cuve', 'mes' : 'Matière en suspension (kgMES/an)', 'prod_e' : 'Réactifs', 'pelletisation' : 'Présence de pelletisation',
         'lavage' : 'Sables lavé ?', 'conc' : 'Graisses concentrées ?', 'aere' : 'Avec aération', 'grand' : 'Diamètre supérieur à 2m', 
         'dbo' : 'DBO en amont de la filière boue (kgDBO/an)', 'Niveau de détail 1' : 'Conception générale', 'Niveau de détail 2' : 'Conception détaillée',
         'Niveau de détail 3' : 'Etude de faisabilité', 'Niveau de détail 4' : 'Conception très détaillée', 'Niveau de détail 5' : "Précision maximale",
         'Niveau de détail 6' : "Intrants (Comptabilisé même pour les sur blocs)", 'feexpl' : 'Type de structure',
         'methode' : 'Procédé principale de la filière', 'methode_fe' : 'Consommation électrique (kWh/DBO5 éliminé)', 
         'model' : 'Modèle', 'name' : 'Nom', 'd_vie' : 'Durée de vie', 'dcoelim' : 'DCO éliminée (kgDCO/an)', 'ntkelim' : 'NTK éliminée (kgNTK/an)',
         'methode_2' : 'Procédé principale de la filière', 'methode_2_fe' : 'N2O émis par NTK éliminé (kgN2O/kgNTK)'
         }
Alias_intrant = {
    "q_hcl": "Acide chlorhydrique",
    "q_citrique": "Acide citrique",
    "q_phosphorique": "Acide phosphorique",
    "q_nitrique": "Acide nitrique",
    "q_sulf": "Acide sulfurique",
    "q_ethanol": "Éthanol",
    "q_antiscalant": "Antiscalants",
    "q_nahso3": "Bisulfite de sodium",
    "q_caco3": "Carbonate de calcium",
    "q_soude_c": "Cristaux de soude",
    "q_ca_regen": "Régénérant de calcium",
    "q_ca_neuf": "Calcium neuf",
    "q_ca_poudre": "Poudre de calcium",
    "q_chaux": "Chaux",
    "q_cl2": "Chlore",
    "q_naclo3": "Chlorate de sodium",
    "q_anti_mousse": "Antimousse",
    "q_mhetanol": "Méthanol",
    "q_oxyl": "Oxygène liquide",
    "q_kmno4": "Permanganate de potassium",
    "q_h2o2": "Peroxyde d’hydrogène",
    "q_poly": "Floculant",
    "q_anio": "Résine anionique",
    "q_catio": "Résine cationique",
    "q_rei": "Résine échangeuse d’ions",
    "q_sable_t": "Sable de filtration",
    "q_soude": "Soude",
    "q_sulf_alu": "Sulfate d’aluminium",
    "q_sulf_sod": "Sulfate de sodium",
    "q_uree": "Urée", 
    "q_fecl3": "Chlorure ferrique", 
    "q_co2l": "CO2 liquide",
    "q_coagl": "Coagulant liquide",
    "q_javel": "Eau de javel",
    "q_lait": "Lait de chaux"
}
ConstrOnly = set(['cad', 'e', 'tauenterre'])

Input_and_output = set(['tbentrant'])

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
            QGisProjectManager.refresh_layers(value)

    @staticmethod
    def refresh_layers(model_name):
        if iface is not None:
            for layer in iface.mapCanvas().layers():
                layer.setSubsetString(f"model = '{model_name}'")
                

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

        cv = QgsProject.instance().customVariables()
        current_model = cv.get('current_model', None)
        if current_model:
            QGisProjectManager.refresh_layers(current_model)
        
        # add layers if they are not already there
        root = project.layerTreeRoot()
        name_id_map = {layer.name(): layer.layerId() for layer in root.findLayers()}
        
        layertree = QGisProjectManager.layertree()
        layertree_custom = QGisProjectManager.layertree_custom(project_filename)
        # print("layertree : ", layertree_custom)
        properties, paths = get_all_properties("bloc", layertree)
        # print(get_all_properties("bloc", layertree_custom))
        prop2, paths2 = get_all_properties("bloc", layertree_custom) if layertree_custom else ([], [])
        # print("bonjour")
        # print(properties, paths, prop2, paths2) 
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
            uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"''' + (' (geom)' if grp != tr('Propriété') and grp != tr('Formules') else '')
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
            elif key.endswith('__ref') :
                properties[key] += val
        # print(properties)
        
        QGisProjectManager.load_qml(project, project_filename)
        # On load avant pour que les relations définies dans les qml soient prises en compte je sais pas pourquoi marche pas sur ancien projet.
        print('LES RELATIONS')
        print(project.relationManager().relations())
        
        for field in properties : 
            print('YOOOO', field)
            if not field.endswith('__ref') and properties.get(field+'__ref') :
                prop_layers = project.mapLayersByName(Alias.get(properties[field][0], properties[field][0]))
                if not prop_layers:
                    layer_name, sch, tbl, key = properties[field]
                    layer_name = Alias.get(layer_name, layer_name)
                    uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"'''
                    prop_layer = QgsVectorLayer(uri, layer_name, "postgres")
                    prop_layer.setDisplayExpression('val')
                    project.addMapLayer(prop_layer, False)
                    
                    root = project.layerTreeRoot()
                    g = root.findGroup(tr('Propriétés')) or root.insertGroup(-1, tr('Propriétés'))
                    g.addLayer(prop_layer)
                    if not prop_layer.isValid():
                        raise RuntimeError(f'layer {layer_name} is invalid')
                else : 
                    prop_layer = prop_layers[0]
                refs = properties[field+'__ref']
                for ref in refs : 
                    name, referencedField, referencingLayer, referencingField = ref
                    if not len(project.relationManager().relationsByName(name)):
                        print("On est passé")
                        referencedLayer = prop_layer.id()
                        print(name, referencedField, referencingLayer, referencingField)
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
                    else : 
                        print('Relation déjà là !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        
        g = root.findGroup(tr('Formules')) or root.insertGroup(-1, tr('Formules'))
        layer_name, sch, tbl, key = tr('Bloc recapitulatif'), 'api', 'input_output', 'b_type'
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
        
        layer_name, sch, tbl, key = tr('Formules'), 'api', 'formulas', 'id'
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
        
        layer_name, sch, tbl, key = tr('Index'), 'api', 'alias_table', 'name'
        if not len(project.mapLayersByName(layer_name)):
            uri = f'''dbname='{project_name}' service='{get_service()}' sslmode=disable key='{key}' checkPrimaryKeyUnicity='0' table="{sch}"."{tbl}"'''
            layer = QgsVectorLayer(uri, layer_name, "postgres")
            project.addMapLayer(layer, False)
            g.addLayer(layer)
            config = layer.editFormConfig()
            c = 0
            for f in layer.fields() : 
                config.setReadOnly(c, True)
                c+=1
            layer.setEditFormConfig(config)
                    
        
        project.write()

    
    @staticmethod
    def hide_columns(layer, columns) :
        config = layer.attributeTableConfig()
        cols = config.columns()
        for col in cols : 
            if col.name in columns :
                col.hidden = True
        config.setColumns(cols)
        layer.setAttributeTableConfig(config)
        
    
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
                doc = QDomDocument()
                doc.setContent(QFile(qml))
                root = doc.documentElement()
                referencedLayers = root.firstChildElement('referencedLayers')
                while referencedLayers.childNodes().count():
                    referencedLayers.removeChild(referencedLayers.firstChild())
                with open(qml, 'w', encoding='utf-8') as f:
                    f.write(doc.toString(2))
                # J'ai pas trouvé mieux que de réécrire tout le fichier.
                layer.loadNamedStyle(qml)
                QGisProjectManager.hide_columns(layer, _columns_to_hide)  
    
    @staticmethod
    def save_qml2ressource(project, layertree) : 
        locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        lang = '' if locale == 'en' else '_fr'
        lang = ''
        blocs = get_all_properties("bloc", layertree)[0]
        layers = {bloc[0] : bloc[2] for bloc in blocs}
        for layer_name, tbl in layers.items() : 
            found_layers = project.mapLayersByName(layer_name)
            if len(found_layers):
                layer = found_layers[0]
                qml_basename = tbl+lang+'.qml'
                qml = os.path.join(_qml_dir, qml_basename)
                custom_qml = os.path.join(_custom_qml_dir, qml_basename)
                if not os.path.exists(qml) and os.path.exists(custom_qml):
                    layer.saveNamedStyle(qml)
                    
        
        
    @staticmethod
    def update_qml(project, project_filename, f_details, inp_outs, f_inputs) : 
    
        tic = time.time()
        # Pour l'instant on appelle à chaque ouverture de projet mais on pourrait vouloir ne pas toujours l'appeler
        locale = QgsSettings().value('locale/userLocale', 'fr_FR')[0:2]
        lang = '' if locale == 'en' else '_fr'
        lang = ''
        layers = project.mapLayers()
        dico_layer = {layer.name() : (layer, id) for id, layer in layers.items()}
        for layer_name, tbl in QGisProjectManager.layers(project_filename).items():
            found_layer = dico_layer[layer_name]
            print('temps de finding layers', time.time()-tic)
            if found_layer:
                layer = found_layer[0]
                qml_basename = tbl+lang+'.qml'
                qml = os.path.join(_custom_qml_dir, qml_basename)
                if not os.path.exists(qml):
                    print('qml not found', qml)
                    qml = os.path.join(_qml_dir, qml_basename)
                print('founded qml', qml)
                if tbl.endswith('_bloc') : 
                    b_types = tbl[:-5]
                    # if layer_name == 'Canalisation' :
                    #     print('\nMais Non il est LA !!!\n')
                    #     print('b_types', b_types)
                    #     print('f_details', f_details[b_types])
                    #     print('inp_outs', inp_outs[b_types])

                    if f_details.get(b_types) :
                        if not f_inputs.get(b_types) :
                            f_inputs[b_types] = {}
                        if inp_outs[b_types]['concrete'] :
                            print('Avant update', time.time()-tic)
                            QGisProjectManager.update1qml(dico_layer, layer, qml, f_details[b_types], inp_outs[b_types], f_inputs[b_types])
        print('temps', time.time()-tic)
                        
                            
    @staticmethod
    def update1qml(dico_layer, layer, qml, f_details, inp_outs, f_inputs, rapid = 0) : 
        t1 = time.time()
        
        try : layer.loadNamedStyle(qml)
        except : pass
        config = layer.editFormConfig()
        try : config.setLayout(Qgis.AttributeFormLayout(1)) # y'a des versions de qgis où ça marche pas
        except : rapid = 2
        # En attendant pour pas que ce soit toujours trop long de tout recharger, plus tard y'aura un json propre qui permettra de gérer les blocs
        fieldnames = [f.name() for f in layer.fields()]
        field_fe = set()
        field_intrant = set()
        for field in fieldnames :
            if field == 'model' : 
                defval = QgsDefaultValue()
                defval.setExpression("@current_model")
                layer.setDefaultValueDefinition(layer.fields().indexFromName(field), defval)
                
            if field.endswith('_fe') :
                field_fe.add(field[:-3])
                defval = QgsDefaultValue()
                fe_idx = layer.fields().indexFromName(field)
                prop_id = dico_layer[Alias.get(field[:-3], field[:-3])][1]
                default_fe = layer.defaultValueDefinition(fe_idx)
                default_fe = f"attribute(get_feature(layer:='{prop_id}', attribute:='val', value:=\"{field[:-3]}\"), 'fe')"
                defval.setExpression(default_fe)
                defval.setApplyOnUpdate(True)
                layer.setDefaultValueDefinition(fe_idx, defval)
                layer.setFieldAlias(fe_idx, Alias.get(field, 'FE'))
            elif field.startswith('q_') or field.startswith('transp_') : 
                field_intrant.add(field)
                if field.startswith('q_') :
                    layer.setFieldAlias(layer.fields().indexFromName(field), 'Quantité de '+Alias_intrant[field])
                else : 
                    layer.setFieldAlias(layer.fields().indexFromName(field), 'Distance d\'approvisionnement')
            else : 
                layer.setFieldAlias(layer.fields().indexFromName(field), Alias.get(field, field))
        if rapid == 2 : return
        if rapid == 1 :
            for tab in config.tabs() :
                if tab.name() in ['Exploitation', 'Construction'] : 
                    print("Déjà bien configuré")
                    return
        # print('on va configurer')
        config.clearTabs()
        
        name = attrfield(Alias.get('name', 'name'), layer.fields().indexFromName('name'), None)
        model = attrfield(Alias.get('model', 'model'), layer.fields().indexFromName('model'), None)
        d_vie = attrfield(Alias.get('d_vie', 'd_vie'), layer.fields().indexFromName('d_vie'), None)
        config.addTab(name)
        config.addTab(model)
        config.addTab(d_vie)
        
        expl_tab = QgsAttributeEditorContainer('Exploitation', None)
        expl_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(expl_tab)
        constr_tab = QgsAttributeEditorContainer('Construction', None)
        constr_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(constr_tab)
        
        input_tab = QgsAttributeEditorContainer('Entrée', None)
        input_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(input_tab)
        
        output_tab = QgsAttributeEditorContainer('Sortie', None)
        output_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(output_tab)
            
        lvlmax = 6
        in2tab = {'constr' : {k : False for k in range(lvlmax+1)}, 'expl' : {k : False for k in range(lvlmax+1)}, 'input' : {k : False for k in range(lvlmax+1)}}
        in2tab_constr = {'constr' : {k : False for k in range(lvlmax+1)}, 'expl' : {k : False for k in range(lvlmax+1)}, 
                         'input' : {k : False for k in range(lvlmax+1)}}
        in2tab_default = {'constr' : {k : False for k in range(lvlmax+1)}, 'expl' : {k : False for k in range(lvlmax+1)}, 
                          'input' : {k : False for k in range(lvlmax+1)}}
        level_container = {'constr' : {k : QgsAttributeEditorContainer(Alias.get('Niveau de détail %d' % k, 'Niveau de détail %d' % k), constr_tab) for k in range(lvlmax+1)},
                        'expl' : {k : QgsAttributeEditorContainer(Alias.get('Niveau de détail %d' % k, 'Niveau de détail %d' % k), expl_tab) for k in range(lvlmax+1)}, 
                        'input' : {k : QgsAttributeEditorContainer(Alias.get('Niveau de détail %d' % k, 'Niveau de détail %d' % k), input_tab) for k in range(lvlmax+1)}
                        }
        constr_container = {'constr' : {k:QgsAttributeEditorContainer('Valeurs par défaut construction', constr_tab) for k in range(lvlmax+1)}, 
                            'expl' : {k:QgsAttributeEditorContainer('Valeurs par défaut construction', expl_tab) for k in range(lvlmax+1)}, 
                            'input' : {k:QgsAttributeEditorContainer('Valeurs par défaut construction', input_tab) for k in range(lvlmax+1)}}
        default_container = {'constr' : {k:QgsAttributeEditorContainer('Valeurs par défaut spécifiques', constr_tab) for k in range(lvlmax+1)},
                             'expl' : {k:QgsAttributeEditorContainer('Valeurs par défaut spécifiques', expl_tab) for k in range(lvlmax+1)}, 
                             'input' : {k:QgsAttributeEditorContainer('Valeurs par défaut spécifiques', input_tab) for k in range(lvlmax+1)}}
        level_container_children = {'constr' : {k : set() for k in range(lvlmax+1)}, 'expl' : {k : set() for k in range(lvlmax+1)}, 
                                    'input' : {k : set() for k in range(lvlmax+1)}}
        def treat_formula(f_name, formulas, f_inputs, lvl) :
            # cont_name = f_name.split()
            # cont_name = ' '.join(cont_name[:-2] + cont_name[-1:])
            cont_name = f_name
            sides = formulas.split('=')
            group_field = []
            c_or_e = 'constr'
            # print(sides)
            if len(sides) == 2 : 
                group_field = read_formula(sides[1],  inp_outs['inp'])
                # print('group_field', group_field)
                if sides[0].strip().endswith('_c') : 
                    c_or_e = 'constr'
                elif sides[0].strip().endswith('_e') :
                    c_or_e = 'expl'
                else :
                    c_or_e = 'input'
                f_container = QgsAttributeEditorContainer(cont_name, level_container[c_or_e][lvl])
            flag_intrant2 = False
            flag_intrant1 = 'prod_e' in fieldnames 
            for val in group_field : 
                idx = layer.fields().indexFromName(val)
                if val in field_fe :
                    container = QgsAttributeEditorContainer(Alias.get(val, val).upper(), level_container[c_or_e][lvl])
                    container.setColumnCount(2)
                    container.addChildElement(attrfield(val, idx, container))
                    fe_idx = layer.fields().indexFromName(val+'_fe')
                    container.addChildElement(attrfield(val+"_fe", fe_idx, container))
                    
                    if val.upper() not in level_container_children[c_or_e][lvl] :
                        f_container.addChildElement(container)
                        # level_container[c_or_e][lvl].addChildElement(container)
                        level_container_children[c_or_e][lvl].add(val.upper()) 
                elif val in field_intrant and flag_intrant1 :
                    if not flag_intrant2 :
                        flag_intrant2 = True
                        field_prod = layer.fields().indexFromName('prod_e')
                        # level_container[c_or_e][lvl].addChildElement(attrfield('prod_e', field_prod, level_container[c_or_e][lvl]))
                        f_container.addChildElement(attrfield('prod_e', field_prod, f_container))
                        level_container_children[c_or_e][lvl].add(field_prod)
                        for intr in field_intrant : 
                            if intr.startswith('q_') :
                                q_intr = intr 
                                transp_intr = 'transp_'+intr[2:]
                            else : 
                                q_intr = 'q_'+intr[7:]
                                transp_intr = intr
                            if intr == q_intr : 
                                # row = QgsAttributeEditorContainer(intr, level_container[c_or_e][lvl])
                                row = QgsAttributeEditorContainer(intr, f_container)
                                row.setType(Qgis.AttributeEditorContainerType(2))
                                row.setVisibilityExpression(QgsOptionalExpression(QgsExpression(f"\"prod_e\" = '{Alias_intrant[q_intr]}'")))
                                row.addChildElement(attrfield(q_intr, layer.fields().indexFromName(q_intr), row))
                                row.addChildElement(attrfield(transp_intr, layer.fields().indexFromName(transp_intr), row))
                                f_container.addChildElement(row)
                                # level_container[c_or_e][lvl].addChildElement(row)
                            
                elif val in f_inputs : 
                    if val not in level_container_children[c_or_e][lvl] :
                        if val in ConstrOnly : 
                            constr_container[c_or_e][lvl].addChildElement(attrfield(val, idx, constr_container[c_or_e][lvl]))
                            in2tab_constr[c_or_e][lvl] = True
                        else :
                            default_container[c_or_e][lvl].addChildElement(attrfield(val, idx, default_container[c_or_e][lvl]))
                            in2tab_default[c_or_e][lvl] = True
                else : 
                    # print("avant c_or_e", c_or_e, lvl, val)   
                    if val not in level_container_children[c_or_e][lvl] :
                        # print("c_or_e", c_or_e, lvl, val)
                        # level_container[c_or_e][lvl].addChildElement(attrfield(val, idx, level_container[c_or_e][lvl]))
                        f_container.addChildElement(attrfield(val, idx, f_container))
                        level_container_children[c_or_e][lvl].add(val)
                        # layer.setFieldAlias(idx, Alias.get(val, ''))
                        
            level_container[c_or_e][lvl].addChildElement(f_container)
            in2tab[c_or_e][lvl] = True
            return set(group_field)
        treated = set()
        t2 = time.time()
        # print('temps avant', t2-t1)
        for formula_name, f in f_details.items() :
            formula, lvl = f 
            treated = treated.union(treat_formula(formula_name, formula, f_inputs, lvl))
        t3 = time.time()
        # print('temps après boucle', t3-t2)

        for c_or_e in in2tab : 
            for lvl in in2tab[c_or_e] : 
                if in2tab[c_or_e][lvl] :
                    if  in2tab_constr[c_or_e][lvl] :
                        constr_container[c_or_e][lvl].setCollapsed(True)
                        level_container[c_or_e][lvl].addChildElement(constr_container[c_or_e][lvl])
                    if in2tab_default[c_or_e][lvl] :
                        default_container[c_or_e][lvl].setCollapsed(True)
                        level_container[c_or_e][lvl].addChildElement(default_container[c_or_e][lvl])
                    if c_or_e == 'constr' :
                        constr_tab.addChildElement(level_container[c_or_e][lvl])
                    elif c_or_e == 'expl' :
                        expl_tab.addChildElement(level_container[c_or_e][lvl])
                    elif c_or_e == 'input' :
                        input_tab.addChildElement(level_container[c_or_e][lvl])
                    
        def addval2tab(val, tab) : 
            idx = layer.fields().indexFromName(val)
            # print("sortie", val, idx)
            if val in field_fe : 
                
                container = QgsAttributeEditorContainer(Alias.get(val, val).upper(), tab)
                container.setColumnCount(2)
                container.addChildElement(attrfield(val, idx, container))
                fe_idx = layer.fields().indexFromName(val+'_fe')
                container.addChildElement(attrfield(val+"_fe", fe_idx, container))
                tab.addChildElement(container)
            else:
                tab.addChildElement(attrfield(val, idx, tab))
                
        for val in inp_outs['out'] :
            addval2tab(val, output_tab)
        for val in inp_outs['inp'] : 
            flag_in = False
            if val[-2:] == '_e' : 
                flag_in = True
            elif val + '_s' in inp_outs['out'] :
                flag_in = True
            if val=='prod_e' :
                flag_in = False
            if val in Input_and_output :
                flag_in = True
            if flag_in :
                addval2tab(val, input_tab)
        
        for field in field_fe : 
            idx = layer.fields().indexFromName(field[:-3])
            layer.setFieldAlias(idx, ' ')
                 
        t4 = time.time()
        # print('temps après boucle 2', t4-t3)
        layer.setEditFormConfig(config)
        # print('temps edit form config', time.time()-t4)
        layer.saveNamedStyle(qml)
        
        return
                
                
        
                    
                    
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
        lang = ''

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
