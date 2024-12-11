import io
import matplotlib
from qgis.PyQt.QtWidgets import QApplication, QWidget, QGridLayout, QMenu
from qgis.PyQt.QtGui import QCursor, QImage, QPalette
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT, FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from matplotlib.pyplot import setp
from matplotlib import cycler
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
        
    def pie_chart(self, data, labels, title) : 
        self.__ax.clear()
        # if data == [0,0,0] : 
        #     data = [1,1,1]
        # def autopct_format(values):
        #     def my_format(pct):
        #         total = sum(values)
        #         val = int(round(pct*total/100.0))
        #         return '{v:d}'.format(v=val)
        #     return my_format
        # print("pie_data", data)
        # print("pie_labels", labels)
        # print("pie_color", list(color.values()))
        # self.__ax.pie(data, autopct=autopct_format(data), colors=list(color.values()))
        # self.__ax.pie(data)
        
        # Petit cycle de couleur daltionien friendly (nécessaire selon un daltonien qui écrit ce message) 
        CB_color_cycle = ['#377eb8', '#ff7f00', '#4daf4a',
                  '#f781bf', '#a65628', '#984ea3',
                  '#999999', '#e41a1c', '#dede00']
        self.__ax.set_prop_cycle(cycler('color', CB_color_cycle))
        wedges, texts = self.__ax.pie(data, labels=labels, labeldistance=0.7)
        self.fig.tight_layout(rect= [-0.05, -0.05, 1.05, 1.05])
        renderer = self.canvas.get_renderer()
        bboxes = [t.get_window_extent(renderer=renderer) for t in texts]
        for i in range(len(bboxes)):
            for j in range(i + 1, len(bboxes)):
                if bboxes[i].overlaps(bboxes[j]):
                    print('overlapping', texts[j].get_text())
                    texts[j].set_visible(False)
        
        self.__render()
        
    def bar_chart(self, r, data, data_err, c_or_e, names, ids, color, edgecolor, title, ylabel, xlabel, render = True) :
        # print("bar_data", data)
        # print("test", data)
        width = 0.4 
        # print(data_err)
        self.__ax.clear()
        if c_or_e == 'c' or c_or_e == 'e' : 
            self.__ax.bar(r, data['co2'], 
                    color = color['co2'], edgecolor=edgecolor,  label = 'CO2', width=width)
            self.__ax.bar(r, data['ch4'], 
                    bottom = data['co2'], 
                    color = color['ch4'], edgecolor=edgecolor, label = 'CH4', width=width)
            self.__ax.bar(r, data['n2o'], 
                    bottom = [x + y for x, y in zip(data['co2'], data['ch4'])], 
                    color = color['n2o'], edgecolor=edgecolor, label = 'N2O', 
                    yerr = data_err, capsize = 5, ecolor = 'black', width=width)
        elif c_or_e == 'ce' : 
            self.__ax.bar(r, data, color = color['co2'], edgecolor=edgecolor, label = 'CO2eq', 
                          yerr = data_err, capsize = 5, ecolor = 'black', width=width)
        
        self.__ax.set_title(title)
        self.__ax.set_xticks(r, names)
        self.__ax.set_ylabel(ylabel)
        self.__ax.set_xlabel(xlabel)
        self.__ax.legend(edgecolor='black')
        self.__ax.grid(axis='y')
        self.fig.tight_layout(rect=[0.03, 0.03, 0.97, 0.97 ])
        # Faudra changer les noms en id si ça dépasse et un jour peut être truc d'affichage vraiment clean avec décalage sur deux écrans si ça dépasse.
        labels = self.__ax.get_xticklabels()
        renderer = self.canvas.get_renderer()
        flag_overlap = False
        if len(labels) > 1 :
            for i in range(len(labels)-1) :
                box1 = labels[i].get_window_extent(renderer=renderer)
                box2 = labels[i+1].get_window_extent(renderer=renderer)
                if box1.overlaps(box2) :
                    flag_overlap = True
                    break
            if flag_overlap :
                labels = [ids[name] for name in names]
                self.__ax.set_xticklabels(labels)
        # self.fig.tight_layout()
        if render :
            self.__render()

    def add_bar_chart(self, r, rtot, data, data_err, c_or_e, names, color, edgecolor) : 
        width = 0.4
        if c_or_e =='e' or c_or_e == 'c' :
            self.__ax.bar(r, data['co2'], 
                    color = color['co2'], edgecolor=edgecolor,  label = 'co2', width=width)
            self.__ax.bar(r, data['ch4'], 
                    bottom = data['co2'], 
                    color = color['ch4'], edgecolor=edgecolor, label = 'ch4', width=width)
            self.__ax.bar(r, data['n2o'], 
                    bottom = [x + y for x, y in zip(data['co2'], data['ch4'])], 
                    color = color['n2o'], edgecolor=edgecolor, label = 'n2o', 
                    yerr = data_err, capsize = 5, ecolor = 'black', width=width)
        elif c_or_e == 'ce' : 
            self.__ax.bar(r, data, color=color['co2'], edgecolor=edgecolor, label = 'CO2eq', 
                          yerr = data_err, capsize = 5, ecolor = 'black', width=width)
        print(rtot, names)
        self.__ax.set_xticks(rtot, names)
        self.__render()
        
def pretty_number(num, incert, unit, nb_sig = 3, nb_decimals = 1) :
    if num == 0 and incert == 0 :
        return "No value"
    if num / 1000 > 1 : 
        return  f"{num:.{nb_sig}g}" + " ± " + f"{incert:.{nb_sig}g}" + ' ' + unit
    else : 
        return  f"{num:.{nb_decimals}f}" + " ± " + f"{incert:.{nb_decimals}f}" + ' ' + unit
    
def fill_bars(prg, data, stud_time) : 
    bars = {'co2_e' : [], 'ch4_e': [], 'n2o_e': [], 'co2_c' : [], 'ch4_c': [], 'n2o_c': [], 'co2_eq_ce' : []}
    names = []
    for key in data : 
        if key != 'total' :
            names.append(key)
            for field in bars :
                bars[field].append(data[key].get(field, {'val' : 0, 'incert' : 0}))
    r = range(len(bars['co2_e'])) 
    print('r', r)
    print('prg', prg)
    print("NAMES ET BARS")
    print(names)
    bars_c = {'co2' : [x['val']*prg['co2'] for x in bars['co2_c']], 
                'ch4' : [x['val']*prg['ch4'] for x in bars['ch4_c']], 
                'n2o' : [x['val']*prg['n2o'] for x in bars['n2o_c']]}
    bars_e = {'co2' : [x['val']*prg['co2'] for x in bars['co2_e']], 
                'ch4' : [x['val']*prg['ch4'] for x in bars['ch4_e']], 
                'n2o' : [x['val']*prg['n2o'] for x in bars['n2o_e']]}
    
    bars_ce = [x['val']*prg['co2']*stud_time for x in bars['co2_eq_ce']]
    
    bars_c_err = [bars['co2_c'][k]['incert']*bars_c['co2'][k] + bars['ch4_c'][k]['incert']*bars_c['ch4'][k] + bars['n2o_c'][k]['incert']*bars_c['n2o'][k] for k in r]
    
    bars_e_err = [bars['co2_e'][k]['incert']*bars_e['co2'][k] + bars['ch4_e'][k]['incert']*bars_e['ch4'][k] + bars['n2o_e'][k]['incert']*bars_e['n2o'][k] for k in r]
    
    bars_ce_err = [bars['co2_eq_ce'][k]['incert']*bars_ce[k] for k in r]
    
    return r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names

from numpy import argsort
def sort_bars(bars1, names1, err1, bars2 = None, names2 = None, err2 = None) : 
    # si bars2 est none c'est qu'on a pas encore fait de bar donc il faut trier bars1
    # Sinon bars1 est déjà trié et on doit insérer correctement
    fields = ['co2', 'ch4', 'n2o']
    # print("On entre dans la fonction")
    # print('avant actions', bars1, names1, err1)
    if not bars2 : 
        # print('premier cas')
        if isinstance(bars1, dict) :
            sum_values = [sum([bars1[field][i] for field in fields]) for i in range(len(bars1['co2']))]
            sorted_idx = argsort(sum_values)[::-1]
            for field in fields : 
                bars1[field] = [bars1[field][i] for i in sorted_idx]
            names = [names1[i] for i in sorted_idx]
            err1 = [err1[i] for i in sorted_idx]
            # print('premier cas', bars1, names1, err1)
            return bars1, names, err1
        elif isinstance(bars1, list) : 
            sorted_idx = argsort(bars1)[::-1]
            bars1 = [bars1[i] for i in sorted_idx]
            names = [names1[i] for i in sorted_idx]
            err1 = [err1[i] for i in sorted_idx]
            return bars1, names, err1
    else :
        # print('deuxième cas')
        # print(isinstance(bars1, dict))
        if isinstance(bars1, dict) :
            # print('On passe par là ?')
            # Un jour on pourra opti, pour le moment flemme
            sum_values1 = [sum([bars1[field][i] for field in fields]) for i in range(len(bars1['co2']))] # trier donc idéalement faudrait insérer là dedans (genre par dicotomie)
            sum_values2 = [sum([bars2[field][i] for field in fields]) for i in range(len(bars2['co2']))]
            bar = {}
            for field in fields : 
                bar[field] = bars1[field] + bars2[field]
            sum_values = sum_values1 + sum_values2
            # print("sum_values", sum_values)
            sorted_idx = argsort(sum_values)[::-1]
            for field in fields :
                bar[field] = [bar[field][i] for i in sorted_idx]
            names = names1 + names2
            names = [names[i] for i in sorted_idx]
            err = err1 + err2
            err = [err[i] for i in sorted_idx]
            # print(bar, names, err)
            return bar, names, err
        elif isinstance(bars1, list) :
            bar = bars1 + bars2
            sorted_idx = argsort(bar)[::-1]
            bar = [bar[i] for i in sorted_idx]
            names = names1 + names2
            names = [names[i] for i in sorted_idx]
            err = err1 + err2
            err = [err[i] for i in sorted_idx]
            return bar, names, err
        
        
if __name__ == '__main__' : 
    app = QApplication([])
    widget = GraphWidget()
    # widget.pie_chart([1,2,3], ['a', 'b', 'c'], {'a':'red', 'b':'blue', 'c':'green'}, "test")
    widget.bar_chart(range(3), {'co2':[1,2,3], 'ch4':[1,2,3], 'n2o':[1,2,3]}, 'e', ['a', 'b', 'c'], {'co2':'red', 'ch4':'blue', 'n2o':'green'}, 'black', 'test', 'y', 'x')
    widget.add_bar_chart(range(3, 6), range(6), {'co2':[1,2,3], 'ch4':[1,2,3], 'n2o':[1,2,3]}, 'e',['a', 'b', 'c']+['d', 'e', 'f'], {'co2':'red', 'ch4':'blue', 'n2o':'green'}, 'blue')
    widget.show()
    app.exec_()