import numpy as np
from matplotlib import pyplot as plt
import cv2
from skimage.morphology import disk, dilation, morphology
import scipy.ndimage

def otsu(gray):
    pixel_number = gray.shape[0] * gray.shape[1]
    mean_weight = 1.0/pixel_number
    his, bins = np.histogram(gray, np.arange(0,257))
    final_thresh = -1
    final_value = -1
    intensity_arr = np.arange(256)
    for t in bins[1:-1]: # This goes from 1 to 254 uint8 range (Pretty sure wont be those values)
        pcb = np.sum(his[:t])
        pcf = np.sum(his[t:])
        Wb = pcb * mean_weight
        Wf = pcf * mean_weight

        mub = np.sum(intensity_arr[:t]*his[:t]) / float(pcb)
        muf = np.sum(intensity_arr[t:]*his[t:]) / float(pcf)
        #print mub, muf
        value = Wb * Wf * (mub - muf) ** 2

        if value > final_value:
            final_thresh = t
            final_value = value
    final_img = gray.copy()
    print(final_thresh)
    final_img[gray > final_thresh] = 255
    final_img[gray < final_thresh] = 0
    return final_img

def label2rgb(labels):
  """
  Convert a labels image to an rgb image using a matplotlib colormap
  """
  label_range = np.linspace(0, 1, 256)
  lut = np.uint8(plt.cm.viridis(label_range)[:,2::-1]*256).reshape(256, 1, 3)  # replace viridis with a matplotlib colormap of your choice
  return cv2.LUT(cv2.merge((labels, labels, labels)), lut)

def char_segementation(Igray, i, index, *args, **kwargs):
    print('char started')
    img_height = 1000
    BWimage = otsu(Igray)
    BWimage = 1 - BWimage
    BWimage1 = BWimage

    Border_coordinates, hierarchy = cv2.findContours(BWimage, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    boundingBoxes = [cv2.boundingRect(c) for c in Border_coordinates]
    (Border_coordinates, boundingBoxes) = zip(*sorted(zip(Border_coordinates, boundingBoxes), key=lambda b: b[1][0], reverse=False))
    #Set a picture array ready for extracted characters
    character_imgs = np.zeros([img_height , img_height , len(Border_coordinates)])
    k=1
    for i in range(len(Border_coordinates)):
        #Find span of character from contour
        minx, maxx, miny, maxy = BorderSpan(Border_coordinates[i,1])
        xdif = maxx - minx
        xinit = round((img_height - xdif) / 2)
        ydif = maxy - miny
        yinit = round((img_height - ydif) / 2)

        #Extract the image of character
        #Contains parts of adjacent characters
        #Solution:
        #USE WATERSHED ALGORITHM
        #MASK THE SMALLER REGIONS(poly2mask IS A FUNCTION THAT DOES THAT)
        #GET THE DESIRED CHARACTER
        #character will be dominating in the image
        #crop the desired character...containg incomplete parts of adjecent char images too
        BufferImg = BWimage1[minx:maxx,miny:maxy]
        BufferImg[1,:]=0
        BufferImg[np.size(BufferImg,1),:]=0
        BufferImg[:,1]=0
        BufferImg[:,np.size(BufferImg,2)]=0

        #pause;
        InnerBorder, hierarchy1 = cv2.findContours(BufferImg, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        boundingBoxes1 = [cv2.boundingRect(c) for c in InnerBorder]
        (InnerBorder, boundingBoxes1) = zip(*sorted(zip(InnerBorder, boundingBoxes1), key=lambda b: b[1][0], reverse=False))
        print(len(InnerBorder))
        if (len(InnerBorder) > 1):
            #indicating more characters...ues watershed to segment it..
            #Watershed steps
            BufferImg = 1 - BufferImg
            sobelx = cv2.Sobel(np.logical_not(BufferImg), cv2.CV_64F, 1, 0)  # Find x and y gradients
            sobely = cv2.Sobel(np.logical_not(BufferImg), cv2.CV_64F, 0, 1)
            gmag = np.sqrt(sobelx ** 2.0 + sobely ** 2.0)
           # gmag = imgradient((1 - BufferImg))
            L = cv2.watershed(gmag)
           # gmag[markers == -1] = [255, 0, 0]
            #L=watershed(gmag)
            Lrgb = label2rgb(L)
            se = disk(10)
           # se=strel('disk',10)
            Ie = cv2.erode(BufferImg,se)
         #   Ie=imerode(BufferImg,se)
            Iobr = cv2.dilate(Ie, BufferImg)
           # Iobr=imreconstruct(Ie,BufferImg)
            Ioc = cv2.morphologyEx(Iobr, cv2.MORPH_CLOSE, se)
            #Ioc=imclose(Iobr,se)
            lm = scipy.ndimage.filters.maximum_filter(Iobr)
            msk = (Iobr == lm)  # // convert local max values to binary mask
            fgm= np.logical_not(msk)
            se2 = np.ones((5,5),np.uint8)
           # se2=strel(ones(5,5))
            fgm2 = cv2.morphologyEx(fgm, cv2.MORPH_CLOSE, se2)
             #   imclose(fgm,se2)
            fgm3 = cv2.erode(fgm2,se2)
                #imerode(fgm2,se2)
            fgm4  = morphology.remove_small_objects(fgm3, min_size=20)
          #  fgm4=bwareaopen(fgm3,20)
            a1 = np.array(fgm)
            D = scipy.ndimage.distance_transform_edt(1-a1)
            #D=bwdist(fgm)
            DL= cv2.watershed(D)
            #    watershed(D)
            bgm=DL == 0
            #pause;
            region, hierarchy2 = cv2.findContours(np.logical_not(bgm), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
            boundingBoxes2 = [cv2.boundingRect(c) for c in region]
            (region, boundingBoxes2) = zip(*sorted(zip(region, boundingBoxes2), key=lambda b: b[1][0], reverse=False))

            oldbgm = bgm
            big_border=Biggest_Border(region)
            temp = region[big_border]
            mask = poly2mask(temp[:,2],temp[:,1],bgm.shape)
            #retain the unwanted...
            #Subtract the original image and the unwanted character
            #images...to get the desired character....
            #e.g If you have 5 cats and 1 dogs....
            #you want to have only cats...
            #Instead of catching each cat and taking it out...
            #catch the dog and move him out...
            #The remaining group is of cats...
            #So find the unwanted and the remove it...
            mask= 1- mask
            #imshow(mask);
            #pause;
            BufferImg1 = np.multiply((1-BufferImg),mask)
            BufferImg = (1 - BufferImg) - BufferImg1
            #             #imshow(BufferImg);
#             ###pause;
        #============================================================#
    #   character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BWimage1(minx:maxx,miny:maxy);
        #Saving the char images
        character_imgs[xinit:(xinit + xdif), yinit:(yinit + ydif),k] = BufferImg
        x = str(k + index) #num2str(k + index)
        name= 'character'.join(x) #strcat('character',x)
        name= name + '.jpg' #strcat(name,'.jpg')
        cv2.imwrite(character_imgs[:,:,k],name)
        k=k + 1
        print('hello')
    index = k + index
    return index
    
if __name__ == '__main__':
    pass
    