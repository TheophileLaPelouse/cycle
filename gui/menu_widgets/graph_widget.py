import io
import matplotlib
from qgis.PyQt.QtWidgets import QApplication, QWidget, QGridLayout, QMenu
from qgis.PyQt.QtGui import QCursor, QImage, QPalette
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT, FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import math

matplotlib.rc('xtick', labelsize=8)
matplotlib.rc('ytick', labelsize=8)

class GraphWidget(QWidget):
    def __init__(self, parent=None, dpi=75):
        QWidget.__init__(self, parent)
        self.__dpi = dpi
        self.fig = Figure(dpi=self.__dpi)
        self.__ax = self.fig.add_subplot(111)
        self.__ax.grid(True)
        # self.graph_title = self.fig.suptitle("")
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self)
        box = QGridLayout()
        box.addWidget(self.canvas)
        if parent is not None :
            parent.setLayout(box)
        self.canvas.setVisible(False)
        # print("test color backgound", self.palette().color(self.backgroundRole()))
        # print("test color backgound 2", self.palette().color(QPalette.Base).name())
        
    def __render(self):
        # self.fig.set_tight_layout({"rect": [0,0,1,0.95]})
        parent_bg_color = self.palette().color(self.backgroundRole())
        darker_color = parent_bg_color.lighter(102)
        darker_color_rgb = (darker_color.redF(), darker_color.greenF(), darker_color.blueF())
        # print("darker_color", darker_color_rgb)
        self.fig.set_facecolor(darker_color_rgb)
        self.canvas.draw()
        self.canvas.setVisible(True)
        
    def pie_chart(self, data, labels, color, title) : 
        self.__ax.clear()
        if data == [0,0,0] : 
            data = [1,1,1]
        def autopct_format(values):
            def my_format(pct):
                total = sum(values)
                val = int(round(pct*total/100.0))
                return '{v:d}'.format(v=val)
            return my_format
        # print("pie_data", data)
        # print("pie_labels", labels)
        # print("pie_color", list(color.values()))
        # self.__ax.pie(data, autopct=autopct_format(data), colors=list(color.values()))
        self.__ax.pie(data, colors=list(color.values()))
        self.fig.tight_layout(rect= [-0.05, -0.05, 1.05, 1.05])
        # self.__ax.legend(labels, loc='upper right', bbox_to_anchor=(1, 1))
        self.__ax.legend(labels, loc='upper right')
        # self.__ax.set_title(title)
        self.__render()
        
    def bar_chart(self, r, data, data_err, c_or_e, names, color, edgecolor, title, ylabel, xlabel) :
        # print("bar_data", data)
        # print("test", data)
        width = 0.4 
        
        self.__ax.clear()
        self.__ax.bar(r, data['co2'], 
                color = color['co2'], edgecolor=edgecolor,  label = 'co2', width=width)
        self.__ax.bar(r, data['ch4'], 
                bottom = data['co2'], 
                color = color['ch4'], edgecolor=edgecolor, label = 'ch4', width=width)
        self.__ax.bar(r, data['n2o'], 
                bottom = [x + y for x, y in zip(data['co2'], data['ch4'])], 
                color = color['n2o'], edgecolor=edgecolor, label = 'n2o', 
                yerr = data_err, capsize = 5, ecolor = 'black', width=width)
        
        self.__ax.set_title(title)
        self.__ax.set_xticks(r, names)
        self.__ax.set_ylabel(ylabel)
        self.__ax.set_xlabel(xlabel)
        self.__ax.legend(edgecolor='black')
        self.__ax.grid(axis='y')
        # self.fig.tight_layout(rect=[0.1, 0.1, 0.9, 0.9 ])
        self.fig.tight_layout()
        self.__render()

    def add_bar_chart(self, r, rtot, data, data_err, c_or_e, names, color, edgecolor) : 
        width = 0.4
        self.__ax.bar(r, data['co2'], 
                color = color['co2'], edgecolor=edgecolor,  label = 'co2', width=width)
        self.__ax.bar(r, data['ch4'], 
                bottom = data['co2'], 
                color = color['ch4'], edgecolor=edgecolor, label = 'ch4', width=width)
        self.__ax.bar(r, data['n2o'], 
                bottom = [x + y for x, y in zip(data['co2'], data['ch4'])], 
                color = color['n2o'], edgecolor=edgecolor, label = 'n2o', 
                yerr = data_err, capsize = 5, ecolor = 'black', width=width)
        print(rtot, names)
        self.__ax.set_xticks(rtot, names)
        self.__render()
        
def pretty_number(num, incert, unit, nb_sig = 3, nb_decimals = 1) :
    if num / 1000 > 1 : 
        return  f"{num:.{nb_sig}g}" + " ± " + f"{incert:.{nb_sig}g}" + ' ' + unit
    else : 
        return  f"{num:.{nb_decimals}f}" + " ± " + f"{incert:.{nb_decimals}f}" + ' ' + unit
        
if __name__ == '__main__' : 
    app = QApplication([])
    widget = GraphWidget()
    # widget.pie_chart([1,2,3], ['a', 'b', 'c'], {'a':'red', 'b':'blue', 'c':'green'}, "test")
    widget.bar_chart(range(3), {'co2':[1,2,3], 'ch4':[1,2,3], 'n2o':[1,2,3]}, 'e', ['a', 'b', 'c'], {'co2':'red', 'ch4':'blue', 'n2o':'green'}, 'black', 'test', 'y', 'x')
    widget.add_bar_chart(range(3, 6), range(6), {'co2':[1,2,3], 'ch4':[1,2,3], 'n2o':[1,2,3]}, 'e',['a', 'b', 'c']+['d', 'e', 'f'], {'co2':'red', 'ch4':'blue', 'n2o':'green'}, 'blue')
    widget.show()
    app.exec_()