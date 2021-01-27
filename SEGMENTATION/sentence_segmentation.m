function [n]=sentence_segmentation(BWimage,I,Igray,ptch)
    %Detect boundaries of all picture elements
    B=bwboundaries(~BWimage,8,'noholes');
    Bedge=edge(~BWimage);
    imshow(Bedge)
    %pause;

    %Draw line within word to establish connectivity in each document element
    for k=1:1:length(B)

        coordinates=B{k,1};
        coordinates_sorted=sortrows(coordinates,1);
        maxy=max(coordinates_sorted(:,2));
        miny=min(coordinates_sorted(:,2));
        t=length(coordinates_sorted);
        %Find average vertical pixel location
        maxx=floor(mean(coordinates_sorted(:,1)));
        nexty=maxy;
        while(miny<=maxy)
            BWimage(maxx,miny)=0;
            miny=miny+1;
        end

        %Draw a line towards right from the current pixel
        %till we intersect some other word pixel 
        nexty=nexty+1;
        while(nexty<size(I,2))
            if(BWimage(maxx,nexty)~=0)
                BWimage(maxx,nexty)=0;
                nexty=nexty+1;
            else
                break;
            end
        end
        miny=min(coordinates_sorted(:,2));
        maxx=max(coordinates_sorted(:,1));
    end
    %Check points
    %imshow(~BWimage);
    %pause;
    %================end of connectivity part
    
    %==============Watershed steps
    gmag = imgradient(~BWimage);
    L = watershed(gmag);
    Lrgb = label2rgb(L);

    se = strel('disk',10);
    Ie = imerode(BWimage,se);
    Iobr = imreconstruct(Ie,BWimage);
    
    Ioc = imclose(Iobr,se);
    fgm = ~imregionalmax(Iobr);

    se2 = strel(ones(5,5));
    fgm2 = imclose(fgm,se2);
    fgm3 = imerode(fgm2,se2);

    fgm4 = bwareaopen(fgm3,20);

    D = bwdist(fgm);
    DL = watershed(D);
    bgm = DL == 0;
%     Check points
%     imshow(I)
%     pause;
%     imshow(Ie)
%     pause;
%     imshow(Iobr)
%     pause;
%     imshow(bgm)
%     pause;
    %===========END OF WATERSHED
    
    
    %===============================
    %Overlap watershed output lines with original image. 
    %Only for Visualization purpose
    %No contribution to any computation or operation
    J1=Igray;
    for i=1:size(I,1)
        for j=1:size(I,2)
            if(bgm(i,j)==1)
                J1(i,j)=0;
            end
        end
    end
    imshow(J1);
    %pause;
    %============================
    
    J=Igray;
    bgmsize=size(bgm);
    bgm(1,:)=1;
    bgm(bgmsize(1),:)=1;
    bgm(:,1)=1;
    bgm(:,bgmsize(2))=1;

    %Find contours of watershed lines to detect areas in image
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
        imshow(Sentence_Cut);
        %pause;
        Cut=bwboundaries(Sentence_Cut);
        Big_Border=Biggest_Border(Cut);
        
        
        %Suppress the area surrounding the main sentence area including the
        %watershed line. This assumes that the sentence lies in the dominating
        %area of image. Hence suppress every area except the area with
        %largest contours
        
        %Check point
        %imshow(Sentence_Image)
        %pause;
        p=(Suppress_Surrounding1(Sentence_Image,Cut{Big_Border,1},ptch));
        %figure(k-1);
        %imshow(p);
        %pause;
        x=num2str(k-1);
        
        %SAVING THE SENTENCE IMAGE
        name=strcat('sentence',x);
        name=strcat(name,'.jpg');
        imwrite(p,name)
    end
    n=x;
end