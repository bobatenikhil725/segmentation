function [index]=char_segementation_prog(Igray,i,index)
    disp('char started proj')  
    pause;
      
  

    img_height=1000;
    level=graythresh(Igray);%uses Otsu’s global thresholding algorith
    %%imshow(img_gray)
    BWimage=im2bw(Igray,level);
    BWimage=~BWimage;
    BWimage1=BWimage;

    %Extract contours in image
    %let No. of contour=No. of characters....Fails on i,j etc
    Border_coordinates = bwboundaries(BWimage,8,'noholes');
    %Border=edge(BWimage)%Visualization

    %Set a picture array ready for extracted characters
    character_imgs=zeros([img_height img_height length(Border_coordinates)]);
    k=1;
    if(index==260)
        %imshow(Igray);
        %%%pause;
        
    end
    for i=1:1:length(Border_coordinates)
        %Find span of character from contour
        [minx maxx miny maxy]=BorderSpan(Border_coordinates{i,1});

        xdif=maxx-minx;
        xinit=round((img_height-xdif)/2);

        ydif=maxy-miny;
        yinit=round((img_height-ydif)/2);
        %Accurate char detection needed
        %============================================================%
        %Extract the image of character
        %Contains parts of adjacent characters
        %Solution:
        %Detect contours again
        %Suppress Smaller contour regions: assuming that area covered by main
        %character will be dominating in the image

        BufferImg=BWimage1(minx:maxx,miny:maxy);
        InnerBorder=bwboundaries(BufferImg,8,'noholes');
        if(length(InnerBorder)>1)
            Big_Border=Biggest_Border(InnerBorder);
            for itr=1:1:length(InnerBorder)
                if(itr~=Big_Border)
                    [xmin xmax ymin ymax]=BorderSpan(InnerBorder{itr,1})
                    BufferImg(xmin:xmax,ymin:ymax)=0;
                end
            end
        end
        %============================================================%
    %   character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BWimage1(minx:maxx,miny:maxy);
        character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BufferImg;
        x=num2str(k+index);
        name=strcat('word',x);
        name=strcat(name,'.jpg');
        imwrite(character_imgs(:,:,k),name);
        k=k+1;
        disp('hello');
    end
    index=k+index;
end