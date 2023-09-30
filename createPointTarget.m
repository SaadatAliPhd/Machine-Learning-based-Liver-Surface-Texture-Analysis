function target = createPointTarget(x,y,size,sigma)
% This function creates a gaussian centered at row = x and col = y in an 
% image of given size used in Filter 
    x = (0:size(1)-1)-x;
    y = (0:size(2)-1)-y;
    scale = 1.0 / (sigma*sigma);
    target = exp(-scale*x.*x)'*exp(-scale*y.*y);
end