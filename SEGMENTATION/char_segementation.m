function [index]=char_segementation(Igray,i,index)
    %CODE FOR WATERSHED BASED SEGMENTATION
       disp('char started')
    %IGNORE THIS BLOCK
    %===================================================
%     Programatic Approach- Cropping based approach


%     img_height=500;
%     level=graythresh(Igray);%uses Otsu’s global thresholding algorithm
%     %%imshow(img_gray)
%     BWimage=im2bw(Igray,level);
%     BWimage=~BWimage;
%     BWimage1=BWimage;
% 
%     %Extrat contours in image
%     %let No. of contour=No. of characters....Fails on i,j etc
%     Border_coordinates = bwboundaries(BWimage,8,'noholes');
%     %Border=edge(BWimage)%Visualization
% 
%     %Set a picture array ready for extracted characters
%     character_imgs=zeros([img_height img_height length(Border_coordinates)]);
%     k=1;
%     if(index==260)
%         %imshow(Igray);
%         %%%pause;
%         
%     end
%     for i=1:1:length(Border_coordinates)
%         %Find span of character from contour
%         [minx maxx miny maxy]=BorderSpan(Border_coordinates{i,1});
% 
%         xdif=maxx-minx;
%         xinit=round((img_height-xdif)/2);
% 
%         ydif=maxy-miny;
%         yinit=round((img_height-ydif)/2);
%         %Accurate char detection needed
%         %============================================================%
%         %Extract the image of character
%         %Contains parts of adjacent characters
%         %Solution:
%         %Detect contours again
%         %Suppress Smaller contour regions: assuming that area covered by main
%         %character will be dominating in the image
% 
%         BufferImg=BWimage1(minx:maxx,miny:maxy);
%         InnerBorder=bwboundaries(BufferImg,8,'noholes');
%         if(length(InnerBorder)>1)
%             Big_Border=Biggest_Border(InnerBorder);
%             for itr=1:1:length(InnerBorder)
%                 if(itr~=Big_Border)
%                     [xmin xmax ymin ymax]=BorderSpan(InnerBorder{itr,1})
%                     BufferImg(xmin:xmax,ymin:ymax)=0;
%                 end
%             end
%         end
%         %============================================================%
%     %   character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BWimage1(minx:maxx,miny:maxy);
%         character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BufferImg;
%         x=num2str(k+index);
%         name=strcat('word',x);
%         name=strcat(name,'.jpg');
%         imwrite(character_imgs(:,:,k),name);
%         k=k+1;
%         disp('hello');
%     end
%     index=k+index;
    %=====================================================
    
    
    img_height=1000;%SET THE OUTPUT IMAGE SIZE
    %LARGE VALUSE TO ACCOMODATE UNSEGMENTED LETTERS
    
    level=graythresh(Igray);%uses Otsu’s global thresholding algorithm
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
    for i=1:1:length(Border_coordinates)
        %Find span of character from contour
        [minx maxx miny maxy]=BorderSpan(Border_coordinates{i,1});
        
        %PADDING CALCULATIONS FOR SAVING IMAGE...
        xdif=maxx-minx;
        xinit=round((img_height-xdif)/2);

        ydif=maxy-miny;
        yinit=round((img_height-ydif)/2);
       
        
        %============================================================%
        %Extract the image of character
        %Contains parts of adjacent characters
        %Solution:
        %USE WATERSHED ALGORITHM
        %MASK THE SMALLER REGIONS(poly2mask IS A FUNCTION THAT DOES THAT)
        %GET THE DESIRED CHARACTER
        
        
        %character will be dominating in the image
        
        

        %crop the desired character...containg incomplete parts of adjecent char images too
        BufferImg=BWimage1(minx:maxx,miny:maxy);
        BufferImg(1,:)=0;
        BufferImg(size(BufferImg,1),:)=0;
        BufferImg(:,1)=0;
        BufferImg(:,size(BufferImg,2))=0;
        %imshow(BufferImg);
        %pause;
        
      
        InnerBorder=bwboundaries(BufferImg,8,'noholes');  %To detect the numbe rof entities present
        disp(length(InnerBorder));
        %%pause;
        if(length(InnerBorder)>1)% IF the number of entitied are more...
            %indicating more characters...ues watershed to segment it..
            
            %Watershed steps
            BufferImg=~BufferImg;
            gmag = imgradient(~BufferImg);
            L = watershed(gmag);
            Lrgb = label2rgb(L);

            se = strel('disk',10);
            Ie = imerode(BufferImg,se);
            Iobr = imreconstruct(Ie,BufferImg);

            Ioc = imclose(Iobr,se);
            fgm = ~imregionalmax(Iobr);

            se2 = strel(ones(5,5));
            fgm2 = imclose(fgm,se2);
            fgm3 = imerode(fgm2,se2);

            fgm4 = bwareaopen(fgm3,20);

            D = bwdist(fgm);
            DL = watershed(D);
            bgm = DL == 0;
            %imshow(bgm);
            %pause;
            region=bwboundaries(~bgm,8);
            oldbgm=bgm;
            big_border=Biggest_Border(region);%detect biggest border...
            
            temp=region{big_border};
            mask=poly2mask(temp(:,2),temp(:,1),size(bgm,1),size(bgm,2));
            %suppress the wanted character...
            %retain the unwanted...
            %Subtract the original image and the unwanted character
            %images...to get the desired character....
            
            %e.g If you have 5 cats and 1 dogs....
            %you want to have only cats...
            %Instead of catching each cat and taking it out...
            %catch the dog and move him out...
            %The remaining group is of cats...
            
            %So find the unwanted and the remove it...
            mask=~mask;
            %check point
            %imshow(mask);
            %pause;
            BufferImg1=~BufferImg.*mask;
            BufferImg=~BufferImg-BufferImg1;
%             %imshow(BufferImg);
%             %%%pause;
        else
            
        end
        %============================================================%
    %   character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BWimage1(minx:maxx,miny:maxy);
    
    %Saving the char images
        character_imgs(xinit:xinit+xdif,yinit:yinit+ydif,k)=BufferImg;
        
        x=num2str(k+index);
        name=strcat('character',x);
        name=strcat(name,'.jpg');
        imwrite(character_imgs(:,:,k),name);
        k=k+1;
        disp('hello');
    end
    index=k+index;
end