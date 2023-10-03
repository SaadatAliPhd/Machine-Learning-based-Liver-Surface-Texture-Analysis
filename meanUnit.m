function tile = meanUnit(tile)
%This function makes the input image to have zero mean and unit norm
    tile = tile - mean2(tile);
    length = sqrt(sum(sum(tile.*tile)));
    if length > 0.0
        tile = tile / length;
    end   
end