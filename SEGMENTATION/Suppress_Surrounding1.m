function I=Suppress_Surrounding1(Image,Retain_Border,p)
    %imshow(Image);
    %pause;
    I=Image;
    %Mask the smaller areas
    mask=poly2mask(Retain_Border(:,2),Retain_Border(:,1),size(Image,1),size(Image,2));
    %imshow(mask);
    %pause;
    
    %Mask the areas with background colour
    for i=1:1:size(Image,1)
        for j=1:1:size(Image,2)
            if(mask(i,j)==0)
                I(i,j)=p;
            end
        end
    end
end