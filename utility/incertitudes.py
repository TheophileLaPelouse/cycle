"""

Fonctions de calcul des incertitudes 
"""

def addition(l) : 
    """
    Parameters
    ----------
    l : list of tuple
        [(A, delta A); ...].

    Returns
    -------
    (A, delta A).
    
    """
    s = 0
    inc = 0
    for tup in l : 
        s += tup[0]
        inc += tup[1]
        
    return(s, inc)

def produit(l):
    """
    Parameters
    ----------
    l : list of tuple
        [(A, delta A); ...].

    Returns
    -------
    (A, delta A).
    
    """
    
    p = 1
    inc = 0 
    for tup in l : 
        p = p * tup[0]
        inc += (tup[1]/tup[0])**2
        
    inc = p * inc**(1/2)
    
    return(p, inc)

def puissance(tup, n):
    """
    Parameters
    ----------
    l : tuple
        (A, delta A).

    Returns
    -------
    (A, delta A).
    
    """
    return (tup[0]**n, abs(n)*tup[1]/tup[0] * tup[0]**n)


