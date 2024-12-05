
                

import os 
from PyQt5.QtWidgets import QDialog, QTreeWidget, QTreeWidgetItem, QVBoxLayout, QPushButton, QFileDialog, QLabel, QProgressBar, QCheckBox, QComboBox
from PyQt5 import uic
from cycle.utility.json_utils import get_propertie

class Resume_result(QDialog):
    def __init__(self, parent=None):
        super(Resume_result, self).__init__(parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'results_graphs.ui'), self)
        bloc_tree = {'bloc1': ['bloc2', 'bloc3', 'bloc4']}
        self.colors = ['blue', 'red', 'green', 'magenta', 'cyan', 'white']
        self.params = {}
        self.refresh_tree(bloc_tree)
        self.selected_blocs = set()
        self.bloc_tree = bloc_tree
        
                
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

                
        # self.exec_()
        
if __name__ == '__main__':
    import sys
    from PyQt5.QtWidgets import QApplication
    app = QApplication(sys.argv)
    dialog = Resume_result()
    dialog.show()
    sys.exit(app.exec_())