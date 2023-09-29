% Implementation of Average of Synthetic Exact Filters and MOSSE Filters
% ASEF Class Implementation
% Usage: 
%     H = COREF(size,regularization);
%     H.addTraining(image,target) % multiple (image,target) can be added
%     H.correlate(image)
% References:
% 	Bolme, D.S., B.A. Draper, and J.R. Beveridge. “Average of Synthetic Exact Filters.” In IEEE Conference on Computer Vision and Pattern Recognition, 2009. CVPR 2009, 2105–12, 2009. doi:10.1109/CVPR.2009.5206701.
%	David S. Bolme, J. Ross Beveridge, Bruce A. Draper, and Yui Man Lui. “Visual Object Tracking Using Adaptive Correlation Filters,” 2010.

classdef COREFBank < handle
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
        
        
        function obj = COREFBank(Angles,range,Base,size)
            obj.angle= Angles;
            obj.range=range;
            obj.filter = Base;
            obj.size = size;
            obj.window = cosineWindow(obj.size);
            obj.output=zeros(obj.size);
            obj.num_average=0;
        end
        
        function Apply(obj,tile)
            % add a single image for training into the filter
            g = obj.filter;
            a = obj.angle;
           ra=obj.range/5;
            
            for i=1:ra
                Z = fftshift(ifft2(conj(g)));
                Z=imrotate(Z,a-(5*i), 'bilinear','crop');
                obj.filter=conj(fft2(ifftshift(Z)));
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
         tile = tile.*obj.resizeWindow(size(tile));         
        end
       
        function averagecorrelate(obj,tile)
            tile=(tile>0).* tile.^2;
            obj.output = obj.output+tile;
            obj.num_average=obj.num_average+1;
            
        end
    end
end