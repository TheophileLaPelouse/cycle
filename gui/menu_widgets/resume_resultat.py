import os
from qgis.PyQt import uic
from qgis.PyQt.QtGui import QBrush, QColor, QIcon
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QDockWidget, QTableWidgetItem, QSplitter
from ...qgis_utilities import QGisProjectManager, tr 
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT, FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from .graph_widget import GraphWidget, pretty_number, fill_bars, sort_bars

class RecapResults(QDockWidget) : 
    
    def __init__(self, model_name, project) : 
        QDockWidget.__init__(self, tr("Results"))
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'resume_resultat.ui'), self)
        
        icon = QIcon(os.path.join(os.path.dirname(__file__), '..', '..', 'ressources', 'svg', 'warning.svg'))
        self.warning_btn.setIcon(icon)
        self.warning_btn.setEnabled(False)
        
        icon = QIcon(os.path.join(os.path.dirname(__file__), '..', '..', 'ressources', 'svg', 'refresh.svg'))
        self.refresh_btn.setIcon(icon)
        self.refresh_btn.clicked.connect(self.update_model_list)
        self.refresh_btn.clicked.connect(self.show_results)
        self.refresh_btn.setFixedHeight(self.model_combo.sizeHint().height())
        self.refresh_btn.clicked.connect(self.show_results)
        
        self.to_make_flashy = {}
        
        for k in range(10) : 
            button = getattr(self, f'pushButton_{k+1}')
            button.clicked.connect(lambda _, index=k+1: self.navigate(index))
        
        self.project = project
        
        self.__current_model = model_name 
        self.__recap_table = None 
        self.__results = None 
        
        self.graph_pie_e = GraphWidget(self.pie_chart_e, dpi=100)
        self.graph_pie_c = GraphWidget(self.pie_chart_c, dpi=100)
        self.graph_bar_e = GraphWidget(self.bar_chart_e, dpi=90)
        self.graph_bar_c = GraphWidget(self.bar_chart_c, dpi=90)
        self.graph_bar_ce = GraphWidget(self.bar_chart_ce, dpi=90)
        
        model_list = self.project.models
        self.update_model_list()
        self.model_combo.currentIndexChanged.connect(self.show_results)
        
        self.prg = {}
        prgs = project.fetchall("select name, val from ___.global_values where name like 'PRG_%'")
        for prg in prgs :
            self.prg[prg[0][4:].lower()] = prg[1]
            
        layout = self.layout_frame.layout()
        splitter = QSplitter(Qt.Vertical)
        splitter.addWidget(self.stackedWidget)
        splitter.addWidget(self.frame_splitter)
        splitter.setSizes([300, 300])
        layout.addWidget(splitter)
        
        if model_name is not None : 
            print("ici")
            self.model_combo.setCurrentText(model_name)
        
    def update_model_list(self) : 
        model_list = self.project.models
        print('list', model_list)
        self.model_combo.clear()
        self.model_combo.addItems([''] + model_list)    
    
    def show_results(self, index_change, model_name = None) : 
        # Rempli le tableau récaptilatif des résultats et affiche les graphes
        print(index_change)
        if index_change == 0 : 
            return
        if model_name is None :
            model_name = self.model_combo.currentText()
        if model_name == '' :
            return    
        print("wut ?")
        print('model', model_name)
        results = self.project.fetchall(f"select name, res, co2_eq_e, co2_eq_c, id from api.results where model = '{model_name}'")
        self.__results = {}
        f_bloc_c = {}
        f_bloc_e = {}
        for result in results : 
            formula_c = set()
            formula_e = set()
            self.__results[result[0]] = {}
            self.__results[result[0]]['id'] = result[4]
            unknowns = set()
            detail = set()
            for formula in result[1]['data'] : 
                if formula['in use'] :
                    detail.add(str(formula['detail']))                    
                if formula['unknown'] : 
                    unknowns = unknowns.union(set(formula['unknown']))
                if formula['name'].endswith('_e'): 
                    formula_e.add(formula['formula'])
                elif formula['name'].endswith('_c') : 
                    formula_c.add(formula['formula'])
                    
            if None in formula_e :
                formula_e.remove(None)
            if None in formula_c :
                formula_c.remove(None)
            no_formula_e = len(formula_e) == 0 
            no_formula_c = len(formula_c) == 0
            f_bloc_e[result[0]] = no_formula_e
            f_bloc_c[result[0]] = no_formula_c
            unknowns2 = set()
            for val in unknowns :
                if val.startswith('q_') :
                    unknowns2.add('intrants')
                else : 
                    unknowns2.add(val)
            unknowns = unknowns2 
            self.__results[result[0]]['unknown'] = ', '.join(list(set(unknowns))) 
            self.__results[result[0]]['detail'] = ', '.join(detail)
            print('res', result[2])
            value, incert = result[2].strip()[1:-1].split(',')
            if not value : 
                value = 0
            value = float(value)
            if not incert : 
                incert = 0
            incert = float(incert)
            self.__results[result[0]]['co2_eq_e'] = pretty_number(value, value*incert, '')
            
            value, incert = result[3].strip()[1:-1].split(',')
            if not value : 
                value = 0
            value = float(value)
            if not incert : 
                incert = 0
            incert = float(incert)
            self.__results[result[0]]['co2_eq_c'] = pretty_number(value, value*incert, '')
            
            # self.__results[result[0]]['data'] = result[1]['data']
        # Cette variable sera réutilisée pour les graphes plus précise dans l'affichage des résultats plus complet
        self.__current_model = model_name
        self.__recap_table = {}
        
        for key in self.__results : 
            self.__recap_table[key] = [key, 
                                       self.__results[key]['id'],
                                       self.__results[key]['co2_eq_e'], self.__results[key]['co2_eq_c'],
                                       self.__results[key]['unknown'], 
                                       self.__results[key]['detail']]
            if self.__results[key]['co2_eq_e']=='No value' and self.__results[key]['co2_eq_c']=='No value' :
                self.to_make_flashy[key] = 'ce'
            elif self.__results[key]['co2_eq_e']=='No value' and not f_bloc_e[key] :
                self.to_make_flashy[key] = 'e'  
            elif self.__results[key]['co2_eq_c']=='No value' and not f_bloc_c[key] :
                self.to_make_flashy[key] = 'c'
            else :
                if self.to_make_flashy.get(key) : 
                    del self.to_make_flashy[key]
        
        self.fill_table()
            
        self.table_recap.resizeColumnsToContents()
        self.table_recap.setShowGrid(True)
        self.table_recap.setSortingEnabled(True)
        
        self.show_plot()
        
        if self.to_make_flashy : 
            self.warning_btn.setEnabled(True)
            self.warning_btn.clicked.connect(self.filter_table)
            
    def fill_table(self) :
        # Rempli le tableau récapitulatif des résultats
        self.table_recap.setRowCount(len(self.__recap_table))
        idx = 0
        print("BONJOUR")
        for key, values in self.__recap_table.items() : 
            for k in range(6) : 
                self.table_recap.setItem(idx, k, QTableWidgetItem(str(values[k])))
                if idx % 2 == 0 :
                    self.table_recap.item(idx, k).setBackground(Qt.lightGray)
                if self.to_make_flashy.get(key) == 'ce' :
                    print('flashy', key)
                    self.table_recap.item(idx, k).setBackground(QBrush(QColor(255, 165, 0)))
            if self.to_make_flashy.get(key) == 'e' :
                self.table_recap.item(idx, 2).setBackground(QBrush(QColor(255, 165, 0)))
            if self.to_make_flashy.get(key) == 'c' :
                self.table_recap.item(idx, 3).setBackground(QBrush(QColor(255, 165, 0)))
            idx += 1
            
    def filter_table(self) :
        # Filtre le tableau en fonction de to_make_flashy, soit affiche tout soit que les valeur manquantes
        if self.table_recap.rowCount() != len(self.to_make_flashy) :
            self.table_recap.setRowCount(len(self.to_make_flashy))
            idx = 0
            for key, values in self.__recap_table.items() : 
                if self.to_make_flashy.get(key) : 
                    for k in range(6) : 
                        self.table_recap.setItem(idx, k, QTableWidgetItem(str(values[k])))
                        if idx % 2 == 0 :
                            self.table_recap.item(idx, k).setBackground(Qt.lightGray)
                        if self.to_make_flashy.get(key) == 'ce' :
                            self.table_recap.item(idx, k).setBackground(QBrush(QColor(255, 165, 0)))
                    if self.to_make_flashy.get(key) == 'e' :
                        self.table_recap.item(idx, 2).setBackground(QBrush(QColor(255, 165, 0)))
                    if self.to_make_flashy.get(key) == 'c' :
                        self.table_recap.item(idx, 3).setBackground(QBrush(QColor(255, 165, 0)))
                    idx += 1
        else : 
            self.fill_table()
        
    def show_plot(self, bloc_name = None, dpi = 75, edgecolor = 'grey', color = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) :
        # Trace les diagrammes circulaires puis les histogrammes.
        data = self.project.fetchone(f"select api.get_histo_data('{self.__current_model}')")
        data = data[0]
        print(data)
        fields = ['co2_e', 'ch4_e', 'n2o_e', 'co2_c', 'ch4_c', 'n2o_c']
        self.label_e.setText(pretty_number(data['total']['co2_eq_e']['val'], data['total']['co2_eq_e']['incert']*data['total']['co2_eq_e']['val'], 'kgCO2/an'))
        self.label_c.setText(pretty_number(data['total']['co2_eq_c']['val'], data['total']['co2_eq_c']['incert']*data['total']['co2_eq_c']['val'], 'kgCO2'))
        self.label_e.setStyleSheet("font-weight: bold; font-size: 13px;")
        self.label_c.setStyleSheet("font-weight: bold; font-size: 13px;")

        # self.graph_pie_e.pie_chart(data_pie_e, labels, color, tr("kgGaz/an"))
        data_pie_e = []
        data_pie_c = []
        names_pie = []
        for bloc in data : 
            if bloc != 'total' :
                names_pie.append(bloc) 
                data_pie_e.append(data[bloc]['co2_eq_e']['val'])
                data_pie_c.append(data[bloc]['co2_eq_c']['val'])
        
        # data_pie_c = [data['total'][field]['val']*self.prg[field[:-2]] for field in fields[3:]]
        try : 
            self.graph_pie_e.pie_chart(data_pie_e, names_pie, tr("kgGaz/an"))
        except : 
            pass
        try : 
            self.graph_pie_c.pie_chart(data_pie_c, names_pie, tr("kgGaz"))
        except : pass
        stud_time = self.project.fetchone(f"select val from ___.global_values where name = 'study_time'")[0]
        
        # bars
        bloc_id = {key : self.__results[key]['id'] for key in self.__results}

        r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names = fill_bars(self.prg, data, stud_time)
        bars_c, names_c, bars_c_err = sort_bars(bars_c, names, bars_c_err)
        self.graph_bar_c.bar_chart(r, bars_c, bars_c_err, 'c', names_c, bloc_id, color, edgecolor, tr(""), tr('kg de GES émis'), tr('Blocs du modèle %s' % self.__current_model))
        bars_e, names_e, bars_e_err = sort_bars(bars_e, names, bars_e_err)
        self.graph_bar_e.bar_chart(r, bars_e, bars_e_err, 'e', names_e, bloc_id, color, edgecolor, tr(""), tr('kg de GES émis par an'), tr('Blocs du modèle %s' % self.__current_model))   
        bars_ce, names_ce, bars_ce_err = sort_bars(bars_ce, names, bars_ce_err)
        self.graph_bar_ce.bar_chart(r, bars_ce, bars_ce_err, 'ce', names_ce, bloc_id, color, edgecolor, tr(""), tr('kg de CO2eq émis par %d ans' % stud_time), tr('Blocs du modèle %s' % self.__current_model))   

        
    def navigate(self, index) :
        if index == 1 : 
            self.stackedWidget.setCurrentIndex(2)
        elif index == 10 : 
            self.stackedWidget.setCurrentIndex(0)
        elif index % 2 == 0 : 
            self.stackedWidget.setCurrentIndex(self.stackedWidget.currentIndex() + 1)
        else :
            self.stackedWidget.setCurrentIndex(self.stackedWidget.currentIndex() - 1)
            