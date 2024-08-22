from qgis.PyQt.QtCore import QSettings
import os

def set_service(value):
    settings = QSettings()
    settings.setValue('expresseau/service', value)