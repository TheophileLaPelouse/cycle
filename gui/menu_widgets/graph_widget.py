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
        self.__axe = self.fig.add_subplot(111)
        self.__axe.grid(True)
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
        self.__axe.grid(True)
        self.__axe.get_xaxis().get_major_formatter().set_useOffset(False)
        self.__axe.get_yaxis().get_major_formatter().set_useOffset(False)
        self.canvas.draw()
        self.canvas.setVisible(True)
        
    def pie_chart(self, data, labels, color, title) : 
        self.__ax.pie(data, labels=labels, autopct='%1.1f%%', colors=list(color.values()), shadow=True)
        self.__ax.set_title(title)
        self.__render()
        
    def bar_chart(self, r, data, c_or_e, names, color, edgecolor, title) :
        
        self.__ax.bar(r, data['co2_'+c_or_e], 
                color = color['co2'], edgecolor=edgecolor,  label = 'co2_'+c_or_e)
        self.__ax.bar(r, data['ch4_'+c_or_e], 
                bottom = data['co2_'+c_or_e], 
                color = color['ch4'], edgecolor=edgecolor, label = 'ch4_'+c_or_e)
        self.__ax.bar(r, data['n2o_'+c_or_e], 
                bottom = [x + y for x, y in zip(data['co2_'+c_or_e], data['ch4_'+c_or_e])], 
                color = color['n2o'], edgecolor=edgecolor, label = 'n2o_'+c_or_e)
        
        self.__ax.set_title(title)
        self.__ax.set_xticks(r, names)
        self.__ax.set_ylabel('kg de GES émis par an' if c_or_e == 'e' else 'kg de GES émis')
        self.__ax.set_xlabel('Sous-blocs de %s' % self.name)
        self.__ax.legend()
        self.__ax.grid(axis='y')
        
        self.__render()