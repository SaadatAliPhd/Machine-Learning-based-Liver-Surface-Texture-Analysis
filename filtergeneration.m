% This code do implementation of Average of Synthetic Exact Filters and
% MOSSE Filters on our project images
% ASEF Class Implementation
% Usage: 
%     H = COREF(size,regularization);
%     H.addTraining(image,target) % multiple (image,target) can be added
%     H.correlate(image)
% References:
% 	Bolme, D.S., B.A. Draper, and J.R. Beveridge. “Average of Synthetic Exact Filters.” In IEEE Conference on Computer Vision and Pattern Recognition, 2009. CVPR 2009, 2105–12, 2009. doi:10.1109/CVPR.2009.5206701.
%	David S. Bolme, J. Ross Beveridge, Bruce A. Draper, and Yui Man Lui. “Visual Object Tracking Using Adaptive Correlation Filters,” 2010.

%% Generating filter using desired images and orignal images
clear all;

dname = './finalorigional/';
flist = dir([dname  '*.bmp']);

dname2 = './finaldesired/';
flist2 = dir([dname2  '*.bmp']);
close all
s = 2.0;
 H = COREF([486,554],1.0);
for i =  1:length(flist)
    
    fname = [dname flist(i).name];
    I = imread(fname);
    I = im2double(rgb2gray(I(95:580,202:755,:)));
    
    
    
    fname2 = [dname2 flist(i).name];
    X = imread(fname2);
    target=im2double(X);;
    hg = fspecial('gaussian',[5*s 5*s],s);
    target=imfilter(target,hg);
   
    H.addTraining(I,target);
    
end
%% Show filter
imshow(H.getFilterImage(),[])
pause
%% Saving as filter61wg for further use in segmentation process
save('filter61wg.mat','H');