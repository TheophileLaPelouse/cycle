import os 
from qgis.PyQt.QtWidgets import QDialog, QTreeWidget, QTreeWidgetItem, QVBoxLayout, QPushButton, QFileDialog, QLabel, QCheckBox, QComboBox, QHeaderView
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QIcon
from ...qgis_utilities import QGisProjectManager, tr 
from ...utility.json_utils import get_propertie
from .graph_widget import GraphWidget, pretty_number

# Faudra ajouter les paramètres de taille dans Bloc_Icon
Bloc_Icon = {'clarificateur' : 'clarificateur.svg'}
path_icons = os.path.join(os.path.dirname(__file__), '..', '..', 'ressources', 'svg')


class Result(QDialog) : 
    def __init__(self, project, parent=None) : 
        QDialog.__init__(self, parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'results_graphs.ui'), self)
        self.project = project
        
        bloc_tree = self.project.bloc_tree()
        
        query = f"select name, b_type from api.bloc"
        b_types = self.project.fetchall(query)
        self.b_types = {b[0] : b[1] for b in b_types}
        
        self.colors = ['blue', 'red', 'green', 'magenta', 'cyan', 'white']
        self.params = {}
        self.refresh_tree(bloc_tree)
        # Adjust column widths
        self.treeWidget.header().setStretchLastSection(False)
        self.treeWidget.header().setSectionResizeMode(0, QHeaderView.Stretch)
        self.treeWidget.header().setSectionResizeMode(1, QHeaderView.ResizeToContents)
        self.treeWidget.header().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        self.treeWidget.header().setSectionResizeMode(3, QHeaderView.ResizeToContents)
        
        self.treeWidget.setStyleSheet("""
            QHeaderView::section {
                border-right: 1px solid lightgray;
            }
            QTreeWidget::item {
                border-bottom: 1px solid lightgray ;
            }
        """)
        
        self.graph_bar_e = GraphWidget(self.bar_chart_e, dpi=90)
        self.graph_bar_c = GraphWidget(self.bar_chart_c, dpi=90)
        self.graph_bar_ce = GraphWidget(self.bar_chart_ce, dpi=90)
        
        self.show_result_button.clicked.connect(self.show_results)
        
        self.selected_blocs = set()
        self.bloc_tree = bloc_tree
        
        self.prg = {}
        prgs = project.fetchall("select name, val from ___.global_values where name like 'PRG_%'")
        for prg in prgs :
            self.prg[prg[0][4:].lower()] = prg[1]
        
    def refresh_tree(self, bloc_tree) : 
        self.treeWidget.clear()
        def add_node(dico, node = self.treeWidget, etage = 0, color = self.colors[0]) : 
            k = 0
            for key in dico : 
                if etage == 0 : 
                    k = k % len(self.colors)
                    color = self.colors[k]
                k += 1 
                print(dico, key)
                childnode = QTreeWidgetItem(node)
                checkbox1 = QCheckBox(self.treeWidget)
                color_choice = QComboBox(self.treeWidget)
                color_choice.addItems(self.colors)
                color_choice.setCurrentText(color)
                childnode.setText(0, key)
                if self.b_types.get(key) in Bloc_Icon :
                    icon = QIcon(os.path.join(path_icons, Bloc_Icon[self.b_types[key]]))
                    childnode.setIcon(0, icon)
                if etage != 0 : 
                    self.treeWidget.setItemWidget(childnode, 1, checkbox1)
                self.treeWidget.setItemWidget(childnode, 3, color_choice)
                self.params[key] = [checkbox1, color_choice]
                print(self.params)
                checkbox1.stateChanged.connect(lambda x, k=key : self.select_bloc(k, x))
                if len(dico[key]) > 0 : 
                    checkbox2 = QCheckBox(self.treeWidget)
                    self.treeWidget.setItemWidget(childnode, 2, checkbox2)
                    checkbox2.stateChanged.connect(lambda x, k=key : self.select_ss_blocs(k, x))
                    color_choice.currentTextChanged.connect(lambda x, k=key : self.change_ss_colors(k, x))
                    add_node(dico[key], childnode, etage+1)

        add_node(bloc_tree)
    
    def select_bloc(self, bloc, state) :
        print(state)
        if state :
            self.selected_blocs.add(bloc)
        else : 
            self.selected_blocs.remove(bloc)
        print(self.selected_blocs)
    
    def select_ss_blocs(self, bloc, x) :
        specific_bloc_tree = get_propertie(bloc, self.bloc_tree)
        print('specific', specific_bloc_tree)
        for key in specific_bloc_tree :
            self.params[key][0].setCheckState(x)
            
    def change_ss_colors(self, bloc, color) :
        specific_bloc_tree = get_propertie(bloc, self.bloc_tree)
        for key in specific_bloc_tree :
            self.params[key][1].setCurrentText(color)
            
    def show_results(self) :
        # Séparation par couleur 
        bloc_groups = {}
        for bloc in self.params :
            color = self.params[bloc][1].currentText()
            if color not in bloc_groups :
                bloc_groups[color] = set()
            if bloc in self.selected_blocs :
                bloc_groups[color].add(bloc)
        
        for color in bloc_groups : 
            query = f"select api.get_histo_data2(array{[bloc for bloc in bloc_groups[color]]}::text[])"
            bloc_groups[color] = self.project.fetchone(query)[0]
        
        stud_time = self.project.fetchone(f"select val from ___.global_values where name = 'study_time'")[0] 
        
        self.show_table(bloc_groups, stud_time)
        self.show_graphs(bloc_groups, stud_time)
    
    
    def show_table(self, bloc_groups, stud_time) :
        return 
     
    def show_graphs(self, bloc_groups, stud_time, ges_colors = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) :
        i = 0
        for color in bloc_groups :
            if i == 0 : 
                r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names = self.fill_bars(bloc_groups[color], stud_time)
                self.graph_bar_c.bar_chart(r, bars_c, bars_c_err, 'c', names, ges_colors, color, tr("Emission construction (kgGaz)"), tr('kg de GES émis'), tr('Sous blocs'))
                self.graph_bar_e.bar_chart(r, bars_e, bars_e_err, 'e', names, ges_colors, color, tr("Emission exploitation (kgGaz/an)"), tr('kg de GES émis par an'), tr("Sous blocs"))   
                self.graph_bar_ce.bar_chart(r, bars_ce, bars_ce_err, 'ce', names, ges_colors, color, tr("Emission exploitation et construction (kgCO2eq/%d ans)" % (stud_time)), tr('kg de CO2eq émis par %d ans' % stud_time), tr("Sous blocs"))
                i += 1
                rtot = r
            else : 
                r2, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names2 = self.fill_bars(bloc_groups[color], stud_time)
                rtot = range(0, rtot[-1] + 1 + r2[-1])
                r = range(r[-1]+1, r2[-1]+1+r[-1]+1)
                names += names2
                self.graph_bar_c.add_bar_chart(r, rtot, bars_c, bars_c_err, 'c', names, ges_colors, color)
                self.graph_bar_e.add_bar_chart(r, rtot, bars_e, bars_e_err, 'e', names, ges_colors, color)  
                self.graph_bar_ce.add_bar_chart(r, rtot, bars_ce, bars_ce_err, 'ce', names, ges_colors, color)
                
    def fill_bars(self, data, stud_time) : 
        bars = {'co2_e' : [], 'ch4_e': [], 'n2o_e': [], 'co2_c' : [], 'ch4_c': [], 'n2o_c': [], 'co2_eq_ce' : []}
        for key in data : 
            if key != 'total' :
                for field in bars :
                    bars[field].append(data[key].get(field, {'val' : 0, 'incert' : 0}))
        r = range(len(bars['co2_e'])) 
        names = list(data.keys())
        names.remove('total')
        print('r', r)
        print('prg', self.prg)
        bars_c = {'co2' : [x['val']*self.prg['co2'] for x in bars['co2_c']], 
                  'ch4' : [x['val']*self.prg['ch4'] for x in bars['ch4_c']], 
                  'n2o' : [x['val']*self.prg['n2o'] for x in bars['n2o_c']]}
        
        bars_e = {'co2' : [x['val']*self.prg['co2'] for x in bars['co2_e']], 
                  'ch4' : [x['val']*self.prg['ch4'] for x in bars['ch4_e']], 
                  'n2o' : [x['val']*self.prg['n2o'] for x in bars['n2o_e']]}
        
        bars_ce = [x['val']*self.prg['co2']*stud_time for x in bars['co2_eq_ce']]
        
        bars_c_err = [bars['co2_c'][k]['incert']*bars_c['co2'][k] + bars['ch4_c'][k]['incert']*bars_c['ch4'][k] + bars['n2o_c'][k]['incert']*bars_c['n2o'][k] for k in r]
        
        bars_e_err = [bars['co2_e'][k]['incert']*bars_e['co2'][k] + bars['ch4_e'][k]['incert']*bars_e['ch4'][k] + bars['n2o_e'][k]['incert']*bars_e['n2o'][k] for k in r]
        
        bars_ce_err = [bars['co2_eq_ce'][k]['incert']*bars_ce[k]*stud_time for k in r]
        
        return r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names
                        
        

# import os 
# from PyQt5.QtWidgets import QDialog, QTreeWidget, QTreeWidgetItem, QVBoxLayout, QPushButton, QFileDialog, QLabel, QProgressBar, QCheckBox
# from PyQt5 import uic

# class Resume_result(QDialog):
#     def __init__(self, parent=None):
#         super(Resume_result, self).__init__(parent)
#         uic.loadUi(os.path.join(os.path.dirname(__file__), 'results_graphs.ui'), self)
#         layertree = {'bloc1': ['bloc1', 'bloc2', 'bloc3']}
#         rootnode = QTreeWidgetItem(self.treeWidget)
#         for elem in layertree:
#             node = QTreeWidgetItem(rootnode)
#             node.setText(0, elem)
#             for child in layertree[elem]:
#                 childnode = QTreeWidgetItem(node)
#                 childnode.setText(0, child)
#                 # Add QCheckBox to the "Sélection" column
#                 checkbox = QCheckBox(self.treeWidget)
#                 self.treeWidget.setItemWidget(childnode, 1, checkbox)
#                 # Connect the QCheckBox to a function
#                 checkbox.stateChanged.connect(lambda x : self.on_checkbox_state_changed(child))
                
#     def on_checkbox_state_changed(self, name):
#         print(name)

                
#         # self.exec_()
        
# if __name__ == '__main__':
#     import sys
#     from PyQt5.QtWidgets import QApplication
#     app = QApplication(sys.argv)
#     dialog = Resume_result()
#     dialog.show()
#     sys.exit(app.exec_())