
% to do
% in refresh, do not reload when i is the same
% user input filename
% user input threshold vector
% batch mode for several analysis
% scale for petri dish?
% analyse all?
% calculate lag time?
% put tic toc message in pluggin + took toc time
% add image in code
%

%% initiating GUI
function varargout = ColoniesTimeLapseAnalysis(varargin)
% COLONIESTIMELAPSEANALYSIS MATLAB code for ColoniesTimeLapseAnalysis.fig
%      COLONIESTIMELAPSEANALYSIS, by itself, creates a new COLONIESTIMELAPSEANALYSIS or raises the existing
%      singleton*.
%
%      H = COLONIESTIMELAPSEANALYSIS returns the handle to a new COLONIESTIMELAPSEANALYSIS or the handle to
%      the existing singleton*.
%
%      COLONIESTIMELAPSEANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLONIESTIMELAPSEANALYSIS.M with the given input arguments.
%
%      COLONIESTIMELAPSEANALYSIS('Property','Value',...) creates a new COLONIESTIMELAPSEANALYSIS or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ColoniesTimeLapseAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ColoniesTimeLapseAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ColoniesTimeLapseAnalysis

% Last Modified by GUIDE v2.5 15-Jan-2017 15:40:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ColoniesTimeLapseAnalysis_OpeningFcn, ...
    'gui_OutputFcn',  @ColoniesTimeLapseAnalysis_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before ColoniesTimeLapseAnalysis is made visible.
end
function ColoniesTimeLapseAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ColoniesTimeLapseAnalysis (see VARARGIN)

% Choose default command line output for ColoniesTimeLapseAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes ColoniesTimeLapseAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
end
function varargout = ColoniesTimeLapseAnalysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
end
function handles=initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the setNum flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to setNum the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end

%image analysis
handles.minRadN = 20;
handles.maxRadN = 60;
set(handles.minRad, 'String', handles.minRadN);
set(handles.maxRad,  'String', handles.maxRadN);
handles.sensitivityN = 0.82;
handles.sauvolarange=[100 100];% this is used for autothresholding of image

%counts and radii
handles.counts=cell(4,4);
handles.centers = [];
handles.radii = [];
handles.centersBack = [];
handles.radiiBack = [];

%file and folder handling
handles.dir='/Users/vulincle/Desktop/test_timeLapse/jpg';
handles.i = 1;
handles.l = []; %will contain a list of files with filename
%handles.filename='IMG_'; %typical filename before numbers
handles.filextension='.JPG';

% dust handling (not usefull for colony analysis)
handles.rgbAVG=[];
handles.numImgAVG = 30;
handles.centersDust = [];
handles.radiiDust = [];
handles.OnlyCenterTick=0;

handles.apR=1; %appearing radius for cells
set(handles.NumCells, 'String', 0);
set(handles.timeRemain, 'String', '');

%local empty variables will contain data
handles.rgb=[];
handles.im=[];
handles.RadMean=[];
handles.RadMean2=[];
handles.Rad=[];

%for timelapse analysis
handles.Zonesize=1.2;
handles.percsizeMean=0.01;% total image area to define the zero
handles.Tresh=3; %Threshold under which there is no colony (in fold of min)
handles.Numtresh=5;%number of values needed to call threshold reached
handles.tres=128; % # of grid points for theta coordinate (change to needed binning)
handles.showplot=0; %if true, shows the graphs of analysis in userwindow 

%image handling
handles.panButton=0;

% Update handles structure
guidata(handles.figure1, handles);
end %initiate all parameters

%% naviguate images
function chngdir_Callback(hObject, eventdata, handles)
% hObject    handle to chngdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%ask user for dir
handles.dir=uigetdir(handles.dir,'please select the directory with the files to correct');

if handles.dir==0; return; end; %user cancelled
set(handles.currentdir, 'String', handles.dir);
guidata(handles.figure1, handles);
chngDir(handles.figure1, handles.dir,handles);
%length(handles.l)
end
function errorloading=chngDir(figure1, directory, handles) %will return 1 if loading was correct
%getting file list
errorloading=1;
handles.l=dir([directory, '/', '*',handles.filextension]); %lists all files with filextension

%removing the possible hidden files or subfolders. They start with "."
for h=1:size(handles.l,1)
    keep(h)=(handles.l(h).name(1)~='.');
end
handles.l=handles.l(keep);

if isempty(handles.l)
    errordlg(['Did not find any ' handles.filextension ' images in folder' directory '. If you are working with other images types, please consider editing handles.filextension.'],'Error');
    errorloading=0;
    return
end

%loading previously saved data if existant
% if ~isempty(dir([directory, '/', '*','all','*'])); %found a file countaing "all"
%     try
%     files=dir([directory, '/', '*','all','*']);
%     fileAll=load([directory,'/',files(end).name]); %this contains, counts, i, Rad, RadMean, dir, minRad, maxRad and sensitivity
%     handles.counts=fileAll.counts;
%     handles.oldi=fileAll.i;
%     handles.Rad=fileAll.Rad;
%     handles.RadMean=fileAll.RadMean;
%     handles.minRad=fileAll.minRad;
%     handles.maxRad=fileAll.maxRad;
%     handles.sensitivity=fileAll.sensitivity;
%     catch
%         disp('did not find all files');
%         handles.counts=cell(length(handles.l),2); %creating empty cell with the nb of pictures
%         errorloading=0;
%         handles.i=1;
%     end
%     set(handles.UserMess, 'String', 'found previous analysis, loaded it into Matlab');
% elseif 
if size(dir([handles.dir, '/', '*','_all.mat']),1) %there is a _all.mat file
    fileSaved=dir([handles.dir, '/', '*','_all.mat']);
    fileload=load([handles.dir, '/', fileSaved(1).name]); %nb: here, if there are several matching files, Matlab takes the first one
    handles.counts=fileload.counts;
    handles.i=fileload.i;
    handles.maxRad=fileload.maxRad;
    handles.minRad=fileload.minRad;
    handles.Rad=fileload.Rad;
    handles.RadMean=fileload.RadMean;
    handles.RadMean2=fileload.RadMean2;
    handles.sensitivity=fileload.sensitivity;
    
    set(handles.UserMess, 'String', ['found ',fileSaved(1).name ,', loaded it into Matlab']);
    
elseif exist ([handles.dir '/sidesave.mat'], 'file')&& exist ([handles.dir '/stoped_at.mat'], 'file') %check for an older saved analysis
    handles.countsload=load([handles.dir '/sidesave.mat']); %this file was produced when saving
    handles.oldiload=load([handles.dir '/stoped_at.mat']); %this file was produced when saving
    handles.counts=handles.countsload.counts; %because load gives a struct object
    handles.oldi=handles.oldiload.i;
    set(handles.UserMess, 'String', 'found previous analysis, loaded it into Matlab');

elseif exist([handles.dir '/counts.mat'], 'file')
    handles.countsload=load ([handles.dir '/counts.mat']); %this file was produced when analysing
    handles.counts=handles.countsload.counts; %because load gives a struct object
    handles.oldi=1; %start from the start!
    
else %nothing found
    handles.counts=cell(length(handles.l),2); %creating empty cell with the nb of pictures
    errorloading=0;
    handles.i=1;
end

%handles.rgb = imread([handles.dir, '/',handles.l(handles.i).name]); %load pic

% Update handles structure
guidata(figure1, handles);
refresh(handles,0);

end % --- Executes on button press in chngdir.
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% a=handles.i;
if handles.i<length(handles.l)
    handles.counts{handles.i,1}=handles.centers;
    handles.counts{handles.i,2}=handles.radii;
    handles.i=handles.i+1;
    guidata(hObject,handles)% Update handles structure
    refresh(handles,0);
else
    errordlg('No image after this one','Error');
end
end % --- Executes on button press in next.
function previous_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.i>1
    handles.counts{handles.i,1}=handles.centers;
    handles.counts{handles.i,2}=handles.radii;
    handles.i=handles.i-1;
    guidata(hObject,handles)% Update handles structure
    refresh(handles,0);
else
    errordlg('No image before this one','Error');
end
end % --- Executes on button press in previous.
function NumSlice_Callback(hObject, eventdata, handles)
% hObject    handle to NumSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumSlice as text
%        str2double(get(hObject,'String')) returns contents of NumSlice as a double
i = str2double(get(hObject, 'String')); %getting value
if isnan(i) %if not a number, error
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if i>0 && i<length(handles.l)+1 %checking it is inside range
    handles.i = i;
    guidata(hObject,handles)
    refresh(handles,0);
else
    errordlg('Input number outside of range','Error');
end
end % --- Executes on button press in AddCells.
function NumSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % --- Executes during object creation, after setting all properties.
function setNum_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to setNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%initialize_gui(gcbf, handles, true);

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

%in the end, this is just a refresh function:
refresh(handles,0);

end % --- Executes on button press in setNum.

%% modify images
function AddCells_Callback(hObject, eventdata, handles)

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end


handles.centersBack=handles.centers; %saving for undo purpose
handles.radiiBack=handles.radii; %saving for undo purpose

if handles.OnlyCenterTick %this means user is only interreted in centers
    set(handles.UserMess, 'String', 'click on image for new circle center(s), press retur key ');
    [X1, Y1] = ginput;
    X1=X1; Y1=Y1;
    r=ones(length(X1),1); %the radius is selected to be 1
    
else %in the case where user wants to use radius values
    % instructions to users
    set(handles.UserMess, 'String', 'click on image for a new colony, drag to radius, then click again');

    %get colony center
    [X1, Y1] = ginput(1);
    hold on;
    h = plot(X1, Y1, 'r');
    %get radius from a sencon click
    set(gcf, 'WindowButtonMotionFcn', {@mousemove, h, [X1 Y1]}); %to have an updating circle
    k = waitforbuttonpress; %#ok<NASGU>
    set(gcf, 'WindowButtonMotionFcn', ''); %unlock the graph
    r = norm([h.XData(1) - X1 h.YData(2) - Y1]); %circle coordinates are in h object
end

%add cells
if size(handles.centers,1)>=1 %add to existing list
    a=[handles.centers(:,1);X1] ;%to check
    b=[handles.centers(:,2);Y1] ;%to check
    handles.centers=[a b];
    handles.radii=[handles.radii;r];
else %or to empty matrix
    handles.centers=[X1,Y1];
    handles.radii=r;
end

% Update handles structure
handles.counts{handles.i,1}=handles.centers;
handles.counts{handles.i,2}=handles.radii;
guidata(hObject, handles);
%refresh Graph
refresh(handles,1);
end  %OK
function mousemove(object, eventdata, h, bp)
%from http://stackoverflow.com/questions/13840777/select-a-roi-circle-and-square-in-matlab-in-order-to-aply-a-filter
cp = get(gca, 'CurrentPoint');
r = norm([cp(1,1) - bp(1) cp(1,2) - bp(2)]);
theta = 0:.1:2*pi;
xc = r*cos(theta)+bp(1);
yc = r*sin(theta)+bp(2);
set(h, 'XData', xc);
set(h, 'YData', yc);
end % --- This function to refresh upon mouse move
function ClearZone_Callback(hObject, eventdata, handles)
% hObject    handle to ClearZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

handles.centersBack=handles.centers; %saving for undo purpose
handles.radiiBack=handles.radii; %saving for undo purpose

set(handles.UserMess, 'String', 'choose zone to remove cells');
[~,xi,yi]=roipoly(); %user inputs a polygon

%remove for current frame
in=inpolygon(handles.centers(:,1),handles.centers(:,2),xi,yi); %all cells in polygon
handles.centers=handles.centers(in==0,:); %remove from centers
handles.radii=handles.radii(in==0); %remove from radii
% Update handles structure
handles.counts{handles.i,1}=handles.centers;
handles.counts{handles.i,2}=handles.radii;
guidata(hObject, handles);
refresh(handles,1);

end % --- Executes on button press in ClearZone.
function ClearRecZone_Callback(hObject, eventdata, handles)
% hObject    handle to ClearZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

handles.centersBack=handles.centers; %saving for undo purpose
handles.radiiBack=handles.radii; %saving for undo purpose

set(handles.UserMess, 'String', 'choose zone to remove cells');
[~,xi,yi]=roipoly(); %user inputs a polygon

%remove for current frame
in=inpolygon(handles.centers(:,1),handles.centers(:,2),xi,yi); %all cells in polygon
handles.centers=handles.centers(in==1,:); %remove from centers
handles.radii=handles.radii(in==1); %remove from radii
% Update handles structure
handles.counts{handles.i,1}=handles.centers;
handles.counts{handles.i,2}=handles.radii;
guidata(hObject, handles);
refresh(handles,1);
end % --- Executes on button press in ClearRecZone.
function AddDust_Callback(hObject, eventdata, handles)
% hObject    handle to AddCells (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

%create a average image for dust (15 images)
set(handles.UserMess, 'String', 'averaging images...');
rgbAVG=handles.rgb*0;
for i=handles.i:handles.i+handles.numImgAVG-1
    %look for file
    fil=[handles.dir, '/', ...
        handles.filename,num2str(i),handles.filextension]; %this is file name with dir
    fil2=[handles.dir, '/', ...
        handles.filename2,num2str(i,['%0',num2str(handles.digNumbers),...
        'd']),handles.filextension]; %two alternative names
    if ~exist(fil,'file') && ~exist(fil2,'file')
        disp (['could not find file ',fil, ' or ', filename2,num2str(i,['%0',...
            num2str(digNumbers),'d']),filextension]) %didn't find file
    else
        if ~exist(fil,'file') %not this file, then it is the other
            fil=fil2;
        end
        
        rgb = imread(fil); %load pic
        rgbAVG=rgbAVG+rgb/handles.numImgAVG;%imadjust(handles.rgb); %this is an autocontrast
        
    end
end
%handles.rgbAVG=imadjust(rgbAVG);
imshow(handles.rgbAVG,'InitialMagnification', 25)
viscircles(handles.centersDust,...
    handles.radiiDust*handles.apR,...
    'Color','b');

% Update handles structure
guidata(handles.figure1, handles);

% instructions to users
set(handles.UserMess, 'String', 'click on image on the dust, then press enter');
[x,y] = ginput; %user inputs new cells by clicking

%add cells
if size(handles.centersDust,1)>1 %add to existing list
    a=[handles.centersDust(:,1);x] ;%to check
    b=[handles.centersDust(:,2);y] ;%to check
    handles.centersDust=[a b];
    handles.radiiDust=[handles.radiiDust;ones(length(x),1)];
else %or to empty matrix
    handles.centersDust=[x,y];
    handles.radiiDust=ones(length(x),1);
end

% Update handles structure
guidata(hObject, handles);
refresh(handles);
end %obsolete here % --- Executes on button press in AddDust.
function RemoveCol_Callback(hObject, eventdata, handles) % --- Executes on button press in RemoveCol.

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

handles.centersBack=handles.centers; %saving for undo purpose
handles.radiiBack=handles.radii; %saving for undo purpose

% instructions to users
set(handles.UserMess, 'String', 'click on one colony to remove');

%get position
[X1, Y1] = ginput(1);

%calculate distance to click
dist=zeros(1,length(handles.centers(:,1)));
for i=1:length(handles.centers(:,1))
    dist(i) = norm([handles.centers(i,1) - X1 handles.centers(i,2) - Y1]);
end
dist=dist';
in=(handles.radii>dist); %clicked inside
handles.centers=handles.centers(in==0,:); %remove from centers
handles.radii=handles.radii(in==0); %remove from radii

% Update handles structure
handles.counts{handles.i,1}=handles.centers;
handles.counts{handles.i,2}=handles.radii;
guidata(hObject, handles);
%refresh Graph
refresh(handles,1);
end

%% apperance on images
function updateRad_Callback(hObject, eventdata, handles)
% hObject    handle to updateRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end
%in the end, this is just a refresh function:
refresh(handles,1);
end % --- Executes on button press in updateRad.
function Rad_Callback(hObject, eventdata, handles)
% hObject    handle to Rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Rad as text
%        str2double(get(hObject,'String')) returns contents of Rad as a double
appRadN = str2double(get(hObject, 'String'));
if isnan(appRadN)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new minRad value
handles.apR = appRadN;
guidata(hObject,handles)


end 
function Rad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end % --- Executes during object creation, after setting all properties.

%% automatic analyse of images
% Setting properties.
function sensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end %OK
function sensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to maxRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sensitivity = str2double(get(hObject, 'String'));
if isnan(sensitivity)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new maxRad value
handles.sensitivityN = sensitivity;
guidata(hObject,handles)
end %OK
function minRad_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to minRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function minRad_Callback(hObject, eventdata, handles)
% hObject    handle to minRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minRad as text
%        str2double(get(hObject,'String')) returns contents of minRad as a double
minRadN = str2double(get(hObject, 'String'));
if isnan(minRadN)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new minRad value
handles.minRadN = minRadN;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
end
function maxRad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
function maxRad_Callback(hObject, eventdata, handles)
% hObject    handle to maxRad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxRad as text
%        str2double(get(hObject,'String')) returns contents of maxRad as a double
maxRadN = str2double(get(hObject, 'String'));
if isnan(maxRadN)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% Save the new maxRad value
handles.maxRadN = maxRadN;
guidata(hObject,handles)

end
% Push buttons
function Recalc1_Callback(hObject, eventdata, handles) % --- Executes on button press in Recalc1, finds cicles in current image
% hObject    handle to Recalc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

tic
range1=[handles.minRadN handles.maxRadN];
rgb = handles.rgb;
%test=handles.sauvolarange
%find circles
set(handles.UserMess, 'String', 'calculating threshold...');guidata(hObject, handles);pause(0.05); %pause was needed to force refresh
rgbT=sauvola(rgb(:,:,2), handles.sauvolarange); %thresholding on the rgb image
set(handles.UserMess, 'String', 'searching for colonies...');guidata(hObject, handles);pause(0.05); %pause was needed to force refresh
[handles.centers,handles.radii]= imfindcircles(rgbT,range1,...
    'ObjectPolarity','bright', 'Sensitivity',handles.sensitivityN, 'Method', 'Twostage');
handles.counts{handles.i,1}=handles.centers;
handles.counts{handles.i,2}=handles.radii;

guidata(hObject, handles);
set(handles.UserMess, 'String', ['recalculated for image' num2str(handles.i)]);
refresh(handles,0);
set(handles.timeRemain, 'String', ['took ',num2str(floor(toc)),' seconds for 1 frame']);
end
function AnalyseAllImages_Callback(hObject, eventdata, handles) % --- Executes on button press in AnalyseAllImages.
% hObject    handle to AnalyseAllImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tic
    rgb = handles.rgb;
    range1=[handles.minRadN handles.maxRadN];
    set(handles.UserMess, 'String', 'calculating threshold...');guidata(hObject, handles);pause(0.05); %pause was needed to force refresh
        rgbT=sauvola(rgb(:,:,2), handles.sauvolarange); %thresholding on the rgb image
        set(handles.UserMess, 'String', 'searching for colonies...');guidata(hObject, handles);pause(0.05); %pause was needed to force refresh
        [handles.centers,handles.radii]= imfindcircles(rgbT,range1,...
            'ObjectPolarity','bright', 'Sensitivity',handles.sensitivityN, 'Method', 'TwoStage');
        handles.counts{handles.i,1}=handles.centers; 
        handles.counts{handles.i,2}=handles.radii;

        guidata(hObject, handles);
        set(handles.UserMess, 'String', ['recalculated for image' num2str(handles.i)]);
    istart=handles.i;
    while handles.i<length(handles.l) %going for all the next slides
        %what could have been programmed
        %         handles.i=handles.i+1
        %         test = handles.i
        %         %next_Callback(hObject, eventdata, handles)
        %         guidata(hObject, handles);
        %         Recalc1_Callback(hObject, eventdata, handles);
        %         
        %         set(handles.UserMess, 'String', ['recalculated for image' num2str(handles.i)]);
        %         %refresh(handles); %might be slowing things down here, but well...
        %         timeElapsed=floor(toc);
        %         percDone=(handles.i-istart+1)/(length(handles.l)-istart+1)*100;
        %         set(handles.timeRemain, 'String', {[num2str(percDone), '% done']; ['Est. ',...
        %             num2str((1-percDone/100)*timeElapsed/percDone*100), 's remain' ]});
        
        %what was copy pasted
        handles.i=handles.i+1;
        guidata(hObject, handles);
        refresh(handles,0);
        range1=[handles.minRadN handles.maxRadN];
        handles.rgb = imread([handles.dir, '/',handles.l(handles.i).name]); %load pic
        rgb = handles.rgb;
        
        %find circles
        set(handles.UserMess, 'String', 'calculating threshold...');guidata(hObject, handles);pause(0.05); %pause was needed to force refresh
        rgbT=sauvola(rgb(:,:,2), handles.sauvolarange); %thresholding on the rgb image
        set(handles.UserMess, 'String', 'searching for colonies...');guidata(hObject, handles);pause(0.05); %pause was needed to force refresh
        [handles.centers,handles.radii]= imfindcircles(rgbT,range1,...
            'ObjectPolarity','bright', 'Sensitivity',handles.sensitivityN, 'Method', 'TwoStage');
        handles.counts{handles.i,1}=handles.centers; 
        handles.counts{handles.i,2}=handles.radii;

        guidata(hObject, handles);
        set(handles.UserMess, 'String', ['recalculated for image' num2str(handles.i)]);
        %refresh function has trouble updating the handle. reproducing it here
            handles.rgb = imread([handles.dir, '/',handles.l(handles.i).name]); %load pic
            hold off;
            imshow(handles.rgb,'InitialMagnification', 25)

            %showing circles (if handles.counts{handles.i,1} exists)
            if handles.i<=size(handles.counts,1)
                if ~isempty(handles.counts{handles.i,1})
                    viscircles(handles.counts{handles.i,1},handles.counts{handles.i,2}*handles.apR); %ploting with small diameter to enhance visualisation
                end
                set(handles.NumCells, 'String', num2str(size(handles.counts{handles.i,2},1)));
                if isempty(handles.centers)
                    handles.centers=handles.counts{handles.i,1};
                    handles.radii=handles.counts{handles.i,2}; %splitting in two variables
                end
            else 
                handles.centers=[];
                handles.radii=[]; %splitting in two variables
            end
            %updating user messages
            set(handles.imageNumber, 'String', ['image number ',num2str(handles.i), ' out of ', num2str(length(handles.l))]); pause(0.05);
            guidata(hObject, handles);
            saveall(handles);

        %message to user
        timeElapsed=floor(toc);
        percDone=(handles.i-istart+1)/(length(handles.l)-istart+1)*100;
        remT=floor((1-percDone/100)*timeElapsed/percDone*100);
        if remT<120
            mess=[num2str(remT),' s'];
        else
            mess=[num2str(remT/60),' min'];
        end
        set(handles.timeRemain, 'String', {[num2str(percDone), '% done']; ['Est. ',mess, ' remain' ]});
    end


end

%functions for image analysis
function output=sauvola(image, varargin)

%SAUVOLA local thresholding.
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
end % threshold function, downloaded from Matlab forum
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

%% timelapse analysis
function RecalcNext_Callback(hObject, eventdata, handles) % --- Executes on button press in RecalcNext.
% the computer will calculate the growth curves assuming the pictures folder is an ordered timelapse movie.
if sum(size(handles.l))==0; %the list doesn't exist
    errordlg('please load a image series')
    return
end

%ask user if analysisng over all colonies and timepoints
prompt = {'How many colonies? Which colonies?','How many times? Which times'};
dlg_title = 'Parameters for timelapse analysis (0=all, if several input separate by space)'; num_lines = 1;
defaultans = {'0','0'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

if isempty(answer); return; end; %user cancelled

%colonies
UserColNb=str2num(answer{1,1}); %#ok<ST2NM> %user input
if sum(UserColNb==0)>=1 % contains a zero: over all colonies
    colList=1:size(handles.counts{handles.i,2},1); %over all colonies
elseif size(UserColNb,2)>1 %user input more than one colony
    colList=min(UserColNb,size(handles.counts{handles.i,2},1)); %at the risk of doing several time the last one...
else
    colList=1:min(size(handles.counts{handles.i,2},1),UserColNb);
end

%time 
UserTimeNb=str2num(answer{2,1}); %#ok<ST2NM>
nbtimes=length(handles.l);
if UserTimeNb==0
    timeList=nbtimes:-1:1;
    deltaT=1; %in this case, only used for user messages
elseif size(UserTimeNb,2)>1 %user input more than one timepoint <====================need to introduce sorting!
    timeList=min(UserTimeNb,nbtimes);
    timeList=timeList(end:-1:1);
    deltaT=1; %in this case, only used for user messages
else
    deltaT=round(nbtimes/UserTimeNb);
    timeList=nbtimes:-deltaT:1;
end

%setting up parameters
showPlot=handles.showplot; %this is an internal parameter to be made accessible. It allows user visualisation of timelapse analysis
percsizeMean=handles.percsizeMean; % total image area to define the zero
Tresh=handles.Tresh; %Threshold under which there is no colony (in fold of min)
Numtresh=handles.Numtresh; %number of values needed to call threshold reached
tres=handles.tres; % # of grid points for theta coordinate (change to needed binning)

%create empty variables
Rad=cell(max(colList),length(timeList)); % a cell containing every colony for everytimepoint
RadMean=nan(size(Rad)); %same, but will contain mean radii. A matrix is enough
RadMean2=nan(size(Rad)); %same, but will contain mean radii. A matrix is enough

tic
set(handles.UserMess, 'String', 'starting analysis');
refresh(handles,0);
for whichTime=timeList %over times
    rgb=imread([handles.dir, '/',handles.l(whichTime).name]); %load image
    
    for whichCol=colList %over all/userdefined Number colonies
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        center=[round(handles.counts{handles.i,1}(whichCol,2)),round(handles.counts{handles.i,1}(whichCol,1))]; %contains the centers of colonies
        Zonesize=handles.Zonesize;
        Zone=round(handles.counts{handles.i,2}(whichCol)*Zonesize); %the analyzed zone is Zonesize fold bigger than the last radii
 if center(1)-Zone<0 || center(1)+Zone>size(rgb,1) || center(2)-Zone<0 || center(2)+Zone >size(rgb,2)%the colony is two close from the border

            if errColBorder==0

            disp('one or more colonies was too close to border of the image, it was ignored')

            errColBorder=errColBorder+1;

            end

 else
        rgbcol=rgb(center(1)-Zone:center(1)+Zone,center(2)-Zone:center(2)+Zone,:); %for ploting purposes
        rgbcolG=rgb(center(1)-Zone:center(1)+Zone,center(2)-Zone:center(2)+Zone,2); %picking up subpart of the image for further analysis
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
        
        %F = scatteredInterpolant(rho,theta,z,'linear'); %calculate interpolants >===============
        F = scatteredInterpolant(rho,theta,z,'nearest'); %calculate interpolants >===============
        
        %Evaluate the interpolant at the locations (rhoi, thetai).
        %The corresponding value at these locations is Zinterp:
        [rhoi,thetai] = meshgrid(linspace(rmin,rmax,rres),linspace(tmin,tmax,tres));
        Zinterp = F(rhoi,thetai);
        
        if showPlot %this allows user to see the colonies analysis live
            subplot(1,3,1); imshow(rgbcol) ; axis square %#ok<*UNRCH>
            subplot(1,3,2); imagesc(Zinterp) ; axis square
            subplot(1,3,3); plot (Zinterp(1,:)); hold on;
            for j=2:size(Zinterp,1); %finding colony
                plot (Zinterp(j,:));
            end;
            hold off;
            title(['col ' num2str(whichCol) ', time ' num2str(whichTime) ]);
        end
        
        %calculating a local threshold value
        A=Zinterp; %will replace minimums by nans in A to find the N first minimums
        sizeMean=round(size(A,1)*size(A,1)*percsizeMean);
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
        Rad{whichCol, whichTime}=nan(size(Zinterp,1),1);
        for j=1:size(Zinterp,1) %looking for value of Zinterp reaching under a threshold.
            test=Zinterp(j,:)<Tresh*TreshVal;
            %finding the first consecutive 10 values after thresh
            k=1; test2=0;
            while test2<Numtresh && k<size(Zinterp,2)
                if test(k) 
                    test2=test2+1; %incrementing
                else
                    test2=0;
                end
                k=k+1;
            end
            if k<size(Zinterp,2)
                Rad{whichCol,whichTime}(j)=(k-Numtresh);
            end
        end
        
        RadMean(whichCol,whichTime)=nanmean(Rad{whichCol,whichTime})/sqrt(2); %the square root comes out upon transformation from square to circle
        
        %test for a direct Hough transform
        %a first radius estimate
%         if whichTime<max(timeList) %it is not the first radius to find
%             indic=find(timeList==whichTime); %finding wich is the 
%             estimatedRad=RadMean2(whichCol,timeList(indic-1)); %taking last found radius
%         else
%             estimatedRad=handles.counts{handles.i,2}(whichCol); %taking radius entered by user
%         end
%         if estimatedRad<5; 
%             radii=5:1:10;
%         else
%             radii=floor(estimatedRad*0.8):1:floor(estimatedRad*1.2);
%         end
%         e = edge(rgbcolG, 'canny'); %decting edges
%         h = circle_hough(e, radii, 'same', 'normalise'); %performing circular hough transform
%         peaks = circle_houghpeaks(h, radii, 'npeaks', 1);
%         RadMean2(whichCol,whichTime)=peaks(3);
        
        if showPlot
            subplot(1,3,2); hold on;
            plot(smooth(Rad{whichCol,whichTime},9),1:size(Zinterp,1), 'k', 'linewidth',2)
            subplot(1,3,1); hold on;
            viscircles([X0,Y0],RadMean(whichCol,whichTime),'Color','r'); hold off;
            %viscircles([X0,Y0],RadMean2(whichCol,whichTime),'Color','b'); hold off;
            subplot(1,3,3); hold on; 
            plot([0 size(Zinterp,2)],[Tresh*TreshVal Tresh*TreshVal],'r','linewidth',3)
            plot([RadMean(whichCol,whichTime) RadMean(whichCol,whichTime)],[0 max(Zinterp(:))],'r','linewidth',3); hold off;
            pause (2)
        end
 end % if a colony is too close from the border....   
    end %over all colonies
    text=([num2str(floor(100*(1-((whichTime-deltaT)/length(timeList))))),'% done, est. ' num2str(ceil(toc/(1-((whichTime-deltaT)/length(timeList)))*((whichTime-deltaT)/length(timeList))/60)), ' min remaining']);
    set(handles.timeRemain, 'String', text); 
    %disp(text);
    guidata(hObject, handles);
end %over all times
set(handles.timeRemain, 'String', ['done: took ',num2str(toc/60) ,'min']); 
handles.RadMean=RadMean;
handles.RadMean2=RadMean2;
handles.Rad=Rad;
guidata(hObject,handles)
saveall(handles);
end
function Batch_mode_timelapse_Callback(hObject, eventdata, handles) % --- Executes on button press in Batch_mode_timelapse.
% hObject    handle to Batch_mode_timelapse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get all folders
prompt = {'Please enter all folders, separated by ;'};
defaultans = {'0'};
dlg_title = 'all colonies and timepoints will be analysed'; num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

%create a list of all folders to analyse
delimiters=strfind (answer, ';'); delimiters=[0 delimiters]; %list of delimiters
listF=cell(1,1);
for i=2:length(delimiters)
    listF{i-1}=answer(delimiters(i-1)+1:delimiters(i));
end
listF{end+1}=answer(delimiters(end)+1:end);

%go over all folders
for i=1:length(listF)
    chngDir(directory, handles) %going to directory
end


end
%functions for image analysis, taken from David Young
function [h, margin] = circle_hough(b, rrange, varargin)
%CIRCLE_HOUGH Hough transform for circles
%   from https://ch.mathworks.com/matlabcentral/fileexchange/26978-hough-transform-for-circles/content/html/circle_houghdemo.html
%   [H, MARGIN] = CIRCLE_HOUGH(B, RADII) takes a binary 2-D image B and a
%   vector RADII giving the radii of circles to detect. It returns the 3-D
%   accumulator array H, and an integer MARGIN such that H(I,J,K) contains
%   the number of votes for the circle centred at B(I-MARGIN, J-MARGIN),
%   with radius RADII(K). Circles which pass through B but whose centres
%   are outside B receive votes.
%
%   [H, MARGIN] = CIRCLE_HOUGH(B, RADII, opt1, ...) allows options to be
%   set. Each option is a string, which if included has the following
%   effect:
%
%   'same' returns only the part of H corresponding to centre positions
%   within the image. In this case H(:,:,k) has the same dimensions as B,
%   and MARGIN is 0. This option should not be used if circles whose
%   centres are outside the image are to be detected.
%
%   'normalise' multiplies each slice of H, H(:,:,K), by 1/RADII(K). This
%   may be useful because larger circles get more votes, roughly in
%   proportion to their radius.
%
%   The spatial resolution of the accumulator is the same as the spatial
%   resolution of the original image. Smoothing the accumulator array
%   allows the effective resolution to be controlled, and this is probably
%   essential for sensitivity to circles of arbitrary radius if the spacing
%   between radii is greater than 1. If time or memory requirements are a
%   problem, a generalisation of this function to allow larger bins to be
%   used from the start would be worthwhile.
%
%   Each feature in B is allowed 1 vote for each circle. This function
%   could easily be generalised to allow weighted features.
%
%   See also CIRCLEPOINTS, CIRCLE_HOUGHPEAKS, CIRCLE_HOUGHDEMO

% Copyright David Young 2008, 2010

% argument checking
opts = {'same' 'normalise'};
narginchk(2, 2+length(opts));
validateattributes(rrange, {'double'}, {'real' 'positive' 'vector'});
if ~all(ismember(varargin, opts))
    error('Unrecognised option');
end

% get indices of non-zero features of b
[featR, featC] = find(b);

% set up accumulator array - with a margin to avoid need for bounds checking
[nr, nc] = size(b);
nradii = length(rrange);
margin = ceil(max(rrange));
nrh = nr + 2*margin;        % increase size of accumulator
nch = nc + 2*margin;
h = zeros(nrh*nch*nradii, 1, 'uint32');  % 1-D for now, uint32 a touch faster

% get templates for circles at all radii - these specify accumulator
% elements to increment relative to a given feature
tempR = []; tempC = []; tempRad = [];
for i = 1:nradii
    [tR, tC] = circlepoints(rrange(i));
    tempR = [tempR tR]; %#ok<*AGROW>
    tempC = [tempC tC];
    tempRad = [tempRad repmat(i, 1, length(tR))];
end

% Convert offsets into linear indices into h - this is similar to sub2ind.
% Take care to avoid negative elements in either of these so can use
% uint32, which speeds up processing by a factor of more than 3 (in version
% 7.5.0.342)!
tempInd = uint32( tempR+margin + nrh*(tempC+margin) + nrh*nch*(tempRad-1) );
featInd = uint32( featR' + nrh*(featC-1)' );

% Loop over features
for f = featInd
    % shift template to be centred on this feature
    incI = tempInd + f;
    % and update the accumulator
    h(incI) = h(incI) + 1;
end

% Reshape h, convert to double, and apply options
h = reshape(double(h), nrh, nch, nradii);

if ismember('same', varargin)
    h = h(1+margin:end-margin, 1+margin:end-margin, :);
    margin = 0;
end

if ismember('normalise', varargin)
    h = bsxfun(@rdivide, h, reshape(rrange, 1, 1, length(rrange)));
end

end
function peaks = circle_houghpeaks(h, radii, varargin)
%CIRCLE_HOUGHPEAKS finds peaks in the output of CIRCLE_HOUGH
%   PEAKS = CIRCLE_HOUGHPEAKS(H, RADII, MARGIN, OPTIONS) locates the
%   positions of peaks in the output of CIRCLE_HOUGH. The result PEAKS is a
%   3 x N array, where each column gives the position and radius of a
%   possible circle in the original array. The first row of PEAKS has the
%   x-coordinates, the second row has the y-coordinates, and the third row
%   has the radii.
%
%   H is the 3D accumulator array returned by CIRCLE_HOUGH.
%
%   RADII is the array of radii which was passed as an argument to
%   CIRCLE_HOUGH.
%
%   MARGIN is optional, and may be omitted if the 'same' option was used
%   with CIRCLE_HOUGH. Otherwise, it should be the second result returned
%   by CIRCLE_HOUGH.
%
%   OPTIONS is a comma-separated list of parameter/value pairs, with the
%   following effects:
%
%   'Smoothxy' causes each x-y layer of H to be smoothed before peak
%   detection using a 2D Gaussian kernel whose "sigma" parameter is given
%   by the value of this argument.
%
%   'Smoothr' causes each radius column of H to be smoothed before peak
%   detection using a 1D Gaussian kernel whose "sigma" parameter is given
%   by the value of this argument.
%
%       Note: Smoothing may be useful to locate peaks in noisy accumulator
%       arrays. However, it may also cause the performance to deteriorate
%       if H contains sharp peaks. It is most likely to be useful if
%       neighbourhood suppression (see below) is not used.
%
%       Both smoothing operations use reflecting boundary conditions to
%       compute values close to the boundaries.
%
%   'Threshold' sets the minimum number of votes (after any smoothing)
%   needed for a peak to be counted. The default is 0.5 * the maximum value
%   in H.
%
%   'Npeaks' sets the maximum number of peaks to be found. The highest
%   NPEAKS peaks are returned, unless the threshold causes fewer than
%   NPEAKS peaks to be available.
%
%   'Nhoodxy' must be followed by an odd integer, which sets a minimum
%   spatial separation between peaks. See below for a more precise
%   statement. The default is 1.
%
%   'Nhoodr' must be followed by an odd integer, which sets a minimum
%   separation in radius between peaks. See below for a more precise
%   statement. The default is 1.
%
%       When a peak has been found, no other peak with a position within an
%       NHOODXY x NHOODXY x NHOODR box centred on the first peak will be
%       detected. Peaks are found sequentially; for example, after the
%       highest peak has been found, the second will be found at the
%       largest value in H excepting the exclusion box found the first
%       peak. This is similar to the mechanism provided by the Toolbox
%       function HOUGHPEAKS.
%
%       If both the 'Nhoodxy' and 'Nhoodr' options are omitted, the effect
%       is not quite the same as setting each of them to 1. Instead of a
%       sequential algorithm with repeated passes over H, the Toolbox
%       function IMREGIONALMAX is used. This may produce slightly different
%       results, since an above-threshold point adjacent to a peak will
%       appear as an independent peak using the sequential suppression
%       algorithm, but will not be a local maximum. 
%
%   See also CIRCLE_HOUGH, CIRCLE_HOUGHDEMO

% check arguments
params = checkargs(h, radii, varargin{:});

% smooth the accumulator - xy
if params.smoothxy > 0
    [m, hsize] = gaussmask1d(params.smoothxy);
    % smooth each dimension separately, with reflection
    h = cat(1, h(hsize:-1:1,:,:), h, h(end:-1:end-hsize+1,:,:));
    h = convn(h, reshape(m, length(m), 1, 1), 'valid');
    
    h = cat(2, h(:,hsize:-1:1,:), h, h(:,end:-1:end-hsize+1,:));
    h = convn(h, reshape(m, 1, length(m), 1), 'valid');
end

% smooth the accumulator - r
if params.smoothr > 0
    [m, hsize] = gaussmask1d(params.smoothr);
    h = cat(3, h(:,:,hsize:-1:1), h, h(:,:,end:-1:end-hsize+1));
    h = convn(h, reshape(m, 1, 1, length(m)), 'valid');
end

% set threshold
if isempty(params.threshold)
    params.threshold = 0.5 * max(h(:));
end

if isempty(params.nhoodxy) && isempty(params.nhoodr)
    % First approach to peak finding: local maxima
    
    % find the maxima
    maxarr = imregionalmax(h);
    
    maxarr = maxarr & h >= params.threshold;
    
    % get array indices
    peakind = find(maxarr);
    [y, x, rind] = ind2sub(size(h), peakind);
    peaks = [x'; y'; radii(rind)];
    
    % get strongest peaks
    if ~isempty(params.npeaks) && params.npeaks < size(peaks,2)
        [~, ind] = sort(h(peakind), 'descend');
        ind = ind(1:params.npeaks);
        peaks = peaks(:, ind);
    end
    
else
    % Second approach: iterative global max with suppression
    if isempty(params.nhoodxy)
        params.nhoodxy = 1;
    elseif isempty(params.nhoodr)
        params.nhoodr = 1;
    end
    nhood2 = ([params.nhoodxy params.nhoodxy params.nhoodr]-1) / 2;
    
    if isempty(params.npeaks)
        maxpks = 0;
        peaks = zeros(3, round(numel(h)/100));  % preallocate
    else
        maxpks = params.npeaks;  
        peaks = zeros(3, maxpks);  % preallocate
    end
    
    np = 0;
    while true
        [r, c, k, v] = max3(h);
        % stop if peak height below threshold
        if v < params.threshold || v == 0
            break;
        end
        np = np + 1;
        peaks(:, np) = [c; r; radii(k)];
        % stop if done enough peaks
        if np == maxpks
            break;
        end
        % suppress this peak
        r0 = max([1 1 1], [r c k]-nhood2);
        r1 = min(size(h), [r c k]+nhood2);
        h(r0(1):r1(1), r0(2):r1(2), r0(3):r1(3)) = 0;
    end 
    peaks(:, np+1:end) = [];   % trim
end

% adjust for margin
if params.margin > 0
    peaks([1 2], :) = peaks([1 2], :) - params.margin;
end
end
function params = checkargs(h, radii, varargin)
% Argument checking
ip = inputParser;

% required
htest = @(h) validateattributes(h, {'double'}, {'real' 'nonnegative' 'nonsparse'});
ip.addRequired('h', htest);
rtest = @(radii) validateattributes(radii, {'double'}, {'real' 'positive' 'vector'});
ip.addRequired('radii', rtest);

% optional
mtest = @(n) validateattributes(n, {'double'}, {'real' 'nonnegative' 'integer' 'scalar'});
ip.addOptional('margin', 0, mtest); 

% parameter/value pairs
stest = @(s) validateattributes(s, {'double'}, {'real' 'nonnegative' 'scalar'});
ip.addParam('smoothxy', 0, stest); %CV: 161214 changed addParamValue to addParam for 5 next occurences
ip.addParam('smoothr', 0, stest);
ip.addParam('threshold', [], stest);
nptest = @(n) validateattributes(n, {'double'}, {'real' 'positive' 'integer' 'scalar'});
ip.addParam('npeaks', [], nptest);
nhtest = @(n) validateattributes(n, {'double'}, {'odd' 'positive' 'scalar'});
ip.addParam('nhoodxy', [], nhtest);
ip.addParam('nhoodr', [], nhtest);
ip.parse(h, radii, varargin{:});
params = ip.Results;
end
function [m, hsize] = gaussmask1d(sigma)
% truncated 1D Gaussian mask
hsize = ceil(2.5*sigma);  % reasonable truncation
x = (-hsize:hsize) / (sqrt(2) * sigma);
m = exp(-x.^2);
m = m / sum(m);  % normalise
end
function [r, c, k, v] = max3(h)
% location and value of global maximum of a 3D array
[vr, r] = max(h);
[vc, c] = max(vr);
[v, k] = max(vc);
c = c(1, 1, k);
r = r(1, c, k);
end
function [x, y] = circlepoints(r)
%CIRCLEPOINTS  Returns integer points close to a circle
%   [X, Y] = CIRCLEPOINTS(R) where R is a scalar returns coordinates of
%   integer points close to a circle of radius R, such that none is
%   repeated and there are no gaps in the circle (under 8-connectivity).
%
%   If R is a row vector, a circle is generated for each element of R and
%   the points concatenated.

%   Copyright David Young 2010

x = [];
y = [];
for rad = r
    [xp, yp] = circlepoints1(rad);
    x = [x xp];
    y = [y yp];
end

end
function [x, y] = circlepoints1(r)    
% Get number of rows needed to cover 1/8 of the circle
l = round(r/sqrt(2));
if round(sqrt(r.^2 - l.^2)) < l   % if crosses diagonal
    l = l-1;
end
% generate coords for 1/8 of the circle, a dot on each row
x0 = 0:l;
y0 = round(sqrt(r.^2 - x0.^2));
% Check for overlap
if y0(end) == l
    l2 = l;
else
    l2 = l+1;
end
% assemble first quadrant
x = [x0 y0(l2:-1:2)]; 
y = [y0 x0(l2:-1:2)];
% add next quadrant
x0 = [x y];
y0 = [y -x];
% assemble full circle
x = [x0 -x0];
y = [y0 -y0];
end

%% generic resfresh and data save
function refresh(handles, z)
%this function could be optimized by updating the image only if it has
%changed... need to separate graph and image for this

% if z=1, zoom is kept
handles.rgb = imread([handles.dir, '/',handles.l(handles.i).name]); %loading pic
hold off;
xlim=[];ylim=[];
%remembering zoom
if ~isempty(handles.im) && z==1
    ylim = handles.axes1.YLim;
    xlim = handles.axes1.XLim;
end

%update image
%subplot('Position', [0 0 1 1]); %going from subplot to plot in one image
%close;
handles.im=imshow(handles.rgb,'InitialMagnification', 25);

if ~isempty(handles.counts{handles.i,1})
    if handles.OnlyCenterTick %this mean 'only centers' tick is activated
        viscircles(handles.counts{handles.i,1},ones(size(handles.counts{handles.i,2}))*10*handles.apR,'Color', 'b'); %ploting with a 10x diameter to enhance visualisation
    else
        viscircles(handles.counts{handles.i,1},handles.counts{handles.i,2}*handles.apR, 'Color', 'b'); %ploting with actual diameter x user factor
    end
end

set(handles.NumCells, 'String', num2str(size(handles.counts{handles.i,2},1)));

handles.centers=handles.counts{handles.i,1};
handles.radii=handles.counts{handles.i,2}; %splitting in two variables

%resetting the previous zoom
if ~isempty(xlim) && z==1
    handles.axes1.XLim=xlim;
    handles.axes1.YLim=ylim;
end



%updating user messages
set(handles.imageNumber, 'String', ['image number ',num2str(handles.i), ' out of ', num2str(length(handles.l))]); pause(0.05);

saveall(handles);

% Update handles structure
guidata(handles.figure1, handles);

end
function saveall(handles)
%create internal variables to be saved
counts=handles.counts; %#ok<NASGU>
i=handles.i;%#ok<NASGU>
Rad=handles.Rad;%#ok<NASGU>
RadMean2=handles.RadMean2;%#ok<NASGU>
RadMean=handles.RadMean;%#ok<NASGU>
dir=handles.dir;%#ok<NASGU>
minRad=handles.minRadN;%#ok<NASGU>
maxRad=handles.maxRadN;%#ok<NASGU>
sensitivity=handles.sensitivityN;%#ok<NASGU>

save([handles.dir '/sidesave.mat'],'counts') %to be place on a step by step save
save([handles.dir '/stoped_at.mat'],'i')
save([handles.dir '/Rad.mat'],'Rad')
save([handles.dir '/RadMean.mat'],'RadMean')
save([handles.dir '/RadMean2.mat'],'RadMean2')

%also with date to avoid too much loss in case of crash
save([handles.dir '/' date 'sidesave.mat'],'counts') %to be place on a step by step save
save([handles.dir '/' date 'stoped_at.mat'],'i')
save([handles.dir '/' date 'Rad.mat'],'Rad')
save([handles.dir '/' date 'RadMean2.mat'],'RadMean2')
del=strfind(handles.dir,'/'); %looking for delimiter in folder name
if isempty(del)
    del=strfind(handles.dir,'\'); %because windows and mac have different delimiters
end
if isempty(del)
    del=strfind(handles.dir,'\'); %because windows and mac have different delimiters
end
save([handles.dir handles.dir(del(end-1):del(end)-1) '_all.mat'], 'counts','i','dir', 'minRad','maxRad', 'sensitivity','RadMean','RadMean2','Rad')

end
function saveall_Callback(hObject, eventdata, handles) % --- Executes on button press in saveall.
% hObject    handle to saveall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveall(handles)
end
function Undo_Callback(hObject, eventdata, handles) % --- Executes on button press in Undo.
% hObject    handle to Undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if sum(size(handles.l))==0 %the list doesn't exist
    errordlg('please load a image series')
    return
end

handles.centers=handles.centersBack; %saving for undo purpose
handles.radii=handles.radiiBack; %saving for undo purpose
handles.counts{handles.i,1}=handles.centers;
handles.counts{handles.i,2}=handles.radii;
guidata(handles.figure1, handles);
refresh(handles,1)

end

%% shortcuts for pressed keys
function figure1_WindowKeyPressFcn(hObject, eventdata, handles) % --- Executes on key press with focus on figure1 or any of its controls.
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%usefull to evaluate key name (launched independantly
%h_fig = figure;
%set(h_fig,'KeyPressFcn',@(h_obj,evt) disp(evt.Key));

%setHotkeys(hObject,handles);

switch eventdata.Key
    case 'c'
        AddCells_Callback(hObject, eventdata, handles)
    case 't'
        ClearZone_Callback(hObject, eventdata, handles)
    case'o'
        chngdir_Callback(hObject, eventdata, handles)
    case 'leftarrow'
        previous_Callback(hObject, eventdata, handles)
    case 'backspace'
        Undo_Callback(hObject, eventdata, handles)
    case 'rightarrow'
        next_Callback(hObject, eventdata, handles)
    case 'r'
        RemoveCol_Callback(hObject, eventdata, handles)
%     case 'x'    
% %         mode = 'Exploration.Pan';
% %         new_state = toggle(hObject,mode);        
%          if handles.panButton
%             pan(hObject, 'off');
%             disp ('off')
%              ReleaseFocusFromAnyUI(handles);
%          else
%              handles.panButton=1;
%              pan(hObject, 'off');
%              disp ('on')
%          end
%          guidata(handles.figure1, handles); %refresh gui for toggle
%         %updateCallbacks( hObject);%, mode );  
%     case 'z'
%         %mode = 'Exploration.ZoomIn';
%         %new_state = toggle(hObject,mode);
%         zoom(hObject,new_state);
%         updateCallbacks( hObject, mode );  
%         
%         %rabio
%         htbA=getAllChildren(findall(hObject,'Type','uitoolbar'));
%         htb=htba(3);
%         switch htb.State
%         
%         case 'on'
%             new_state = 'off';
%             
%         case 'off'
%             new_state = 'on';
%            
%         otherwise
%             error('figkeys:onKeyPress:unexpectedState',...
%                   'Unexpected button state');              
%               
%     end
        
        
        
        
    otherwise            
        return; % ignore keypress
    
end
  
end
function ReleaseFocusFromAnyUI(uiObj)
          set(uiObj, 'Enable', 'off');
          drawnow update;
          set(uiObj, 'Enable', 'on');
end


%% to implement
function AddOnlyCenters_Callback(hObject, eventdata, handles) % --- Executes on button press in AddOnlyCenters.
% hObject    handle to AddOnlyCenters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of AddOnlyCenters

handles.OnlyCenterTick=get(hObject,'Value'); %getting value
guidata(hObject,handles) %refreshing object


end
function Showdust_Callback(hObject, eventdata, handles) % --- Executes on button press in Showdust.
% hObject    handle to Showdust (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Showdust
handles.Showdust= get(hObject,'Value');
if get(hObject,'Value')
    viscircles(handles.centersDust,...
        handles.radiiDust*handles.apR,...
        'Color','b'); %ploting with small diameter to enhance visualisation
else
    refresh(handles,1)
end
% Update handles structure
guidata(handles.figure1, handles);

end

function zoomdezoom()
%% work around zoom dezomm issues
% function htb = findToolbarButton(hObject,tag)
% % Find handle of the toolbar button via it's tag. 
% % 
% % The list of tags of a regular figure (left-to-right):
% %
% %     'Standard.NewFigure'
% %     'Standard.FileOpen'
% %     'Standard.SaveFigure'
% %     'Standard.PrintFigure'
% %     'Standard.EditPlot'
% %     'Exploration.ZoomIn'  
% %     'Exploration.ZoomOut'
% %     'Exploration.Pan'
% %     'Exploration.Rotate'
% %     'Exploration.DataCursor'
% %     'Exploration.Brushing'
% %     'DataManager.Linking'
% %     'Annotation.InsertColorbarhtbA'
% %     'Annotation.InsertLegend'
% %     'Plottools.PlottoolsOff'
% %     'Plottools.PlottoolsOn'
% 
%     ht = findall(hObject,'Type','uitoolbar');
%     htbA=getAllChildren(ht);
% 
%     % We have to use getprop-or-empty() because the array htbA appears to
%     % be heterogeneous, and some its elements may miss "Tag" property.
%     tagC = cell(1,numel(htbA));
%     for i=1:numel(htbA)
%         if isprop(htbA(i),'Tag')
%             tagC{i} = htbA(i).Tag;
%         end
%     end
%     
%     [TF,loc]=ismember(tag,tagC);
%     assert(sum(TF)==1);
% loc
%     htb = htbA(loc);
% end
function children = getAllChildren( hObject )
% Performs  ch = get(hObject,'children') with ShowHiddenHandles == 'on'

old=get(0,'ShowHiddenHandles');
tmp=onCleanup(@() set(0,'ShowHiddenHandles',old));

set(0,'ShowHiddenHandles','on');
children = get(hObject,'children');

delete(tmp);

end

% htb3.ClickedCallback = ...
%     @(varargin) fkWrapper(hObject,'pan',mode);
% 
% end
% function fkWrapper(hObject,passedArg,mode)
% % Evaluate built-in matlab callback, and restore overwritten custom
% % callbacks.
% 
%     putdowntext(passedArg,gcbo);
%     updateCallbacks(hObject,mode);
%     
% end
end
