from ..project import Project

def get_sur_blocs(project, model_name = None, bloc = None) : 
    if not model_name : 
        model_name = project.current_model
    if bloc : 
        query = f"""
        select id, sur_bloc from api.bloc as sur_b
        where model = '{model_name}' 
        and st_within(sur_b.geom_ref, (select b.geom_ref from api.bloc as b where name = '{bloc}'));
        """
        return project.fetchall(query)
    else : 
        return project.fetchall("select id, sur_bloc from api.bloc where model = %s", model_name)

def get_links(project, model_name = None) : 
    if not model_name : 
        model_name = project.current_model
    return project.fetchall("select api.get_up_to_down('{model_name}')")

class Bloc: 
    def __init__(self, project, model, name, origin) : 
        self.project = project
        self.name = name
        self.model = model
        self.ss_blocs = []
        self.sur_bloc = None
        self.entrees = {}
        self.sorties = {}
        self.formules = []
        self.links_up = []
        self.links_down = []
        
        if origin == True: 
            self.all_blocs = {self.name : self}
            self.originale = self
        else : 
            self.originale = origin
        self.gen = 0
        self.ges = {}
        
    def add_b(self, name, entrees, sorties, formules) : 
        
        