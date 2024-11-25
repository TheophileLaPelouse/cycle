# -*- coding: utf-8 -*-

from qgis.PyQt.QtCore import QObject, QTranslator, QCoreApplication, Qt
from qgis.PyQt.QtWidgets import QAction, QDockWidget
from qgis.core import QgsProject, QgsSettings
from qgis.gui import QgsGui

from .qgis_utilities import QGisLogger, QGisProjectManager #, ArrayWidgetFactory
from .gui.menu_widgets.menu import CycleMenu
from .gui.menu_widgets.toolbar import CycleToolbar
from .service import set_service
from .utility.log import LogManager
from .project import Project
 
import os

def tr(msg):
    return QCoreApplication.translate("Cycle", msg)

class Cycle(QObject):
    """QGIS Plugin Implementation."""

    def __init__(self, iface):
        """Constructor.

        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        QObject.__init__(self)
        self.__iface = iface
        self.__project = None

        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)

        self.__log_manager = LogManager(QGisLogger(self.__iface), "Cycle")
        self.__toolbar = None
        self.__menu = None
        self.__dock_results = None

        self.__iface.projectRead.connect(self.__project_loaded)
        self.__iface.newProjectCreated.connect(self.__project_loaded)
        
        self.__iface.projectRead.connect(self.__update_docks)
        self.__iface.newProjectCreated.connect(self.__update_docks)
        
        # self.__iface.currentLayerChanged.connect(self.print_current_layer)
    
        # initialize locale
        locale = QgsSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'Cycle_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)
            QCoreApplication.installTranslator(self.translator)



    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('Cycle', message)


    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        icon_path = ':/plugins/cycle/ressources/icon.png'

        self.__menu = CycleMenu(self.__log_manager)
        self.__iface.mainWindow().menuBar().addMenu(self.__menu)
        # QgsGui.editorWidgetRegistry().registerWidget("Array", ArrayWidgetFactory())
        self.__project_loaded()
        self.__edit_action = self.__iface.mainWindow().findChild(QAction, "mActionToggleEditing")
        self.__edit_action.triggered.connect(self.__toggle_edit_mode)
        
        print("bonjour", self.__dock_results)
        # self.__create_docks()

    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""

        if self.__menu is not None:
            self.__menu.setParent(None)
            self.__menu = None
        if self.__toolbar is not None:
            self.__toolbar.setParent(None)
            self.__toolbar = None

        self.__iface.newProjectCreated.disconnect(self.__project_loaded)
        self.__iface.projectRead.disconnect(self.__project_loaded)


    def print_current_layer(self, layer):
        print("current layer", layer)
    
    def __project_loaded(self):
        '''Loads plugin concepts and UI if an expresseau project is opened via a QGIS process'''
        if self.__toolbar is not None:
            self.__toolbar.setParent(None)
            self.__toolbar = None

        if QGisProjectManager.is_cycle_project():
            set_service(QgsProject.instance().readEntry('cycle', 'service', 'cycle')[0] )
            self.__toolbar = CycleToolbar(self.__log_manager)
            # self.__toolbar.model_updated.connect()
            self.__iface.addToolBar(self.__toolbar)
            QgsProject.instance().customVariablesChanged.connect(self.__toolbar.variables_changed)

    def __toggle_edit_mode(self, checked):
        if not checked :
            self.__update_docks()
    
    def __update_docks(self):
        print("is it none ?", self.__dock_results is None)
        if self.__dock_results is None and QGisProjectManager.is_cycle_project() : 
            self.__create_docks()
        elif QGisProjectManager.is_cycle_project():
            self.__dock_results.update_model_list()
            
    
    def __create_docks(self):
        self.__iface.mainWindow().addDockWidget(Qt.RightDockWidgetArea, self.visu_results_dock())
        self.__iface.mainWindow().tabifyDockWidget(self.__iface.mainWindow().findChildren(QDockWidget, "Browser")[0], self.visu_results_dock())
        
    def visu_results_dock(self):
        from .gui.menu_widgets.resume_resultat import RecapResults
        if QGisProjectManager.is_cycle_project() : 
            project = Project(QGisProjectManager.project_name(), self.__log_manager)
            print(dir(self.__dock_results))
            if self.__dock_results is None : 
                flag = True 
            elif self.__dock_results.project.name != project.name : 
                flag = True
            else : flag = False
        else : flag = False 
        if flag: 
            model = QgsProject.instance().customVariables().get('current_model')
            print("bonjour", model)
            self.__dock_results = RecapResults(model, Project(QGisProjectManager.project_name(), self.__log_manager))
            self.__dock_results.setWindowTitle(tr('Résumer résultats'))
            self.__dock_results.show()
        return self.__dock_results
            
        