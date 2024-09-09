

class Bloc: 
    def __init__(self, project, model, origin) : 
        self.project = project
        self.name = ''
        self.ss_blocs = []
        self.sur_bloc = None
        self.entrees = {}
        self.sorties = {}
        self.formules = []
        self.links_up = []
        self.links_down = []
        
        if origin == True: 
            self.all_blocs = {Id: self}
            self.originale = self
        else : 
            self.originale = origin
        self.gen = 0
        self.ges = {}
        
        