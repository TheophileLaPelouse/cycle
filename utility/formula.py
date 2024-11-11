import re 
from cycle.utility.string import isfloat

operators = ['+', '-', '*', '/', '^', '(', ')', '>', '<']

# f = 'A = B*U/D+ C'

class ErrorNotEnoughData(Exception) : 
    pass

def read_formula(formula, dico) : 
    """
    L'objectif est simplement de reconnaitre les données d'entrées nécessaire au calcul 
    """
    l = set()
    pat = '['+re.escape(''.join(operators))+']'
    formula = formula.replace(' ', '')
    args = re.split(pat, formula)
    # print('FORMULA', formula)
    # print("INSIDE", args)
    for d in dico : 
        if d in args :
            l.add(d)   
    if not dico : 
        for arg in args :
            if arg not in operators and arg not in l and not isfloat(arg) : 
                l.add(arg)
    return l

def calculate_formula(formula, dico):
    """
    Calcul d'une formule avec un dictionnaire de donnée d'entrées
    """
    
    sides = formula.split('=')
    if len(sides) > 2 : 
        print('Erreur, trop de =')
        return
    
    if len(sides) > 1 : 
        rightside = sides[1]
    else : rightside = sides[0]
    parenthesis = re.split('(\((.*?)\))', rightside)
    k = 0
    for expr in parenthesis : 
        if len(expr) > 0 and expr[0] == '(' : 
            parenthesis[k] = str(calculate_formula(expr[1:-1], dico))
            parenthesis.pop(k+1) # k+1 correspond à la même chaîne que k	
        k += 1
    
    f = ''.join(parenthesis)
    
    tosum = re.split('([\+-])', f)
    
    s = 0
    sgn = '+'
    for expr in tosum : 
        if expr == '+' : 
            sgn = '+'
        elif expr == '-' :
            sgn = '-'
        else :
            if sgn == '+' : 
                s += read_expr(expr, dico)
            else :
                s -= read_expr(expr, dico)
    
    if len(sides) == 1 : 
        return s
    else :
        dico[sides[0].strip()] = s 
        print('%s = ' % sides[0], s)
        return s


def read_expr(expr, dico) : 
    """
    On va lire une expression
    """
    toprod = re.split('([\*/^])', expr)
    s = 1
    sgn = '*'
    for term in toprod : 
        term = term.strip()
        try : 
            term = float(term)
        except : pass
    
        if term == '*' : 
            sgn = '*'
        elif term == '/' :
            sgn = '/'
        elif term == '^' :
            sgn = '^'
        else :
            term = term if isinstance(term, float) else dico[term]
            if term is None : 
                raise ErrorNotEnoughData('Not Enough data to calculate %s' % expr)
            if sgn == '*' : 
                s *= term
            elif sgn == '/' :
                s /= term
            else : 
                s **= term            
    return s
