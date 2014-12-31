function [T,m1, Eigenfaces, ProjectedImages, imageno]=Eigenface_calculation2(imageno);% we need to make it a function to increase modularity of our program
T=imageno;
n=1;
aftermean=[];
I=[];

gs = figure('name','Image Pre-Processing :');
tt = uicontrol('Parent',gs,'Style','text',...
        'Position',[60 8 420 35],...
        'String','Input images resized and converted to grayscale','fontsize',10,...
                         'fontweight','bold');
for i=1:2
imshow('Frame1.png');
pause(0.1);
imshow('Frame2.png');
pause(0.1);
imshow('Frame3.png');
pause(0.1);
imshow('Frame4.png');
pause(0.1);
imshow('Frame5.png');
pause(0.1);
imshow('Frame6.png');
pause(0.1);
end

k = 1;
for i=1:T
    imagee=strcat(int2str(i),'.jpg');
 
h = statusbar('Processing %d of %d (%.1f%%)...',i,T,100*i/T);

    eval('imagg=imread(imagee);');
    subplot(ceil(sqrt(T)),ceil(sqrt(T)),i)
    imagg=rgb2gray(imagg);
    imagg=imresize(imagg,[200,180],'bilinear');
    [m n]=size(imagg)
    imshow(imagg)
    temp=reshape(imagg',m*n,1);
    I=[I temp]
end

 
w = waitforbuttonpress;
if w == 0
    close(gs);
else
    close(gs);
end
m1=mean(I,2);
 ima=reshape(m1',n,m);
     ima=ima';
     mf = figure('name','Mean Images :');
	 ttm = uicontrol('Parent',mf,'Style','text',...
        'Position',[60 8 420 35],...
        'String','Images are Normalized and Mean face is calculated ','fontsize',10,...
                         'fontweight','bold');
	
	
	 
for i=1:2
imshow('Frame1.png');
pause(0.1);
imshow('Frame2.png');
pause(0.1);
imshow('Frame3.png');
pause(0.1);
imshow('Frame4.png');
pause(0.1);
imshow('Frame5.png');
pause(0.1);
imshow('Frame6.png');
pause(0.1);
end

for i=1:T
l = statusbar('Processing %d of %d (%.1f%%)...',i,T,100*i/T);
    temp=double(I(:,i))
    I1(:,i)=(temp-m1);% normalizing
end
for i=1:T
    subplot(ceil(sqrt(T)),ceil(sqrt(T)),i);
    imagg1=reshape(I1(:,i),n,m);
    imagg1=imagg1';
    [m n]=size(imagg1);
    imshow(imagg1);% display mean images
end
a1=[];
for i=1:T
    te=double(I1(:,i));
    a1=[a1,te];
end
a=a1';
covv=a*a';

[eigenvec eigenvalue]=eig(covv);
d=eig(covv);
sorteigen=[];
eigval=[];
for i=1:size(eigenvec,2);
    if(d(i)>(0.5e+008))
        sorteigen=[sorteigen, eigenvec(:,i)];
        eigval=[eigval, eigenvalue(i,i)];
    end;
end;
Eigenfaces=[];
Eigenfaces=a1*sorteigen;% matrix of Eigenfaces

for i=1:size(sorteigen,2)
    k=sorteigen(:,i);
    tem=sqrt(sum(k.^2));
    sorteigen(:,i)=sorteigen(:,i)./tem;
end
Eigenfaces=a1*sorteigen; 
%uiwait(3)
w = waitforbuttonpress;
if w == 0
    close(mf);
else
    close(mf);
end

ef = figure('name','Eigen Faces :');
	 tte = uicontrol('Parent',ef,'Style','text',...
        'Position',[60 8 420 35],...
        'String','Eigenfaces that are stored in the database for recognition process','fontsize',10,...
                         'fontweight','bold');
E=size(Eigenfaces,2);
for i=1:size(Eigenfaces,2)
o = statusbar('Processing %d of %d (%.1f%%)...',i,E,100*i/E);
    ima=reshape(Eigenfaces(:,i)',n,m);
    ima=ima';
      subplot(ceil(sqrt(T)),ceil(sqrt(T)),i)
     imshow(ima);
end

ProjectedImages=[];
for i = 1 : T
    temp = Eigenfaces'*a1(:,i); % Projection of centered images into facespace
    ProjectedImages = [ProjectedImages temp]; 
    end
	
	w = waitforbuttonpress;
	if w == 0
		close(ef);
	else
		close(ef);
	end
	
	clc
	menu3
	
end