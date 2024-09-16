from ..utility.formula import calculate_formula, read_formula, ErrorNotEnoughData
import re

def get_sur_blocs(project, model_name = None, bloc = None) : 
    if not model_name : 
        model_name = project.current_model
    if not model_name : 
        raise ValueError('No model name given')
    if bloc : 
        l_sur_bloc = project.fetchall(f"select api.get_blocs('{model_name}', '{bloc}')")
    else : 
        l_sur_bloc = project.fetchall(f"select api.get_blocs('{model_name}')")
        print(l_sur_bloc)
    d_sb, d_name, d_formula, d_i, d_o = {}, {}, {}, {}, {}
    for val in l_sur_bloc :
        # val is a tuple of the form ('(Id, sur_bloc, name, formula, inputs, outputs)',)
        val = val[0]
        val = val.replace('"', '')
        pattern = r',\s*(?![^{}]*\})'
        val = re.split(pattern, val[1:-1])
        Id, sur_bloc, name, formula, inputs, outputs = val 
        Id = int(Id)
        try : 
            sur_bloc = int(sur_bloc)
        except : 
            sur_bloc = None
        formula = formula[1:-1].split(',')
        
        def to_dico(string) : 
            string = string[1:-1].split(',')
            dico = {}
            for s in string : 
                s = s.split(':')
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
    for key in l_links : 
        d_links[int(key)] = l_links[key]
    return d_links

Input_Output = {}

class Bloc: 
    def __init__(self, project, model, name, origin) : 
        self.project = project
        self.name = name
        self.model = model
        self.ss_blocs = {}
        self.sur_bloc = None
        self.entrees = {}
        self.sorties = {}
        self.formules = []
        self.links_up = {}
                
        if origin == True: 
            self.all_blocs = {self.name : self}
            self.originale = self
        else : 
            self.originale = origin
        self.gen = 0
        self.ges = {}
        
    def add_blank_b(self, name, link_up, entrees, sorties, formules, origin = False) : 
        new_bloc = Bloc(self.project, self.model, name, origin)
        self.originale.all_blocs[name] = new_bloc
        
        new_bloc.entrees = entrees.copy()  
        new_bloc.sorties = sorties.copy() # Faudra faire gaffe au copy dans le doute 
        
        new_bloc.links_up = link_up.copy()
        
        self.ss_blocs[name] = new_bloc
        
        return new_bloc

    def add_from_sur_bloc(self, dico_sur_bloc, names, Entrees, Sorties, Formules, links) : 
        """
        On crée une file d'ajout de blocs, on part de l_surbloc de la forme [(id, sur_bloc), ...]
        on la transforme en un dictionnaire de la forme {id : sur_bloc},
        pour chaque id, 
        """
        if self.originale != self : 
            return 
        
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
        return
    
    def calculate_bloc(self) :
        """
        On va faire un peu comme pour les sur_blocs, on va mettre dans un dictionnaire le résultat de la formule
        couplé à aux données nécessaire au calcul.
        Et on va parcourir les formules pour les calculer dans l'ordre afin d'avoir toutes les données nécessaires
        """
        inp_out = dict(self.entrees, **self.sorties)
        self.recup_entree()
        bilan = {}
        results = {}
        formulas = {}
        for f in self.formules : 
            sides = f.split('=')
            if len(sides) > 2 : 
                print('Erreur, trop de =')
            else : 
                bilan[sides[0].strip()] = read_formula(sides[1], inp_out)
                formulas[sides[0].strip()] = f
        known_data = {name : inp_out[name] is not None for name in inp_out}
        for data in bilan : 
            stack = []
            treatment_stack = []
            stack.append(data)
            
            while stack : 
                to_calc = stack.pop()
                treatment_stack.append(to_calc)
                known_data[to_calc] = True
                if (not to_calc in known_data) or (not known_data[to_calc]) : 
                    for d in bilan[to_calc] : 
                        if known_data[d] :
                            stack.append(d)     
            while treatment_stack :
                to_calc = treatment_stack.pop(-1)
                try : 
                    result = calculate_formula(formulas[to_calc], inp_out)
                except ErrorNotEnoughData : 
                    results = None
                results[to_calc] = result 
                if to_calc in inp_out : 
                    inp_out[to_calc] = result
                if to_calc in self.sorties : 
                    self.sorties[to_calc] = result
                if to_calc in self.entrees :
                    self.entrees[to_calc] = result
        
        self.ges = results
    
    def calculate(self) : 
        """
        Si on est sur un sur_bloc et que les résultats des sous blocs sont disponibles on privilégie ceux là
        """
        result = {}
        def parcours_rec(bloc) : 
            for name, sb in bloc.ss_blocs.items() : 
                result[name] = b.ges
                parcours_rec(sb)
            return
        parcours_rec(self)
        return(result)
        
    def recup_entree(self) : 
        """
        Permet de récupérer les données d'entrées d'un bloc à partir des données de sorties des blocs qui ont un lien avec celui-ci
        """
        for link, bloc in self.links_up.items() :
            for name, data in bloc.sorties.items() : 
                if name in self.entrees : 
                    self.entrees[name] = data
        
            
            
if __name__ =='__main__' : 
    # Test add_from_sur_bloc
    l_sur_bloc = [(1, 9), (2, 10), (3,11), (4,2), (5,4), (6,4), (7,3), (8,7), (9,2), (10, None), (11, 10)]
    names = {i : '%d' % i for i in range(1, 12)}
    Entrees = {i : {} for i in range(1, 12)}
    Sorties = {i : {} for i in range(1, 12)}
    Formules = {i : [] for i in range(1, 12)}
    links = {i : [] for i in range(1, 12)}
    b = Bloc(None, 'test', 'test_bloc', True)
    b.add_from_sur_bloc(dict(l_sur_bloc), names, Entrees, Sorties, Formules, links)
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
    b.formules = ['A = B*U/D+ C - I^2']
    b.calculate_bloc()