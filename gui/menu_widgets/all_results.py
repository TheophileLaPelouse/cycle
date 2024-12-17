import os 
from qgis.PyQt.QtWidgets import QDialog, QTreeWidget, QTreeWidgetItem, QVBoxLayout, QPushButton, QFileDialog, QLabel, QCheckBox, QComboBox, QHeaderView, QSplitter
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QIcon, QColor, QBrush
from ...qgis_utilities import QGisProjectManager, tr 
from .new_results import Result
import pandas as pd
import json

class AllResults(QDialog) : 
    def __init__(self, project, parent=None) : 
        QDialog.__init__(self, parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'all_results.ui'), self)
        
        self.setWindowFlag(Qt.WindowMinimizeButtonHint, True)
        self.setWindowFlag(Qt.WindowMaximizeButtonHint, True)
        
        self.project = project
        
        self.export_btn.clicked.connect(self.export_results)
        self.save_plot_btn.clicked.connect(self.save_plot)
        self.save_all_btn.clicked.connect(self.save_all)
        self.load_all_btn.clicked.connect(self.load_all)
        self.refresh_btn.clicked.connect(self.refresh)
        self.close_button.clicked.connect(self.close)
        
        parent_bg_color = self.palette().color(self.backgroundRole())
        darker_color = parent_bg_color.darker(97)
        darker_color_rgb = (darker_color.redF(), darker_color.greenF(), darker_color.blueF())
        rgb_int = [str(int(255 * x)) for x in darker_color_rgb]
        # print("darker_color", darker_color_rgb)
        self.tabWidget.setStyleSheet(f"background-color: rgb({','.join(rgb_int)});")
        # self.tabWidget.setStyleSheet("background-color: lightgray;")
        
        self.tabWidget.currentChanged.connect(self.tab_changed)
        self.tab_changed(0)
        
    def close(self) :
        # Y'aura peut être d'autres trucs ?
        self.accept()
        
    def tab_changed(self, index) : 
        if index == self.tabWidget.count() - 1 : 
            self.create_new_tab()
            
    def create_new_tab(self) : 
        new_tab = Result(self.project)
        new_tab.remove_tab_btn.clicked.connect(lambda : self.remove_tab(new_tab))
        self.tabWidget.insertTab(self.tabWidget.count() - 1, new_tab, "page_"+str(self.tabWidget.count()-1))
        self.tabWidget.setCurrentIndex(self.tabWidget.count() - 2)
        return new_tab
        
        # Ne fonctionne pas je ne sais pas trop pourquoi
        
    def remove_tab(self, tab) :
        index = self.tabWidget.indexOf(tab)
        self.tabWidget.removeTab(index)
        tab.deleteLater()
        
    def save_plot(self) : 
        tab = self.tabWidget.currentWidget()
        
        graphs = {'tab' : tab.graph_bar_c, 'tab_2' : tab.graph_bar_e, 'tab_3' : tab.graph_bar_ce}
        graph_widget = graphs[tab.tabWidget.currentWidget().objectName()]
        print('graph_widget', type(graph_widget), graph_widget.objectName())
        current_plot = graph_widget.fig
        file, __ = QFileDialog.getSaveFileName(self, self.tr("Sélectionner un fichier"), filter="PNG (*.png)")
        if not file : return 
        current_plot.savefig(file)
        
    def refresh(self) :
        n = self.tabWidget.count()
        for k in range(n-1) : 
            param_values = self.tabWidget.widget(k).get_params()
            self.tabWidget.widget(k).refresh_tree()
            self.tabWidget.widget(k).set_params(param_values)
            
    def save_all(self) :
        # Sauvegarde de tous les paramètres d'affichage des différents onglet (pour les recharger plus tard)
        default_directory = self.project.directory
        file, __ = QFileDialog.getSaveFileName(self, self.tr("Sélectionner un fichier"), default_directory, filter="graph_lieges (*.plot_lieges)")
        if not file : return
        save = {}
        for k in range(self.tabWidget.count()-1) :
            tab = self.tabWidget.widget(k)
            save[self.tabWidget.tabText(k)] = tab.get_params()
        with open(file, 'w') as f : 
            json.dump(save, f)
            
    def load_all(self) :
        default_directory = self.project.directory
        file, __ = QFileDialog.getOpenFileName(self, self.tr("Sélectionner un fichier"), default_directory, filter="graph_lieges (*.plot_lieges)")
        if not file : return 
        with open(file, 'r') as f :
            save = json.load(f)
        for k in save :
            tab = self.create_new_tab()
            tab.set_params(save[k])
            
        
    def export_results(self) :
        # Exporte les résultats au format csv ou excel.
        models = self.project.models
        
        file, __ = QFileDialog.getSaveFileName(self, self.tr("Sélectionner un fichier"), filter="CSV (*.csv) ;;Excel (*.xlsx)")
        if not file : return 
        col_alias = {'co2_e' : ('CO2 exploitation valeur', 'CO2 exploitation incertitude'), 'ch4_e' : ('CH4 exploitation valeur', 'CH4 exploitation incertitude'),
                             'n2o_e' : ('N2O exploitation valeur', 'N2O exploitation incertitude'), 'co2_c' : ('CO2 construction valeur', 'CO2 construction incertitude'),
                             'ch4_c' : ('CH4 construction valeur', 'CH4 construction incertitude'), 'n2o_c' : ('N2O construction valeur', 'N2O construction incertitude'),
                             'co2_eq_c' : ('CO2eq construction valeur', 'CO2eq construction incertitude'), 'co2_eq_e' : ('CO2eq exploitation valeur', 'CO2eq exploitation incertitude'),
                             'co2_eq_ce' : ('CO2eq construction et exploitation valeur', 'CO2eq construction et exploitation incertitude')}
        columns = []
        for key in col_alias : 
            columns.append(col_alias[key][0])
            columns.append(col_alias[key][1])
        All_data = {}
        for mod in models : 
            blocs = self.project.fetchall(f"""
                with b_types as (select b_type from api.input_output where concrete or b_type='sur_bloc')
                select name from api.bloc where model = '{mod}' and b_type in (select b_type from b_types)""")
            blocs = [bloc[0] for bloc in blocs]
            data_mod = {}
            for bloc in blocs : 
                data = self.project.fetchone(f"select api.get_histo_data('{mod}', '{bloc}')")[0]
                indexs = list(data.keys())
                df = pd.DataFrame(index=indexs, columns=columns)
                for index, col in data.items() : 
                    for c in col : 
                        df.loc[index, col_alias[c][0]] = col[c]['val']
                        df.loc[index, col_alias[c][1]] = col[c]['incert']
                data_mod[bloc] = df
            data = self.project.fetchone(f"select api.get_histo_data('{mod}')")[0]
            indexs = list(data.keys())
            df = pd.DataFrame(index=indexs, columns=columns)
            for index, col in data.items() : 
                for c in col : 
                    df.loc[index, col_alias[c][0]] = col[c]['val']
                    df.loc[index, col_alias[c][1]] = col[c]['incert']
            data_mod[mod] = df
            All_data[mod] = data_mod
        
        if file.endswith('.csv') :
            with open(file, 'w') as f : 
                f.write(f"-- Résultats du projet {self.project.name}\n")
            
            for mod in All_data :
                with open(file, 'a') as f : 
                    f.write(f"\n\n-- Modèle {mod}--\n")
                for bloc in All_data[mod] :
                    with open(file, 'a') as f : 
                        f.write(f"\n-- Bloc {bloc}\n")
                    All_data[mod][bloc].to_csv(file, mode='a')
        else :
            with pd.ExcelWriter(file) as writer:
                for mod in All_data:
                    sheet_name = f"{mod}"
                    pd.DataFrame(columns=[f"Résultats du projet {self.project.name}", f"Modèle {mod}"]).to_excel(writer, sheet_name=sheet_name, index=False)
                    start = 3
                    for bloc in All_data[mod]:
                        pd.DataFrame(index=["Bloc"], data=[f"{bloc}"]).to_excel(writer, sheet_name=sheet_name, index=True, header=False, startrow = start)
                        start += 1
                        All_data[mod][bloc].to_excel(writer, sheet_name=sheet_name, startrow=start)
                        start += len(All_data[mod][bloc].index) + 2
