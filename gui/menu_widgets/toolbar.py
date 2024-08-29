"""
Cycle toolbar menu
"""

from __future__ import unicode_literals
from builtins import str
import os
import re
from pathlib import Path
from operator import itemgetter
from functools import partial
from datetime import timedelta
from qgis.PyQt.QtCore import QCoreApplication, Qt, pyqtSignal
from qgis.PyQt.QtWidgets import QApplication, QWidget, QToolBar, QAction, QPushButton, QComboBox, QMessageBox, QDialog, QFileDialog, QHBoxLayout
from qgis.core import QgsApplication, QgsWkbTypes
from qgis.PyQt.QtGui import QIcon
from ...utility.map_point_tool import VisibleGeometry, MapPointTool



def tr(msg):
    return QCoreApplication.translate("@default", msg)

_plugin_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, os.pardir))
_icons_dir = os.path.join(_plugin_dir, "ressources", "images")


class CycleToolbar(QToolBar):
    mod_changed_signal = pyqtSignal()
    layers_changed_signal = pyqtSignal(list)

    def __add_action_button(self, name, icon, action, togglable = False):
        action_button = QAction(QIcon(os.path.join(_icons_dir, icon)), tr(name), self)
        action_button.triggered.connect(action)
        self.addAction(action_button)
        action_button.setCheckable(togglable)
        return action_button

    def __init__(self, title, project, iface):
        QToolBar.__init__(self, title)
        self.setObjectName('cycle toolbar') # used by simulate

        self.__current_tool = None
        self.__last_tool_clicked = None

        self.__currentproject = project
        self.__iface = iface

        self.__model_combo = QComboBox()
        self.__model_combo.setSizeAdjustPolicy(QComboBox.AdjustToContents)
        self.__model_combo.currentIndexChanged.connect(self.__model_changed)

        # self.__isloading allow to re-populate comboboxes without triggering
        # the xx_changed function connected to the currentIndexChanged signal of each comboboxes
        self.__isloading = True
        
        # Assembling toolbar's widgets
        self.addWidget(self.__model_combo)
        self.edit_button = self.__add_action_button(tr("Edit"), "edit_button.svg", self.__edit_tool, togglable = True)
        self.del_button = self.__add_action_button(tr("Delete"), "delete_button.svg", self.__delete_tool, togglable = True)
        # self.__search_button = self.__add_action_button(tr("Search objects"), "search.svg", self.__search_tool)
        self.select_button = self.__add_action_button(tr("Select"), "select.svg", self.__select_tool, togglable = True)
        # self.__geom_button = self.__add_action_button(tr("Geometries library"), "geom.svg", self.__edit_geometries)
        # self.__valid_button = self.__add_action_button(tr("List invalid objects"), "validity.svg", self.__validity_tool)
        # self.__config_button = self.__add_action_button(tr("List configured objects"), "configured.svg", self.__configuration_tool)
        # self.__regulation_button = self.__add_action_button(tr("List regulated objects"), "regulated.svg", self.__regulation_tool)
        # Boutons qui pourraient être utiles plus tard
        self.addSeparator()
        self.addWidget(self.__scn_combo)
        self.addWidget(self.__run_button)
        self.__display_results_button = self.__add_action_button(tr("Synthetic results"), "show_results.svg", self.__display_results)
        self.addSeparator()

        self.__iface.mapCanvas().mapToolSet.connect(self.map_tool_changed)

        self.__refresh_combos()
        self.__refresh_buttons()
        self.__refresh_time_control()
        self.__isloading = False

        # QgsApplication.instance().taskManager().taskAboutToBeDeleted.connect(self.__taskAboutToBeDeleted) # usefull when running simulate from processing

    # def __taskAboutToBeDeleted(self, taskId):
    #     self.refresh_content()

    def refresh_content(self, project=None):
        self.__isloading=True
        if project:
            self.__currentproject = project

        self.__refresh_combos()
        self.__refresh_buttons()

        self.__isloading=False

    def __refresh_combos(self):
        # Models combobox
        self.__model_combo.clear()
        models = self.__currentproject.get_models()
        for model in sorted(models, key=str.lower):
            self.__model_combo.addItem(model)
        if self.__currentproject.get_current_model():
            self.__model_combo.setCurrentIndex(self.__model_combo.findText(self.__currentproject.get_current_model().name))
        else:
            self.__model_combo.setCurrentIndex(-1)


    def __refresh_buttons(self):
        if not self.__currentproject.get_models() or not self.__currentproject.get_current_scenario():
            self.__run_button.setEnabled(False)
        else:
            self.__run_button.setEnabled(True)

        exists_model = True
        if not self.__currentproject.get_current_model():
            exists_model = False

        self.edit_button.setEnabled(exists_model)
        self.del_button.setEnabled(exists_model)
        self.__search_button.setEnabled(exists_model)
        self.__valid_button.setEnabled(exists_model)
        self.__display_results_button.setEnabled(exists_model)

        # Untoggle inactive buttons
        for action in self.actions():
            if action.isCheckable():
                if not action.isEnabled():
                    action.setChecked(False)

    def __model_changed(self):
        if self.__isloading:
            return
        if self.__currentproject.get_current_model() is not None and self.__currentproject.get_current_model().name==self.__model_combo.currentText():
            return

        if self.__model_combo.currentIndex() != -1:
            self.__currentproject.log.notice(tr("Current model set to ") + self.__model_combo.currentText())
            self.__currentproject.set_current_model(self.__model_combo.currentText())
        else :
            self.__currentproject.log.notice(tr("No current model"))
            self.__currentproject.set_current_model(None)
        self.mod_changed_signal.emit()

    # def __run_calculation(self):
    #     confirm = QMessageBox(
    #                     QMessageBox.Question,
    #                     tr('Starting {}').format(self.__currentproject.get_current_scenario()[1]),
    #                     tr('Proceed with computation for {}?').format(self.__currentproject.get_current_scenario()[1]),
    #                     QMessageBox.Ok | QMessageBox.Cancel
    #                 ).exec_()
    #     if confirm == QMessageBox.Ok:
    #         self.__currentproject.unload_csv_results_layers(self.__currentproject.get_current_scenario()[1])
    #         self.drop_results()

    #         dialog = ComputationWindow(self.__currentproject, parent=self)
    #         dialog.open()

    #         dialog.run_calculation()

    #         self.refresh_content()
    #         self.layers_changed_signal.emit(['configured_current'])


    def map_tool_changed(self):
        
        self.edit_button.setChecked(self.__last_tool_clicked == "edit")
        self.del_button.setChecked(self.__last_tool_clicked == "delete")
        if self.__last_tool_clicked is None and self.__current_tool:
            self.__iface.mapCanvas().unsetMapTool(self.__current_tool)
            self.__current_tool and self.__current_tool.setParent(None)
            self.__current_tool=None
        self.__last_tool_clicked = None

    def __edit_tool(self, flag=None):
        from .edit import EditTool
        if self.edit_button.isChecked():
            self.__last_tool_clicked = "edit"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = 20 # SettingsProperties.get_snap() Faudra regarder cette histoire de snap mais j'ai pas envie d'utiliser settings_properties
                # Si je dis pas n'importe quoi le snap c'est la distance en plus de sensibilité, genre là je peux clicker à 20 pixels de l'objet et ça va le sélectionner
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                table = EditTool(self.__currentproject, geom, size, None, self.__iface).get_table()
                if table:
                    self.layers_changed_signal.emit([table])

            def on_right_click(point):
                self.__iface.mapCanvas().setMapTool(self.prev_tool)

            self.__current_tool = MapPointTool(self.__iface.mapCanvas(), self.__currentproject.log)
            self.__current_tool.leftClicked.connect(on_left_click)
            self.__current_tool.rightClicked.connect(on_right_click)
            self.__iface.mapCanvas().setMapTool(self.__current_tool)

            while self.__iface.mapCanvas().mapTool() == self.__current_tool:
                QApplication.instance().processEvents()

            if self.__current_tool:
                self.__iface.mapCanvas().unsetMapTool(self.__current_tool)
                self.__current_tool and self.__current_tool.setParent(None)
                self.__current_tool=None
        else:
            self.map_tool_changed()

    def __delete_tool(self, flag=None):
        from .delete import DeleteTool
        if self.del_button.isChecked():
            self.__last_tool_clicked = "delete"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = 20 # SettingsProperties.get_snap() comme pour l'autre 
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                delete = DeleteTool(self.__currentproject, geom, size)
                table = delete.get_table()
                cascade = delete.is_cascade()
                if table:
                    if cascade :
                        self.layers_changed_signal.emit([])
                    else:
                        self.layers_changed_signal.emit([table, 'coverage'])

            def on_right_click(point):
                self.__iface.mapCanvas().setMapTool(self.prev_tool)

            self.__current_tool = MapPointTool(self.__iface.mapCanvas(), self.__currentproject.log)
            self.__current_tool.leftClicked.connect(on_left_click)
            self.__current_tool.rightClicked.connect(on_right_click)
            self.__iface.mapCanvas().setMapTool(self.__current_tool)

            while self.__iface.mapCanvas().mapTool() == self.__current_tool:
                QApplication.instance().processEvents()

            if self.__current_tool:
                self.__iface.mapCanvas().unsetMapTool(self.__current_tool)
                self.__current_tool and self.__current_tool.setParent(None)
                self.__current_tool=None
        else:
            self.map_tool_changed()

    # def __search_tool(self):
    #     from hydra.gui.search import SearchTool
    #     SearchTool(self.__currentproject, self.__iface).exec_()
    #     self.refresh_content()
    #     self.layers_changed_signal.emit([])

    def __display_results(self):

        print("bonjour")
        return

# class ComputationWindow(QDialog):
#     def __init__(self, project, parent=None):
#         QDialog.__init__(self, parent)

#         self.__project = project
#         self.__scn_id, self.__scn_name = self.__project.get_current_scenario()
#         self.__runner = Kernel(self.__project, self.__scn_id, parent=self)

#         self.__licence_level = None
#         self.__starter_duration = None
#         self.__pro_duration = None

#         self.__init_gui()

#     def closeEvent(self, evnt):
#         '''stops computation process at close event'''
#         self.__runner.kill_process()
#         QApplication.restoreOverrideCursor()
#         QDialog.closeEvent(self, evnt)

#     def __init_gui(self):
#         '''creates gui elements'''
#         self.setWindowFlags(self.windowFlags() | Qt.WindowMinimizeButtonHint)
#         self.setWindowTitle(self.__scn_name)
#         self.setFixedSize(1000, 430)

#         self.log_scroll = ScrollLogger()
#         self.output_scroll = ScrollLogger(night_mode=True)

#         self.lay = QHBoxLayout()
#         self.lay.addWidget(self.log_scroll)
#         self.lay.addWidget(self.output_scroll)

#         self.setLayout(self.lay)

#     def run_calculation(self):
#         '''start computation for specified scenario'''
#         self.__log("Starting {}".format(self.__scn_name))

#         invalid_model = self.__runner.models_validity()
#         if invalid_model:
#             self.close()
#             QMessageBox(QMessageBox.Warning, tr('Warning'), tr('There are still some invalidities in models {}.'.format(', '.join(invalid_model))), QMessageBox.Ok).exec_()
#         else:
#             self.__log("{} processing ok".format(self.__scn_name))

#             self.__log("Exporting {}".format(self.__scn_name))
#             # export topological data for calculation
#             exporter = ExportCalcul(self.__project)
#             exporter.export(self.__scn_id)
#             # export cartograpic data for triangulation
#             exporter = ExportCartoData(self.__project)
#             exporter.export(self.__scn_id)
#             self.__log("Export ok".format(self.__scn_name))

#             #Computation with Kernel
#             try:
#                 self.__runner.log.connect(self.__log)
#                 self.__runner.output.connect(self.__output_log)
#                 self.__runner.run()
#                 QApplication.processEvents()
#             except Exception as e:
#                 QMessageBox.critical(self, tr('Error during computation'), tr("An error occured during {}:\n    {}").format(self.__scn_name, str(e)), QMessageBox.Ok)

#         if self.__licence_level == 'STARTER':
#             text = tr("""<center>Les calculs en licence <b>STARTER</b> ont duré : <b>{}</b></center>
#                          <center>Durée des calculs si vous étiez en version <b>PRO: {}</b></center>"""
#                       ).format(self.__starter_duration or "duration not found", self.__pro_duration or "duration not found")
#             starter_box = QMessageBox()
#             starter_box.setWindowTitle(tr('Computation complete'))
#             starter_box.setTextFormat(Qt.RichText)
#             starter_box.setText(text)
#             starter_box.exec_()

#     def __log(self, text):
#         ''' add line for macro logging (big steps in scenario run)'''
#         text = '\n'.join(re.split('\n+', text.strip()))
#         if text:
#             weight = None
#             color = None

#             self.__check_for_licence(text)

#             if "error" in text :
#                 color = "red"
#                 weight = "bold"
#                 self.__project.log.error(text)
#             elif "ok" in text:
#                 weight = "bold"
#                 self.__project.log.notice(text)
#             self.log_scroll.add_line(text, weight, color)
#             # Raise error if needed after logging text
#             if color == "red":
#                 raise KernelError(text)

#     def __check_for_licence(self, text):
#         # manholes
#         manholes_in_models = any([self.__project.execute(f"select exists(select 1 from {model}.manhole_node limit 1)").fetchone()[0] for model in self.__runner.list_models()])
#         # licence
#         if self.__licence_level is None and "numero de cle de license lu" in text:
#             match_l = re.search(r"\( licence \'(\D*)\'\)", text)
#             if match_l:
#                 self.__licence_level = match_l.group(1)
#                 if self.__licence_level == 'STARTER':
#                     text = tr(f"""<center>La version PRO vous permettrait d'accélérer les calculs</center>
#                                   <center>et d'accéder à des options complémentaires.</center>
#                                 {"<center>Voir message en fin de calcul estimant les temps de calcul avec la version PRO.</center>" if manholes_in_models else ''}""")
#                     starting_box = QMessageBox()
#                     starting_box.setWindowTitle(tr('Computation starting'))
#                     starting_box.setTextFormat(Qt.RichText)
#                     starting_box.setText(text)
#                     starting_box.exec_()

#         # computation time
#         if "temps de calcul de la simulation hydraulique" in text:
#             match_d = re.findall(r"(\d*)hr\s*(\d*)mn\s*(\d*)sec", text)
#             if match_d:
#                 if self.__licence_level == 'STARTER' and self.__starter_duration is None:
#                     self.__starter_duration = timedelta(hours=int(match_d[0][0]), minutes=int(match_d[0][1]), seconds=int(match_d[0][2]))
#                     self.__pro_duration = timedelta(hours=int(match_d[1][0]), minutes=int(match_d[1][1]), seconds=int(match_d[1][2]))
#                 elif self.__licence_level == 'PRO' and self.__pro_duration is None:
#                     self.__pro_duration = timedelta(hours=int(match_d[0][0]), minutes=int(match_d[0][1]), seconds=int(match_d[0][2]))

#     def __output_log(self, text):
#         ''' add line for kernel output logging'''
#         text = '\n'.join(re.split('\n+', text.strip()))
#         if text:
#             weight = None
#             if "output" in text :
#                 self.output_scroll.new_label()
#                 self.output_scroll.add_line(text, weight='bold', color='#ffffff')
#             else:
#                 self.output_scroll.add_line(text, color='#ffffff')
#             if "PHASE CALCUL TRANSITOIRE" in text:
#                 self.output_scroll.new_label(15)

class KernelError(Exception):
    pass
