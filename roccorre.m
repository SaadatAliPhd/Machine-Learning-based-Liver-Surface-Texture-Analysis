%% Using SVM for classification:
Af2=[];
surface2=[];

load('mydata.mat');
load('scores.mat');
load('labelsx.mat');
%%
for i=1:68
   data1=cellfun(@min,mydata);
   data1(2,:)=cellfun(@max,mydata);
   %data1(3,:)=cellfun(@mean,mydata);
   %data1(4,:)=cellfun(@std,mydata);

testimg= data1(:,i);
if data1(:,i) == testimg;
    data1(:,i)=[];
    labels1=labels;
    labels1(:,i)=[];
end

labels12=labels1' ;
data=data1';
xtest=testimg';
svm=svmtrain(data,labels12,'kernel_function','linear','boxconstraint',50);
surface=svmclassify(svm,xtest);
surface2=[surface2 surface];

Xnew=xtest;
shift = svm.ScaleData.shift;
scale = svm.ScaleData.scaleFactor;
Xnew = bsxfun(@plus,Xnew,shift);
Xnew = bsxfun(@times,Xnew,scale);
sv = svm.SupportVectors;
alphaHat = svm.Alpha;
bias = svm.Bias;
kfun = svm.KernelFunction;
kfunargs = svm.KernelFunctionArgs;
f = kfun(sv,Xnew,kfunargs{:})'*alphaHat(:) + bias;
f=-f;
Af2 = [Af2 f];
end
XVZ2=labels;
labels2=XVZ2';
[X,Y,T,AUC]=perfcurve(labels2,Af2,1);
plot(X,Y,'r')
hold on 
xlabel('FPR') 
ylabel('TPR') 
title('ROC for classification')