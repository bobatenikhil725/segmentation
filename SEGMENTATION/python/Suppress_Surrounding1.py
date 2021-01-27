
import numpy as np
from skimage import draw

def poly2mask(vertex_row_coords, vertex_col_coords, shape):
    fill_row_coords, fill_col_coords = draw.polygon(vertex_row_coords, vertex_col_coords, shape)
    mask = np.zeros(shape, dtype=np.bool)
    mask[fill_row_coords, fill_col_coords] = True
    return mask

def Suppress_Surrounding1(Image=None,Retain_Border=None,p=None,*args,**kwargs):
    I= Image
    mask = poly2mask(Retain_Border[:,1],Retain_Border[:,0],Image.shape)
    
    #Mask the areas with backgrounf colour
    for i in np.arange(1,np.size(Image,1),1).reshape(-1):
        for j in np.arange(1,np.size(Image,2),1).reshape(-1):
            if (mask[i,j] == 0):
                I[i,j]=p

    
    return I
    
if __name__ == '__main__':
    pass
    