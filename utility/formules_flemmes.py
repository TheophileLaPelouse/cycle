import re
import pandas as pd
import ast
from math import pi
import os
import sympy
        
def replace_singleton(expr) : 
    operators = ['+', '-', '*', '/', '^', '>', '<', '(', ')']
    new_expr = ''
    for k in range(len(expr)) : 
        if k > 0 and k < len(expr) -1 and expr[k-1] in operators and expr[k+1] in operators and re.match(r'[a-zA-Z]', expr[k]) :
                new_expr += expr[k] + '___'
        elif k == 0 and expr[k+1] in operators and re.match(r'[a-zA-Z]', expr[k]) :
                new_expr += expr[k] + '___'
        elif k == len(expr) - 1 and expr[k-1] in operators and re.match(r'[a-zA-Z]', expr[k]) :
                new_expr += expr[k] + '___'
        else : 
            new_expr += expr[k]
    return new_expr

def invert_singleton(expr) :
    new_expr = expr.replace('___', '') 
    # operators = ['+', '-', '*', '/', '^', '>', '<', '(', ')']
    # new_expr = ''
    # for k in range(len(expr)) : 
    #     if k > 0 and k < len(expr) -2 and expr[k-1] in operators and expr[k+2] in operators and re.match(r'[a-zA-Z]_', expr[k]+expr[k+1]) :
    #             new_expr += expr[k]
    #     elif k == 0 and expr[k+1] in operators and re.match(r'[a-zA-Z]_', expr[k]+expr[k+1]) :
    #             new_expr += expr[k]
    #     elif k == len(expr) - 2 and expr[k-1] in operators and re.match(r'[a-zA-Z]_', expr[k]+expr[k+1]) :
    #             new_expr += expr[k]
    #     elif expr[k] == '_' :
    #         pass
    #     else : 
    #         new_expr += expr[k]
    return new_expr

class formula : 
    def __init__(self,gas_f , hypo, var) : 
        self.h = hypo.copy()
        self.var = var[:]
        # print(self.var)
        self.f = gas_f.copy()
        n= len(self.var)
        self.results = {}
        for k in range(n) : 
            self.results[k+1] = {}
            for f in self.f : 
                for f2 in self.f[f] :
                    if var[k] :
                        # print("BONJOUE3", f2)
                        final_expr = write_formula(f2, self.h, self.var[k])
                        if not( '>' in final_expr or '<' in final_expr) : 
                            final_expr =replace_singleton(final_expr)
                            final_expr =  sympy.simplify(final_expr)
                            final_expr = round_expr(final_expr, 5)
                            final_expr = invert_singleton(str(final_expr))
                        if not self.results[k+1].get(f) :
                            self.results[k+1][f] = set()
                        self.results[k+1][f].add(final_expr)
                # self.formula_by_detail_level['variables pour %s' % str(k+1)] = self.var[k]
            # self.formula_by_detail_level['Hypothèses'] = self.h
                
            
        # self.create_formula('1+b', dico)
        
    def save(self, path = 'formulas.csv') :
        df = pd.DataFrame(self.results)
        df.to_csv(os.path.join(os.path.dirname(__file__), path), sep=';')
    

def sort_operators_by_priority(operators):
    # Define the priority of each operator
    priority = {
        '^': 4,
        '>': 3,
        '<': 3,
        '*': 2,
        '/': 2,
        '+': 1,
        '-': 1
    }
    
    # Sort the operators based on their priority
    sorted_operators = sorted(operators, key=lambda op: priority[op], reverse=True)
    
    return sorted_operators

def insert_op(operators, op) : 
    priority = {
        '^': 4,
        '>': 3,
        '<': 3,
        '*': 2,
        '/': 2,
        '+': 1,
        '-': 1
    }
    # print('op', operators)
    if not operators :
        return [op], -1
    else : 
        k = 0
        while k < len(operators) and priority[op] <= priority[operators[k]] :
            k += 1
        operators = operators[:k] + [op] + operators[k:]
        # print('op2', operators)
    return (operators, k)

def write_formula(expr, dico, var = set(), c = 0):
    # print("Dans write formula", expr)
    if c > 20 : 
        return
    # print(expr)
    operators = ['+', '-', '*', '/', '^', '>', '<', '(', ')']
    args = re.split(r'([\+\-\/\*\>\<\^\(\)])', expr)
    args = [arg.strip() for arg in args]
    # print("Mais Non ?", args)
    i = 0
    calc = [[]]
    idx = 0 
    last_op = [[]]
    flag_op = [False]
    for i in range(len(args)) : 
        # print('argument', args[i])
        # # print(i, flag_op)
        if args[i] == '(' :
            calc.append([])
            flag_op.append(False)
            last_op.append([])
            idx += 1
        elif args[i] == ')' : 
            # query = eval_sum(query, dico, var)
            calc[idx] = calc[idx] + last_op[idx]
            calc[idx-1].append(calc.pop(idx))
            flag_op.pop(idx)
            last_op.pop(idx)
            idx -= 1
        elif args[i] in var :
            calc[idx].append(args[i])
        elif args[i] in dico : 
            written_formula = write_formula(dico[args[i]], dico, var, c=c+1)
            if is_number(written_formula) :
                calc[idx].append(written_formula)
            else : 
                calc[idx].append('('+written_formula + ')')
            # print("written formula", calc[idx][-1])
        elif args[i] in operators :
            # print(insert_op(last_op[idx], args[i]))
            last_op[idx], shift = insert_op(last_op[idx], args[i])
            # print('length', len(last_op[idx]), shift)
            flag_op[idx] = shift > 0
            if flag_op[idx] :
                k = 0
                while k < shift :
                    calc[idx].append(last_op[idx].pop(0))
                    k += 1
                flag_op[idx] = False
        elif args[i] :
            calc[idx].append(args[i])
    calc[idx] += last_op[idx]

    # print('calc', calc)
    def formula_from_calc(calc) :
        if not isinstance(calc, list) : 
            return calc
        
        if len(calc) == 1 : 
            return formula_from_calc(calc[0])
        args = [] 
        args.append(calc.pop(0))
        if isinstance(args[0], list) :
            args[0] = formula_from_calc(args[0])
            if not is_number(args[0]) : 
                args[0] = '(' + args[0] + ')'
        while len(calc) > 0 : 
            new = calc.pop(0)
            if isinstance(new, list) :
                new = formula_from_calc(new)
                if not is_number(new) : 
                    new = '(' + new + ')'
            if new in operators :
                arg2 = args.pop()
                arg = args.pop()
                op = new
                if arg == 'pi' : 
                    arg = str(pi)
                if arg2 == 'pi' : 
                    arg2 = str(pi)
                # print('hihi', arg, arg2, op)
                
                if is_number(arg) and is_number(arg2) : 
                    if op == '+' :
                        # print("bonjour")
                        arg=  str(float(arg) + float(arg2))
                    elif op == '-' : 
                        arg= str(float(arg) - float(arg2))
                    elif op == '*' : 
                        arg= str(float(arg) * float(arg2))
                    elif op == '/' : 
                        arg= str(float(arg) / float(arg2))
                    elif op == '^' : 
                        arg= str(float(arg) ** float(arg2))
                    elif op == '>' : 
                        arg= str(float(float(arg) > float(arg2)))
                    elif op == '<' : 
                        arg += str(float(float(arg) < float(arg2)))
                else :
                    # print("euh", arg, op, arg2)
                    arg = arg + op + arg2
                    if op == '/' and arg == arg2 : 
                        arg = '1'
                    elif op =='*' and arg == arg2 : 
                        arg = '('+arg+')^2'
                    
                args.append(arg)
            else :
                args.append(new)
            # print('args', args)
        return args[0]
    final_expr = formula_from_calc(calc)
    return final_expr
    
    # return ast.unparse(ast.parse(formula_from_calc(calc)))

def round_expr(expr, num_digits):
    return expr.xreplace({n : round(n, num_digits) for n in expr.atoms(sympy.Number)})

def is_number(strval) : 
    if strval == 'pi' : 
        return True
    try : 
        float(strval)
        return True 
    except : 
        return False

def add_dico(dico1, dico2) : 
    # Servira pour rentrer le custom json dans l'admin json
    if not isinstance(dico2, dict) :
        return dico1
    if not isinstance(dico1, dict) : 
        return dico2
    for key in dico2 : 
        if key not in dico1 : 
            dico1[key] = dico2[key]
        else : 
            dico1[key] = add_dico(dico1[key], dico2[key])
    return dico1

def save_h(H, path, mode = 'a') : 
    df = pd.DataFrame(H, range(len(H)), ['Valeur', 'Formules'])
    df['Valeur'] = H.keys()
    df['Formules'] = H.values()
    df.to_csv(path, mode = mode, sep = ';')
    return df

if __name__ == '__main__' : 
    formules_eau = {'co2_c': 'Vbet*rhobet*FEbet + Vterre*rhoterre*FEevac + Vterre*cad*FEpelle', 
                    'co2_dechet' : '13*Tsables + 45*Tgraisses', 
                    'N2O_rejet' : 'FEn2o_oxi*NGLs',
                    'CH4_rejet' : 'FEch4_mil*DCOs',
                    'co2_c_degrilleur' : 'FEpoids*Mdegrilleur', 'co2_c_tamis' : 'FEpoids*Mtamis',
                    'co2_e_degrilleur' : 'rhodechet*FEdegrilleur*Vdd', 'co2_e_tamis' :'rhodechet*FEdegrilleur*Vdt',
                    'co2_c_lamel' : 'Nblam*Slam*elam*FElam*rholam'
                    }
    formules_boues = {'co2_c': 'FEobj_eh*TBentrant', 'co2_stockage' : 'FEsilo * DBO5', 
                      'co2_methanisation' : 'tau_co2*Vbiogaz*rhoco2', 'ch4_methanisation' : 'Vbiogaz*tau_fuite*rhometha'}
    formules_gen = {'co2_elec' : '0.052*Welec', 'co2_intrant' : 'FEintrant*Tintrant', 'co2_transport' : 'FEtransport*Ttransport*dist'}
    H_EH = {'DBO5' : '0.06*EH', 'DCO' : '0.135*EH', 'NTK' : '0.015*EH', 'Phosphore' : '0.004*EH',
            'Qe' : '0.12*EH', 'MES':'0.09*EH', 'Welec' : '25*EH', 'EH' : 'knownQ/0.06'}
    H_boue = {'FEobj_eh' : 'FEobj10*(EH<10000) + FEobj50*(EH>10000)*(EH<100000) + FEobj100*(EH>100000)',
              'TBentrant' : '(DBO5/2 + MES/2)/1000', 'Vbiogaz' : '225*TBsortant', 'TBsortant' : 'TBentrant*tau_abattement',
              'rhometha' : '0.657', 'rhoco2' : '1.87'
              }
    H_boue_finale = add_dico(H_boue, H_EH)
    f_boue_finale = add_dico(formules_boues, formules_gen)
    boue_lvl = [set(['EH']), set(['DBO5', 'MES', 'EH']), set(['TBentrant', 'EH']), set(['Vbiogaz', 'EH'])]
    boue = formula( f_boue_finale, H_boue_finale, boue_lvl) 
    
    H_eau_1 = {'Vterre' : 'Sterre*Hterre*tauenterre', 'Sterre' : 'pi*(R + e)^2', 'Hterre' : '(H+e)', 'S' : 'Q/(vit/24)', 'R' : '(S/pi)^(1/2)', 
              'Vbet' : '(e*pi*(2*R+e))*H + S*e', 
              'Q' : 'Qe*(1+taur)', 'H' : 'Vu/(pi*(R^2))',
              'Vu' : 'Q*tsejour', 'tsejour' : 'S*H/Q', 
              'Mdegrilleur' : 'Qe/Qmax*Munite', 'rhodechet' : '0.96', 'FEdegrilleur' : '0.045', 'Mtamis' : 'Qe/Qmax*Munite',
              'Vdd' : '(compd*gros*1.5 + (1-compd*gros)*3 + (1-compd)*(1-gros)*4 + (1-gros)*compd*2)*EH', 
              'Vdt' : '((1-compt)*8 + compt*4)*EH', 'compd' : '0', 'gros' : '0', 'compt' : '0', 
              'Tsables' : 'Csables*EH/1000', 'Tgraisses' : 'Cgraisses*EH*dgraisses/1000', 'dgraisses' : '0.96', 
              'Csables' : '(0.0009*lavage + 0.0026*(1-lavage))', 'Cgraisses' : '10', 
              'abatNGL' : '0.8', 'abatDCO' : '0.75',
              'NGLs' : 'NTK*(1-abatNGL)', 'DCOs' : 'DCO*(1-abatDCO)'
              }
    H_eau = {'Vterre' : 'Sterre*Hterre*tauenterre', 'Sterre' : 'pi*(R + e)^2', 'Hterre' : '(H+e)', 'S' : 'Q/vit', 'R' : '(S/pi)^(1/2)', 
              'Vbet' : '(e*pi*(2*R+e))*H + S*e', 
              'Q' : 'Qe*(1+taur)', 'H' : 'Vu/(pi*(R^2))',
              'Vu' : 'Q*tsejour', 'vit' : '(H*Q)/Vu', 'tsejour' : 'S*H/Q',
              'Mdegrilleur' : 'Qe/Qmax*Munite', 'rhodechet' : '0.96', 'FEdegrilleur' : '0.045', 'Mtamis' : 'Qe/Qmax*Munite',
              'Vdd' : '(compd*gros*1.5 + (1-compd*gros)*3 + (1-compd)*(1-gros)*4 + (1-gros)*compd*2)*EH', 
              'Vdt' : '((1-compt)*8 + compt*4)*EH', 'compd' : '0', 'gros' : '0', 'compt' : '0', 
              'Tsables' : 'Csables*EH', 'Tgraisses' : 'Cgraisses*EH*dgraisses', 'dgraisses' : '0.96', 
              'Csables' : '(0.0009*lavage + 0.0026*(1-lavage))', 'Cgraisses' : '10', 
              'abatNGL' : '0.8', 'abatDCO' : '0.75',
              'NGLs' : 'NTK*(1-abatNGL)', 'DCOs' : 'DCO*(1-abatDCO)'
              }
    # H_eau = {'abatNGL' : '0.8', 'abatDCO' : '0.75', 
    # 'NGLs' : 'NTK*(1-abatNGL)', 'DCOs' : 'DCO*(1-abatDCO)'}
    # formules_eau = { 'N2O_rejet' : 'FEn2o_oxi*NGLs',
    # 'CH4_rejet' : 'FEch4_mil*DCOs'}
    # formules_eau = {'co2_c_degrilleur' : 'FEpoids*Mdegrilleur', 'co2_c_tamis' : 'FEpoids*Mtamis',
    # 'co2_e_degrilleur' : 'rhodechet*FEdegrilleur*Vdd', 'co2_e_tamis' :'rhodechet*FEdegrilleur*Vdt'}
    formules_lamellaire = {'co2_c' : 'Vbet*rhobet*FEbet + Vterre*rhoterre*FEevac + Vterre*cad*FEpelle + Vlam*rholam*FElam'}
    H_lamellaire = {'Vterre' : 'Sterre*Hterre', 'Sterre' : '(long+e)*(larg+e)', 'long' : 'prop_l*S', 
                    'larg' : '(S^2)/prop_l', 'prop_l' : '1', 
                    'S' : 'Qe/vit',
                    'Vbet' : 'e*long*larg + 2*long*Hterre*e + 2*larg*Hterre*e', 'Hterre' : 'h+e', 
                    'Slam' : 'Qe/vlam', 'elam' : '0.002', 'Vlam' : 'Slam*elam'}
    # eau_lvl = [set(['EH', 'H']), set(['Qe', 'H']), set(['Qe', 'v', 'H']), set(['Qe', 'tsejour', 'H']), set(['Qe', 'H', 'S'])]
    eau_lvl = [set(['EH', 'H', 'tjour']), set(['Qe', 'tjour', 'H']), set(['Vu', 'H'])]
    eau_lvl1 = [set(['EH', 'H', 'vit']), set(['Qe', 'vit', 'H'])]
    lam_lvl = [set(['EH', 'H', 'vit']), set(['Qe', 'vit', 'H']), set(['Qe', 'long', 'larg', 'H'])]
    # H_eau = {'Vterre' : 'Sterre*Hterre', 'Sterre' : 'pi*(R + e)^2', 'Hterre' : '(H+e)', 'S' : 'Vu/H', 'R' : '(S/pi)^(1/2)', 
    #           'Vbet' : '(e*pi*(2*R+e))*H + S*e', 
    #           'H' : 'Vu/(pi*(R^2))', 'Vu' : 'Qe*tjour'
    #           }
    # eau_lvl = [set(['Qe', 'H', 'S']), set(['Qe', 'tsejour', 'H'])]
    f_eau = add_dico(formules_eau, formules_gen)
    # f_eau = {'co2_c' : 'Vterre'}
    H_eau_finale = add_dico(H_eau, H_EH)
    # eau = formula(f_eau, H_eau_finale1, eau_lvl)
    H_eau_finale1 = add_dico(H_eau_1, H_EH)
    eau1 = formula(f_eau, H_eau_finale1, eau_lvl1)
    h_lam = add_dico(H_lamellaire, H_EH)
    lamelle = formula(formules_lamellaire, h_lam, lam_lvl)
    # eau.save('formulas_eau.csv')
    boue.save('formulas_boue.csv')
    # f1 = write_formula('(1+2*(3+4))', {}, set())
    # f2 = write_formula('(a+b*(c+d))', {}, set())
    # On s'est arrêté à MBBR
    
    