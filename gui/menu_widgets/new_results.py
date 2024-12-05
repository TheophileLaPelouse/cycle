import os 
from qgis.PyQt.QtWidgets import QDialog, QTreeWidget, QTreeWidgetItem, QVBoxLayout, QPushButton, QFileDialog, QLabel, QCheckBox, QComboBox
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from ...qgis_utilities import QGisProjectManager, tr 
from ...utility.json_utils import get_propertie
from .graph_widget import GraphWidget, pretty_number

class Result(QDialog) : 
    def __init__(self, project, bloc_tree, parent=None) : 
        QDialog.__init__(self, parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'results_graphs.ui'), self)
        self.project = project
        
        self.colors = ['blue', 'red', 'green', 'magenta', 'cyan', 'white']
        self.params = {}
        self.refresh_tree(bloc_tree)
        
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
                self.treeWidget.setItemWidget(childnode, 1, checkbox1)
                self.treeWidget.setItemWidget(childnode, 3, color_choice)
                self.params[key] = [checkbox1, color_choice]
                print(self.params)
                checkbox1.stateChanged.connect(lambda x, k=key : self.select_bloc(k, x))
                if isinstance(dico, dict) : 
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
        self.show_table()
        self.show_graphs()
    
    def show_graphs(self) :
        # On récupère les données de tous les blocs sélectionnés d'un coup sous la forme d'un gros dico comme avant
        # Puis histoire de fill_bars et add_char_plot couleur par couleur.
                

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