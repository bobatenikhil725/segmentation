import matplotlib.image as img
import cv2
import numpy as np
import os
clear = lambda: os.system('cls')
clear()

def rgb2gray(rgb):

    r, g, b = rgb[:,:,0], rgb[:,:,1], rgb[:,:,2]
    gray = 0.2989 * r + 0.5870 * g + 0.1140 * b

    return gray

def get_hist(image):
    h, w = image.shape[:2]
    histogram = np.zeros([256],np.unit64)
    for i in range(h):
      for j in range(w):
        histogram[image[i][j]] +=1
    return histogram
#MAIN FUNCTION
    
    #Image path
path='C:\Users\Atharva\Desktop\SEM7\Final_Year_project\\'
name='Image_Name'
ext='.jpeg'
img_path = path + name + ext

rgb =img.imread(img_path)
rg = cv2.cvtColor(rgb, cv2.COLOR_RGB2BGR)
I = cv2.cvtColor(rg, cv2.COLOR_BGR2GRAY)
Igray = I

    #To find background colour for masking of unwanted regions
val, ptch = max(get_hist(Igray))
BWimage = cv2.threshold(I, 127, 255, cv2.THRESH_BINARY)
    #Check points
#imshow(I);
#pause;
        #Forming directories
#Makes a folder in the same ddirectors where the image is
folder= name + '_Segmentation'
os.chdir(path)
#cd(path)
status,msg,msgID= os.mkdir(folder)
os.chdir(path + '\' + folder)
folder_path = path +'\' + folder
status,msg,msgID = os.mkdir('Sentences')
sentence_path = folder_path + '\' + 'Sentences'
status,msg,msgID = os.mkdir('Words')
word_path = folder_path + '\' + 'Words'
status,msg,msgID = os.mkdir('Characters')
character_path = folder_path + '\' + 'Characters'

    #Calling sentence segemntation
os.chdir(sentence_path)
n = sentence_segmentation(BWimage,I,Igray,ptch)
#Index to keep a note of the number of images etc...
n= int(n)
index=0

    #takes one sentence image at a time
#Sends the image to word segmentation function
#Word segemntation function saves the image is the proper folder
os.chdir(word_path)
    
print('starting words')
for i in arange(1,n,1).reshape(-1):
    name = 'sentence' + str(i) + '.jpg'
    img = sentence_path + '\' + name
    word = cv2.imread(img)
    index = word_segmentation1(word,i,index,ptch)

    
    #====================
    
    #takes one word image at a time
#Sends the image to char segmentation function
#char segemntation function saves the image is the proper folder
os.chdir(character_path)
print('starting chars')
print(index)
n = index
index=0

for i in arange(1,n,1).reshape(-1):
    name = 'word' + str(i) + '.jpg'
    img = word_path + '\' + name
    word = cv2.imread(img)

        #index=char_segementation_prog(word,i,index);
        #watershed approach call this function
    index = char_segementation(word,i,index)
    