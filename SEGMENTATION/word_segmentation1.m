function [index]=word_segmentation(Igray,n,index,ptch)
    %-------------------------------------------------
    %Check point.
    %imshow(Igray);
    %pause;
    level=graythresh(Igray);%uses Otsu’s global thresholding algorithm
    BWimage=im2bw(Igray,level);
    B=bwboundaries(~BWimage,8,'noholes');
    Bedge=edge(~BWimage);
    %imshow(Bedge);
    %pause;

    %====================================================
    %ESTABLISH INTRA WORD CONNECTIVITY
    %STATISTICAL APPROACH
    %CONNECTS ELEMENTS WHICH ARE WITHIN 40 PIXEL TOWARDS RIGHT
    %SO APPROXIMATELY A WORD GETS CONNECTED
    %CHANGE THE NUMBER OF PIXELS (number_of_pixels_horizontal)TO TUNE THE CONNECTIVITY
    number_of_pixels_vertical=10;% To connect dot of 'i' and 'j'
    number_of_pixels_horizontal=20;     %Tune connectivity
    for i=1:1:length(B)
        coordinates=B{i,1};
        coordinates_sorted=sortrows(coordinates,1);
        maxy=max(coordinates_sorted(:,2));
        miny=min(coordinates_sorted(:,2));
        t=length(coordinates_sorted);
        meanx=floor(mean(coordinates_sorted(:,1)));
        meany=floor(mean(maxy,miny));
        miny1=miny;
        while(miny1 <= maxy)
            BWimage(meanx,miny1)=0;
            miny1=miny1+1;
        end
        %check point
        %imshow(BWimage);
        %pause;
               
        nexty=maxy;
        nexty=nexty+1;
        while(nexty<maxy+number_of_pixels_vertical && nexty<=size(BWimage,2))
            if(BWimage(meanx,nexty)~=0)
                BWimage(meanx,nexty)=0;
                nexty=nexty+1;
            else
                break;
            end
        end
        %check point
        %imshow(BWimage);
        %pause;
        
        nexty=miny;
        nexty=nexty-1;
        while(nexty>miny-number_of_pixels_vertical && nexty>0)
            if(BWimage(meanx,nexty)~=0)
                BWimage(meanx,nexty)=0;
                nexty=nexty-1;
            else
                break;
            end
        end

        nextx=meanx;
        nextx=nextx+1;
        while(nextx<meanx+number_of_pixels_horizontal && nextx<=size(BWimage,1))
            if(BWimage(nextx,meany)~=0 || 1)
                BWimage(nextx,meany)=0;
                nextx=nextx+1;
            else
                break;
            end
        end
        %check point
        %imshow(BWimage);
        %pause;
  
    end
    imshow(~BWimage);
    %pause;

    %===================================
    %WATERSHED STEPS
    %-------------------------------------------------
    I=BWimage;
    %Watershed steps
    gmag = imgradient(I);

    L = watershed(gmag);
    Lrgb = label2rgb(L);
    
    se = strel('disk',10);
    Ie = imerode(I,se);
    Iobr = imreconstruct(Ie,I);

    Ioc = imclose(Iobr,se);

    fgm = ~imregionalmax(Iobr);
    
    se2 = strel(ones(5,5));
    fgm2 = imclose(fgm,se2);
    fgm3 = imerode(fgm2,se2);

    fgm4 = bwareaopen(fgm3,20);

    D = bwdist(fgm);
    DL = watershed(D);
    bgm = DL == 0;
    
    %============================
    %ONLY FOR VISVUALIZATION PURPOSE
    %DOESNT CONTRIBUTE TO ANY OPERATIONS
    J=Igray;
    cut_size=size(bgm);
    for i=1:1:cut_size(1)
        for j=1:1:cut_size(2)
            if(bgm(i,j)==1)
                J(i,j)=0;
            end
        end
    end
    figure(n)
    imshow(J)
    %pause;
    %===================================
    
    
    J=Igray;
    bgmsize=size(bgm);
    bgm(1,:)=1;
    bgm(bgmsize(1),:)=1;
    bgm(:,1)=1;
    bgm(:,bgmsize(2))=1;

    %Find contours of watershed lines to find areas in image
    Cut_Boundaries=bwboundaries(bgm);
    Cut_Image=edge(bgm);

    
    for k=2:1:length(Cut_Boundaries)
        %Cut the image region detected by boundaries
        coordinates=Cut_Boundaries{k,1};
        maxx=max(coordinates(:,1));
        minx=min(coordinates(:,1));
        maxy=max(coordinates(:,2));
        miny=min(coordinates(:,2));   
        Sentence_Image=J(minx-1:maxx+1,miny:maxy);
        Sentence_Cut=bgm(minx-1:maxx+1,miny-1:maxy+1);
        %imshow(Sentence_Cut);
        Cut=bwboundaries(Sentence_Cut);
        Big_Border=Biggest_Border(Cut);
        
        %Suppress the area surrounding the main sentence area including the
        %watershed line. This assumes that the sentence lies in the dominating
        %area of image
        p=(Suppress_Surrounding1(Sentence_Image,Cut{Big_Border,1},ptch));
        %Check point
        %figure(k-1);
        %imshow(p);
        
        %SAVE WORD IMAGES
        x=num2str(k-1+index);
        name=strcat('word',x);
        name=strcat(name,'.jpg');
        imwrite(p(:,1:size(p,2)-1),name)
    end
    index=k-1+index;
    %INDEX TO KEEP A NOTE OF NUMBER OF WORD IMAGES
end    