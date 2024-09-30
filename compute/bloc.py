from ..utility.formula import calculate_formula, read_formula, ErrorNotEnoughData
import re
import matplotlib.pyplot as plt

def get_sur_blocs(project, model_name = None, bloc = None) : 
    if not model_name : 
        model_name = project.current_model
    if not model_name : 
        raise ValueError('No model name given')
    if bloc : 
        l_sur_bloc = project.fetchall(f"select api.get_blocs('{model_name}', '{bloc}')")
    else : 
        l_sur_bloc = project.fetchall(f"select api.get_blocs('{model_name}')")
        # print(l_sur_bloc)
    d_sb, d_name, d_formula, d_i, d_o = {}, {}, {}, {}, {}
    for val in l_sur_bloc :
        # val is a tuple of the form ('(Id, sur_bloc, name, formula, inputs, outputs)',)
        val = val[0]
        val = val.replace('"', '')
        pattern = r',\s*(?![^{}]*\})'
        val = re.split(pattern, val[1:-1])
        Id, sur_bloc, name, formula_name, inputs, outputs, formula_details = val
        print("formula_details", formula_details)
        Id = int(Id)
        try : 
            sur_bloc = int(sur_bloc)
        except : 
            sur_bloc = None
        # formula = formula[1:-1].split(',')
        
        def to_dico(string) : 
            string = string[1:-1].split(',')
            dico = {}
            for s in string : 
                s = s.split(':')
                if len(s) > 1 : 
                    if s[1].strip() == 'null' : 
                        s[1] = None
                    else :
                        try : 
                            s[1] = int(s[1])
                        except :
                            try : 
                                s[1] = float(s[1])
                            except : 
                                s[1] = s[1].strip()
                    dico[s[0].strip()] = s[1]
            return dico
        inputs = to_dico(inputs)
        outputs = to_dico(outputs)
        formula = to_dico(formula_details)
        for key in inputs :
            if key + '_fe' in inputs :
                inputs[key] = inputs[key + '_fe']
        for key in outputs :
            if key + '_fe' in outputs :
                outputs[key] = outputs[key + '_fe']
        
        d_sb[Id] = sur_bloc
        d_name[Id] = name
        d_formula[Id] = formula
        d_i[Id] = inputs
        d_o[Id] = outputs
    return d_sb, d_name, d_formula, d_i, d_o


def get_links(project, model_name = None) : 
    if not model_name : 
        model_name = project.current_model
    if not model_name :
        raise ValueError('No model name given')
    l_links = project.fetchall(f"select api.get_links('{model_name}')")
    l_links = l_links[0][0]
    d_links = {}
    if l_links : 
        for key in l_links : 
            if l_links[key] is None :
                d_links[int(key)] = {}
            else : d_links[int(key)] = l_links[key]
    return d_links

Input_Output = {}

class Bloc: 
    def __init__(self, project, model, name, origin) : 
        print('BONJOUR')
        self.project = project
        self.name = name
        self.model = model
        self.ss_blocs = {}
        self.sur_bloc = None
        self.entrees = {}
        self.sorties = {}
        self.formules = []
        self.links_up = []
                
        if origin == True: 
            self.all_blocs = {self.name : self}
            self.originale = self
        else : 
            self.originale = origin
        self.gen = 0
        self.ges = {'co2_e' : 0, 'co2_c' : 0, 'ch4_e' : 0, 'ch4_c' : 0, 'n2o_e' : 0, 'n2o_c' : 0}
        
    def add_blank_b(self, name, link_up, entrees, sorties, formules, origin = False) : 
        new_bloc = Bloc(self.project, self.model, name, origin)
        self.originale.all_blocs[name] = new_bloc
        
        new_bloc.entrees = entrees.copy()  
        new_bloc.sorties = sorties.copy() # Faudra faire gaffe au copy dans le doute 
        new_bloc.formules = formules.copy()
        new_bloc.links_up = link_up.copy()
        
        self.ss_blocs[name] = new_bloc
        
        return new_bloc

    def add_from_sur_bloc(self, dico_sur_bloc, names, Formules, Entrees, Sorties, links) : 
        """
        On crée une file d'ajout de blocs, on part de l_surbloc de la forme [(id, sur_bloc), ...]
        on la transforme en un dictionnaire de la forme {id : sur_bloc},
        pour chaque id, 
        """
        if self.originale != self : 
            return 
        print("bonjour")
        print("sur_bloc", dico_sur_bloc)
        print("name", names)
        print("entree", Entrees)
        print("sorties", Sorties)
        print("formules", Formules)
        print(links)
        treated = {Id : False for Id in dico_sur_bloc}
        stack = []
        for Id in dico_sur_bloc :
            bloc = self 
            treatment_stack = []
            stack.append(Id)
            while stack : 
                Id2 = stack.pop()
                treatment_stack.append(Id2)
                if dico_sur_bloc[Id2] : 
                    stack.append(dico_sur_bloc[Id2])
            print(treatment_stack)
            while treatment_stack : 
                to_add = treatment_stack.pop(-1)
                if not treated[to_add] : 
                    bloc = bloc.add_blank_b(names[to_add], links[to_add], Entrees[to_add], Sorties[to_add], Formules[to_add], self.originale)
                    treated[to_add] = True
                else :
                    bloc = bloc.ss_blocs[names[to_add]]
        print("allblocs", self.originale.all_blocs)
        return
    
    def calculate_bloc(self) :
        """
        On va faire un peu comme pour les sur_blocs, on va mettre dans un dictionnaire le résultat de la formule
        couplé à aux données nécessaire au calcul.
        Et on va parcourir les formules pour les calculer dans l'ordre afin d'avoir toutes les données nécessaires
        """
        print("euh", self.entrees, self.sorties)
        self.recup_entree()
        print("apres recup", self.entrees, self.sorties)
        inp_out = {key : self.entrees[key] for key in self.entrees}
        for key in self.sorties : 
            if not inp_out.get(key) : 
                inp_out[key] = self.sorties[key]
        
        bilan = {}
        results = {}
        formulas = {}
        for f in self.formules : 
            sides = f.split('=')
            if len(sides) > 2 : 
                print('Erreur, trop de =')
            else : 
                side0 = sides[0].strip()
                if not bilan.get(side0) : 
                    bilan[side0] = []
                    formulas[side0] = [] 
                bilan[side0].append((read_formula(sides[1], inp_out), self.formules[f]))
                formulas[side0].append((f, self.formules[f]))
        print("bilan", bilan)
        print("formulas", formulas)
        known_data = {name : inp_out[name] is not None for name in inp_out}
        print("known_data", known_data)
        for data in bilan : 
            stack = []
            treatment_stack = []
            stack.append(data)
            c= 0
            while stack and c < 1000 : 
                c+=1
                print("stack", stack)
                to_calc = stack.pop()
                print(to_calc)
                if ((not to_calc in known_data) or (not known_data[to_calc])) and to_calc in bilan : 
                    treatment_stack.append(to_calc)
                    known_data[to_calc] = True
                    for bil in bilan[to_calc] : 
                        for d in bil[0] : 
                            if not known_data[d] :
                                stack.append(d)   
            if c == 1000 : 
                raise RuntimeError('Trop de calculs')  
            c=0
            while treatment_stack and c < 1000:
                c+=1
                print("treatment_stack", treatment_stack)
                to_calc = treatment_stack.pop(-1)
                print(to_calc)
                if not results.get(to_calc) :
                    results[to_calc] = [] 
                for f in formulas[to_calc] :
                    try : 
                        print("f", f)
                        result = (calculate_formula(f[0], inp_out), f[1])
                    except ErrorNotEnoughData : 
                        result = (None, f[1])
                    print("result", result)
                    results[to_calc].append(result) 
                if to_calc in inp_out : 
                    inp_out[to_calc] = max(results[to_calc], key=lambda x : x[1])[0] 
                if to_calc in self.sorties : 
                    self.sorties[to_calc] = max(results[to_calc], key=lambda x : x[1])[0]
                if to_calc in self.entrees :
                    self.entrees[to_calc] = max(results[to_calc], key=lambda x : x[1])[0]
            if c == 1000 : 
                raise RuntimeError('Trop de calculs') 
        print("results", results)
        self.ges = results
        none_results = {'co2_e' : 0, 'co2_c' : 0, 'ch4_e' : 0, 'ch4_c' : 0, 'n2o_e' : 0, 'n2o_c' : 0}
        for key in none_results :
            if not results.get(key) :
                results[key] = none_results[key]
    
    def calculate(self) : 
        """
        Si on est sur un sur_bloc et que les résultats des sous blocs sont disponibles on privilégie ceux là
        """
  
        def parcours_rec(bloc, result = {}) : 
            bloc.calculate_bloc()
            for name, sb in bloc.ss_blocs.items() : 
                if sb != bloc :
                    result[name] = {}
                    parcours_rec(sb, result[name])
                    result[name]['values'] = sb.ges
                    # print("result calculate", result)
                
            return result
        result = parcours_rec(self)
        return(result)
        
    def recup_entree(self) : 
        """
        Permet de récupérer les données d'entrées d'un bloc à partir des données de sorties des blocs qui ont un lien avec celui-ci
        """
        for bloc in self.links_up :
            bloc = self.originale.all_blocs[bloc]
            if not bloc.sorties:
                for name in bloc.links_up : 
                    self.links_up.append(name)
            for name, data in bloc.sorties.items() : 
                if name[-2:] == '_s' : 
                    print("BONCHOUR", self.name)
                    print(self.entrees)
                    if name[:-2] in self.entrees :
                        print("ALORS ?", name[:-2], data)
                        self.entrees[name[:-2]] = data
                    elif name[:-2] + '_e' in self.entrees : 
                        self.entrees[name[:-2] + '_e'] = data
                # Comme ça on peut appeler un attribut truc_s et truc_e pour entrées et sorties et les différencier.
                if name in self.entrees :
                    self.entrees[name] = data
                    
    def get_result_from_ssbloc(self) :
        """
        On va chercher le résultat d'un bloc à partir de ses sous blocs.
        Pour se faire, on parcourt les sous blocs de manière récusive, à chaque étage,
        on fait la somme des résultats des sous blocs, si ça vaut None on ne retient pas l'étage.
        """
        keys = ['co2_e', 'co2_c', 'ch4_e', 'ch4_c', 'n2o_e', 'n2o_c']
        def rec(bloc) :
            current_result = {}
            for key in keys :
                if isinstance(bloc.ges[key], (float, int)) :
                    val = 0 # Cas où la valeur n'a pas été calculée (de base 0)
                else :
                    bloc.ges[key].sort(key=lambda x : x[1]) # On trie en fonction du niveau de détails
                    val = bloc.ges[key][-1][0]
                if val is not None: 
                    current_result[key] = val
                else : 
                    current_result[key] = None
            if not bloc.ss_blocs : 
                return current_result
            else : 
                sum_res = {key : 0 for key in keys}
                for name, sb in bloc.ss_blocs.items() : 
                    res = rec(sb)
                    print("name", name)
                    print("bonjour", res)
                    for key in sum_res :
                        if res[key] is None : 
                            sum_res[key] = current_result[key]
                        else : 
                            sum_res[key] += res[key]
                
                return sum_res
        # Dans l'idéal on pourrait dérécursivé la fonction avec des stack
        # mais c'est pas si simple pour être sûr d'aller au bout (ça se fait quand même)
        
        return(rec(self))
                    
    def show_results(self, edgecolor = 'grey', color = {'co2' : 'grey', 'ch4' : 'brown', 'n2o' : 'yellow'}) : 
        to_plot = {'co2_e' : [], 'co2_c' : [], 'ch4_e' : [], 'ch4_c' : [], 'n2o_e' : [], 'n2o_c' : []}
        names = []
        fig_c, ax_c = plt.subplots()
        fig_e, ax_e = plt.subplots()
        for name, bloc in self.ss_blocs.items() : 
            print(name)
            print(bloc.ges)
            print('---------------------')
            names.append(name)
            result = bloc.get_result_from_ssbloc()
            for key in to_plot :
                to_plot[key].append(result[key])
        r = range(len(names))
        print('len r', len(r))
        print('len to_plot', len(to_plot['co2_e']))
        def create_ax(ax, title, c_or_e) : 
            ax.bar(r, to_plot['co2_'+c_or_e], 
                     color = color['co2'], edgecolor=edgecolor,  label = 'co2_'+c_or_e)
            ax.bar(r, to_plot['ch4_'+c_or_e], 
                    bottom = to_plot['co2_'+c_or_e], 
                    color = color['ch4'], edgecolor=edgecolor, label = 'ch4_'+c_or_e)
            ax.bar(r, to_plot['n2o_'+c_or_e], 
                    bottom = [x + y for x, y in zip(to_plot['co2_'+c_or_e], to_plot['ch4_'+c_or_e])], 
                    color = color['n2o'], edgecolor=edgecolor, label = 'n2o_'+c_or_e)
            
            ax.set_title(title)
            ax.set_xticks(r, names)
            ax.set_ylabel('kg de GES émis par an' if c_or_e == 'e' else 'kg de GES émis')
            ax.set_xlabel('Sous-blocs de %s' % self.name)
            ax.legend()
        
        create_ax(ax_c, 'Gaz à effets de serre émis lors de la construction', 'c')
        create_ax(ax_e, "Gaz à effets de serre émis lors de l'exploitation", 'e')
        plt.show()
        return fig_c, fig_e
        
            
            
            
if __name__ =='__main__' : 
    # Test add_from_sur_bloc
    l_sur_bloc = [(1, 9), (2, 10), (3,11), (4,2), (5,4), (6,4), (7,3), (8,7), (9,2), (10, None), (11, 10)]
    names = {i : '%d' % i for i in range(1, 12)}
    Entrees = {i : {} for i in range(1, 12)}
    Sorties = {i : {} for i in range(1, 12)}
    Formules = {i : {} for i in range(1, 12)}
    links = {i : [] for i in range(1, 12)}
    b = Bloc(None, 'test', 'test_bloc', True)
    b.add_from_sur_bloc(dict(l_sur_bloc), names, Formules, Entrees, Sorties, links)
    # ça à l'air de fonctionner jusqu'ici
    
    # Test formules
    f = 'A = B*U/D+ C - I^2'
    sides = f.split('=')
    dico_test = {'B' : 1, 'U' : 3, 'D' : 3, 'C' : 4, 'I' : 2}
    # The reult is 1
    tab  =read_formula(sides[1], dico_test)
    r = calculate_formula(f, dico_test)
    
    #test calculate_bloc
    b.entrees = {'B' : 1, 'U' : 3, 'D' : 3, 'C' : 4, 'I' : 2}
    b.sorties = {'A' : None}
    b.formules = {'A = B*U/D+ C - I^2': 1, 'A = 5' : 3}
    b.calculate_bloc()