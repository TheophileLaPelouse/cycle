import os
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QApplication, QMessageBox, QToolButton, QDockWidget, QInputDialog, QTableWidgetItem
from ...qgis_utilities import QGisProjectManager, tr 
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT, FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from .graph_widget import GraphWidget

class RecapResults(QDockWidget) : 
    
    def __init__(self, model_name, project, logger) : 
        QDockWidget.__init__(self, tr("Results"))
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'resume_resultat.ui'), self)
        
        self.__project = project
        self.__logger = logger
        
        self.__current_fig = None
        self.__current_model = model_name 
        self.__recap_table = None 
        self.__results = None 
        
        self.graph_pie_e = GraphWidget(self.pie_chart_e, dpi=75)
        self.graph_pie_c = GraphWidget(self.pie_chart_c, dpi=75)
        self.graph_bar_e = GraphWidget(self.bar_chart_e, dpi=75)
        self.graph_bar_c = GraphWidget(self.bar_chart_c, dpi=75)
        if model_name is not None : 
            self.show_results(model_name)   
        
        
        
        
    def show_results(self, model_name) : 
        # On fait un peu bourrain mais en vrai même si on a 500 blocs, ça reste linéaire donc ça passe 
        results = self.__project.fetchall(f"select id, res from api.results where model = '{model_name}'")
        self.__results = {result[1]: [result[2], result[3], result[4]] for result in results}
        self.__current_model = model_name
        
        self.__recap_table = {}
        for key in self.__results : 
            self.__recap_table[key] = [key, self.__results[key][0]['unknown'], 
                                       self.__results[key][1], self.__results[key][2], 
                                       self.__results[key][0]['detail'], self.__results[key][0]['in_use']]
        self.table_recap.setRowCount(len(self.__recap_table))
        idx = 0
        for key, values in self.__recap_table.items() : 
            for k in range(5) : 
                self.table_recap.setItem(idx, k, QTableWidgetItem(str(values[k])))
                if idx % 2 == 0 :
                    self.table_recap.item(idx, k).setBackground(Qt.lightGray)
                if values[5] : 
                    font = self.table_recap.item(idx, k).font()
                    font.setBold(True)
                    self.table_recap.item(idx, k).setFont(font)
            idx += 1
            
        self.table_recap.resizeColumnsToContents()
        self.table_recap.setShowGrid(True)
        self.table_recap.setSortingEnabled(True)
        
        self.show_plot()
        
    def show_plot(self, bloc_name = None, dpi = 75, edgecolor = 'grey', color = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) :
        
        data = self.__project.fetchone(f"select api.get_histo_data('{self.__current_model}')")
        
        # pie e 
        fields = ['co2_e', 'ch4_e', 'n2o_e']
        data_pie_e = [data['total'][field] for field in fields]
        labels = ['CO2', 'CH4', 'N2O']
        self.graph_pie_e.pie_chart(data_pie_e, labels, color, tr("Total emission for exploitation (kgGas/an)"))
        
        # pie c
        fields = ['co2_c', 'ch4_c', 'n2o_c']
        data_pie_c = [data['total'][field] for field in fields]
        labels = ['CO2', 'CH4', 'N2O']
        self.graph_pie_c.pie_chart(data_pie_c, labels, color, tr("Total emission for construction (kgGas)"))    
        
        # bars
        bars = {'co2_e' : [], 'ch4_e': [], 'n2o_e': [], 'co2_c' : [], 'ch4_c': [], 'n2o_c': []}
        for key in data : 
            if key != 'total' :
                for field in bars : 
                    bars[field].append(data[key][field])
        r = range(len(bars['co2_e']))        
        
        names = list(data.keys())
        names.remove('total')
        
        self.graph_bar_c.bar_chart(r, bars, 'c', names, color, edgecolor, tr("Construction emission (kgGas)"))
        self.graph_bar_e.bar_chart(r, bars, 'e', names, color, edgecolor, tr("Exploitation emission (kgGas/an)"))   
        