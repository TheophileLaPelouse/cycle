# coding=utf-8


from qgis.PyQt.QtCore import QCoreApplication
from qgis.PyQt.QtWidgets import QMessageBox
from .select_menu import SelectTool
from ...utility.tables_properties import TablesProperties

def tr(msg):
    return QCoreApplication.translate("Hydra", msg)


class DeleteTool(SelectTool):
    def __init__(self, project, point, size=10, parent=None):
        SelectTool.__init__(self, project, point, size, parent, excluded_layers = [])
        self.cascade = False
        if self.table is not None:
            key_id = self.list_objects[self.schema, self.table][1]
            self.cascade = DeleteTool.delete(self, self.currentproject, self.schema, self.table, key_id, self.id)

    def is_cascade(self):
        return self.cascade

    @staticmethod
    def delete(parent, currentproject, schema, table, key_id, id):
        cascade=False
        if table is None:
            return cascade
        name, = currentproject.execute("select name from {}.{} where {}={};".format(schema, table, key_id, id)).fetchone()

        reply = QMessageBox.question(parent, tr('Confirm'), tr("Are you sure you want to delete {} ({})?".format(name, TablesProperties.get_properties()[table]['name'])), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)

        tn = TablesProperties.get_properties()[table]['name']
        if TablesProperties.get_properties()[table]['name'] in (): # Faudra voir si y'a des trucs où on veut ce message
            reply = QMessageBox.warning(parent, tr('Warning'), tr("/!\ This is a {}, removing it will remove linked object or create domain issue, are you sure ?".format(tn)), QMessageBox.Yes | QMessageBox.No, QMessageBox.No)

        if reply == QMessageBox.Yes:
            success, ret = currentproject.try_execute("delete from {}.{} where {}={};".format(
                                                schema, table, key_id, id))
            if not success:
                reply = QMessageBox.question(parent, tr('Confirm'),
                    tr("Multiple objects will be deleted or modified, continue?"), QMessageBox.Yes |
                    QMessageBox.No, QMessageBox.No)

                if reply == QMessageBox.Yes:
                    cascade=True
                    # if table == 'hydrograph_bc_singularity':
                    #     DeleteTool.delete_hy_bc(parent, currentproject, schema, id)
                    # Au cas par cas, mais peut être qu'il faut qu'on fasse un truc particuler pour un bloc, genre en mode checkbow pour si cascade ou non 
            currentproject.commit()
        return cascade

    @staticmethod
    def delete_hy_bc(parent, currentproject, schema, id):
        routings = [i for i, in currentproject.execute("""select id
                                                from {model}.routing_hydrology_link
                                                where hydrograph={id}""".format(model=schema, id=id)).fetchall()]
        connectors = [i for i, in currentproject.execute("""select id
                                                from {model}.connector_hydrology_link
                                                where hydrograph={id}""".format(model=schema, id=id)).fetchall()]
        for routing in routings:
            currentproject.execute("""update {model}.routing_hydrology_link set hydrograph=null
                                        where id={id}""".format(model=schema,id=routing))
        for connector in connectors:
            currentproject.execute("""update {model}.connector_hydrology_link set hydrograph=null
                                        where id={id}""".format(model=schema,id=connector))
        # On enlève les liens entre deux objets, en fonction de comment on s'occupe des liens il faudra effectivement faire un truc dans le genre
        
        currentproject.execute("""delete from {model}.hydrograph_bc_singularity
                                    where id={id}""".format(model=schema, id=id))

    @staticmethod
    def delete_link(parent, currentproject, schema, type, id):
        # tables = {'qq_split_hydrology_singularity':['downstream', 'split1', 'split2'],
        #           'zq_split_hydrology_singularity':['downstream', 'split1', 'split2'],
        #           'reservoir_rs_hydrology_singularity':['drainage', 'overflow'],
        #           'reservoir_rsp_hydrology_singularity':['drainage', 'overflow']}
        tables = {} # On verra ce qu'on met là dedans
        for table, columns in tables.items():
            for column in columns:
                currentproject.execute("""update {model}.{table} set {column}=null, {column}_type=null where {column}={link}""".format(model=schema, table=table, column=column, link=id))
        currentproject.execute("""delete from {model}.{type}
                                    where id={id}""".format(model=schema, type=type, id=id))

    @staticmethod
    def delete_node(parent, currentproject, schema, table, id):
        links = currentproject.execute("""select id, link_type
                                        from {model}._link
                                        where up={id} or down={id}""".format(model=schema, id=id)).fetchall()
        for link in links:
            DeleteTool.delete_link(parent, currentproject, schema, link[1]+'_link', link[0])
        singularities = currentproject.execute("""select id, singularity_type
                                        from {model}._singularity
                                        where node={id}""".format(model=schema, id=id)).fetchall()
        for singularity in singularities:
            if singularity[1]=='hydrograph_bc':
                DeleteTool.delete_hy_bc(parent, currentproject, schema, singularity[0])
            else:
                currentproject.execute("""delete from {model}.{type}_singularity
                                        where id={id}""".format(model=schema,type=singularity[1], id=singularity[0]))

