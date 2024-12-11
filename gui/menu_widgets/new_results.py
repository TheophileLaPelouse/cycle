import os 
from qgis.PyQt.QtWidgets import QDialog, QTreeWidget, QTreeWidgetItem, QVBoxLayout, QPushButton, QFileDialog, QLabel, QCheckBox, QComboBox, QHeaderView, QSplitter
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtGui import QIcon, QColor, QBrush
from ...qgis_utilities import QGisProjectManager, tr 
from ...utility.json_utils import get_propertie
from .graph_widget import GraphWidget, pretty_number, fill_bars, sort_bars

# Faudra ajouter les paramètres de taille dans Bloc_Icon
Bloc_Icon = {'clarificateur' : 'clarificateur.svg'}
path_icons = os.path.join(os.path.dirname(__file__), '..', '..', 'ressources', 'svg')


class Result(QDialog) : 
    def __init__(self, project, parent=None) : 
        QDialog.__init__(self, parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'results_graphs.ui'), self)
        self.project = project
       
        query = f"select name, b_type from api.bloc"
        b_types = self.project.fetchall(query)
        self.b_types = {b[0] : b[1] for b in b_types}
        
        self.colors = ['blue', 'red', 'green', 'magenta', 'white']
        self.color_brushes = {'blue' : QBrush(QColor(173, 216, 230)), 
                              'red' : QBrush(QColor(254, 89, 89)), 
                              'green' : QBrush(QColor(20, 255, 57)),
                              'magenta' : QBrush(QColor(238, 76, 166)),
                              'white' : QBrush(QColor('white')), 
                              'grey' : QBrush(QColor(180, 180, 180))}
        self.params = {}
        self.bloc_id = {}
        self.bloc_tree = {}
        self.refresh_tree()
        # Adjust column widths
        self.treeWidget.header().setStretchLastSection(False)
        self.treeWidget.header().setSectionResizeMode(0, QHeaderView.Stretch)
        self.treeWidget.header().setSectionResizeMode(1, QHeaderView.ResizeToContents)
        self.treeWidget.header().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        self.treeWidget.header().setSectionResizeMode(3, QHeaderView.ResizeToContents)
        
        self.frame.setStyleSheet("""
            QFrame {
                border: 1px solid lightgray;
                border-radius: 3px;
            }
            QPushButton {
                margin: 3px;
            }
            QTableWidget {
                margin: 3px;
            }
        """)
                
        self.treeWidget.setStyleSheet("""
            QHeaderView::section {
                border-right: 1px solid lightgray;
            }
            QTreeWidget::item {
                border-bottom: 1px solid lightgray ;
            }
        """)
        
        self.table.header().setStretchLastSection(False)
        for i in range(4) : 
            self.table.header().setSectionResizeMode(i, QHeaderView.ResizeToContents)
            
        self.frame_table.setStyleSheet("""
            QFrame {
                border: 1px solid lightgray;
                border-radius: 3px;
                }
        """)
        
        layout = self.frame_splitter.layout()
        splitter = QSplitter(Qt.Horizontal)
        splitter.addWidget(self.frame)
        splitter.addWidget(self.frame_table)
        layout.addWidget(splitter)
        
        layout = self.frame_splitter_V.layout()
        splitter = QSplitter(Qt.Vertical)
        splitter.addWidget(self.frame_splitter)
        splitter.addWidget(self.tabWidget)
        splitter.setSizes([300, 300])
        layout.addWidget(splitter)
        
        # self.table.setStyleSheet("""
        #     QHeaderView::section {
        #         border-right: 1px solid lightgray;
        #     }
        #     QTreeWidget::item {
        #         border-bottom: 1px solid lightgray;
        #     }
        # """) ça écrase les couleurs donc pas fou
        
        self.graph_bar_e = GraphWidget(self.bar_chart_e, dpi=90)
        self.graph_bar_c = GraphWidget(self.bar_chart_c, dpi=90)
        self.graph_bar_ce = GraphWidget(self.bar_chart_ce, dpi=90)
        
        self.show_result_button.clicked.connect(self.show_results)
        
        self.selected_blocs = set()
        
        
        
        self.prg = {}
        prgs = project.fetchall("select name, val from ___.global_values where name like 'PRG_%'")
        for prg in prgs :
            self.prg[prg[0][4:].lower()] = prg[1]
        
    def refresh_tree(self) : 
        bloc_tree = self.project.bloc_tree()
        blocs_id = self.project.fetchall("select name, id from api.bloc")
        self.bloc_id = {b[0] : b[1] for b in blocs_id}
        self.bloc_tree = bloc_tree
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
                color_choice = QComboBox(self.treeWidget)
                color_choice.addItems(self.colors)
                color_choice.setCurrentText(color)
                childnode.setText(0, key)
                if self.b_types.get(key) in Bloc_Icon :
                    icon = QIcon(os.path.join(path_icons, Bloc_Icon[self.b_types[key]]))
                    childnode.setIcon(0, icon)
                if etage != 0 : 
                    checkbox1 = QCheckBox(self.treeWidget)
                    self.treeWidget.setItemWidget(childnode, 1, checkbox1)
                else : 
                    checkbox1 = None
                self.treeWidget.setItemWidget(childnode, 3, color_choice)
                self.params[key] = [checkbox1, color_choice]
                print(self.params)
                if checkbox1 :
                    checkbox1.stateChanged.connect(lambda x, k=key : self.select_bloc(k, x))
                if len(dico[key]) > 0 : 
                    checkbox2 = QCheckBox(self.treeWidget)
                    self.treeWidget.setItemWidget(childnode, 2, checkbox2)
                    checkbox2.stateChanged.connect(lambda x, k=key : self.select_ss_blocs(k, x))
                    color_choice.currentTextChanged.connect(lambda x, k=key : self.change_ss_colors(k, x))
                    add_node(dico[key], childnode, etage+1, color)

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
        self.table.clear()
        
        def add_children(parent_node, data, brush) : 
            fields = ['co2', 'ch4', 'n2o']
            for field in fields : 
                val_c = data[field+'_c']['val']
                val_e = data[field+'_e']['val']
                if val_c or val_e :
                    child_node = QTreeWidgetItem(parent_node)
                    child_node.setText(0, field.upper())
                    child_node.setText(2, pretty_number(data[field+'_c']['val'], data[field+'_c']['incert']*data[field+'_c']['val'], 'kgGaz'))
                    child_node.setText(3, pretty_number(data[field+'_e']['val'], data[field+'_e']['incert']*data[field+'_e']['val'], 'kgGaz/an')) 
                    for i in range(5): 
                        child_node.setBackground(i, brush)
                                    
        for color in bloc_groups : 
            if not (bloc_groups[color]['total']['co2_eq_c']['val'] == 0 and bloc_groups[color]['total']['co2_eq_e']['val'] == 0) :
                for key in bloc_groups[color] :
                    # self.table est un treeWidget 
                    if key == 'total' :
                        separator_node = QTreeWidgetItem(self.table)
                        for i in range(5) :
                            separator_node.setBackground(1, QBrush(QColor(255, 255, 255)))  # White background
                
                        brush = self.color_brushes['grey']
                    else :
                        brush = self.color_brushes[color]
                    
                    parent_node = QTreeWidgetItem(self.table)
                    font = parent_node.font(0)
                    font.setBold(True)
                    parent_node.setFont(0, font)
                    parent_node.setText(0, key)
                    if key != 'total' : 
                        parent_node.setText(1, str(self.bloc_id[key]))               
                        
                    # Create child nodes for the details
                    co2_eq_c_val = bloc_groups[color][key]['co2_eq_c']['val']
                    co2_eq_c_incert = bloc_groups[color][key]['co2_eq_c']['incert'] * co2_eq_c_val
                    co2_eq_e_val = bloc_groups[color][key]['co2_eq_e']['val']
                    co2_eq_e_incert = bloc_groups[color][key]['co2_eq_e']['incert'] * co2_eq_e_val
                    co2_eq_ce_val = bloc_groups[color][key]['co2_eq_ce']['val'] * stud_time
                    co2_eq_ce_incert = bloc_groups[color][key]['co2_eq_ce']['val'] * bloc_groups[color][key]['co2_eq_ce']['incert'] * stud_time
                    
                    # Set the summary values in the parent node
                    parent_node.setText(2, pretty_number(co2_eq_c_val, co2_eq_c_incert, ''))
                    parent_node.setText(3, pretty_number(co2_eq_e_val, co2_eq_e_incert, ''))
                    parent_node.setText(4, pretty_number(co2_eq_ce_val, co2_eq_ce_incert, ''))
                    
                    for i in range(5): 
                        parent_node.setBackground(i, brush)
                    
                    add_children(parent_node, bloc_groups[color][key], brush) 
        
        self.table.header().setStretchLastSection(False)
        for i in range(5) : 
            self.table.header().setSectionResizeMode(i, QHeaderView.ResizeToContents)
        
        return 
     
    def show_graphs(self, bloc_groups, stud_time, ges_colors = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) :
        first = True
        j = 0
        n = len(bloc_groups)
        render = False
        names_color = {key : self.params[key][1].currentText() for key in self.params}
        for color in bloc_groups :
            # print('Bloc GROUPE', bloc_groups[color])
            if not (bloc_groups[color]['total']['co2_eq_c']['val'] == 0 and bloc_groups[color]['total']['co2_eq_e']['val'] == 0) :
                if j == n -1 : 
                    render = True
                    
                if first : 
                    r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names = fill_bars(self.prg, bloc_groups[color], stud_time)
                    bars_c, names_c, bars_c_err = sort_bars(bars_c, names, bars_c_err)
                    edgecolor = [names_color[name] for name in names_c]
                    self.graph_bar_c.bar_chart(r, bars_c, bars_c_err, 'c', names_c, self.bloc_id, ges_colors, edgecolor, tr("Emission construction (kgGaz)"), tr('kg de GES émis'), tr('Sous blocs'), render=render)
                    bars_e, names_e, bars_e_err = sort_bars(bars_e, names, bars_e_err)
                    edgecolor = [names_color[name] for name in names_c]
                    self.graph_bar_e.bar_chart(r, bars_e, bars_e_err, 'e', names_e, self.bloc_id, ges_colors, edgecolor, tr("Emission exploitation (kgGaz/an)"), tr('kg de GES émis par an'), tr("Sous blocs"), render=render)   
                    bars_ce, names_ce, bars_ce_err = sort_bars(bars_ce, names, bars_ce_err)
                    edgecolor = [names_color[name] for name in names_c]
                    self.graph_bar_ce.bar_chart(r, bars_ce, bars_ce_err, 'ce', names_ce, self.bloc_id, ges_colors, edgecolor, tr("Emission exploitation et construction (kgCO2eq/%d ans)" % (stud_time)), tr('kg de CO2eq émis par %d ans' % stud_time), tr("Sous blocs"), render=render)
                    first = False
                else : 
                    r2, bars_c2, bars_c_err2, bars_e2, bars_e_err2, bars_ce2, bars_ce_err2, names2 = fill_bars(self.prg, bloc_groups[color], stud_time)
                    
                    r = range(0, r[-1] + 1 + r2[-1]+1)
                    # r = range(r[-1]+1, r2[-1]+1+r[-1]+1)
                    bars_c, names_c, bars_c_err = sort_bars(bars_c, names, bars_c_err, bars_c2, names2, bars_c_err2)
                    if render : edgecolor = [names_color[name] for name in names_c]
                    self.graph_bar_c.bar_chart(r, bars_c, bars_c_err, 'c', names_c, self.bloc_id, ges_colors, edgecolor, tr("Emission construction (kgGaz)"), tr('kg de GES émis'), tr('Sous blocs'), render=render)
                    bars_e, names_e, bars_e_err = sort_bars(bars_e, names, bars_e_err, bars_e2, names2, bars_e_err2)
                    if render : edgecolor = [names_color[name] for name in names_c]
                    self.graph_bar_e.bar_chart(r, bars_e, bars_e_err, 'e', names_e, self.bloc_id, ges_colors, edgecolor, tr("Emission exploitation (kgGaz/an)"), tr('kg de GES émis par an'), tr("Sous blocs"), render=render)   
                    bars_ce, names_ce, bars_ce_err = sort_bars(bars_ce, names, bars_ce_err, bars_ce2, names2, bars_ce_err2)
                    if render : edgecolor = [names_color[name] for name in names_c]
                    self.graph_bar_ce.bar_chart(r, bars_ce, bars_ce_err, 'ce', names_ce, self.bloc_id, ges_colors, edgecolor, tr("Emission exploitation et construction (kgCO2eq/%d ans)" % (stud_time)), tr('kg de CO2eq émis par %d ans' % stud_time), tr("Sous blocs"), render=render)   
            j += 1    
        
                        
    def get_params(self) :
        params_values = {} 
        for bloc in self.params : 
            params_values[bloc] = [self.params[bloc][0].isChecked() if self.params[bloc][0] else None, 
                                   self.params[bloc][1].currentText()]
        return params_values

    def set_params(self, param_values) : 
        for bloc in param_values : 
            if bloc in self.params :
                print('bloc and params', bloc, param_values)
                if self.params[bloc][0] :
                    self.params[bloc][0].setChecked(param_values[bloc][0])
                self.params[bloc][1].setCurrentText(param_values[bloc][1])
                 

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