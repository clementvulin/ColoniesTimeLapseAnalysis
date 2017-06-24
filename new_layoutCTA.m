function new_layoutCTA
%% initialize
   % Add the UI components
   Layoutcomponents;
   
   %initialise variables
   p=struct();
   initialize_gui;
   
   % Make figure visible after adding components
   hs.fig.Visible = 'on';
         
    function Layoutcomponents
        % new figure
        hs.f = figure('units','norm','Position',[0.2 0.2 0.8 0.8], 'KeyPressFcn', @WindowKeyPressFcn,...
            'WindowScrollWheelFcn', @ScrollWheelFcn, 'MenuBar', 'none', 'NumberTitle', 'off','HandleVisibility','on'); 
        
        % cutting main units
        hs.main=uix.VBoxFlex('Parent', hs.f); %#1 sep
        hs.TopLayer=uix.HBox('Parent',hs.main); %#2 sep
        hs.BottomLayer=uix.HBox('Parent',hs.main); %#2 sep
        hs.LeftPan=uix.VBox('Parent', hs.BottomLayer,'Padding', 30); %#3 sep

        % smaller cuts
        hs.NavigatePics=uix.HBox('Parent', hs.LeftPan); %#4 sep

        % add contents
            
            %in Toplayer (2)
            hs.LoadSave=uix.VBox('Parent', hs.TopLayer);
                hs.LoadButton=uicontrol('Parent', hs.LoadSave, 'String', 'Load / Open', 'CallBack', @LoadButton_callback,'FontSize',15, 'BackgroundColor', [0 0.8 0]); 
                hs.LoadSaveAS=uix.HBox('Parent', hs.LoadSave);
                hs.SaveAsButton=uicontrol('Parent', hs.LoadSaveAS, 'String', 'Save folder', 'CallBack', @SaveAsButton_callback,'FontSize',15, 'BackgroundColor', [0 0.8 0]);
                hs.LoadData=uicontrol('Parent', hs.LoadSaveAS, 'String', 'Load analysis', 'CallBack', @LoadData_callback,'FontSize',15, 'BackgroundColor', [0 0.8 0]);
                hs.SaveAsCSV=uicontrol('Parent', hs.LoadSaveAS, 'String', 'CSV Export', 'CallBack', @Export_callback,'FontSize',15, 'BackgroundColor', [0 0.8 0]);
            hs.UserMessage=uix.VBox('Parent', hs.TopLayer);
            hs.UserMess=uicontrol('Style', 'text','Parent',hs.UserMessage, 'String', 'starting','FontSize',12);
            hs.UserMess2=uix.HBoxFlex('Parent',hs.UserMessage);
                hs.UserMessDir=uicontrol('Style', 'text','Parent',hs.UserMess2, 'String', 'directory','FontSize',12);
                hs.UserMessFrame=uicontrol('Style', 'text','Parent',hs.UserMess2, 'String', 'Frame number','FontSize',12);
                hs.UserMessNumCol=uicontrol('Style', 'text','Parent',hs.UserMess2, 'String', 'number of colonies','FontSize',12);
            hs.Progress1=axes('Parent', hs.UserMessage, 'Color', [0.8 0.9 0.8], 'Visible', 'off', 'Xcolor', 'none','Ycolor', 'none','Position', [0 0 1 1]);
            hs.Progress2=axes('Parent', hs.UserMessage, 'Color', [0.8 0.9 0.8], 'Visible', 'off', 'Xcolor', 'none','Ycolor', 'none','Position', [0 0 1 1]);


            % in left Pan (2)
                % in navigate (3)
                hs.LeftButton=uicontrol('Parent', hs.NavigatePics, 'String', 'Previous (<-)','Callback', @previous_Callback,'FontSize',15,'BackgroundColor', [0 0.8 0]);
                hs.SetFrameButton=uicontrol('Parent', hs.NavigatePics, 'String', 'Set Frame','Callback', @set_frame_callback,'FontSize',15,'BackgroundColor', [0 0.8 0]);
                hs.RightButton=uicontrol('Parent', hs.NavigatePics, 'String', 'Next (->)', 'Callback', @next_Callback,'FontSize',15,'BackgroundColor', [0 0.8 0]);
                hs.NavigatePics.Widths=[-1,-1,-1];
                hs.RadAppear=uicontrol('Parent',hs.LeftPan, 'String', 'Change radius appearance', 'Callback', @RadAppear_Callback,'FontSize',15,'BackgroundColor', [0 0.8 0]);

                %tabs
                hs.Tabs=uitabgroup('Parent', hs.LeftPan); %%%%%%%%%%%%%%%%%
                hs.AutoDetectTab = uitab('Parent', hs.Tabs, 'Title', 'Detect', 'ButtonDownFcn', @AutoDetectTab_callback);
                hs.TimeLapseTab = uitab('Parent', hs.Tabs, 'Title', 'Timelapse');
                hs.DataSizeTab = uitab('Parent', hs.Tabs, 'Title', 'Size data');
                hs.DataTimeTab = uitab('Parent', hs.Tabs, 'Title', 'Time data');

            % in right Pan
            hs.figpan=uipanel('Parent', hs.BottomLayer); %in order to be able to use subplot, creating a panel for the figure
            hs.fig=axes('Parent', hs.figpan, 'Color', [0.8 0.9 0.8], 'Visible', 'off', 'Xcolor', 'none','Ycolor', 'none','Position', [0 0 1 1]); %creating axes in it
            
            % in tabs
                %Detect Tab
                hs.DetectTabBox=uix.VBox('Parent', hs.AutoDetectTab,'Padding', 20);
                hs.DefineParamButton=uicontrol('Parent',hs.DetectTabBox,'FontSize',15, 'String', 'Enter parameters manually', 'Callback', @DefineParamButton_Callback,'BackgroundColor', [0 0.8 0]); %will open a pop up for user input
                hs.FindCol=uix.HBox('Parent',hs.DetectTabBox);
                    hs.FindColonies=uicontrol('Parent',hs.FindCol, 'String', 'Find here', 'Callback', @FindColonies_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                    hs.FindColoniesAll=uicontrol('Parent',hs.FindCol, 'String', 'All frames','Callback', @FindColoniesAll_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]); %timer is wrong
                hs.Void=uix.Empty('Parent', hs.DetectTabBox);
                hs.ManualCorrectStrg=uicontrol('Style', 'text','Parent',hs.DetectTabBox, 'String', {'';'Manual correction'},'FontSize',20);
                hs.AddRmv=uix.HBox('Parent',hs.DetectTabBox);
                    hs.AddCol=uicontrol('Parent',hs.AddRmv, 'String', 'Add New (C)', 'Callback', @Addcol_callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                    hs.RmvCol=uicontrol('Parent',hs.AddRmv, 'String', 'Remove (R)', 'Callback', @RemoveCol_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                hs.Clean=uix.HBox('Parent',hs.DetectTabBox);
                    hs.CleanZone=uicontrol('Parent',hs.Clean, 'String', 'Clear zone (Z)', 'Callback', @ClearZone_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                    hs.CleanOutZone=uicontrol('Parent',hs.Clean, 'String', 'Clear outside zone', 'Callback', @ClearOutZone_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                hs.UndoButton=uicontrol('Parent',hs.DetectTabBox, 'String', 'Undo (backslash)', 'Callback', @Undo_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                hs.Void3=uix.Empty('Parent', hs.DetectTabBox);
                
                %Timelapse tab
                hs.TimelapseTabBox=uix.VBox('Parent', hs.TimeLapseTab,'Padding', 20);
                hs.SetRefFrame=uicontrol('Parent',hs.TimelapseTabBox, 'String', 'set reference frame', 'Callback', @SetRefFrame_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                hs.OneTimePoint=uicontrol('Parent',hs.TimelapseTabBox, 'String', 'process for one time point', 'Callback', @OneTimePoint_Callback,'FontSize',15','BackgroundColor', [0 0.5 0]);
                hs.EstimateTime=uicontrol('Parent',hs.TimelapseTabBox, 'String', 'estimate processing time', 'Callback', @EstimateTime_Callback,'FontSize',15);
                hs.DefineSubset=uicontrol('Parent',hs.TimelapseTabBox, 'String', 'define subset of analysis', 'Callback', @DefineSubset_Callback,'FontSize',15);
                
                hs.FindTimeCol=uicontrol('Parent',hs.TimelapseTabBox, 'String', 'process for all', 'Callback', @FindTimeCol_Callback,'FontSize',15,'BackgroundColor', [0 0.5 0]);
                hs.Void2=uix.Empty('Parent', hs.TimelapseTabBox);
                
        % proportions of buttons
        hs.TopLayer.Widths=[400, -3];
        hs.main.Heights=[-1, -10];
        hs.BottomLayer.Widths=[-1, -3];
        hs.LeftPan.Heights=[80,40,-8];
        hs.TimelapseTabBox.Heights=[-1 -1 -1 -1 -1 -4];
        hs.DetectTabBox.Heights=[-1 -1 -1 -1 -1 -1 -1 -4];
    end
    function initialize_gui
        
        %image analysis
        p.minRadN = 20;
        p.maxRadN = 60;
        p.sensitivityN = 0.82;
        p.sauvolarange=[100 100];% this is used for autothresholding of image
        p.color=2;
        
        %counts and radii
        p.counts=cell(4,4);
        p.centers = [];
        p.radii = [];
        p.centersBack = [];
        p.radiiBack = [];
        
        %file and folder handling
        p.dir='/Users/vulincle/Desktop/test to delete';
        p.i = 1;
        p.l = []; %will contain a list of files with filename
        p.filextension='.JPG';
        
        p.apR=1; %appearing radius for cells
        
        %local empty variables will contain data
        p.rgb=[];
        p.im=[];
        p.RadMean=[];
        p.RadMean2=[];
        p.Rad=[];
        
        %for timelapse analysis
        p.Zonesize=1.2;
        p.percsizeMean=0.01;% total image area to define the zero
        p.Tresh=3; %Threshold under which there is no colony (in fold of min)
        p.Numtresh=5;%number of values needed to call threshold reached
        p.tres=128; % # of grid points for theta coordinate (change to needed binning)
        p.showPlot=0; %if true, shows the graphs of analysis in userwindow
        p.colList=[];
        p.timeList=[];
        p.focalframe=[];
        
        %image handling
        p.panButton=0;
        p.zoomlvl=1;
        p.overlayIMGstatus=0;
        p.dirOverlay=[];
        
        hs.UserMess.String='started'; %user message to be printed
        
    end %initiate all parameters
     %user message to be printed
%% load, save, refresh and data handling
    function LoadButton_callback (~, ~)
        %This function executes when "Load/Open" button is pressed. It asks
        %user to find a directory and calls the function loadDir
        
        %ask user for dir
            p.dir=uigetdir(p.dir,'please select the directory with the files to correct');
            p.dirS=p.dir; %the file saving is initialy done on teh same folder
            if p.dir==0; return; end; %user cancelled
            if length(p.dir)>30
                hs.UserMessDir.String = p.dir(end-30:end);
            else
                hs.UserMessDir.String = p.dir;
            end
            [~]=chngDir;
            refresh(0);
    end
    function errorloading=chngDir 
        %will return 1 if loading was correct. Loads a list of files in a
        %directory. Looks if previous mat files were already save, and
        %loads them accordingly.
        
        %getting file list
        errorloading=1;
        p.l=dir([p.dir, '/', '*',p.filextension]); %lists all files with filextension
        for h=1:size(p.l,1)
            keep(h)=(p.l(h).name(1)~='.'); %#ok<AGROW> %removes all directories and parents (files which start with '.')
        end
        p.l=p.l(keep);
        
        if isempty(p.l)
            errordlg(['Did not find any ' p.filextension ' images in folder' p.dir...
                '. If you are working with other images types, please consider editing hs.filextension.'],'Error');
            errorloading=0;
            return
        end
        
        %loading previously saved data if existant
        if ~isempty(dir([p.dir, '/', '*','all','*'])); %found a file countaing "all"
            try
                files=dir([p.dir, '/', '*','all','*']);
                fileAll=load([p.dir,'/',files(end).name]); %this contains, counts, i, Rad, RadMean, dir, minRad, maxRad and sensitivity
                p.counts=fileAll.counts;
                p.oldi=fileAll.i;
                p.Rad=fileAll.Rad;
                p.RadMean=fileAll.RadMean;
                p.minRad=fileAll.minRad;
                p.maxRad=fileAll.maxRad;
                p.sensitivity=fileAll.sensitivity;
            catch
                disp('did not find all files');
                p.counts=cell(length(p.l),2); %creating empty cell with the nb of pictures
                errorloading=0;
                p.i=1;
            end
            p.UserMess='found previous analysis, loaded it into Matlab';
        elseif exist ([p.dir '/sidesave.mat'], 'file')&& exist ([p.dir '/stoped_at.mat'], 'file') %check for an older saved analysis
            p.countsload=load([p.dir '/sidesave.mat']); %this file was produced when saving
            p.oldiload=load([p.dir '/stoped_at.mat']); %this file was produced when saving
            p.counts=p.countsload.counts; %because load gives a struct object
            p.oldi=p.oldiload.i;
            set(p.UserMess, 'String', 'found previous analysis, loaded it into Matlab');
        elseif exist([p.dir '/counts.mat'], 'file')
            p.countsload=load ([p.dir '/counts.mat']); %this file was produced when analysing
            p.counts=p.countsload.counts; %because load gives a struct object
            p.oldi=1; %start from the start!
        else %nothing found
            p.counts=cell(length(p.l),2); %creating empty cell with the nb of pictures
            errorloading=0;
            p.i=1;
        end
    end
    function refresh(z)
        %this function could be optimized by updating the image only if it has
        %changed... need to separate graph and image for this
        if isempty(p.l); return; end %the list doesn't exist        
        
        % if z=1, zoom is kept
        p.rgb = imread([p.dir, '/',p.l(p.i).name]); %loading pic
        
        if p.overlayIMGstatus==1
            if isempty(p.dirOverlay) %first time for the tick
                p.dirOverlay=uigetdir(p.dir,'please select the directory with the files to overlay');
                p.lOverlay=dir([p.dirOverlay, '/', '*',p.filextension]); %lists all files with filextension
            end
            p.rgbOverlay = imread([p.dirOverlay, '/',p.lOverlay(p.i).name]); %loading pic
        end
        
        
        hold off;
        xlim=[];ylim=[]; %note that this must come before calling axes 5 lines below.
        %remembering zoom
        if ~isempty(p.im) && z==1
            ylim = hs.fig.YLim;
            xlim = hs.fig.XLim;
        end
        delete(hs.fig); %otherwise staking up images, and memory leak
        hs.fig=axes('Parent', hs.figpan, 'Color', [0.9 0.9 0.8], 'Position', [0 0 1 1]); %creating axes
        
        % update image
        p.im=imshow(p.rgb,'InitialMagnification', 40); 
        
        if ~isempty(p.counts{p.i,1})
            viscircles(p.counts{p.i,1},p.counts{p.i,2}*p.apR,'Color','b'); %ploting with small diameter to enhance visualisation
        end
        
        p.NumCells=num2str(size(p.counts{p.i,2},1));
        
        % make sure the centers and radii variables are up to date (e.g. for start up)
        p.centers=p.counts{p.i,1};
        p.radii=p.counts{p.i,2}; %splitting in two variables
        
        if p.overlayIMGstatus==1
            hold on;
            p.imOverlay=imshow(p.rgbOverlay,'InitialMagnification', 25);
            set(p.imOverlay,'AlphaData',0.5);
        end
        
        %resetting the previous zoom
        if ~isempty(xlim) && z==1
            hs.fig.XLim=xlim;
            hs.fig.YLim=ylim; 
            %setting Ylim causes problems...
        end
        
        %updating user messages
        hs.UserMessFrame.String=['frame ',num2str(p.i), ' of ', num2str(length(p.l))]; 
        hs.UserMessNumCol.String= [num2str(length(p.radii)) ' colonies on image']; drawnow
        saveall(p.dirS);
    end
    function SaveAsButton_callback(~, ~)
        p.dirS=uigetdir(p.dir,'please select the directory to save the analysis');
        saveall(p.dirS);
    end
    function Export_callback(~, ~)
        % saving data as CSV
        
        % first, some important variables
        names={'min Radius';'max Radius';'sensitivity';'sauvolarange';'color channel';'dir';...
            'current frame';'file list'; 'file extension'; 'timelapse focus size';...
            'percentage noise level (Tlapse)'; 'Noise Treshold (Tlapse)'; 'Threshold sensitivity (Tlapse)';...
            'Radial Resolution'; 'colonies List (Tl)'; 'times List (Tl)'; 'focal frame (Tl)'};
        
        fileList=''; for i=1:length(p.l); fileList=strcat(fileList,' , ',p.l(i).name);end
        values= {p.minRadN;p.maxRadN; p.sensitivityN; p.sauvolarange; p.color; p.dir;...
            p.i; fileList; p.filextension; p.Zonesize; ...
            p.percsizeMean; p.Tresh; p.Numtresh; ...
            p.tres; p.colList; p.timeList; p.focalframe};
        svtbl=table(values, 'Rownames', names);
        writetable(svtbl,[p.dirS,'/variables.csv'], 'WriteRowNames', 1)

        % then saving the colonies centers and radii
        titles={};
        a=max(cellfun('length', p.counts)); %size of the longest vector
        values=nan(3*3,a(1)); %creating an empty variable
        for i=1:length(p.l)
            titles {end+1,1}= ['X' num2str(i)];
            titles {end+1,1}= ['Y' num2str(i)];
            titles {end+1,1}= ['R' num2str(i)];
            values((i-1)*3+1:(i-1)*3+2,1:length(p.counts{i}))=p.counts{i,1}';
            values((i-1)*3+3,1:length(p.counts{i}))=p.counts{i,2}';
        end
        
        a=table(values, 'Rownames', titles);
        writetable(a,[p.dirS,'/coloniesCenters.csv'], 'WriteRowNames', 1)
        
        % then saving the result of a timelapse analysis
        if ~isempty(p.RadMean)
            writetable(table(p.RadMean), [p.dirS,'/Rad_vs_time.csv'])
        end
        
        msgbox({'Data saved as CSV.'; 'Note that the recuperation from CSV files is not available'}, 'Warning', 'Warn')
    end
%     function LoadData_callback(~, ~)
%         
%     end
    function saveall(dirS) %needs some updating
        %create internal variables to be saved
        counts=p.counts; i=p.i; Rad=p.Rad; RadMean=p.RadMean;%#ok<NASGU>
        minRad=p.minRadN; maxRad=p.maxRadN; sensitivity=p.sensitivityN;dir=dirS; %#ok<NASGU>
        
        %Save separately
        save([dirS '/sidesave.mat'],'counts'); save([dirS '/stoped_at.mat'],'i'); save([dirS '/Rad.mat'],'Rad'); save([dirS '/RadMean.mat'],'RadMean')
            % also with date to avoid too much loss in case of crash
        save([dirS '/' date 'sidesave.mat'],'counts'); save([dirS '/' date 'stoped_at.mat'],'i'); save([dirS '/' date 'Rad.mat'],'Rad'); 
        
        % save whole file
        del=strfind(dirS,'/'); %looking for delimiter in folder name
        if isempty(del)
            del=strfind(dirS,'\'); %because windows and mac have different delimiters
        end
        save([dirS dirS(del(end-1):del(end)-1) '_all.mat'], 'counts','i','dir', 'minRad','maxRad', 'sensitivity','RadMean','Rad') %consider replacing by save(p)
        save([dirS dirS(del(end-1):del(end)-1) date '_all.mat'], 'counts','i','dir', 'minRad','maxRad', 'sensitivity','RadMean','Rad')
    end
    
%% navigate and view images
    function next_Callback(~,~)
        % moving to next frame
        if p.i<length(p.l)
            set_frame(p.i+1);
        else
            errordlg('No image after this one','Error');
        end
    end % --- Executes on button press RightButton.
    function previous_Callback(~,~)
        % moving to next frame
        if p.i>1
            set_frame(p.i-1);
        else
            errordlg('No image before this one','Error');
        end
    end % --- Executes on button press LeftButton.
    function set_frame_callback(~,~)
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist        
        
        defaultans={num2str(p.i)};
        i=inputdlg('Set frame number:','Set frame',1,defaultans);
        if isempty(i); return; end; %user cancelled
        i=str2double(i{1,1}); %inputdlg returns a cell
        if i>0 && i<length(p.l)+1 %checking it is inside range
            set_frame(i);
        else
            errordlg('Input number outside of range','Error');
        end
    end
    function set_frame(i)
        p.i=i; % change frame
        refresh(0);
    end
    function RadAppear_Callback(~,~)
        % this allows the user to change appearing radius on the image.
        % Real measures are not affected, but user sees a different radius.
        % To be used mostl when too many objects are on the images.
        defaultans={num2str(p.apR)};
        i=inputdlg('Change appearing radius:','',1,defaultans);
        if isempty(i); return; end; %user cancelled
        i=str2double(i{1,1}); %inputdlg returns a cell
        if i>0 %checking it is inside range
            p.apR=i;
            refresh(1)
        else
            errordlg('Appearing radius must be positive','Error');
        end
    end

%% manually modify images
    function Addcol_callback(~,~)
        % user clicks on current image to delimit a circle
        
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
        
        p.centersBack=p.centers; %saving for undo purpose
        p.radiiBack=p.radii; %saving for undo purpose
        
        % instructions to users
        hs.UserMess.String='click on image for new cells, then press enter';drawnow
        
        %get colony center
        [X1, Y1] = ginput(1);
        hold on;
        h = plot(X1, Y1, 'r');
        %get radius from a sencon click
        set(gcf, 'WindowButtonMotionFcn', {@mousemove, h, [X1 Y1]}); %to have an updating circle
        k = waitforbuttonpress; %#ok<NASGU>
        set(gcf, 'WindowButtonMotionFcn', ''); %unlock the graph
        r = norm([h.XData(1) - X1 h.YData(2) - Y1]); %circle coordinates are in h object
        
        %add cells
        if size(p.centers,1)>=1 %add to existing list
            a=[p.centers(:,1);X1] ;%to check
            b=[p.centers(:,2);Y1] ;%to check
            p.centers=[a b];
            p.radii=[p.radii;r];
        else %or to empty matrix
            p.centers=[X1,Y1];
            p.radii=r;
        end
        
        % Update handles structure
        p.counts{p.i,1}=p.centers;
        p.counts{p.i,2}=p.radii;
        %refresh Graph
        refresh(1);
    end
    function ClearZone_Callback(~,~)
        cleanzone(0)
    end % --- Executes on button press in ClearZone.
    function ClearOutZone_Callback(~,~)
        cleanzone(1)
    end % --- Executes on button press in ClearRecZone.
    function cleanzone(InOut)
        % When one of the clean zoe buttons is pressed, 
        % user delimitates a zone, all cells inside (in==1) or outside
        %(in==0) the zone are deleted
        
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
        
        p.centersBack=p.centers; %saving for undo purpose
        p.radiiBack=p.radii; %saving for undo purpose
        
        p.UserMess='choose zone to remove cells';
        [~,xi,yi]=roipoly(); %user inputs a polygon
        
        %remove for current frame
        in=inpolygon(p.centers(:,1),p.centers(:,2),xi,yi); %all cells in polygon
        p.centers=p.centers(in==InOut,:); %remove from centers
        p.radii=p.radii(in==InOut); %remove from radii
        % Update handles structure
        p.counts{p.i,1}=p.centers;
        p.counts{p.i,2}=p.radii;
        
        refresh(1);
    end
    function RemoveCol_Callback(~,~) % --- Executes on button press in RemoveCol.
        %user clicks on an existing circle, and the function removes it
        %from the list
        
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
        
        p.centersBack=p.centers; %saving for undo purpose
        p.radiiBack=p.radii; %saving for undo purpose
        
        % instructions to users
        p.UserMess='click on one colony to remove';
        
        %get position
        [X1, Y1] = ginput(1);
        
        %calculate distance to click
        dist=zeros(1,length(p.centers(:,1)));
        for i=1:length(p.centers(:,1))
            dist(i) = norm([p.centers(i,1) - X1 p.centers(i,2) - Y1]);
        end
        dist=dist';
        in=(p.radii>dist); %clicked inside
        p.centers=p.centers(in==0,:); %remove from centers
        p.radii=p.radii(in==0); %remove from radii
        
        % Update handles structure
        p.counts{p.i,1}=p.centers;
        p.counts{p.i,2}=p.radii;
        
        refresh(1);
    end

%% graphical interface functions
    function mousemove(~, ~, h, bp)
        %from http://stackoverflow.com/questions/13840777/select-a-roi-circle-and-square-in-matlab-in-order-to-aply-a-filter
        cp = get(gca, 'CurrentPoint');
        r = norm([cp(1,1) - bp(1) cp(1,2) - bp(2)]);
        theta = 0:.1:2*pi;
        xc = r*cos(theta)+bp(1);
        yc = r*sin(theta)+bp(2);
        set(h, 'XData', xc);
        set(h, 'YData', yc);
    end % --- This function to refresh upon mouse move
    function WindowKeyPressFcn(~,eventdata) % --- Executes on key press with focus on figure1 or any of its controls.
        switch eventdata.Key
            case 'c'
                Addcol_callback
            case 't'
                ClearZone_Callback
            case'o'
                LoadButton_callback
            case 'leftarrow'
                previous_Callback
            case 'backspace'
                Undo_Callback
            case 'rightarrow'
                next_Callback
            case 'r'
                RemoveCol_Callback
            case 'add'
                a.VerticalScrollCount=-1;
                ScrollWheelFcn(a,a)
            case '1'
                a.VerticalScrollCount=-1;
                ScrollWheelFcn(a,a)
            case 'subtract'
                a.VerticalScrollCount=1;
                ScrollWheelFcn(a,a)
            case '0'
                a.VerticalScrollCount=1;
                ScrollWheelFcn(a,a)
            otherwise
                return; % ignore keypress
        end
        
    end
    function Undo_Callback(~,~) % --- Executes on button press in Undo.
        
        if sum(size(p.l))==0; return; end; %the list doesn't exist, nothing to undo!
        
        p.centers=p.centersBack; %saving for undo purpose
        p.radii=p.radiiBack; %saving for undo purpose
        p.counts{p.i,1}=p.centers;
        p.counts{p.i,2}=p.radii;
        refresh(1)
        
    end
    function ScrollWheelFcn(~,eventdata)
        
        % data about current visialusation
        %xl = hs.fig.XLim;
        xlen = size(p.rgb,2);
        %yl = hs.fig.YLim;
        ylen = size(p.rgb,1);
        
        % data about current position
        cp = hs.fig.CurrentPoint;
        x=cp(1,1);y=cp(1,2);
        
        % was zoom in or out?
        switch eventdata.VerticalScrollCount
            case 1
                p.zoomlvl = p.zoomlvl*0.5;
            case -1
                p.zoomlvl = p.zoomlvl*2;
        end
        % cannot downsize the image
        if p.zoomlvl<1
            p.zoomlvl=1;
        end
        
        
        % Change the axis limits to where the mouse click has occurred
        % and make sure that the display window is within the image dimensions
        %zoom(zoomlvl)
        xlimit = [x-xlen/p.zoomlvl/2+0.5 x+xlen/p.zoomlvl/2+0.5];
        if xlimit(1)<0.5, xlimit=[0.5 xlen/p.zoomlvl+0.5]; end
        if xlimit(2)>0.5+xlen, xlimit=[xlen-xlen/p.zoomlvl+0.5 xlen+0.5]; end
        xlim(xlimit);
        
        ylimit = [y-ylen/p.zoomlvl/2+0.5 y+ylen/p.zoomlvl/2+0.5];
        if ylimit(1)<=0.5, ylimit=[0.5 ylen/p.zoomlvl+0.5]; end
        if ylimit(2)>=0.5+ylen, ylimit=[ylen-ylen/p.zoomlvl+0.5 ylen+0.5]; end
        ylim(ylimit);
        
    end
    function timestr = sec2timestr(sec)
        % Convert a time measurement from seconds into a human readable string.
        
        % Convert seconds to other units
        w = floor(sec/604800); % Weeks
        sec = sec - w*604800;
        d = floor(sec/86400); % Days
        sec = sec - d*86400;
        h = floor(sec/3600); % Hours
        sec = sec - h*3600;
        m = floor(sec/60); % Minutes
        sec = sec - m*60;
        s = floor(sec); % Seconds
        
        % Create time string
        if w > 0
            if w > 9
                timestr = sprintf('%d week', w);
            else
                timestr = sprintf('%d week, %d day', w, d);
            end
        elseif d > 0
            if d > 9
                timestr = sprintf('%d day', d);
            else
                timestr = sprintf('%d day, %d hr', d, h);
            end
        elseif h > 0
            if h > 9
                timestr = sprintf('%d hr', h);
            else
                timestr = sprintf('%d hr, %d min', h, m);
            end
        elseif m > 0
            if m > 9
                timestr = sprintf('%d min', m);
            else
                timestr = sprintf('%d min, %d sec', m, s);
            end
        else
            timestr = sprintf('%d sec', s);
        end
    end
    function AutoDetectTab_callback(~,~)
        if sum(size(p.l))==0; return; end %the list doesn't exist, no need to refresh
        refresh(0)
    end

%% auto detect colonies
    function DefineParamButton_Callback(~,~)
        % this function allows user to change parameters for the
        % imfindcircles function of Matlab, and the contrast function
        % (sauvola thresholding)
        
        prompt = {'Sensitivity','Minimal radius','Maximal radius', 'Local contrast window'};
        dlg_title = 'Parameters for automatic detection'; num_lines = 1;
        defaultans = {num2str(p.sensitivityN);num2str(p.minRadN);num2str(p.maxRadN); num2str(p.sauvolarange(1))};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if isempty(answer); return; end; %user cancelled
        p.sensitivityN=str2double(answer{1,1});
        p.minRadN=str2double(answer{2,1});
        p.maxRadN=str2double(answer{3,1});
        p.sauvolarange(1)=str2double(answer{4,1});p.sauvolarange(2)=p.sauvolarange(1); %making a squae window
    end
    function FindColonies_Callback(~,~)
        % finds circles in the current image using contrast function and
        % findColonies function
        
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
        
        tic
        FindColonies
        refresh(0);
        p.UserMess.String=['took ',num2str(floor(toc)),' seconds for 1 frame']; drawnow
    end
    function FindColoniesAll_Callback(~,~) % --- Executes on button press in AnalyseAllImages.
        
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
        tic; istart=p.i; %initialise time calculations
        while p.i<length(p.l)+1
            refresh(0) %refreshing image to find colonies
            FindColonies
            refresh(0);
            p.i=p.i+1;
            %message to user
            timeElapsed=floor(toc);
            percDone=(p.i-istart)/(length(p.l)-istart+1)*100;
            remT=floor((1-percDone/100)*timeElapsed/percDone*100);
            mess=sec2timestr(remT);
            txtMsg= [num2str(floor(percDone)), '% done ; Estimated ',mess, ' remain' ]; drawnow
            axes(hs.Progress1); fill([0 0 percDone/100 percDone/100],[0,1,1,0],[0.5 0.7 0.8]), set(hs.Progress1,'Xlim',[0 1],'Ylim',[0 1], 'Xcolor','none','Ycolor','none');drawnow
            text(0.25, 0.2, txtMsg,'Fontsize', 14);
        end
            
            
        end
    function FindColonies
        rgb = p.rgb;
        
        %find circles
        hs.UserMess.String='calculating threshold...';drawnow
        
        rgbT=contrastfunction(rgb, p.sauvolarange); %thresholding on the rgb image
        
        hs.UserMess.String='searching for colonies...';drawnow
        
        [p.centers,p.radii]= findCircles(rgbT);
        p.counts{p.i,1}=p.centers;
        p.counts{p.i,2}=p.radii;
        
        hs.UserMess.String=['recalculated for image' num2str(p.i)];
    end

%% Time lapse analysis tab
    function SetRefFrame_Callback(~,~)
        defaultans={num2str(p.i)};
        i=inputdlg('Set frame number:','Reference frame for time lapse',1,defaultans);
        if isempty(i); p.localframe=[]; return; end; %user cancelled
        i=str2double(i{1,1}); %inputdlg returns a cell
        if i>=0 && i<length(p.l)+1 %checking it is inside range
            p.focalframe=i;
        else
            errordlg('Input number outside of range','Error');
        end
        
    end
    function DefineSubset_Callback(~,~)
                %ask user if analysisng over all colonies and timepoints
        prompt = {'How many colonies? Which colonies?','How many times? Which times'};
        dlg_title = 'Parameters for timelapse analysis (0=all, if several input separate by space)'; num_lines = 1;
        defaultans = {'0','0'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        
        if isempty(answer); return; end; %user cancelled
        
        %colonies
        p.UserColNb=str2num(answer{1,1}); %#ok<ST2NM> %user input
        if sum(p.UserColNb==0)>=1 % contains a zero: over all colonies
            p.colList=1:size(p.counts{p.i,2},1); %over all colonies
        elseif size(p.UserColNb,2)>1 %user input more than one colony
            p.colList=min(p.UserColNb,size(p.counts{p.i,2},1)); %at the risk of doing several time the last one...
        else
            p.colList=1:min(size(p.counts{p.i,2},1),p.UserColNb);
        end
        
        %time
        p.UserTimeNb=str2num(answer{2,1}); %#ok<ST2NM>
        nbtimes=length(p.l);
        if p.UserTimeNb==0
            p.timeList=nbtimes:-1:1;
            p.deltaT=1; %in this case, only used for user messages
        elseif size(p.UserTimeNb,2)>1 %user input more than one timepoint <=======should introduce sorting!
            p.timeList=min(p.UserTimeNb,nbtimes);
            p.timeList=p.timeList(end:-1:1);
            p.deltaT=1; %in this case, only used for user messages
        else
            p.deltaT=round(nbtimes/p.UserTimeNb);
            p.timeList=nbtimes:-p.deltaT:1;
        end
        
    end
    function FindTimeCol_Callback(~,~)
        % the computer will calculate the growth curves assuming the pictures folder is an ordered timelapse movie.
        
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
        
        % alocate empty variables
        if isempty(p.colList); p.colList=1:size(p.counts{p.i,2},1); end %over all colonies if user didn't define it before
        if isempty(p.timeList); p.timeList=length(p.l):-1:1; p.deltaT=1;  end %over all times if user didn't define it before
        p.Rad=cell(max(p.colList),length(p.timeList)); % a cell containing every colony for everytimepoint
        p.RadMean=nan(size(p.Rad)); %same, but will contain mean radii. A matrix is enough
        
        tic
        hs.UserMess.String='starting analysis';drawnow
        
        if isempty(p.focalframe) || p.focalframe==0 %user didn't define a focal frame
            p.focalframe=p.i; %take actual frame
        end
        
        for whichTime=p.timeList %over times
            p.i=whichTime; refresh(0); % loading image
            
            [p.Rad,p.RadMean]=findColonies2(p.rgb, p.Rad, p.RadMean);
            
            % telling user how long remains
            a=floor(100*(1-((whichTime-p.deltaT)/(length(p.l)))));
            textMsg=([num2str(floor(a)),'% done, est. ' sec2timestr((100*toc/a-toc)), ' remaining']);
            hs.UserMess.String=textMsg; 
            axes(hs.Progress1); fill([0 0 a/100 a/100],[0,1,1,0],[0.5 0.7 0.8]), set(hs.Progress1,'Xlim',[0 1],'Ylim',[0 1], 'Xcolor','none','Ycolor','none'); drawnow
            text(0.25, 0.2, 'Time points','Fontsize', 14);
        end %over all times
        
    end
    function OneTimePoint_Callback(~,~)
        if sum(size(p.l))==0; errordlg('please load a image series'); return; end %the list doesn't exist
                
        % alocate empty variables
        if isempty(p.colList); p.colList=1:size(p.counts{p.i,2},1); end %over all colonies if user didn't define it before
        if isempty(p.timeList); p.timeList=length(p.l):-1:1; p.deltaT=1;  end %over all times if user didn't define it before
        p.Rad=cell(max(p.colList),length(p.timeList)); % a cell containing every colony for everytimepoint
        p.RadMean=nan(size(p.Rad)); %same, but will contain mean radii. A matrix is enough
        
        tic
        hs.UserMess.String='starting analysis';drawnow
        
        if isempty(p.focalframe) || p.focalframe==0 %user didn't define a focal frame
            p.focalframe=p.i; %take actual frame
        end
        old_show=p.showPlot; %keep to retaure later
        p.showPlot=1;
            [p.Rad,p.RadMean]=findColonies2(p.rgb, p.Rad, p.RadMean);
        p.showPlot=old_show; %restaured
            
            % telling user how long remains
            textMsg=(['took ' sec2timestr(toc), ' for 1 frame']);
            hs.UserMess.String=textMsg; 
            axes(hs.Progress1); set(hs.Progress1,'Xlim',[0 1],'Ylim',[0 1], 'Xcolor','none','Ycolor','none'); drawnow
            text(0.25, 0.5, 'Time points','Fontsize', 14);
    end
%     %function EstimateTime_Callback
%     %end

%% image analysis funtions
    function output=contrastfunction(image, varargin)
        %SAUVOLA local thresholding. Done on the Green channel
        %   BW = SAUVOLA(IMAGE) performs local thresholding of a two-dimensional
        %   array IMAGE with Sauvola algorithm.
        %
        %   BW = SAUVOLA(IMAGE, [M N], THRESHOLD, PADDING) performs local
        %   thresholding with M-by-N neighbourhood (default is 3-by-3) and
        %   threshold THRESHOLD between 0 and 1 (default is 0.34).
        %   To deal with border pixels the image is padded with one of
        %   PADARRAY options (default is 'replicate').
        %
        %   Example
        %   -------
        %       imshow(sauvola(imread('eight.tif'), [150 150]));
        %
        %   See also PADARRAY, RGB2GRAY.
        %   For method description see:
        %       http://www.dfki.uni-kl.de/~shafait/papers/Shafait-efficient-binarization-SPIE08.pdf
        %   Contributed by Jan Motl (jan@motl.us)
        %   $Revision: 1.1 $  $Date: 2013/03/09 16:58:01 $
        
        % Initialization
        image=image(:,:,2);
        numvarargs = length(varargin);      % only want 3 optional inputs at most
        if numvarargs > 3
            error('myfuns:somefun2Alt:TooManyInputs', ...
                'Possible parameters are: (image, [m n], threshold, padding)');
        end
        
        optargs = {[3 3] 0.34 'replicate'}; % set defaults
        
        optargs(1:numvarargs) = varargin;   % use memorable variable names
        [window, k, padding] = optargs{:};
        
        if ndims(image) ~= 2 %#ok<*ISMAT>
            error('The input image must be a two-dimensional array.');
        end
        
        % Convert to double
        image = double(image);
        
        % Mean value
        mean = averagefilter(image, window, padding);
        
        % Standard deviation
        meanSquare = averagefilter(image.^2, window, padding);
        deviation = (meanSquare - mean.^2).^0.5;
        
        % Sauvola
        R = max(deviation(:));
        threshold = mean.*(1 + k * (deviation / R-1));
        output = (image > threshold);
    end % threshold function
    function [c,r]=findCircles(img)
        range1=[p.minRadN p.maxRadN];
        [c,r]=imfindcircles(img,range1,...
            'ObjectPolarity','bright', 'Sensitivity',p.sensitivityN, 'Method', 'Twostage');
    end
    function [Rad, RadMean]=findColonies2(img, Rad, RadMean)
        for whichCol=p.colList %over all/userdefined Number colonies
            center=[round(p.counts{p.focalframe,1}(whichCol,2)),round(p.counts{p.focalframe,1}(whichCol,1))]; %contains the centers of colonies
            
            Zone=round(p.counts{p.focalframe,2}(whichCol)*p.Zonesize); %the analyzed zone is Zonesize fold bigger than the last radii
            rgbcol=img(center(1)-Zone:center(1)+Zone,center(2)-Zone:center(2)+Zone,:); % 3 colors, for ploting purposes
            rgbcolG=img(center(1)-Zone:center(1)+Zone,center(2)-Zone:center(2)+Zone,p.color); %picking up subpart of the image for further analysis
            M=double(rgbcolG);   %convert to double for calculation
            
            X0=size(M,1)/2; Y0=size(M,2)/2;
            [Y,X,z]=find(M);
            X=X-X0; Y=Y-Y0;
            theta = atan2(Y,X);
            rho = sqrt(X.^2+Y.^2);
            
            % Determine the minimum and the maximum x and y values:
            rmin = min(rho); tmin = min(theta);
            rmax = max(rho); tmax = max(theta);
            
            % Define the resolution of the grid:
            rres=2*Zone; % # of grid points for R coordinate. (change to needed binning)
            
            F = scatteredInterpolant(rho,theta,z,'nearest'); 
            
            %Evaluate the interpolant at the locations (rhoi, thetai).
            %The corresponding value at these locations is Zinterp:
            [rhoi,thetai] = meshgrid(linspace(rmin,rmax,rres),linspace(tmin,tmax,p.tres));
            Zinterp = F(rhoi,thetai);
            
            %calculating a local threshold value
            A=Zinterp; %will replace minimums by nans in A to find the N first minimums
            sizeMean=round(size(A,1)*size(A,1)*p.percsizeMean);
            Mina=nan(sizeMean,1);Ind=nan(sizeMean,1);
            %determin threshold for research of colonies
            for k=1:sizeMean
                if ~isnan(min(A(:),[],'omitnan'))
                    [Mina(k),Ind(k)]=min(A(:),[],'omitnan');
                    A(Ind(k))=NaN;
                end
            end
            TreshVal=nanmean(Mina);
            
            % finding the colony border
            Rad{whichCol, p.i}=nan(size(Zinterp,1),1);
            for j=1:size(Zinterp,1) %looking for value of Zinterp reaching under a threshold.
                test=Zinterp(j,:)<p.Tresh*TreshVal;
                %finding the first consecutive 10 values after thresh
                k=1; test2=0;
                while test2<p.Numtresh && k<size(Zinterp,2)
                    if test(k)
                        test2=test2+1; %incrementing
                    else
                        test2=0;
                    end
                    k=k+1;
                end
                if k<size(Zinterp,2)
                    Rad{whichCol,p.i}(j)=(k-p.Numtresh);
                end
            end
            
            RadMean(whichCol,p.i)=nanmean(Rad{whichCol,p.i})/sqrt(2); %the square root comes out upon transformation from square to circle
            
            if p.showPlot
                axes(hs.fig); set(hs.fig, 'Color', [0.8 0.9 0.8], 'Visible', 'off', 'Xcolor', 'none','Ycolor', 'none','Position', [0 0 1 1]); %creating axes in it
                hs.fig=subplot(1,3,1); imshow(rgbcol) ; axis square %#ok<*UNRCH>
                subplot(1,3,2); imagesc(Zinterp) ; axis square
                subplot(1,3,3); plot (Zinterp(1,:)); hold on;
                for j=2:size(Zinterp,1); %finding colony
                    plot (Zinterp(j,:));
                end;
                subplot(1,3,2); hold on;
                title(['col ' num2str(whichCol) ', time ' num2str(p.i) ]);
                plot(smooth(Rad{whichCol,p.i},9),1:size(Zinterp,1), 'k', 'linewidth',2)
                subplot(1,3,1); hold on;
                viscircles([X0,Y0],RadMean(whichCol,p.i),'Color','r'); hold off;
                subplot(1,3,3); hold on;
                plot([0 size(Zinterp,2)],[p.Tresh*TreshVal p.Tresh*TreshVal],'r','linewidth',3)
                plot([RadMean(whichCol,p.i) RadMean(whichCol,p.i)],[0 max(Zinterp(:))],'r','linewidth',3); hold off;
                pause (2)
            end
            
            % telling user how long remains
            a=(whichCol/(length(p.colList)));
            axes(hs.Progress2); fill([0 0 a a],[0,1,1,0],[0.5 0.7 0.8]); set(hs.Progress2,'Xlim',[0 1],'Ylim',[0 1],'Xcolor','none','Ycolor','none'); drawnow
            text(0.25, 0.5, ['analysed ' num2str(whichCol) ' of ' num2str(length(p.colList)) 'colonies'],'Fontsize', 14);
            
        end %over all colonies
    end

% further math functions for analysis
    function image=averagefilter(image, varargin)
        %AVERAGEFILTER 2-D mean filtering.
        %   B = AVERAGEFILTER(A) performs mean filtering of two dimensional
        %   matrix A with integral image method. Each output pixel contains
        %   the mean value of the 3-by-3 neighborhood around the corresponding
        %   pixel in the input image.
        %
        %   B = AVERAGEFILTER(A, [M N]) filters matrix A with M-by-N neighborhood.
        %   M defines vertical window size and N defines horizontal window size.
        %
        %   B = AVERAGEFILTER(A, [M N], PADDING) filters matrix A with the
        %   predefinned padding. By default the matrix is padded with zeros to
        %   be compatible with IMFILTER. But then the borders may appear distorted.
        %   To deal with border distortion the PADDING parameter can be either
        %   set to a scalar or a string:
        %       'circular'    Pads with circular repetition of elements.
        %       'replicate'   Repeats border elements of matrix A.
        %       'symmetric'   Pads array with mirror reflections of itself.
        %
        %   Comparison
        %   ----------
        %   There are different ways how to perform mean filtering in MATLAB.
        %   An effective way for small neighborhoods is to use IMFILTER:
        %
        %       I = imread('eight.tif');
        %       meanFilter = fspecial('average', [3 3]);
        %       J = imfilter(I, meanFilter);
        %       figure, imshow(I), figure, imshow(J)
        %
        %   However, IMFILTER slows down with the increasing size of the
        %   neighborhood while AVERAGEFILTER processing time remains constant.
        %   And once one of the neighborhood dimensions is over 21 pixels,
        %   AVERAGEFILTER is faster. Anyway, both IMFILTER and AVERAGEFILTER give
        %   the same results.
        %
        %   Remarks
        %   -------
        %   The output matrix type is the same as of the input matrix A.
        %   If either dimesion of the neighborhood is even, the dimension is
        %   rounded down to the closest odd value.
        %
        %   Example
        %   -------
        %       I = imread('eight.tif');
        %       J = averagefilter(I, [3 3]);
        %       figure, imshow(I), figure, imshow(J)
        %
        %   See also IMFILTER, FSPECIAL, PADARRAY.
        
        %   Contributed by Jan Motl (jan@motl.us)
        %   $Revision: 1.2 $  $Date: 2013/02/13 16:58:01 $
        
        
        % Parameter checking.
        numvarargs = length(varargin);
        if numvarargs > 2
            error('myfuns:somefun2Alt:TooManyInputs', ...
                'requires at most 2 optional inputs');
        end
        
        optargs = {[3 3] 0};            % set defaults for optional inputs
        optargs(1:numvarargs) = varargin;
        [window, padding] = optargs{:}; % use memorable variable names
        m = window(1);
        n = window(2);
        
        if ~mod(m,2)
            m = m-1;
        end       % check for even window sizes
        if ~mod(n,2)
            n = n-1;
        end
        
        if (ndims(image)~=2)            % check for color pictures
            display('The input image must be a two dimensional array.')
            display('Consider using rgb2gray or similar function.')
            return
        end
        
        % Initialization.
        [rows,columns] = size(image);   % size of the image
        
        % Pad the image.
        imageP  = padarray(image, [(m+1)/2 (n+1)/2], padding, 'pre');
        imagePP = padarray(imageP, [(m-1)/2 (n-1)/2], padding, 'post');
        
        % Always use double because uint8 would be too small.
        imageD = double(imagePP);
        
        % Matrix 't' is the sum of numbers on the left and above the current cell.
        t = cumsum(cumsum(imageD),2);
        
        % Calculate the mean values from the look up table 't'.
        imageI = t(1+m:rows+m, 1+n:columns+n) + t(1:rows, 1:columns)...
            - t(1+m:rows+m, 1:columns) - t(1:rows, 1+n:columns+n);
        
        % Now each pixel contains sum of the window. But we want the average value.
        imageI = imageI/(m*n);
        
        % Return matrix in the original type class.
        image = cast(imageI, class(image));
        
    end % threshold function, downloaded from Matlab forum


end