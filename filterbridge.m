clear all;
load('filteroldfin.mat')
Z=H;
X=H;


%%[img pth]= uigetfile('.bmp','select image to be cropped');
%img = [pth img];
%test = im2double(rgb2gray(imread(img)));
%=test(95:580,202:755,:);
%out = H.correlate(test);
%figure,imshow(H.getFilterImage(),[])
img2 = fftshift(ifft2(conj(X.filter)));
img2=imrotate(img2,180+30, 'bilinear','crop');
X.filter=fft2(ifftshift((img2)));
for i=1:12

    
img2 = fftshift(ifft2(conj(X.filter)));
img2=imrotate(img2,180-5, 'bilinear','crop');
X.filter=fft2(ifftshift((img2)));
%out2 = X.correlate(test);
figure,imshow(X.getFilterImage(),[])
Zx=X.filter.*X.filter;
end
Z.filter=Zx;

% figure,subplot(2,2,1),imshow(out,[])
% subplot(2,2,2),imshow((out>0).*out.^2,[])
% subplot(2,2,3),imshow((test),[])
% subplot(2,2,4),imshow((out2>0).*out2.^2,[])


% fi=(out>0).*out.^2;
% f2=sum(fi,2);
% f1=max(fi');
% %subplot(2,2,3),plot(f2)
% subplot(2,2,4),plot(f1);
