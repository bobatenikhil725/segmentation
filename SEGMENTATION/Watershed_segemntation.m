clear all;
clc;
%Read input imag
rgb = imread('C:\Users\Atharva\Desktop\SEM7\Final_Year_project\sentence1 (2).jpg');

%I = rgb2gray(rgb);
I=rgb;
Igray=I;

%Dilate the image
I = imgaussfilt(I,5);
imshow(I);
pause;

level=graythresh(I);%uses Otsu’s global thresholding algorithm
I=im2bw(I,level-0.1);

%Watershed steps
%=========================================
gmag = imgradient(I);

%subplot(3,3,2);
%imshow(gmag,[]);
%title('Gradient Magnitude');

L = watershed(gmag);
Lrgb = label2rgb(L);

%subplot(3,3,3)
%imshow(Lrgb)
%title('Watershed Transform of Gradient Magnitude')

se = strel('disk',10);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
%subplot(3,3,4)
%imshow(Iobr)
%title('Opening-by-Reconstruction')

Ioc = imclose(Iobr,se);
%subplot(3,3,5)
%imshow(Ioc)
%title('Opening-Closing')

fgm = ~imregionalmax(Iobr);
%subplot(3,3,5)
%imshow(fgm)
%title('Regional Maxima of Opening-Closing by Reconstruction')
%pause;
se2 = strel(ones(5,5));
fgm2 = imclose(fgm,se2);
fgm3 = imerode(fgm2,se2);

fgm4 = bwareaopen(fgm3,20);

D = bwdist(fgm);
DL = watershed(D);
bgm = DL == 0;
%subplot(3,3,6)
%imshow(bgm)
%title('Watershed Ridge Lines)')

%Visualization purpose
%==========================
J=Igray;
cut_size=size(bgm);
for i=1:1:cut_size(1)
    for j=1:1:cut_size(2)
        if(bgm(i,j)==1)
            J(i,j)=0;
        end
    end
end
%=========================
%subplot(1,1,1)
%imshow(J)
%subplot(1,2,2)
%imshow(fgm)