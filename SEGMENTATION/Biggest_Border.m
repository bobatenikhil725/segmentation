function [location]=Biggest_Border(InnerBorder)
    max=0;
    %Send locations of biggest border in array 'InnerBorder'
    for i=1:1:length(InnerBorder)
        if(length(InnerBorder{i})>max)
            max=length(InnerBorder{i});
            location=i;
        end
    end
    %check points
    %disp(max)
end