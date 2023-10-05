%% This code results in segmentation of region of Interest by applying correlation filter banks

clear all;
%% Call filter that is generated previously
load('filter61wg.mat')
%% Creating filter bank for better results
YT=COREFBank2(30,60,H.filter,[486,554]);
YTX=COREFBank3(30,60,H.filter,[486,554]);
%% Ask Input image from user for segmentation
[img pth]= uigetfile('.bmp','select image to be cropped');
img = [pth img];
%% Applying Filter banks on image
test = im2double(rgb2gray(imread(img)));
test=test(95:580,202:755,:);
YT.Apply(test)
YTX.Apply(test)
%figure,imshow((YT.output))
%figure,imshow(test)
%% Applying morphological operations
BW1=im2bw(YT.output);
BWX1=im2bw(YTX.output);
BW2 = bwmorph(BW1,'thin',Inf);
BWX2 = bwmorph(BWX1,'thin',Inf);
% SM=imsharpen(YT.output,'Radius',5,'Amount',20);
% subplot(2,2,1),imshow((YT.output))
% subplot(2,2,2),imshow(test)
% subplot(2,2,3),imshow(SM)
BW2 = bwmorph(BW2,'clean',Inf) ;
BW2=BW2(:,1:340);

%   se = strel('line',20,10);
%   afterOpening = imopen(BW2,se);
%  size(BW2)figure, imshow(BW2), figure, imshow(afterOpening,[])
[Q,W] = find(BW2'>0.9,100,'last');
marker = zeros(size(BWX2));
marker=im2bw(marker);
marker(W,Q)=1;
obr = imreconstruct(marker,BWX2);
obr= bwmorph(obr, 'spur',60) ;
% figure,
% subplot(2,2,1),imshow(BW2)
% subplot(2,2,2),imshow(test)
% subplot(2,2,3),imshow(obr,[])
% subplot(2,2,4),imshow(BWX2)
% figure,imshow(marker)
% figure,imshow(BW2)
[I,J,V] = find(obr>0.9);
%% Showing image segmentation by red line on orignal image
figure,imshow(test)
hold on
plot(J,I,'r*')