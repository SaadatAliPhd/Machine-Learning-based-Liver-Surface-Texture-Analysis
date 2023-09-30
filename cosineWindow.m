function window = cosineWindow(xsize)
% This function returns a cosine window of given size used in COREF
    w = xsize(1);
    h = xsize(2);
    X = reshape(0:w-1,w,1);
    Y = reshape(0:h-1,1,h);
    X = X*ones(1,h);
    Y = ones(w,1)*Y;
    window = sin(pi*X/(w-1.0)).*sin(pi*Y/(h-1.0));
end