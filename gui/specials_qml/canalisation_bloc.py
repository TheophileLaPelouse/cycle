import os 
from qgis.core import Qgis, QgsProject, QgsVectorLayer, QgsRelation, QgsRelationContext, QgsAttributeEditorContainer, QgsAttributeEditorField as attrfield, QgsDefaultValue, QgsEditorWidgetSetup
from qgis.utils import iface
from .utility.formula import read_formula
from ...qgis_utilities import Alias, ConstrOnly
import re


def update(cycle_project, project, layer, qml, f_details, inp_outs, f_inputs) : 
        
        config = layer.editFormConfig()
        config.clearTabs()
        
        name = attrfield('name', layer.fields().indexFromName('name'), None)
        model = attrfield('model', layer.fields().indexFromName('model'), None)
        config.addTab(name)
        config.addTab(model)
        
        expl_tab = QgsAttributeEditorContainer('Exploitation', None)
        expl_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(expl_tab)
        constr_tab = QgsAttributeEditorContainer('Construction', None)
        constr_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(constr_tab)
        
        input_tab = QgsAttributeEditorContainer('Entrée', None)
        input_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(input_tab)
        
        output_tab = QgsAttributeEditorContainer('Sortie', None)
        output_tab.setType(Qgis.AttributeEditorContainerType(1))
        config.addTab(output_tab)
        
        fieldnames = [f.name() for f in layer.fields()]
        field_fe = {}
        lvlmax = 6
        in2tab = {'constr' : {k : False for k in range(lvlmax+1)}, 'expl' : {k : False for k in range(lvlmax+1)}}
        in2tab_constr = {'constr' : {k : False for k in range(lvlmax+1)}, 'expl' : {k : False for k in range(lvlmax+1)}}
        in2tab_default = {'constr' : {k : False for k in range(lvlmax+1)}, 'expl' : {k : False for k in range(lvlmax+1)}}
        level_container = {'constr' : {k : QgsAttributeEditorContainer('Niveau de détail %d' % k, constr_tab) for k in range(lvlmax+1)},
                        'expl' : {k : QgsAttributeEditorContainer('Niveau de détail %d' % k, expl_tab) for k in range(lvlmax+1)}, 
                        }
        constr_container = {'constr' : {k:QgsAttributeEditorContainer('Valeurs par défaut construction', constr_tab) for k in range(lvlmax+1)}, 
                            'expl' : {k:QgsAttributeEditorContainer('Valeurs par défaut construction', expl_tab) for k in range(lvlmax+1)}}
        default_container = {'constr' : {k:QgsAttributeEditorContainer('Valeurs par défaut spécifiques', constr_tab) for k in range(lvlmax+1)},
                             'expl' : {k:QgsAttributeEditorContainer('Valeurs par défaut spécifiques', expl_tab) for k in range(lvlmax+1)}}
        level_container_children = {'constr' : {k : set() for k in range(lvlmax+1)}, 'expl' : {k : set() for k in range(lvlmax+1)}}
        def treat_formula(formulas, f_inputs, lvl) :
            sides = formulas.split('=')
            group_field = []
            c_or_e = 'constr'
            print(sides)
            if len(sides) == 2 : 
                group_field = read_formula(sides[1],  inp_outs['inp'])
                print('group_field', group_field)
                if sides[0].strip().endswith('_c') : 
                    c_or_e = 'constr'
                else :
                    c_or_e = 'expl'
            for val in group_field : 
                idx = layer.fields().indexFromName(val)
                if field_fe.get(val) :
                    container = QgsAttributeEditorContainer(val.upper(), level_container[c_or_e][lvl])
                    container.setColumnCount(2)
                    container.addChildElement(attrfield(val, idx, container))
                    fe_idx = layer.fields().indexFromName(val+'_fe')
                    container.addChildElement(attrfield(val+"_fe", fe_idx, container))
                    # alias 
                    layer.setFieldAlias(fe_idx, Alias.get(val+"_fe", ''))
                    layer.setFieldAlias(idx, Alias.get(val, ''))
                    
                    # default value
                    defval = QgsDefaultValue()
                    prop_layer = project.mapLayersByName(Alias[val])[0]
                    default_fe = layer.defaultValueDefinition(fe_idx)
                    default_fe = default_fe.expression()
                    #  f"attribute(get_feature(layer:='{prop_layer.id()}', attribute:='val', value:=coalesce(\"{fieldname}\", '{default}')), 'fe')"
                    
                    default_fe = re.sub("layer:='[^']+'", f"layer:='{prop_layer.id()}'", default_fe)
                    defval.setExpression(default_fe)
                    defval.setApplyOnUpdate(True)
                    layer.setDefaultValueDefinition(fe_idx, defval)
                    # indexOf = indexFromName d'après la doc
                    # On va faire un test pas opti : 
                    if val.upper() not in level_container_children[c_or_e][lvl] :
                        level_container[c_or_e][lvl].addChildElement(container)
                        level_container_children[c_or_e][lvl].add(val.upper())  
                elif val in f_inputs : 
                    if val not in level_container_children[c_or_e][lvl] :
                        if val in ConstrOnly : 
                            constr_container[c_or_e][lvl].addChildElement(attrfield(val, idx, constr_container[c_or_e][lvl]))
                            in2tab_constr[c_or_e][lvl] = True
                        else :
                            default_container[c_or_e][lvl].addChildElement(attrfield(val, idx, default_container[c_or_e][lvl]))
                            in2tab_default[c_or_e][lvl] = True
                else : 
                    print("avant c_or_e", c_or_e, lvl, val)   
                    if val not in level_container_children[c_or_e][lvl] :
                        print("c_or_e", c_or_e, lvl, val)
                        level_container[c_or_e][lvl].addChildElement(attrfield(val, idx, level_container[c_or_e][lvl]))
                        level_container_children[c_or_e][lvl].add(val)
                        layer.setFieldAlias(idx, Alias.get(val, ''))
                in2tab[c_or_e][lvl] = True
            return set(group_field)
        treated = set()
        for formulas, lvl in f_details.items() : 
            treated = treated.union(treat_formula(formulas, f_inputs, lvl))

        for c_or_e in in2tab : 
            for lvl in in2tab[c_or_e] : 
                if in2tab[c_or_e][lvl] :
                    if in2tab_constr[c_or_e][lvl] :
                        constr_container[c_or_e][lvl].setCollapsed(True)
                        level_container[c_or_e][lvl].addChildElement(constr_container[c_or_e][lvl])
                    if in2tab_default[c_or_e][lvl] :
                        default_container[c_or_e][lvl].setCollapsed(True)
                        level_container[c_or_e][lvl].addChildElement(default_container[c_or_e][lvl])
                    if c_or_e == 'constr' :
                        constr_tab.addChildElement(level_container[c_or_e][lvl])
                    else :
                        expl_tab.addChildElement(level_container[c_or_e][lvl])
                    
        def addval2tab(val, tab) : 
            idx = layer.fields().indexFromName(val)
            print("sortie", val, idx)
            if field_fe.get(val) : 
                
                container = QgsAttributeEditorContainer(val.upper(), tab)
                container.setColumnCount(2)
                container.addChildElement(attrfield(val, idx, container))
                fe_idx = layer.fields().indexFromName(val+'_fe')
                container.addChildElement(attrfield(val+"_fe", fe_idx, container))
                if val not in treated : 
                    # alias 
                    layer.setFieldAlias(fe_idx, Alias.get(val+"_fe", ''))
                    layer.setFieldAlias(idx, Alias.get(val, ''))
                    
                    # default value
                    defval = QgsDefaultValue()
                    prop_layer = project.mapLayersByName(Alias[val])[0]
                    default_fe = layer.defaultValueDefinition(fe_idx)
                    default_fe = default_fe.expression()
                    #  f"attribute(get_feature(layer:='{prop_layer.id()}', attribute:='val', value:=coalesce(\"{fieldname}\", '{default}')), 'fe')"
                    
                    default_fe = re.sub("layer:='[^']+'", f"layer:='{prop_layer.id()}'", default_fe)
                    defval.setExpression(default_fe)
                    defval.setApplyOnUpdate(True)
                    layer.setDefaultValueDefinition(fe_idx, defval)
                tab.addChildElement(container)
            else:
                if val not in treated :  
                    layer.setFieldAlias(idx, Alias.get(val, ''))
                tab.addChildElement(attrfield(val, idx, tab))
                
        for val in inp_outs['out'] : 
            addval2tab(val, output_tab)
            inp = val
            if inp[:-2] in inp_outs['inp'] :
                inp = inp[:-2]
            elif inp[:-2]+"_e" in inp_outs['inp'] :
                inp = inp[:-2]+"_e"
            elif inp + "_e" in inp_outs['inp'] :
                inp = inp + "_e"
            if inp in inp_outs['inp'] :
                addval2tab(val, input_tab)
            
        layer.setEditFormConfig(config)
        layer.saveNamedStyle(qml)
        return    