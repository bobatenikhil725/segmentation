function [minx maxx miny maxy]=BorderSpan(Border_coordinates)
    coordinates=Border_coordinates;
    
    coordinates_sorted=sortrows(coordinates,1);
    minx=coordinates_sorted(1,1);
    maxx=coordinates_sorted(length(coordinates_sorted),1);
    coordinates_sorted=sortrows(coordinates,2);
    miny=coordinates_sorted(1,2);
    maxy=coordinates_sorted(length(coordinates_sorted),2);
end