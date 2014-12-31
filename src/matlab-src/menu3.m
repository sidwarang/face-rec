function [] = GUI_40()


S.fh = figure('units','pixels',...
              'position',[350 300 620 400],...
              'menubar','none',...
              'name','MAIN MENU',...              
              'resize','off',...
              'numbertitle','off'); 	
  
S.ax = axes('units','pixels',...
            'position',[0 0 620 400],...
            'xtick',[],'ytick',[]);
		
			
S.IMG = imread('back10.jpg');  
S.IH = image(S.IMG);  
S.tte = uicontrol('Parent',S.fh,'Style','text',...
        'Position',[100 100 400 40],...
        'String','Training Complete!','fontsize',20,...
                         'fontweight','bold');

S.BTP = {[566 352 30 48];[434 352 110 48];...
         [297 352 112 48];[190 352 86 48];...
         [27 352 140 48]};
S.BST = {'Quit';'Delete Database';'Update Database';'Recognition';'Calculate Eigenfaces'};  % And labels.   


for ii = 1:5
    F = getframe(S.ax,S.BTP{ii});   
    S.pb(ii) = uicontrol('style','push',...
                         'units','pix',...
                         'position',S.BTP{ii},...
                         'string',S.BST{ii},...
                         'fontsize',10,...
                         'fontweight','bold');
    set(S.pb(ii),'cdata',F.cdata,...
        'foregroundc',[1 1 1])
		
end

set(S.pb(1),'callback',{@pb1_call})
set(S.pb(2),'callback',{@pb2_call})
set(S.pb(3),'callback',{@pb3_call})
set(S.pb(4),'callback',{@pb4_call})
set(S.pb(5),'callback',{@pb5_call})

    function [] = pb5_call(varargin)
        
		
		S.pa = uipanel('Title','','FontSize',12,...
             'Position',[.1 .3 .80 .30]);
		S.tx = uicontrol('Parent',S.pa,'Style','text','Position',[40 40 400 35],'string','Enter Number Of Training Images',...
							'fontsize',10,'fontweight','bold');
		S.ed = uicontrol('Parent',S.pa,...
				 'style','edit',...
                 'units','pixels',...
                 'position',[205 10 28 28],...
                 'fontsize',14,...
                 'string','1');
	S.pb = uicontrol('Parent',S.pa,...
				 'style','push',...
                 'units','pixels',...
                 'position',[235 8 40 32],...
                 'fonts',14,...
                 'str','Ok',...
                 'callback',{@pb_call,S});
				 
				 function [] = pb_call(varargin)
				 S = varargin{3};
				 x=get(S.ed,'string')
				 
				
			try
				imageno= str2num(x);
			catch err
				menu2
				clc
			
			end
			if(imageno<1||imageno>20)
				
				warndlg('You Need To Enter a number between 0 and 20','Error');
				clc
				
			else
				[T, m1, Eigenfaces, ProjectedImages, imageno]=Eigenface_calculation2(imageno);
				close(S.fh);
				save Eigenface.mat;
			end
		end	
		
	end

    function [] = pb4_call(varargin)
            close(S.fh)
		try
			mydata=load('Eigenface.mat');
			T=mydata.T;
			m1=mydata.m1;
			Eigenfaces=mydata.Eigenfaces;
			ProjectedImages=mydata.ProjectedImages;
			imageno=mydata.imageno;
		catch err
			clc
			w = warndlg('You Need To First Create A Database Using "Calculate Eigenfaces" From The Main Menu','Warning!');
			uiwait(w)
			menu2
		end
			outputimage=Recognition(T, m1, Eigenfaces, ProjectedImages, imageno);
			menu2
        
    end

    function [] = pb3_call(varargin)
   
		mydata=load('Eigenface.mat');
		try
			T=mydata.T;
			m1=mydata.m1;
			Eigenfaces=mydata.Eigenfaces;
			ProjectedImages=mydata.ProjectedImages;
			imageno=mydata.imageno;
		catch err
			clc
			w = warndlg('You Need To First Create A Database Using "Calculate Eigenfaces" From The Main Menu','Warning!');
			uiwait(w)
			menu2
		end
			global imageno;
			imageno=imageno+1;
			[filename pathname]=uigetfile('*.jpg', 'Select image for input');
			movefile(filename,strcat(int2str(imageno),'.jpg'));
			[T, m1, Eigenfaces, ProjectedImages, imageno]=Eigenface_calculation2(imageno);
			save Eigenface.mat;
			
    end
	
	 function [] = pb2_call(varargin)
  
		g=questdlg('Do you really want to delete the whole database?',...
						'Attention!',...
						'Yes','No','No');
			switch g
				case 'Yes'
					myFile = java.io.File('Eigenface.mat');
					flen = length(myFile);
					if(flen<1)
						warndlg('No Database To Delete!','Error');
					else
						itr = flen; 
						vblock = 10000;
						h=waitbar(0,'Please wait..'); 
						k = 1;
						for i=1:itr  
							if(k*vblock==i) 
								waitbar(i/itr);
								k = k+1;
							end   
						end
						close(h)
						delete Eigenface.mat;
					end
				case 'No'
					h = msgbox('You have decided not to delete the database','Success','help');
					uiwait(h);
				end
			
			end
	
	 function [] = pb1_call(varargin)
		
		g=questdlg('Are you sure you want to quit',...
						'Confirmation',...
						'Yes','No','No');
		switch g
		case 'Yes'	
   			close(S.fh)
			clc
		case 'No'
		end
    end

    function [] = colorbal()
             
        for jj = 1:5
            set(S.pb(jj),'visible','off')
            F = getframe(S.ax,S.BTP{jj});
            set(S.pb(jj),'cdata',F.cdata,'visible','on')
        end
    end
end


