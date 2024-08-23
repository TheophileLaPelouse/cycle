import os
import re

def __versions():
    res = set()
    for f in os.listdir(os.path.dirname(__file__)):
        m = re.match(r'(\d+)\.(\d+).(\d+)-(\d+)\.(\d+).(\d+)\.sql', f)
        if m:
            res.add((int(m.group(1)), int(m.group(2)), int(m.group(3))))
            res.add((int(m.group(4)), int(m.group(5)), int(m.group(6))))
    return res

__version__ = '{}.{}.{}'.format(*sorted(__versions())[-1])