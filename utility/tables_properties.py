import json
import os

_utility_dir = os.path.join(os.path.dirname(__file__))

class TablesProperties(object):
    __properties = None

    @staticmethod
    def get_properties():
        if TablesProperties.__properties is None:
            # Faudra voir si on garde ce json où si on fait un truc qui marche directement en prennant les propriétés des tables sql directement
            with open(os.path.join(_utility_dir, "tables_properties.json")) as f:
                TablesProperties.__properties = json.load(f)
        return TablesProperties.__properties

    @staticmethod
    def reset_properties():
        TablesProperties.__properties = None