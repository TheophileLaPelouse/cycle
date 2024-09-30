import numpy
import io
import matplotlib
from qgis.PyQt.QtWidgets import QApplication, QWidget, QGridLayout, QMenu
from qgis.PyQt.QtGui import QCursor, QImage
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT, FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

matplotlib.rc('xtick', labelsize=8)
matplotlib.rc('ytick', labelsize=8)

class GraphWidget(QWidget):

    def __getattr__(self, att):
        if att =='axe':
            return self.__axe
        else:
            raise AttributeError

    def __init__(self, parent=None, dpi=75, bar=False, rotate=False):
        QWidget.__init__(self, parent)
        self.__dpi = dpi
        self.__bar = bar
        self.__rotate = rotate
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
        self.__start_x = None
        self.__start_y = None
        self.__start_xlim = None
        self.__start_ylim = None
        self.__xratio = None
        self.fig.canvas.mpl_connect('button_press_event', self.onclick)
        self.canvas.mpl_connect('scroll_event', self.__on_scroll)
        self.canvas.mpl_connect('motion_notify_event', self.__on_move)
        self.canvas.setVisible(False)

    def __on_scroll(self, event):
        "zoom plot on scroll"
        if not self.__active_zoom:
            return
        if event.xdata is None:
            return
        y_min, y_max = self.__axe.get_ylim()
        new_height = (y_max - y_min)*(1.1 if event.step < 0 else .9)
        self.__axe.set_ylim(
                [(y_max+y_min)*.5 - new_height*.5,
                 (y_max+y_min)*.5 + new_height*.5])

        x_min, x_max = self.__axe.get_xlim()
        new_width = (x_max - x_min)*(1.1 if event.step < 0 else .9)
        relx = (x_max - event.xdata) / (x_max - x_min)
        self.__axe.set_xlim(
                [event.xdata - new_width*(1-relx),
                 event.xdata + new_width*(relx)])

        self.canvas.draw()

    def __on_move(self, event):
        "move plot on drag"
        if event.button == 1 and self.__active_zoom:
            if event.x != None:
                self.__axe.set_xlim(self.__start_xlim + (self.__start_x - event.x)*self.__xratio)
            if event.y != None:
                self.__axe.set_ylim(self.__start_ylim + (self.__start_y - event.y)*self.__yratio)
            self.canvas.draw()

    def clear(self):
        self.__axe.clear()
        self.canvas.draw()

    def __render(self):
        self.fig.set_tight_layout({"rect": [0,0,1,0.95]})
        self.__axe.grid(True)
        self.__axe.get_xaxis().get_major_formatter().set_useOffset(False)
        self.__axe.get_yaxis().get_major_formatter().set_useOffset(False)
        self.canvas.draw()
        self.canvas.setVisible(True)

    def add_line(self, x_data, ydata, color, main_title=None, x_title=None, y_title=None, marker="", markersize=6, linestyle="-"):
        if x_title:
            if self.__rotate:
                self.__axe.set_ylabel(x_title)
            else:
                self.__axe.set_xlabel(x_title)
        if y_title:
            if self.__rotate:
                self.__axe.set_xlabel(y_title)
            else:
                self.__axe.set_ylabel(y_title)
        if self.__bar:
            self.__axe.bar(x_data, ydata, align='edge', color=color, alpha=.5)
        else:
            if self.__rotate:
                self.__axe.plot(ydata, x_data, linestyle=linestyle, color=color, marker=marker, markersize=markersize)
            else:
                self.__axe.plot(x_data, ydata, linestyle=linestyle, color=color, marker=marker, markersize=markersize)
        if main_title:
            self.graph_title.set_text(main_title)
        self.__render()

    def onclick(self, event):
        if event.button == 3: #right-click
            menu = QMenu()
            pos = QCursor.pos()
            menu.move(pos.x(), pos.y())
            menu.addAction(tr("Copy image")).triggered.connect(self.__export_image)
            menu.exec_()

        if event.button == 1 and self.__active_zoom: #start drag for pan
            self.__start_x = event.x
            self.__start_y = event.y
            self.__start_xlim = numpy.array(self.__axe.get_xlim())
            self.__start_ylim = numpy.array(self.__axe.get_ylim())
            self.__xratio = (self.__start_xlim[1] -  self.__start_xlim[0])\
                         / self.canvas.width()
            self.__yratio = (self.__start_ylim[1] -  self.__start_ylim[0])\
                         / self.canvas.height()

    def __export_image(self):
        buf = io.BytesIO()
        self.fig.savefig(buf)
        cb = QApplication.clipboard()
        cb.clear(mode=cb.Clipboard )
        cb.setImage(QImage.fromData(buf.getvalue()), mode=cb.Clipboard)
        buf.close()