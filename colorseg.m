clc;
clear all;
dname = './modified/';
flist = dir([dname  '*.bmp']);

dname2 = './desired/';
%%pathName = 'C:\Users\Ahmer pc\Desktop\desired';
% if ~exist(pathName, 'dir')
%   mkdir(pathName);
%   % This will create to the full depth of the path.
%   % Upper folder levels don't have to exist yet.
% end
close all
for i =  1:length(flist)
    
    fname = [dname flist(i).name];
    I = imread(fname);
    I = im2double(I);
    cform = makecform('srgb2lab');
lab_I = applycform(I,cform);
ab = double(lab_I(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
rab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx, cluster_center] = kmeans(rab,nColors,'distance','sqEuclidean', 'Replicates',3);
target = reshape(cluster_idx,nrows,ncols);
mean_cluster_value = cluster_center(:,1);
[tmp, idx] = sort(mean_cluster_value);
background = idx(2);
green = idx(1);
blue = idx(3);
target = im2double(-(target == blue) + (target == green));
    
    
  baseFileName = [dname2 flist(i).name]
  %fullFileName = fullfile(pathName, baseFileName);   
  imwrite(target, baseFileName);
    
end