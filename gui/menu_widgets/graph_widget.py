import io
import matplotlib
from qgis.PyQt.QtWidgets import QApplication, QWidget, QGridLayout, QMenu
from qgis.PyQt.QtGui import QCursor, QImage
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT, FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

matplotlib.rc('xtick', labelsize=8)
matplotlib.rc('ytick', labelsize=8)

class GraphWidget(QWidget):
    def __init__(self, parent=None, dpi=75):
        QWidget.__init__(self, parent)
        self.__dpi = dpi
        self.fig = Figure(dpi=self.__dpi)
        self.__ax = self.fig.add_subplot(111)
        self.__ax.grid(True)
        self.graph_title = self.fig.suptitle("")
        self.canvas = FigureCanvas(self.fig)
        self.canvas.setParent(self)
        box = QGridLayout()
        box.addWidget(self.canvas)
        if parent is not None :
            parent.setLayout(box)
        self.canvas.setVisible(False)
        
    def __render(self):
        self.fig.set_tight_layout({"rect": [0,0,1,0.95]})
        self.canvas.draw()
        self.canvas.setVisible(True)
        
    def pie_chart(self, data, labels, color, title) : 
        if data == [0,0,0] : 
            data = [1,1,1]
        def autopct_format(values):
            def my_format(pct):
                total = sum(values)
                val = int(round(pct*total/100.0))
                return '{v:d}'.format(v=val)
            return my_format
        print("pie_data", data)
        print("pie_labels", labels)
        print("pie_color", list(color.values()))
        self.__ax.pie(data, labels=labels, autopct=autopct_format(data), colors=list(color.values()))
        # self.__ax.set_title(title)
        self.__render()
        
    def bar_chart(self, r, data, c_or_e, names, color, edgecolor, title, ylabel, xlabel) :
        print("bar_data", data)
        print("test", data)
        self.__ax.clear()
        self.__ax.bar(r, data['co2'], 
                color = color['co2'], edgecolor=edgecolor,  label = 'co2')
        self.__ax.bar(r, data['ch4'], 
                bottom = data['co2'], 
                color = color['ch4'], edgecolor=edgecolor, label = 'ch4_'+c_or_e)
        self.__ax.bar(r, data['n2o'], 
                bottom = [x + y for x, y in zip(data['co2'], data['ch4'])], 
                color = color['n2o'], edgecolor=edgecolor, label = 'n2o')
        
        self.__ax.set_title(title)
        self.__ax.set_xticks(r, names)
        self.__ax.set_ylabel(ylabel)
        self.__ax.set_xlabel(xlabel)
        self.__ax.legend()
        self.__ax.grid(axis='y')
        
        self.__render()
        
if __name__ == '__main__' : 
    app = QApplication([])
    widget = GraphWidget()
    widget.pie_chart([1,2,3], ['a', 'b', 'c'], {'a':'red', 'b':'blue', 'c':'green'}, "test")
    widget.bar_chart([1,2,3], {'co2_e':[1,2,3], 'ch4_e':[1,2,3], 'n2o_e':[1,2,3]}, 'e', ['a', 'b', 'c'], {'co2':'red', 'ch4':'blue', 'n2o':'green'}, 'black', 'test', 'y', 'x')
    widget.show()
    app.exec_()