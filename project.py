# coding=utf-8

"""
cycle module to handle project
"""
import os
import psycopg2
from psycopg2.extras import LoggingConnection
import logging
from .database import create_project, autoconnection
from .utility.log import LogManager, ConsoleLogger
from .qgis_utilities import QGisProjectManager, Alias, Alias_intrant, tr
from .utility.string import normalized_name
from .service import get_service
from qgis.core import QgsProject, QgsRasterLayer, QgsDefaultValue

CURRENT_DIR = os.path.dirname(__file__)
CYCLE_DIR = os.path.join(os.path.expanduser('~'), ".cycle")

def project_directory(project_name):
    assert project_name == normalized_name(project_name)
    dir_ = os.path.join(os.path.expanduser('~'), ".cycle", project_name)
    if os.path.isfile(dir_+'.path'):
        with open(dir_+'.path') as f:
            dir_ = f.read().strip()
    return dir_

def backup_directory(project_name):
    d = project_directory(project_name)
    if not os.path.exists(os.path.join(d, 'autosave')):
        os.makedirs(os.path.join(d, 'autosave'))
    return os.path.join(d, 'autosave')


class Project(object):

    @staticmethod
    def create_new_project(project_name, srid, directory = CYCLE_DIR, log_manager = LogManager(ConsoleLogger(), "Cycle")):
        def create_new_project(project_name, srid, directory=CYCLE_DIR, log_manager=LogManager(ConsoleLogger(), "Cycle")):
            """
            Crée un nouveau projet avec un nom et un SRID spécifiés, initialise le répertoire du projet et crée un fichier .path si nécessaire.
            """
        
        assert project_name == normalized_name(project_name)
        create_project(project_name, srid)
        project = Project(project_name, log_manager)
        # create .path file if project directory is not in .cycle
        if not os.path.normpath(directory) == os.path.normpath(CYCLE_DIR):
            with open(os.path.join(CYCLE_DIR, f"{project_name}.path"), 'w') as f:
                f.write(os.path.join(directory, project_name))

        log_manager.cleanup()
        log_manager.notice(f"Project {project_name} created")
        return project

    # @property
    # def engine(self):
    #     return 'xeau' if 'CYCLE_ENGINE' not in os.environ else os.environ['CYCLE_ENGINE']

    @property
    def name(self):
        return self.__name

    @property
    def srid(self):
        return self.fetchone("select srid from api.metadata")[0]

    @property
    def version(self):
        return self.fetchone("select cycle_version()")[0]

    @property
    def has_api(self):
        try:
            res = self.fetchone("select srid from api.metadata")
            return res is not None and len(res) == 1
        except psycopg2.errors.UndefinedTable:
            return False

    @property
    def directory(self):
        return project_directory(self.name)

    @property
    def data_directory(self):
        if not os.path.exists(os.path.join(self.directory, 'data')):
            os.makedirs(os.path.join(self.directory, 'data'))
        return os.path.join(self.directory, 'data')

    @property
    def backup_directory(self):
        return backup_directory(self.name)

    @property
    def qgs(self):
        assert self.name == normalized_name(self.name)
        return os.path.join(self.directory, f"{self.name}.qgs")

    @property
    def models(self):
        try:
            return [model for model, in self.fetchall("select name from api.model order by name")]
        except psycopg2.errors.InsufficientPrivilege:
            return []

    @property
    def scenarios(self):
        return [scenario for scenario, in self.fetchall("select name from api.scenario order by name")]

    @property
    def configurations(self):
        return [config for config, in self.fetchall("select name from api.configuration order by name")]

    @property
    def current_config(self):
        return self.fetchone("select api.current_config()")[0]

    @current_config.setter
    def current_config(self, value):
        self.execute("select api.set_current_config(%s)", (value,))

    @property
    def current_model(self):
        return QGisProjectManager.get_qgis_variable('current_model')

    @current_model.setter
    def current_model(self, value):
        QGisProjectManager.set_qgis_variable('current_model', value)

    @property
    def current_scenario(self):
        return QGisProjectManager.get_qgis_variable('current_scenario')


    @current_scenario.setter
    def current_scenario(self, value):
        QGisProjectManager.set_qgis_variable('current_scenario', value)


    def __init__(self, project_name, log_manager = LogManager(ConsoleLogger(), "Cycle"), debug = False):
        if project_name != normalized_name(project_name):
            log_manager.error(f"Project name {project_name} is not normalized {normalized_name(project_name)}")
        assert project_name == normalized_name(project_name)
        self.log = log_manager
        self.log.cleanup()
        self.__name = project_name
        self.__debug = debug
        # create project directory if not exists
        if not os.path.exists(self.directory):
            os.mkdir(self.directory)

    def add_new_model(self, model):
        self.execute(f"insert into api.model(name) values('{model}')")
        self.current_model = model
        self.log.notice(f"model {model} created")

    def add_new_config(self, config):
        self.execute(f"insert into api.configuration(name) values('{config}')")
        self.current_config = config
        self.log.notice(f"configuration {config} created")

    def delete_model(self, model):
        if model in self.models:
            self.execute(f"delete from api.model where name='{model}'")
            if self.current_model == model:
                self.current_model = self.models[0] if len(self.models) else None
            self.log.notice(f"Model {model} deleted")

    def add_new_scenario(self, scenario):
        self.execute(f"insert into api.scenario(name) values('{scenario}')")
        self.current_scenario = scenario
        self.log.notice(f"Scenario {scenario} created")

    def delete_scenario(self, scenario):
        if scenario in self.scenarios:
            self.execute(f"delete from api.scenario where name='{scenario}'")
            if self.current_scenario == scenario:
                self.current_scenario =self.scenarios[0] if len(self.scenarios) else None
            self.log.notice(f"Scenario {scenario} deleted")

    def connect(self):
        conn = psycopg2.connect(database=self.name, service=get_service(), connection_factory=LoggingConnection)
        logging.basicConfig(level=logging.ERROR if not self.__debug else logging.DEBUG)
        logger = logging.getLogger(__name__)
        conn.initialize(logger)
        return conn

    def vacuum_analyse(self, table=''):
        self.execute("vacuum analyse "+table)

    def fetchone(self, query, param=None):
        with autoconnection(self.name, debug=self.__debug) as con, con.cursor() as cur:
            cur.execute(query, param)
            r = cur.fetchone()
            return tuple(r) if r else None

    def fetchall(self, query, param=None):
        with autoconnection(self.name, debug=self.__debug) as con, con.cursor() as cur:
            cur.execute(query, param)
            return list(cur.fetchall())

    def execute(self, query, param=None):
        with autoconnection(self.name, debug=self.__debug) as con, con.cursor() as cur:
            cur.execute(query, param)

    def executemany(self, query, param):
        with autoconnection(self.name, debug=self.__debug) as con, con.cursor() as cur:
            cur.executemany(query, param)

    def get_values4qml(self):
        """
        regroupe les informations du tableaux input_output et formulas pour pouvoir ensuite les afficher correctement dans les QMLs
        """
        raw_inp_out = self.fetchall('select * from api.input_output')
        input_output = {elem[0] : {'inp' : elem[1], 'out' : elem[2], 'concrete' : elem[-1]} for elem in raw_inp_out}
        query = """
        select jsonb_build_object(b_type, jsonb_agg(jsonb_build_object(
                    'name', f.name,
                    'formula', f.formula,
                    'detail_level', f.detail_level
                )
            )
        ) 
        from api.input_output i_o 
        join api.formulas f on f.name = any(i_o.default_formulas) 
        group by b_type;
        """
        list_f_details = self.fetchall(query)
        f_details = {}
        for elem in list_f_details:
            if elem[0] : 
                for key, value in elem[0].items():
                    f_details[key] = {elem['name'] : [elem['formula'], elem['detail_level']] for elem in value}
        raw_f_inputs = self.fetchone("select api.select_default_input_output() ;")
        f_inputs = raw_f_inputs[0]
        
        return input_output, f_details, f_inputs
    
    def bloc_tree(self) : 
        return self.fetchone("select api.bloc_tree()")[0]
    
    def create_index(self) : 
        # Crée la table des Alias dans la base de données pour pouvoir la visualisée. Il faudra à terme tout passer dans la base de données.
        try : 
            Alias_jsonb = ''
            for key, val in Alias.items() : 
                key = key.replace("'", "''")
                val = val.replace("'", "''")
                Alias_jsonb += f'"{key}" : "{val}",'
            Alias_jsonb = "{"+Alias_jsonb[:-1]+"}"
            self.execute(f"select api.fill_alias_table('{Alias_jsonb}'::jsonb)")
            Alias_jsonb_intrant = str(Alias_intrant).replace("'", '"')
            self.execute(f"select api.fill_alias_table('{Alias_jsonb_intrant}'::jsonb)")
        except : 
            print('Alias table none existant')
            
    def post_traitement(self) : 
        # On fait ce qui ne peut pas être fait dans qgis_utilities (ps : je ne sais pas pourquoi ça ne peut pas être fait dans qgis_utilities)
        
        Qproject = QgsProject.instance()
        root = Qproject.layerTreeRoot()
        
        # Ajoute la couche openstreet map sur la carte.
        
        urlWithParams = 'type=xyz&url=https://a.tile.openstreetmap.org/%7Bz%7D/%7Bx%7D/%7By%7D.png&zmax=19&zmin=0&crs=EPSG3857'
        layers = Qproject.mapLayersByName('OpenStreetMap')
        if not layers : 
            rlayer = QgsRasterLayer(urlWithParams, 'OpenStreetMap', 'wms')
            if rlayer.isValid() : 
                Qproject.addMapLayer(rlayer)
                root.addLayer(rlayer)
                root.removeLayer(root.findLayers()[0].layer())
                Qproject.write()
        
        # Rectification couche diamètre (ajouter bizarrement comment qml chargé)
        diam_layers = Qproject.mapLayersByName('diam')
        print('\ndiam_layers', diam_layers, '\n')
        if diam_layers : 
            new_diam = diam_layers[0].clone()
            new_diam.setName(Alias.get('diam', 'diam'))
            Qproject.addMapLayer(new_diam, False)
            g = root.findGroup(tr('Propriétés'))
            g.addLayer(new_diam)
            for layer in diam_layers : 
                to_remove = root.findLayer(layer.id())
                root.removeChildNode(to_remove)
        cana_layer = Qproject.mapLayersByName('Canalisation')[0]
        if cana_layer : 
            idx = cana_layer.fields().indexFromName('diam_fe') 
            defval = QgsDefaultValue() 
            prop_id = new_diam.id()
            default_fe = f"attribute(get_feature(layer:='{prop_id}', attribute:='val', value:=\"diam\"), 'fe')"
            defval.setExpression(default_fe)
            defval.setApplyOnUpdate(True)
            cana_layer.setDefaultValueDefinition(idx, defval)
            cana_layer.setFieldAlias(idx, Alias.get('diam_fe', 'FE'))
            
        