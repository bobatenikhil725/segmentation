clear all;
clc;
%MAIN FUNCTION

%Image path
path='D:\COLLEGE\1st Sem\IPCV(861)\Project';
name='document4';   %Image name
ext='.jpg';        %Image extension
img_path=strcat(path,'\',name,ext);
rgb = imread(strcat(path,'\',name,ext));
I = rgb2gray(rgb);
Igray=I;


%To find background colour for masking of unwanted regions
histo=imhist(Igray);
[val,ptch]=max(histo);


level=graythresh(I);%uses Otsu’s global thresholding algorithm
BWimage=im2bw(I,level);
%Check points
%imshow(BWimage);
%pause;

%Forming directories
%Makes a folder in the same ddirectors where the image is
folder=strcat(name,'_Segmentation');
cd(path);
[status, msg, msgID] = mkdir(folder);
cd(strcat(path,'\',folder));
folder_path=strcat(path,'\',folder);

[status, msg, msgID] = mkdir('Sentences');
sentence_path=strcat(folder_path,'\','Sentences');
[status, msg, msgID] = mkdir('Words');
word_path=strcat(folder_path,'\','Words');
[status, msg, msgID] = mkdir('Characters');
character_path=strcat(folder_path,'\','Characters');

%Calling sentence segemntation
cd(sentence_path);
n=sentence_segmentation(BWimage,I,Igray,ptch);

%Index to keep a note of the number of images etc...
n=str2num(n);
index=0;

%takes one sentence image at a time
%Sends the image to word segmentation function
%Word segemntation function saves the image is the proper folder
cd(word_path);%directory changed to appropriate folder
disp('starting words');
for i=1:1:n
    name=strcat('sentence',num2str(i),'.jpg');
    img=strcat(sentence_path,'\',name);
    word=imread(img);
    index=word_segmentation1(word,i,index,ptch)
end
%====================

%takes one word image at a time
%Sends the image to char segmentation function
%char segemntation function saves the image is the proper folder
cd(character_path);%directory changed to appropriate folder
disp('starting chars');
disp(index);
n=index;
index=0;

for i=1:1:n
    name=strcat('word',num2str(i),'.jpg');
    img=strcat(word_path,'\',name);
    word=imread(img);
    
    %For programatic approach call this function
    %index=char_segementation_prog(word,i,index);
    
    %watershed approach call this function
    index=char_segementation(word,i,index);
end