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
from qgis.core import QgsApplication
from qgis.PyQt.QtGui import QIcon
from hydra.utility.map_point_tool import create_point, Snapper, VisibleGeometry, MapPointTool

from hydra.utility.settings_properties import SettingsProperties


from hydra.gui.widgets.scroll_log_widget import ScrollLogger

from hydra.gui.widgets.combo_with_values import ComboWithValues

from hydra.kernel import Kernel
from qgis.core import QgsProject


def tr(msg):
    return QCoreApplication.translate("@default", msg)

_plugin_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir, os.pardir))
_icons_dir = os.path.join(_plugin_dir, "ressources", "images")


class ToolBar(QToolBar):
    mod_changed_signal = pyqtSignal()
    scn_changed_signal = pyqtSignal()
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

        self.__scn_combo = ComboWithValues()
        self.__scn_combo.setSizeAdjustPolicy(QComboBox.AdjustToContents)
        self.__scn_combo.currentIndexChanged.connect(self.__scn_changed_signal)

        # self.__isloading allow to re-populate comboboxes without triggering
        # the xx_changed function connected to the currentIndexChanged signal of each comboboxes
        self.__isloading = True
        
        # Assembling toolbar's widgets
        self.addWidget(self.__model_combo)
        self.edit_button = self.__add_action_button(tr("Edit"), "edit_button.svg", self.__edit_tool, togglable = True)
        self.del_button = self.__add_action_button(tr("Delete"), "delete_button.svg", self.__delete_tool, togglable = True)
        self.__search_button = self.__add_action_button(tr("Search objects"), "search.svg", self.__search_tool)
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

        # Scenarios combobox
        self.__scn_combo.clear()
        scn_id_name = self.__currentproject.get_scenarios()
        self.__scn_combo.setEnabled(len(scn_id_name)>0)
        for scn in sorted(scn_id_name, key=itemgetter(1)):
            self.__scn_combo.addItem(scn[1],scn[0], 'black' if self.__currentproject.scn_has_run(scn[0]) else 'red')
        if self.__currentproject.get_current_scenario():
            self.__scn_combo.set_selected_value(self.__currentproject.get_current_scenario()[0])
        else:
            self.__scn_combo.setCurrentIndex(-1)


    def __refresh_buttons(self):
        if not self.__currentproject.get_models() or not self.__currentproject.get_current_scenario():
            self.__run_button.setEnabled(False)
        else:
            self.__run_button.setEnabled(True)

        exists_model = True
        if not self.__currentproject.get_current_model():
            exists_model = False

        exists_scenario = True
        if self.__currentproject.get_current_scenario() is None:
            exists_scenario = False


        self.edit_button.setEnabled(exists_model)
        self.del_button.setEnabled(exists_model)
        self.__search_button.setEnabled(exists_model)
        self.__valid_button.setEnabled(exists_model)
        self.__display_results_button.setEnabled(exists_model and exists_scenario)

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

    def __scn_changed_signal(self):
        if self.__isloading:
            return
        if self.__currentproject.get_current_scenario() is not None and self.__currentproject.get_current_scenario()[0]==self.__scn_combo.get_selected_value():
            return

        prec_scn = self.__currentproject.get_current_scenario()
        if self.__scn_combo.get_selected_value():
            self.__currentproject.log.notice(tr("Current scenario set to ") + self.__scn_combo.currentText())

            self.__currentproject.set_current_scenario(self.__scn_combo.get_selected_value())
        else :
            self.__currentproject.log.notice(tr("No current scenario"))
            self.__currentproject.set_current_scenario(None)
        new_scn = self.__currentproject.get_current_scenario()
        if new_scn != prec_scn:
            self.__display_w15()
            self.scn_changed_signal.emit()

    def __config_changed(self):
        if self.__isloading:
            return
        if self.__currentproject.get_current_model().get_current_configuration()==self.__config_combo.get_selected_value():
            return

        if self.__config_combo.get_selected_value():
            self.__currentproject.log.notice(tr("Current configuration set to ") + self.__config_combo.currentText())
            self.__currentproject.get_current_model().set_current_configuration(self.__config_combo.get_selected_value())
            self.refresh_content()
        self.layers_changed_signal.emit(['invalid'])

    def __run_calculation(self):
        confirm = QMessageBox(
                        QMessageBox.Question,
                        tr('Starting {}').format(self.__currentproject.get_current_scenario()[1]),
                        tr('Proceed with computation for {}?').format(self.__currentproject.get_current_scenario()[1]),
                        QMessageBox.Ok | QMessageBox.Cancel
                    ).exec_()
        if confirm == QMessageBox.Ok:
            self.__currentproject.unload_csv_results_layers(self.__currentproject.get_current_scenario()[1])
            self.drop_results()

            dialog = ComputationWindow(self.__currentproject, parent=self)
            dialog.open()

            dialog.run_calculation()

            self.refresh_content()
            self.layers_changed_signal.emit(['configured_current'])


    def __visu_toolgraph(self, flag=None):
        from hydra.gui.visu_tool import VisuToolGraph
        if self.__visugraph_button.isChecked():
            self.__last_tool_clicked = "visugraph"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = SettingsProperties.get_snap()
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                VisuToolGraph(self.__currentproject, point, size, self)

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

    def __constrain_visu_toolgraph(self, flag=None):
        from hydra.gui.visu_tool import ConstrainToolGraph
        if self.__constrain_visugraph_button.isChecked():
            self.__last_tool_clicked = "constrain_visugraph"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = SettingsProperties.get_snap()
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                ConstrainToolGraph(self.__currentproject, point, size, self)

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

    def __serie_visu_toolgraph(self, flag=None):
        from hydra.gui.visu_tool import VisuToolGraph
        if self.__serie_visugraph_button.isChecked():
            self.__last_tool_clicked = "serie_visugraph"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = SettingsProperties.get_snap()
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                VisuToolGraph(self.__currentproject, point, size, self, mode_serie=True)

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


    def __visu_tooltable (self, flag = None) :
        from hydra.gui.visu_tool import VisuToolTable
        if self.__visutable_button.isChecked():
            self.__last_tool_clicked = "visutable"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = SettingsProperties.get_snap()
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                VisuToolTable(self.__currentproject, point, size, self)

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

    def map_tool_changed(self):
        self.__visugraph_button.setChecked(self.__last_tool_clicked == "visugraph")
        self.__visutable_button.setChecked(self.__last_tool_clicked == "visutable")
        self.__serie_visugraph_button.setChecked(self.__last_tool_clicked == "serie_visugraph")
        self.__constrain_visugraph_button.setChecked(self.__last_tool_clicked == "constrain_visugraph")
        self.edit_button.setChecked(self.__last_tool_clicked == "edit")
        self.del_button.setChecked(self.__last_tool_clicked == "delete")
        if self.__last_tool_clicked is None and self.__current_tool:
            self.__iface.mapCanvas().unsetMapTool(self.__current_tool)
            self.__current_tool and self.__current_tool.setParent(None)
            self.__current_tool=None
        self.__last_tool_clicked = None

    def __edit_tool(self, flag=None):
        from hydra.gui.edit import EditTool
        if self.edit_button.isChecked():
            self.__last_tool_clicked = "edit"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = SettingsProperties.get_snap()
                size = self.__iface.mapCanvas().getCoordinateTransform().mapUnitsPerPixel()*snap
                table = EditTool(self.__currentproject, geom, size, None, self.__iface).get_table()
                if table:
                    self.layers_changed_signal.emit([table])
                    if table == 'street':
                        self.layers_changed_signal.emit(['coverage'])
                    elif table == 'river_cross_section_profile':
                        self.layers_changed_signal.emit(['constrain', 'coverage'])

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
        from hydra.gui.delete import DeleteTool
        if self.del_button.isChecked():
            self.__last_tool_clicked = "delete"
            self.prev_tool = self.__iface.mapCanvas().mapTool()

            def on_left_click(point):
                geom = VisibleGeometry(self.__iface.mapCanvas(), QgsWkbTypes.PointGeometry)
                geom.add_point(point)
                snap = SettingsProperties.get_snap()
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

    def __search_tool(self):
        from hydra.gui.search import SearchTool
        SearchTool(self.__currentproject, self.__iface).exec_()
        self.refresh_content()
        self.layers_changed_signal.emit([])

    def __validity_tool(self):
        from hydra.gui.validity import ValidityTool
        ValidityTool(self.__currentproject, self.__iface).exec_()
        self.refresh_content()
        self.layers_changed_signal.emit([])

    def __configuration_tool(self):
        from hydra.gui.configuration import ConfigurationTool
        ConfigurationTool(self.__currentproject, self.__iface).exec_()
        self.refresh_content()
        self.layers_changed_signal.emit(['invalid'])

    def __regulation_tool(self):
        from hydra.gui.regulation import RegulationTool
        if self.__currentproject is not None:
            dialog = RegulationTool(self.__currentproject, self.__iface)
            dialog.exec_()
        self.layers_changed_signal.emit(['regulated'])

    def __raster_maps(self):
        dem_source = self.__currentproject.execute("""select source from project.dem order by priority limit 1""").fetchone()
        if dem_source:
            input = dem_source[0]
        else:
            QMessageBox.critical(
                self,
                tr('Processing Error'),
                tr('Unable to detect DEM source, please check Terrain configuration'),
                QMessageBox.Ok)
            return

        scenario = self.__currentproject.get_current_scenario()[1]
        time_step = self.__time_control.timestep() or -999.0

        velocity_alg = QgsApplication.instance().processingRegistry().algorithmById('hydra:velocity_raster')
        depth_alg = QgsApplication.instance().processingRegistry().algorithmById('hydra:depth_raster')

        velocity_task = QgsProcessingAlgRunnerTask(
            velocity_alg,
            {
                'PROJECT': self.__currentproject.name,
                'INPUT': input,
                'SCENARIO': scenario,
                'TIME_STEP': time_step,
                'OUTPUT': str(Path(self.__currentproject.carto_dir) / f"velocity_{scenario}_{time_step}.vrt")
            }, context_velo, feedback_velo
        )

        depth_task = QgsProcessingAlgRunnerTask(
            depth_alg,
            {
                'PROJECT': self.__currentproject.name,
                'INPUT': input,
                'SCENARIO': scenario,
                'TIME_STEP': self.__time_control.timestep() or -999.0,
                'OUTPUT': str(Path(self.__currentproject.carto_dir) / f"depth_{scenario}_{time_step}.vrt")
            },
            context_depth, feedback_depth)

        QgsApplication.taskManager().addTask(velocity_task)
        QgsApplication.taskManager().addTask(depth_task)

    def __topo_check(self):
        topo_errors = self.__currentproject.get_current_model().topo_check()
        if not topo_errors:
            QMessageBox(QMessageBox.Information, tr('Topology OK'), tr('Topology of model {} is fine.'.format(self.__currentproject.get_current_model().name)), QMessageBox.Ok).exec_()
        else:
            msg = tr('Topological errors found in model {}:\n'.format(self.__currentproject.get_current_model().name))
            for error_code, items in topo_errors.items():
                msg += '- {}: {}\n'.format(topo_error_dict[error_code].capitalize(), ', '.join(["{} ({})".format(n, t) for (i, n, t) in items]))
            QMessageBox(QMessageBox.Warning, tr('Topology error'), msg, QMessageBox.Ok).exec_()

    def __edit_geometries(self):
        from hydra.gui.geometry_manager import GeometryManager
        GeometryManager(self.__currentproject, iface=self.__iface).exec_()
        self.layers_changed_signal.emit(['constrain', 'coverage'])

    def __display_results(self):

        self.__currentproject.load_synthetic_results_layers()

        result = self.__currentproject.load_csv_results_layers()
        if result==0:
            QMessageBox(QMessageBox.Information, tr('No supporting layers'),
                tr('No layers found to display results. Open "Hydra" => "Settings" => "Synthetic results settings" and refresh some layers.'.format(
                    self.__currentproject.get_current_model().name)), QMessageBox.Ok).exec_()

    def __display_w15(self, force=False):
        if self.__display_w15_button.isChecked() or force:
            project_path = self.__currentproject.directory
            project_name = self.__currentproject.name
            model_name = self.__currentproject.get_current_model().name
            scn_name = self.__currentproject.get_current_scenario()[1]

            file_name = os.path.join(project_path, scn_name.upper(), 'hydraulique', f"{scn_name.upper()}_{model_name.upper()}")
            w14_file = file_name+'.w14'
            w15_file = file_name+'.w15'

            if os.path.isfile(w14_file) and os.path.isfile(w15_file):
                w14 = W14Result(w14_file)
                w15 = W15Result(w15_file)
                self.__time_control.setTimes(["%.2f"%(d) for d in w15.get_step_times()])
                layer = self.__currentproject.reload_w15_layer(w14, w15)
                self.__w15_layer_id = layer.id()
                layer.setStep(self.__time_control.timestep())
                self.__time_control.timeChanged.connect(layer.setStep)
                QgsProject.instance().layersRemoved.connect(self.__layer_removed)
            else:
                self.__currentproject.log.warning(f"cannot find {w14_file} and {w15_file}")
                self.__drop_w15_layer()
        else:
            self.__drop_w15_layer()

        self.__refresh_time_control()

    def __layer_removed(self, layer_ids):
        for lid in layer_ids:
            if lid == self.__w15_layer_id:
               self.__display_w15_button.setChecked(False)
               self.__refresh_time_control()

    def __drop_w15_layer(self):
       self.__w15_layer_id = None
       self.__currentproject.unload_w15_layer()

    def drop_results(self):
       self.__display_w15_button.setChecked(False)
       self.__drop_w15_layer()

    def __animate_rain(self):
        layer = self.__iface.activeLayer()

        if layer is not None:
            file = os.path.normpath(layer.source())
            raster_rains = [os.path.normpath(self.__currentproject.unpack_path(f)) for f, in self.__currentproject.execute(""" select file from project.radar_rainfall""").fetchall()]

            if file in raster_rains:
                rain = RainVrt(file, self.__currentproject)

                self.__rain_control = TimeControl(blocker=None)
                self.__rain_control.setWindowTitle('Rain animation')
                self.__rain_control.setTimes([display_timestamp(str(date)) for [i, date, time] in rain.time_index])

                def p(i):
                    layer.renderer().setBand(i+1)
                    layer.triggerRepaint()
                    QApplication.instance().processEvents()

                self.__rain_control.timeChanged.connect(p)
                self.__rain_control.show()
            else:
                self.__currentproject.log.warning("Select a layer associated with a radar rain.")

class ComputationWindow(QDialog):
    def __init__(self, project, parent=None):
        QDialog.__init__(self, parent)

        self.__project = project
        self.__scn_id, self.__scn_name = self.__project.get_current_scenario()
        self.__runner = Kernel(self.__project, self.__scn_id, parent=self)

        self.__licence_level = None
        self.__starter_duration = None
        self.__pro_duration = None

        self.__init_gui()

    def closeEvent(self, evnt):
        '''stops computation process at close event'''
        self.__runner.kill_process()
        QApplication.restoreOverrideCursor()
        QDialog.closeEvent(self, evnt)

    def __init_gui(self):
        '''creates gui elements'''
        self.setWindowFlags(self.windowFlags() | Qt.WindowMinimizeButtonHint)
        self.setWindowTitle(self.__scn_name)
        self.setFixedSize(1000, 430)

        self.log_scroll = ScrollLogger()
        self.output_scroll = ScrollLogger(night_mode=True)

        self.lay = QHBoxLayout()
        self.lay.addWidget(self.log_scroll)
        self.lay.addWidget(self.output_scroll)

        self.setLayout(self.lay)

    def run_calculation(self):
        '''start computation for specified scenario'''
        self.__log("Starting {}".format(self.__scn_name))

        invalid_model = self.__runner.models_validity()
        if invalid_model:
            self.close()
            QMessageBox(QMessageBox.Warning, tr('Warning'), tr('There are still some invalidities in models {}.'.format(', '.join(invalid_model))), QMessageBox.Ok).exec_()
        else:
            self.__log("{} processing ok".format(self.__scn_name))

            self.__log("Exporting {}".format(self.__scn_name))
            # export topological data for calculation
            exporter = ExportCalcul(self.__project)
            exporter.export(self.__scn_id)
            # export cartograpic data for triangulation
            exporter = ExportCartoData(self.__project)
            exporter.export(self.__scn_id)
            self.__log("Export ok".format(self.__scn_name))

            #Computation with Kernel
            try:
                self.__runner.log.connect(self.__log)
                self.__runner.output.connect(self.__output_log)
                self.__runner.run()
                QApplication.processEvents()
            except Exception as e:
                QMessageBox.critical(self, tr('Error during computation'), tr("An error occured during {}:\n    {}").format(self.__scn_name, str(e)), QMessageBox.Ok)

        if self.__licence_level == 'STARTER':
            text = tr("""<center>Les calculs en licence <b>STARTER</b> ont duré : <b>{}</b></center>
                         <center>Durée des calculs si vous étiez en version <b>PRO: {}</b></center>"""
                      ).format(self.__starter_duration or "duration not found", self.__pro_duration or "duration not found")
            starter_box = QMessageBox()
            starter_box.setWindowTitle(tr('Computation complete'))
            starter_box.setTextFormat(Qt.RichText)
            starter_box.setText(text)
            starter_box.exec_()

    def __log(self, text):
        ''' add line for macro logging (big steps in scenario run)'''
        text = '\n'.join(re.split('\n+', text.strip()))
        if text:
            weight = None
            color = None

            self.__check_for_licence(text)

            if "error" in text :
                color = "red"
                weight = "bold"
                self.__project.log.error(text)
            elif "ok" in text:
                weight = "bold"
                self.__project.log.notice(text)
            self.log_scroll.add_line(text, weight, color)
            # Raise error if needed after logging text
            if color == "red":
                raise KernelError(text)

    def __check_for_licence(self, text):
        # manholes
        manholes_in_models = any([self.__project.execute(f"select exists(select 1 from {model}.manhole_node limit 1)").fetchone()[0] for model in self.__runner.list_models()])
        # licence
        if self.__licence_level is None and "numero de cle de license lu" in text:
            match_l = re.search(r"\( licence \'(\D*)\'\)", text)
            if match_l:
                self.__licence_level = match_l.group(1)
                if self.__licence_level == 'STARTER':
                    text = tr(f"""<center>La version PRO vous permettrait d'accélérer les calculs</center>
                                  <center>et d'accéder à des options complémentaires.</center>
                                {"<center>Voir message en fin de calcul estimant les temps de calcul avec la version PRO.</center>" if manholes_in_models else ''}""")
                    starting_box = QMessageBox()
                    starting_box.setWindowTitle(tr('Computation starting'))
                    starting_box.setTextFormat(Qt.RichText)
                    starting_box.setText(text)
                    starting_box.exec_()

        # computation time
        if "temps de calcul de la simulation hydraulique" in text:
            match_d = re.findall(r"(\d*)hr\s*(\d*)mn\s*(\d*)sec", text)
            if match_d:
                if self.__licence_level == 'STARTER' and self.__starter_duration is None:
                    self.__starter_duration = timedelta(hours=int(match_d[0][0]), minutes=int(match_d[0][1]), seconds=int(match_d[0][2]))
                    self.__pro_duration = timedelta(hours=int(match_d[1][0]), minutes=int(match_d[1][1]), seconds=int(match_d[1][2]))
                elif self.__licence_level == 'PRO' and self.__pro_duration is None:
                    self.__pro_duration = timedelta(hours=int(match_d[0][0]), minutes=int(match_d[0][1]), seconds=int(match_d[0][2]))

    def __output_log(self, text):
        ''' add line for kernel output logging'''
        text = '\n'.join(re.split('\n+', text.strip()))
        if text:
            weight = None
            if "output" in text :
                self.output_scroll.new_label()
                self.output_scroll.add_line(text, weight='bold', color='#ffffff')
            else:
                self.output_scroll.add_line(text, color='#ffffff')
            if "PHASE CALCUL TRANSITOIRE" in text:
                self.output_scroll.new_label(15)

class KernelError(Exception):
    pass
