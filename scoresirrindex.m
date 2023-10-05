dname = './allimages/';
flist = dir([dname  '*.bmp']);

fx=[];
labels=[];
imgname=[];
mydata={};
%%
for o =  1:length(flist)
    %%
    img = [dname flist(o).name]
    if  strfind(img,'irr')
        Label=-1;
        labels=[labels Label];
    else
        Label=+1;
        labels=[labels Label];
    end
    imgname=[imgname img];
    %% loading input image and applying filter for segmentation
    load('filter61wg.mat')
    YT=COREFBank2(30,60,H.filter,[486,554]);
    YTX=COREFBank3(30,60,H.filter,[486,554]);
    test = im2double(rgb2gray(imread(img)));
    v=size(test);
    test=test(95:580,202:755,:);
    YT.Apply(test)
    YTX.Apply(test)
    %figure,imshow((YT.output))
    %figure,imshow(test)
    %% post processing for better segmentation
    %Thining the surface (BW1 used as marker and BW2 as mask latter)
    BW1=im2bw(YT.output);
    BWX1=im2bw(YTX.output);
    BW2 = bwmorph(BW1,'thin',Inf);
    BWX2 = bwmorph(BWX1,'thin',Inf);
    BWX2=BWX2(:,40:523);
    BWX2=padarray(BWX2,[0,35]);
    % Cleaning single pixels and taking left side of BW2 to get marker (marker points should be on surface only)
    BW2 = bwmorph(BW2,'clean',Inf) ;
    BW2=BW2(:,1:340);
    [Q,W] = find(BW2'>0.9,100,'last');
    marker = zeros(size(BWX2));
    marker=im2bw(marker);
    marker(W,Q)=1;
    %Reconstruction using BWX2 as mask(BWX2 has more detected surface pixels than BW2 because of diffrent preprocessing )
    obr = imreconstruct(marker,BWX2);
    %Removing problem of starting and ending hidden nonlinearity
    obr=obr(:,40:523);
    obr=padarray(obr,[0,35]);
    %pruning
    obr= bwmorph(obr, 'spur',30) ;
    % Addressing problem of tree branches like artifact in our segmentation
    [rsx csx]=size(obr);
    for i=1:csx
        if sum(obr(:,i),1)>1
            obr(:,i)=0;
            obr=obr;
        end
    end
    %final segmentation result
    
    obr= bwmorph(obr,'clean',Inf) ;
    %imshow(obr)
    %[I,J,V] = find(obr>0.9);
    %figure,imshow(test)
    %hold on
    %plot(J,I,'r*')
    
    %% Feature extraction (irregularity index)
    SSy=[];
    %Final resultant image
    %figure,imshow(obr,[])
    %initializing for creating window and moving it latter on surface
    %getting endpoints in resultant image
    fxend= bwmorph(obr,'endpoints',Inf) ;
    [endpr,endpc]=find(fxend>0.9);
    %calculating distance between multi-line segments
    k=1;
    kx=1;
    distx=[];
    for i=1:length(endpr)/2
        y2=endpr(k+1);
        x2=endpc(k+1);
        y1=endpr(k);
        x1=endpc(k);
        dist=real(sqrt((y2-y1)^2+(x2-x1)^2));
        k=k+2;
        distx=[distx dist];
    end
    
    %for each line a new iteration run
    for j=1:length(endpr)/2
        obrs=zeros(size(obr));
        for i=1:csx
            if i>endpc(kx)-1 & i<endpc(kx+1)+1
                
                obrs(:,i)=obr(:,i);
                
            end
            
        end
        kx=kx+2;
        %figure,imshow(obrs)
        %calculating how many windows (ix) are required for each line
        windowsize = 100;
        ix=fix(distx(:,j)/(windowsize/2));
        [J2 I2]=find(obrs>0.9);
        xin=49; %49th index
        %figure,
        SSx=[];
        for i=1:ix
            winx=obrs(J2(xin)-14:J2(xin)+15,I2(xin)-49:I2(xin)+50);
            [qw ww]=find(winx>0.9);
            x = ww;
            y1 =qw;
            P = polyfit(x,y1,1);
            yfit = P(1)*x+P(2);
            %windowsx=  (windowsx>0).*windowsx.^2;
            xin=xin+50;
            %     subplot(ceil(sqrt(ix+1)),ceil(sqrt(ix+1)),i)
            %     imshow(winx)
            %     hold on;
            %     plot(x,yfit,'r-');
            yres=y1-yfit;
            %SS=sum(yres.^2);
             SS=sum(abs(yres));
            SSx=[SSx SS];
            %SSx=sort(SSx,2,'descend');
            %SST=(length(y1)-1)*var(y1);
            % rsq=1-SS/SST
        end
        SSy=[SSy SSx];
    end
    %SSy=sort(SSy,2,'descend');
    
    %% final scores
    %SSfx=SSy(1)+SSy(2);
    mydata{o}=SSy;
    %%
    number=o
    %fx=[fx SSfx];
end
save('mydata.mat','mydata');
save('scores.mat','fx');
save('labelsx.mat','labels');