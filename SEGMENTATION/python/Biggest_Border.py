import numpy as np


import numpy as np
def Biggest_Border(InnerBorder=None, *args, **kwargs):
    mx = 0

    for i in np.arange(1, len(InnerBorder), 1).reshape(-1):
        if len(InnerBorder[i]) > mx:
            mx = len(InnerBorder[i])


            location = i

    return location


if __name__ == '__main__':
    pass