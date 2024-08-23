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