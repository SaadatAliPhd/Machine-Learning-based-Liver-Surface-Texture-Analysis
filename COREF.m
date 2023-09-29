%This is used for segmentation 
%Implementation of Average of Synthetic Exact Filters and MOSSE Filter ASEF Class Implementation
% Usage: 
%     H = COREF(size,regularization);
%     H.addTraining(image,target) % multiple (image,target) can be added
%     H.correlate(image)
% References:
% 	Bolme, D.S., B.A. Draper, and J.R. Beveridge. “Average of Synthetic Exact Filters.” In IEEE Conference on Computer Vision and Pattern Recognition, 2009. CVPR 2009, 2105–12, 2009. doi:10.1109/CVPR.2009.5206701.
%	David S. Bolme, J. Ross Beveridge, Bruce A. Draper, and Yui Man Lui. “Visual Object Tracking Using Adaptive Correlation Filters,” 2010.

classdef COREF < handle
   properties
      reg      
      num_training
      size
      filter
      numF
      denF
      window
   end
   methods
       function obj = COREF(size,reg)
           % create an ASEF filter with given size and regularization
           obj.size = size;
           obj.reg = reg;           
           obj.filter = zeros(obj.size);
           obj.numF = zeros(obj.size);
           obj.denF = zeros(obj.size);
           obj.window = cosineWindow(obj.size);
           obj.num_training = 0;
       end
      function addTraining(obj,tile,output)
         % add a single image for training into the filter
         g = output;
         f = obj.preprocess(tile);
         F = fft2(f);
         G = fft2(g);
         cF = conj(F);
         
         % ASEF         
         %H = (G.*cF) ./ (F.*cF+obj.reg);
         %obj.filter = obj.filter + H;
         
         % MOSSE
         obj.numF = obj.numF + G.*cF;
         obj.denF = obj.denF + F.*cF;
         obj.filter = obj.numF ./ (obj.denF + obj.reg);
         
         obj.num_training = obj.num_training + 1;
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
      function img = getFilterImage(obj)
          img = fftshift(ifft2(conj(obj.filter)));
      end
   end
end