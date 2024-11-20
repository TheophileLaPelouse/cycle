# coding=utf-8


"""
cycle module to handle database objects in the database server
"""

import os
import re
import sys
import shutil
import subprocess
import psycopg2
from ..utility.string import normalized_name
from .version import __version__
from ..service import get_service
from qgis.core import QgsMessageLog

__current_dir = os.path.dirname(__file__)

CYCLE_DIR = os.path.join(os.path.expanduser('~'), ".cycle")
_custom_sql_dir = os.path.join(CYCLE_DIR, 'sql')

class ProjectCreationError(Exception):
    pass

class Cursor:
    def __init__(self, cur, debug):
        self.__debug = debug
        self.__cur = cur

    def execute(self, query, args=None):
        if self.__debug:
            sys.stdout.write(query+'\n')
        self.__cur.execute(query, args)

    def executemany(self, query, args):
        if self.__debug:
            sys.stdout.write(query+'\n')
        self.__cur.executemany(query, args)

    def fetchone(self):
        return self.__cur.fetchone()

    def fetchall(self):
        return self.__cur.fetchall()

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.__cur.close()

    def close(self):
        self.__cur.close()

class autoconnection:
    """Context manager for connection in autocommit mode without transaction.
    Usefull for DDL statements.
    @see https://github.com/psycopg/psycopg2/issues/941 to see why this is needed.
    """

    def __init__(self, database: str, service: str = None, debug=False):
        service = service or get_service()
        self.__conn = psycopg2.connect(database=database, service=service)
        self.__conn.autocommit = True
        self.__debug = debug

    def cursor(self):
        return Cursor(self.__conn.cursor(), debug=self.__debug)

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.__conn.close()

class connection:
    """Context manager for connection.
    """

    def __init__(self, database: str, service: str = None, debug=False):
        service = service or get_service()
        self.__conn = psycopg2.connect(database=database, service=service)
        self.__debug = debug

    def cursor(self):
        return Cursor(self.__conn.cursor(), debug=self.__debug)

    def commit(self):
        return self.__conn.commit()

    def rollback(self):
        return self.__conn.rollback()

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.__conn.close()


class TestProject(object):
    '''create a project from template the project contains one model named model'''

    NAME = "template_cycle"

    @staticmethod
    def reset_template(debug=False):
        if project_exists(TestProject.NAME):
            remove_project(TestProject.NAME)
        create_project(TestProject.NAME, 2154, debug)
        with autoconnection("postgres") as con, con.cursor() as cur:
            # close all remaining opened connection to this database if any
            cur.execute(f"select pg_terminate_backend(pg_stat_activity.pid) \
                          from pg_stat_activity \
                          where pg_stat_activity.datname in ('{TestProject.NAME}');")

    def __init__(self, name, keep=False, with_model=False):
        assert(name)
        if not project_exists(TestProject.NAME):
            self.reset_template()
        assert(name[-6:] == "_xtest")
        self.__name = name
        self.__keep = keep
        with autoconnection("postgres") as con, con.cursor() as cur:
            # close all remaining opened connection to this database if any
            cur.execute(f"select pg_terminate_backend(pg_stat_activity.pid) \
                          from pg_stat_activity \
                          where pg_stat_activity.datname in ('{name}');")
            cur.execute(f"drop database if exists {name};")
            if os.path.isdir(os.path.join(CYCLE_DIR, name)):
                shutil.rmtree(os.path.join(CYCLE_DIR, name))
            cur.execute(f"create database {name} with template {TestProject.NAME};")

        if with_model:
            with autoconnection(name) as con, con.cursor() as cur:
                cur.execute("insert into api.model(name) values ('model');")

    def __del__(self):
        if not self.__keep:
            remove_project(self.__name)

def create_project(project_name, srid=2154, debug=False):
    '''create project database'''
    # @todo add user identification
    assert(project_name == normalized_name(project_name))
    if project_exists(project_name):
        raise ProjectCreationError(f"A database named {project_name} already exists. Use another name for the project.")

    with autoconnection("postgres", debug=debug) as con, con.cursor() as cur:
        cur.execute(f"create database {project_name};")

    reset_project(project_name, srid, debug)

def load_file(project_name, file):
    command = ['psql', '-b', f'--file={file}', f'service={get_service()} dbname={project_name}']
    result = subprocess.run(command)
    if result.returncode:
        raise RuntimeError(f"error in command: {' '.join(command)}")

def reset_project(project_name, srid, debug=False):

    # /!\ change connection to project DB
    with autoconnection(project_name, debug=debug) as con, con.cursor() as cur:
        #print(f"create {project_name} with version {__version__}")
        print("où1")
        cur.execute("drop schema if exists api cascade")
        cur.execute("drop schema if exists ___ cascade")
        print("où2")
        cur.execute(f"""
            create or replace function cycle_version()
            returns varchar
            language sql immutable as
            $$
                select '{__version__}'::varchar;
            $$
            ;
            """)
        print("où3")
        # load_file(project_name, os.path.join(__current_dir, 'sql', 'data.sql'))
        # load_file(project_name, os.path.join(__current_dir, 'sql', 'api.sql'))
        # load_file(project_name, os.path.join(__current_dir, 'sql', 'formula.sql'))
        # load_file(project_name, os.path.join(__current_dir, 'sql', 'special_blocs.sql'))
        # load_file(project_name, os.path.join(__current_dir, 'sql', 'blocs.sql'))
        
        with open(os.path.join(__current_dir, 'sql', 'data.sql')) as f:
            cur.execute(f.read())
        print("où4")
        with open(os.path.join(__current_dir, 'sql', 'api.sql')) as f:
            cur.execute(f.read())
        with open(os.path.join(__current_dir, 'sql', 'formula.sql')) as f:
            cur.execute(f.read())
        print("où5")
        with open(os.path.join(__current_dir, 'sql', 'special_blocs.sql')) as f:
            cur.execute(f.read())
        print("où5.1")
        with open(os.path.join(__current_dir, 'sql', 'blocs.sql')) as f:
            text = f.read()
            cur.execute(text)
        print("où5.2")
        # Custom blocs 
        custom_sql = os.path.join(CYCLE_DIR, project_name, 'custom_blocs.sql')
        if os.path.exists(custom_sql):
            with open(custom_sql) as f:
                try : cur.execute(f.read())
                except psycopg2.ProgrammingError : pass # Empty file
        print("où6")
                
        # default srid in cycle extension is already set to 2154
        cur.execute(f"update api.metadata set srid={srid} where {srid}!=2154;")
        print("où7")

def refresh_db(project_name):
    # Pour plus tard en fait 
    return

def is_cycle_db(dbname):
    try:
        with autoconnection(dbname) as con:
            with con.cursor() as cur:
                cur.execute("select cycle_version()")
                return True
    except (psycopg2.OperationalError, psycopg2.InterfaceError, psycopg2.errors.UndefinedFunction):
        return False

def version(dbname):
    with autoconnection(database=dbname, service=get_service()) as con, con.cursor() as cur:
        cur.execute("select cycle_version()")
        return cur.fetchone()[0]


def get_projects_list(all_db=False):
    with autoconnection("postgres") as con, con.cursor() as cur:
        cur.execute("select datname from pg_database where datistemplate=false order by datname;")
        return [db for db, in cur.fetchall() if is_cycle_db(db) or all_db]
    
def get_rid(dbname) : 
    with autoconnection("postgres") as con, con.cursor() as cur:
        cur.execute(f"drop database {dbname};")
        

def project_exists(project_name):
    with autoconnection("postgres") as con, con.cursor() as cur:
        cur.execute(f"select count(1) from pg_database where datname='{project_name}';")
        return cur.fetchone()[0] == 1

def remove_project(project_name):
    with autoconnection("postgres") as con, con.cursor() as cur:
        # close all remaining opened connection to this database if any
        cur.execute(f"select pg_terminate_backend(pg_stat_activity.pid) \
                      from pg_stat_activity \
                      where pg_stat_activity.datname in ('{project_name}');")
        cur.execute(f"drop database if exists {project_name};")

def export_db(project_name, filename):
    with autoconnection(database=project_name, service=get_service()) as con, con.cursor() as cur:
        cur.execute('select cycle_version(), srid from ___.metadata;')
        version, srid = cur.fetchone()
    # dump the project database in a binary file
    subprocess.run([
        'pg_dump',
        '-O', # no ownership of objects
        '-x', # no grant/revoke in dump
        '-f', filename, f"service={get_service()} dbname={project_name}"])
    
    with open(filename, 'rb') as d:
        dump = d.read()
    with open(filename, 'wb') as d:
        eol = ('\n' if os.name != 'nt' else '\r\n')
        d.write(f"-- cycle version {version}{eol}".encode('ascii'))
        d.write(f"-- project SRID {srid}{eol}".encode('ascii'))
        d.write(dump)

def get_srid_from_file(file):
    '''Utility function to look for a project's SRID from an exported file'''
    with open(file, 'r') as f:
        for line in f:
            match = re.search(r"-- project SRID (\d{4,5})", line)
            if match:
                return match.group(1)
            match = re.search(r"COPY ___.metadata.* FROM stdin;", line)
            if match:
                return next(f).split('\t')[2]
    return None

def import_db(project_name, filename):
    with autoconnection("postgres") as con, con.cursor() as cur:
        cur.execute(f"create database {project_name};")
    cmd = ["psql", '-v', 'ON_ERROR_STOP=1',
        "-f", filename, f"service={get_service()} dbname={project_name}"]
    out = subprocess.run(cmd, capture_output=True)
    if out.returncode:
        with autoconnection("postgres") as con, con.cursor() as cur:
            cur.execute(f"drop database {project_name};")
        raise RuntimeError(f"error in command: {' '.join(cmd)}\n"+out.stderr.decode('utf8'))

def update_db(dbname):

    with autoconnection(dbname) as con, con.cursor() as cur:
        cur.execute("select srid from api.metadata")
        srid, = cur.fetchone()
    
    path_dump = os.path.join(__current_dir, 'sql', 'dump.sql')
    subprocess.run([
        'pg_dump',
        '-O', # no ownership of objects
        '-x', # no grant/revoke in dump
        '-a', # only data
        '-f', path_dump, f"service={get_service()} dbname={dbname}"])
    
    reset_project(dbname, srid)
    
    subprocess.run({
        'psql',
        f"service={get_service()} dbname={dbname}",
        '-f', path_dump 
    })
    # Faudra peut être ajouter du controle d'erreur mais en vrai, ça va probablement en faire à cause des duplicate
    os.remove(path_dump)
    
    
    

def duplicate(src, dst):
    with autoconnection("postgres") as con, con.cursor() as cur:
        cur.execute(f"select pg_terminate_backend(pg_stat_activity.pid) \
                      from pg_stat_activity \
                      where pg_stat_activity.datname in ('{src}');")
        cur.execute(f"create database {dst} with template {src}")

def export_model(dbname, model, file):
    # create a temporary database as as cpy of the source database
    # remove all but the model
    # dump the database
    # delete the database
    tmp_db = dbname+'_cpy_for_model_export'
    with autoconnection("postgres") as con, con.cursor() as cur:
        cur.execute(f"select pg_terminate_backend(pg_stat_activity.pid) \
                      from pg_stat_activity \
                      where pg_stat_activity.datname in ('{dbname}');")
        cur.execute(f"drop database if exists {tmp_db}")
        cur.execute(f"create database {tmp_db} with template {dbname}")
    
    with autoconnection(tmp_db) as con, con.cursor() as cur:
        cur.execute("delete from api.model where name != %s", (model,))
    
    export_db(tmp_db, file)
    remove_project(tmp_db)

def import_model(file, model, dbname):
    # load sql in a temporary db
    # change srid to match destination db
    # drop api schema
    # rename ___ schema to cpy
    # delete useless tables (scenario, water_delivery_scenario...)
    # offsets ids of all remaining tables
    # dump temporary database
    # load dump in destination

    assert(file.endswith('.sql'))
    tmp_db = 'tmp_for_model_import'
    tmp_file = file[:-4]+'.tmp.sql'

    remove_project(tmp_db)
    import_db(tmp_db, file)

    with autoconnection(dbname) as con, con.cursor() as cur:
        cur.execute("select srid, cycle_version() from api.metadata")
        dst_srid, dst_version = cur.fetchone()
        #cur.execute("drop schema if exists cpy cascade")

    with autoconnection(tmp_db) as con, con.cursor() as cur:
        cur.execute("select srid, cycle_version() from api.metadata")
        src_srid, src_version = cur.fetchone()
        cur.execute("select count(1) from api.model")
        assert(cur.fetchone()[0] == 1) # only one model allowed
        if dst_srid != src_srid:
            cur.execute("update api.metadata set srid=%s", (dst_srid,))

    if src_version != dst_version:
        update_db(tmp_db)

    with autoconnection(tmp_db) as con, con.cursor() as cur:
        cur.execute("select srid, cycle_version() from api.metadata")
        src_srid, src_version = cur.fetchone()
        assert(dst_version==src_version)
        assert(dst_srid==src_srid)
        cur.execute("update api.model set name=%s",(model,))
        cur.execute("drop schema if exists api cascade")
        cur.execute("drop function create_api")
        cur.execute("drop function create_template")
        cur.execute("drop function cycle_version")
        cur.execute("alter schema ___ rename to cpy")

    subprocess.run(['pg_dump', '-O', '-f', tmp_db, f'service={get_service()} dbname={tmp_db}'])
    with open(tmp_db, 'rb') as d:
        dump = d.read()
    with open(tmp_file, 'wb') as d:
        eol = ('\n' if os.name != 'nt' else '\r\n')
        d.write(f"-- cycle version {dst_version}{eol}".encode('ascii'))
        d.write(f"-- project SRID {dst_srid}{eol}".encode('ascii'))
        d.write(dump)

    remove_project(tmp_db)

    cmd = ['psql', '-v', 'ON_ERROR_STOP=1',
        '-c', "drop schema if exists cpy cascade",
        '-f', tmp_file,
        '-f', os.path.join(__current_dir, 'sql', 'cpy_model.sql'),
        '-d', f'service={get_service()} dbname={dbname}']
    out = subprocess.run(cmd, capture_output=True)
    if out.returncode:
        raise RuntimeError(f"error in command: {' '.join(cmd)}\n"+out.stderr.decode('utf8'))
