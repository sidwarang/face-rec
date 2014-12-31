function [outputimage]=Recognition(T,m1, Eigenfaces, ProjectedImages, imageno);
MeanInputImage=[];
[fname pname]=uigetfile('*.jpg','Select the input image for recognition');
InputImage=imread(fname);
InputImage=rgb2gray(InputImage);
InputImage=imresize(InputImage,[200 180],'bilinear');%resizing of input image for preprocessing
[m n]=size(InputImage);


Imagevector=reshape(InputImage',m*n,1);%to get elements along rows
MeanInputImage=double(Imagevector)-m1;
ProjectInputImage=Eigenfaces'*MeanInputImage;% weights image with respect to our eigenfaces
%Calculating euclidean distance of input image
Euclideandistance=[];
for i=1:T
    temp=ProjectedImages(:,i)-ProjectInputImage;
    Euclideandistance=[Euclideandistance temp];
end

% normalize to find minimum Euclidean distance
tem=[];
for i=1:size(Euclideandistance,2)
    k=Euclideandistance(:,i);
    tem(i)=sqrt(sum(k.^2));
end
% Check whether image is known face or not

[MinEuclid, index]=min(tem);
if(MinEuclid<0.8e008)
if(MinEuclid<0.35e008)
    outputimage=(strcat(int2str(index),'.jpg'));

    y = figure; 
	map2= imread(outputimage);
	map2=rgb2gray(map2);
	map2=imresize(map2,[200 180],'bilinear');
    subplot(1,2,1), subimage(InputImage)
	subplot(1,2,2), subimage(map2)
	tb = uicontrol('Parent',y,'Style','text',...
        'Position',[70 20 420 18],...
        'String','Equivalent Image In Database Found, Press any key to continue','fontsize',10,...
                         'fontweight','bold');
	tts = uicontrol('Parent',y,'Style','text',...
        'Position',[125 75 80 18],...
        'String','Test Image','fontsize',10,...
                         'fontweight','bold');
	ttr = uicontrol('Parent',y,'Style','text',...
        'Position',[365 75 100 18],...
        'String','Training Image','fontsize',10,...
                         'fontweight','bold');
	
	w = waitforbuttonpress;
if w == 0
    close(y);
	clc
else
    close(y);
	clc
end
	

	

else
	 h = msgbox('Equivalent Image Not Found in Database. . .','Error','error');
    outputimage=0;
	uiwait(h)
end
else
    h = msgbox('Equivalent Image Not Found in Database. . .','Error','error');
    outputimage=0;
	uiwait(h)
end

end
