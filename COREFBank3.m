%same purpose as COREF bank 2

classdef COREFBank3 < handle
    properties
        angle
        range
        filter
        size
        window
        output
        num_average
    end
    methods
        
        
        function obj = COREFBank3(Angles,range,Base,size)
            obj.angle= Angles;
            obj.range=range;
            obj.filter = Base;
            obj.size = size;
            obj.window = cosineWindow(obj.size);
            obj.output=zeros(obj.size);
            obj.num_average=1;
        end
        
        function Apply(obj,tile)
            g = obj.filter;
            a = obj.angle;
            ra=obj.range/2;
            
            for i=1:ra
                Z = fftshift(ifft2(conj(g)));
                Z=imrotate(Z,a-(2*i), 'bilinear','crop');
                obj.filter=conj(fft2(ifftshift(Z)));
                %obj.getFilterImage();
                V =obj.correlate(tile);
                obj.averagecorrelate(V)
            end
            
        end
        function h = resizeFilter(obj,size)
            % return a filter of given size
            if all (size == obj.size)
                h = obj.filter;
            else
                h = fft2(ifft2(obj.filter),size(1),size(2));
            end
        end
        function cor = correlate(obj,tile)
            % return the correlation score of a given image with the filter
            f = obj.preprocess(tile);
            F = fft2(f);
            G = obj.resizeFilter(size(f)) .* F;
            g = ifft2(G);
            cor = real(g);
        end
        
        function h = resizeWindow(obj,size)
            % return a window of a given size
            if all (size == obj.size)
                h = obj.window;
            else
                h = cosineWindow(size);
            end
        end
        function tile = preprocess(obj,tile)
            % Preprocess the image
            tile = tile.^2.5;
            tile = meanUnit(tile);
            
            %tile = imgradient(tile,'sobel');
            tile = meanUnit(tile);
            %tile = tile.*obj.resizeWindow(size(tile));
        end
        
        function averagecorrelate(obj,tile)
            tile=(tile>0).* tile.^2;
            
%             figure,subplot(ceil(sqrt(obj.range/5)),ceil(sqrt(obj.range/5)),obj.num_average)
%             imshow(tile)
            obj.output = obj.output+tile;
            obj.num_average=obj.num_average+1;
            
        end
        
        function img = getFilterImage(obj)
            img = fftshift(ifft2(conj(obj.filter)));
            subplot(ceil(sqrt(obj.range/2)),ceil(sqrt(obj.range/2)),obj.num_average)
            imshow(img,[])
        end
    end
end