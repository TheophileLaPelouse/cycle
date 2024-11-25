from qgis.PyQt.QtCore import QSettings
import os

def get_service():
    settings = QSettings()
    if not settings.contains('cycle/service') or settings.value('cycle/service') not in services():
        settings.setValue('cycle/service', 'cycle') # does not work on test server, maybe because QApplication is not instanciated
    return settings.value('cycle/service') or 'cycle' # for tests the value of settings isn't changed, the or 'cycle' is important here


def set_service(value):
    settings = QSettings()
    settings.setValue('cycle/service', value)
    
def services():
    pg_service_file = os.environ['PGSERVICEFILE'] if 'PGSERVICEFILE' in os.environ else (os.path.expanduser('~')+os.sep+".pg_service.conf")
    res = []
    with open(pg_service_file) as f:
        for l in f:
            if l.startswith('['):
                res.append(l.strip().replace('[','').replace(']',''))
    return res

def edit_pg_service(user = 'hydra', password = 'hydra', port = 5454, host = '127.0.0.1'):
    pg_service_file = os.environ['PGSERVICEFILE'] if 'PGSERVICEFILE' in os.environ else (os.path.expanduser('~')+os.sep+".pg_service.conf")
    if not os.path.exists(pg_service_file):
        with open(pg_service_file, 'w') as f:
            f.write('[cycle]\n')
            f.write('user=user\n')
            f.write('password=password\n')
            f.write('host=host\n')
            f.write('port=port\n')
    else : 
        with open(pg_service_file, 'r') as f:
            lines = f.readlines()
            for line in lines:
                if line.startswith('[cycle]'):
                    return
        with open(pg_service_file, 'a') as f:
            f.write('[cycle]\n')
            f.write('user=user\n')
            f.write('password=password\n')
            f.write('host=host\n')
            f.write('port=port\n')
            
        return