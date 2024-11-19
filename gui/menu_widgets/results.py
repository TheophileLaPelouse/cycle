import os
from qgis.PyQt import uic
from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtWidgets import QDialog
from ...qgis_utilities import QGisProjectManager, tr 
import matplotlib.pyplot as plt
from matplotlib.figure import Figure
from .graph_widget import GraphWidget, pretty_number

class AllResults(QDialog) : 
    def __init__(self, project, resume_results_widget, parent=None) : 
        QDialog.__init__(self, parent)
        uic.loadUi(os.path.join(os.path.dirname(__file__), 'results2.ui'), self)
        
        self.setWindowFlag(Qt.WindowMinimizeButtonHint, True)
        self.setWindowFlag(Qt.WindowMaximizeButtonHint, True)
        
        # Les boutons en haut à droite
        self.__project = project
        
        self.refresh()
        self.refresh_button.clicked.connect(self.refresh)
        
        self.combo_mod1.currentIndexChanged.connect(lambda _ : self.update_blocs(1))
        self.combo_mod2.currentIndexChanged.connect(lambda _ : self.update_blocs(2))
        
        self.graph_pie_e1 = GraphWidget(self.pie_chart_e1, dpi=100)
        self.graph_pie_c1 = GraphWidget(self.pie_chart_c1, dpi=100)
        
        self.graph_pie_e2 = GraphWidget(self.pie_chart_e2, dpi=100)
        self.graph_pie_c2 = GraphWidget(self.pie_chart_c2, dpi=100)
        
        self.graph_bar_e = GraphWidget(self.bar_chart_e, dpi=90)
        self.graph_bar_c = GraphWidget(self.bar_chart_c, dpi=90)
        self.graph_bar_ce = GraphWidget(self.bar_chart_ce, dpi=90)
    
        self.resume1.setVisible(False)
        self.resume2.setVisible(False)
        
        self.show_result_button.clicked.connect(self.show_results)
        
        self.close_button.clicked.connect(self.close)
        
        self.prg = {}
        prgs = project.fetchall("select name, val from ___.global_values where name like 'PRG_%'")
        for prg in prgs :
            self.prg[prg[0][4:].lower()] = prg[1]
             
        
    def close(self) :
        # Y'aura peut être d'autres trucs ?
        self.accept()

    def update_blocs(self, index) : 
        model = getattr(self, f'combo_mod{index}').currentText()
        if model == '' : 
            return
        blocs = self.__project.fetchall(f"""
            with b_types as (select b_type from api.input_output where concrete or b_type='sur_bloc')
            select name from api.bloc where model = '{model}' and b_type in (select b_type from b_types)""")
        blocs = [bloc[0] for bloc in blocs]
        combo_bloc = getattr(self, f'combo_bloc{index}')
        combo_bloc.clear()
        combo_bloc.addItems([''] + blocs)
    
    def refresh(self) : 
        model_list = self.__project.models
        self.combo_mod1.clear()
        self.combo_mod2.clear()
        self.combo_mod1.addItems([''] + model_list)
        self.combo_mod2.addItems([''] + model_list) 
        
        # self.__results = {model : {} for model in model_list}
        # results = self.__project.fetchall(f"select * from api.results")
        # for result in results : 
        #     # result = (id, name, model, res, co2_eq_e, co2_eq_c)
        #     to_fill = self.__results[result[2]] # model
        #     to_fill[result[1]] = {}
        #     unknowns = []
        #     detail = None
        #     for formula in result[3]['data'] : 
        #         if formula['in use'] :
        #             detail = formula['detail']                    
        #         if formula['unknown'] : 
        #             unknowns += formula['unknown']
        #     to_fill[result[1]]['unknown'] = list(set(unknowns)) # Pas très beau mais pour une liste de max 10 valeurs très efficace
        #     to_fill[result[1]]['detail'] = detail
        #     to_fill[result[1]]['co2_eq_e'] = result[4]
        #     to_fill[result[1]]['co2_eq_c'] = result[5]
        # Pas sûr que ça serve vraiment tout ça 
        
    def show_results(self) :
        model1 = self.combo_mod1.currentText()
        model2 = self.combo_mod2.currentText()
        bloc1 = self.combo_bloc1.currentText()
        bloc2 = self.combo_bloc2.currentText()
        
        data1 = None
        data2 = None
        
        if model1 : 
            self.resume1.setVisible(True)
            if bloc1 : 
                data1 = self.__project.fetchone(f"select api.get_histo_data('{model1}', '{bloc1}')")
            else :
                data1 = self.__project.fetchone(f"select api.get_histo_data('{model1}')")
            data1 = data1[0]
            self.show_resume(data1, 1)
        else : 
            self.resume1.setVisible(False)
        if model2 :
            self.resume2.setVisible(True)
            if bloc2 : 
                data2 = self.__project.fetchone(f"select api.get_histo_data('{model2}', '{bloc2}')")
            else :
                data2 = self.__project.fetchone(f"select api.get_histo_data('{model2}')")
            data2 = data2[0]
            self.show_resume(data2, 2)
        else :
            self.resume2.setVisible(False)
        
        stud_time = self.__project.fetchone(f"select val from ___.global_values where name = 'study_time'")[0]    
        
        self.show_bar_chart(self.rec_dvie(data1), self.rec_dvie(data2), stud_time)
    
    def rec_dvie(self, data) : 
        # Première implémentation pour aller chercher les d_vies, naïve
        if not data : 
            return None
        
        # Pour améliorer, on pourrait avoir une requête qui va chercher les b_type, puis une autre avec du full join sur les b_type pour avoir name, d_vie
        for key in data :
            if key != 'total' : 
                b_type = self.__project.fetchone(f"select b_type from api.bloc where name = '{key}'")[0]
                try :
                    d_vie = self.__project.fetchone(f"select d_vie from api.{b_type}_bloc where name = '{key}'")[0]
                except :
                    d_vie = None 
                data[key]['d_vie'] = d_vie
        return data
    
    def show_resume(self, data, index, color = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) :
        pie_chart_e = getattr(self, 'graph_pie_e'+str(index))
        pie_chart_c = getattr(self, 'graph_pie_c'+str(index))
        label_e = getattr(self, 'label_co2_eq_e'+str(index))
        label_c = getattr(self, 'label_co2_eq_c'+str(index))
        groupbox = getattr(self, 'resume'+str(index))
        combomod = getattr(self, 'combo_mod'+str(index))
        combobloc = getattr(self, 'combo_bloc'+str(index))
        print(data)
        label_e.setText(pretty_number(data['total']['co2_eq_e']['val'], data['total']['co2_eq_e']['incert']*data['total']['co2_eq_e']['val'], 'kgCO2/an'))
        label_c.setText(pretty_number(data['total']['co2_eq_c']['val'], data['total']['co2_eq_c']['incert']*data['total']['co2_eq_c']['val'], 'kgCO2'))
        label_e.setStyleSheet("font-weight: bold; font-size: 10px;")
        label_c.setStyleSheet("font-weight: bold; font-size: 10px;")
        if combobloc.currentText() == '' : 
            groupbox.setTitle(tr('Modèle ')+ combomod.currentText())
        else :
            groupbox.setTitle(tr('Modèle ')+ combomod.currentText() + tr(', bloc ')+ combobloc.currentText())
                
        fields = ['co2_e', 'ch4_e', 'n2o_e', 'co2_c', 'ch4_c', 'n2o_c']
        data_pie_e = [data['total'][field]['val']*self.prg[field[:-2]] for field in fields[:3]]
        labels = ['CO2', 'CH4', 'N2O']
        pie_chart_e.pie_chart(data_pie_e, labels, color, tr("kgGaz/an"))
        
        data_pie_c = [data['total'][field]['val']*self.prg[field[:-2]] for field in fields[3:]]
        pie_chart_c.pie_chart(data_pie_c, labels, color, tr("kgGaz"))
        print(index, data_pie_e, data_pie_c)
        
    def show_bar_chart(self, data1, data2, stud_time, color = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) :
        bars = {'co2_e' : [], 'ch4_e': [], 'n2o_e': [], 'co2_c' : [], 'ch4_c': [], 'n2o_c': [], 'co2_eq_ce' : []}
        if data1 :
            r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names = self.fill_bars(data1, stud_time)
            self.graph_bar_c.bar_chart(r, bars_c, bars_c_err, 'c', names, color, 'blue', tr("Emmission construction (kgGaz)"), tr('kg de GES émis'), tr('Sous blocs'))
            self.graph_bar_e.bar_chart(r, bars_e, bars_e_err, 'e', names, color, 'blue', tr("Emission exploitation (kgGaz/an)"), tr('kg de GES émis par an'), tr("Sous blocs"))   
            self.graph_bar_ce.bar_chart(r, bars_ce, bars_ce_err, 'ce', names, color, 'blue', tr("Emission exploitation et construction (kgCO2eq/%d ans)" % (stud_time)), tr('kg de CO2eq émis par %d ans' % stud_time), tr("Sous blocs"))
            if data2 : 
                r2, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names2 = self.fill_bars(data2, stud_time)
                rtot = range(r[0], r2[-1]+1+r[-1]+1)
                r = range(r[-1]+1, r2[-1]+1+r[-1]+1)
                names = names + names2
                self.graph_bar_c.add_bar_chart(r, rtot, bars_c, bars_c_err, 'c', names, color, 'red')
                self.graph_bar_e.add_bar_chart(r, rtot, bars_e, bars_e_err, 'e', names, color, 'red')  
                self.graph_bar_ce.add_bar_chart(r, rtot, bars_ce, bars_ce_err, 'ce', names, color, 'red')
        elif data2 : 
            r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names = self.fill_bars(data2, stud_time)
            self.graph_bar_c.bar_chart(r, bars_c, bars_c_err, 'c', names, color, 'red', tr("Emmission construction (kgGaz)"), tr('kg de GES émis'), tr('Sous blocs'))
            self.graph_bar_e.bar_chart(r, bars_e, bars_e_err, 'e', names, color, 'red', tr("Emission exploitation (kgGaz/an)"), tr('kg de GES émis par an'), tr("Sous blocs")) 
            self.graph_bar_ce.bar_chart(r, bars_ce, bars_ce_err, 'ce', names, color, 'red', tr("Emission exploitation et construction (kgCO2eq/%d ans)" % (stud_time)), tr('kg de CO2eq émis par %d ans' % stud_time), tr("Sous blocs"))
        
    def fill_bars(self, data, stud_time) : 
        bars = {'co2_e' : [], 'ch4_e': [], 'n2o_e': [], 'co2_c' : [], 'ch4_c': [], 'n2o_c': [], 'co2_eq_ce' : []}
        for key in data : 
            if key != 'total' :
                for field in bars : 
                    if field == 'co2_eq_ce' :
                        bars[field].append(data[key]['d_vie'] if data[key]['d_vie'] else 15)
                    else : 
                        bars[field].append(data[key][field])
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
        
        bars_ce = bars['co2_eq_ce'][:]
        bars_ce_err = []
        print('d_vies', bars_ce)
        for k in r :
            bars_ce = (bars['co2_e'][k]['val'] + bars['ch4_e'][k]['val'] + bars['n2o_e'][k]['val'] + 
                                    (bars['co2_c'][k]['val'] + bars['ch4_c'][k]['val'] + bars['n2o_c'][k]['val'])/bars['co2_eq_ce'][k]
                                    )*stud_time
            sum1 = (bars['co2_e'][k]['val'] + bars['ch4_e'][k]['val'] + bars['n2o_e'][k]['val'])
            if sum1 == 0 :
                err1 = 0
            else : 
                err1 = (bars['co2_e'][k]['incert']*bars['co2_e'][k]['val']
                    + bars['ch4_e'][k]['incert']*bars['ch4_e'][k]['val']
                    + bars['n2o_e'][k]['incert']*bars['n2o_e'][k]['val']
                    )/sum1
            print("err1", err1)
            sum2 = (bars['co2_c'][k]['val'] + bars['ch4_c'][k]['val'] + bars['n2o_c'][k]['val'])            
            if sum2 == 0 :
                err2 = 0
            else : 
                err2 = (bars['co2_c'][k]['incert']*bars['co2_c'][k]['val']
                    + bars['ch4_c'][k]['incert']*bars['ch4_c'][k]['val']
                    + bars['n2o_c'][k]['incert']*bars['n2o_c'][k]['val']
                    )/sum2
            err2 = err2/bars['co2_eq_ce'][k]
            print("err2", err2)
            err = (err1*sum1 + err2*sum2)*stud_time
            print("err", err)
            bars_ce_err.append(err)
            
        
        bars_c_err = [bars['co2_c'][k]['incert']*bars_c['co2'][k] + bars['ch4_c'][k]['incert']*bars_c['ch4'][k] + bars['n2o_c'][k]['incert']*bars_c['n2o'][k] for k in r]
        
        bars_e_err = [bars['co2_e'][k]['incert']*bars_e['co2'][k] + bars['ch4_e'][k]['incert']*bars_e['ch4'][k] + bars['n2o_e'][k]['incert']*bars_e['n2o'][k] for k in r]
        print('bars_c', bars_c)
        print('bonjour', bars_e_err)
        return r, bars_c, bars_c_err, bars_e, bars_e_err, bars_ce, bars_ce_err, names
        