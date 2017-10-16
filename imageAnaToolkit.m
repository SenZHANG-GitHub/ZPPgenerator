function varargout = imageAnaToolkit(varargin)
% IMAGEANATOOLKIT MATLAB code for imageAnaToolkit.fig
%      IMAGEANATOOLKIT, by itself, creates a new IMAGEANATOOLKIT or raises the existing
%      singleton*.
%
%      H = IMAGEANATOOLKIT returns the handle to a new IMAGEANATOOLKIT or the handle to
%      the existing singleton*.
%
%      IMAGEANATOOLKIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEANATOOLKIT.M with the given input arguments.
%
%      IMAGEANATOOLKIT('Property','Value',...) creates a new IMAGEANATOOLKIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before imageAnaToolkit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to imageAnaToolkit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help imageAnaToolkit

% Last Modified by GUIDE v2.5 26-Apr-2014 00:20:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @imageAnaToolkit_OpeningFcn, ...
                   'gui_OutputFcn',  @imageAnaToolkit_OutputFcn, ...
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


% --- Executes just before imageAnaToolkit is made visible.
function imageAnaToolkit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to imageAnaToolkit (see VARARGIN)

% Choose default command line output for imageAnaToolkit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes imageAnaToolkit wait for user response (see UIRESUME)
% uiwait(handles.figure_Main);
setappdata(handles.figure_Main, 'img', 0);
setappdata(handles.figure_Main, 'dim', 512);
setappdata(handles.figure_Main, 'km', 0.5*pi);
setappdata(handles.figure_Main, 'rmMode', 0);
setappdata(handles.figure_Main, 'H',0);
setappdata(handles.figure_Main, 'theta',0);
setappdata(handles.figure_Main, 'rho',0);
setappdata(handles.figure_Main, 'peakThr',0.5);
setappdata(handles.figure_Main, 'peakNum',1);
setappdata(handles.figure_Main, 'FillGap',5);
setappdata(handles.figure_Main, 'MinLength',7);
setappdata(handles.figure_Main, 'Peaks',0);
setappdata(handles.figure_Main, 'Lines',0);

set(handles.extractTopLeft_pushbutton, 'Enable', 'off');
set(handles.fft2_pushbutton, 'Enable','off');
set(handles.fft2Amp_pushbutton,'Enable','off');
set(handles.saveImg_pushbutton,'Enable','off');
set(handles.canny_pushbutton,'Enable','off');
set(handles.hough_pushbutton,'Enable','off');
set(handles.houghPeak_pushbutton,'Enable','off');
set(handles.houghLines_pushbutton,'Enable','off');


set(handles.dim_edit,'String','512');
set(handles.km_text, 'String','0.5 * pi');
set(handles.km_slider, 'Value',0.5);
set(handles.peakNum_edit,'String','1');
set(handles.peakThr_text,'String','0.5 * max');
set(handles.peakThr_slider,'Value',0.5);
set(handles.FillGap_edit,'String','5');
set(handles.MinLength_edit,'String','7');

% --- Outputs from this function are returned to the command line.
function varargout = imageAnaToolkit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function km_slider_Callback(hObject, eventdata, handles)
% hObject    handle to km_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
setappdata(handles.figure_Main,'km',val*pi);
set(handles.km_text,'String',[num2str(val) ' * pi']);

% --- Executes during object creation, after setting all properties.
function km_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to km_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in geneJahne_pushbutton.
function geneJahne_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to geneJahne_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dim  = getappdata(handles.figure_Main,'dim');
km = getappdata(handles.figure_Main, 'km');
rmMode = getappdata(handles.figure_Main,'rmMode');
if rem(dim,2) == 1
    x2 = (dim-1)/2;
    x1 = -x2;
else
    x2 = dim/2;
    x1 = -x2+1;
end

[x,y] = meshgrid(x1:x2);
r = hypot(x,y);
switch rmMode
    case 0
        rm = x2;
    case 1
        rm = x2*sqrt(2);
end
w = rm/10;
term1 = sin((km*r.^2)/(2*rm));
term2 = 0.5*tanh((rm-r)/w)+0.5;
g = term1.*term2;
% g = term1;
im = (g+1)/2;
axes(handles.axes_Tag);
imshow(im);
% figure;imshow(im)
setappdata(handles.figure_Main, 'img', im);
set(handles.extractTopLeft_pushbutton, 'Enable', 'on');
set(handles.fft2_pushbutton, 'Enable','on');
set(handles.fft2Amp_pushbutton,'Enable','off');
set(handles.saveImg_pushbutton,'Enable','on');
 
% --- Executes on button press in openImg_pushbutton.
function openImg_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to openImg_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile(...
    {'*.bmp;*.jpg;*.png;*.jpeg','Image Files (*.bmp;*.jpg;*.png;*.jpeg)';...
    '*.*','All Files(*.*)'},'Pick an image');
if isequal(filename,0) || isequal(pathname,0)
    return;
end
axes(handles.axes_Tag);
fpath = [pathname filename];
img = imread(fpath);
imshow(img);
setappdata(handles.figure_Main, 'img', img);
set(handles.fft2_pushbutton,'Enable','on');
set(handles.saveImg_pushbutton,'Enable','on');
set(handles.canny_pushbutton,'Enable','on');
set(handles.hough_pushbutton,'Enable','off');
set(handles.houghPeak_pushbutton,'Enable','off');
set(handles.houghLines_pushbutton,'Enable','off');

% --- Executes on button press in extractTopLeft_pushbutton.
function extractTopLeft_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to extractTopLeft_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imTem = getappdata(handles.figure_Main,'img');
im = imTem(1:length(imTem(:,1))/2,1:length(imTem(1,:))/2);
axes(handles.axes_Tag);
imshow(im);
% figure;imshow(im)
setappdata(handles.figure_Main, 'img', im);
set(handles.extractTopLeft_pushbutton, 'Enable', 'off');
set(handles.fft2_pushbutton, 'Enable','on');
set(handles.fft2Amp_pushbutton,'Enable','off');

% --- Executes on button press in fft2_pushbutton.
function fft2_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fft2_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imTem = getappdata(handles.figure_Main,'img');
im = fft2(imTem);
axes(handles.axes_Tag);
imshow(im);
% figure;imshow(im)
setappdata(handles.figure_Main, 'img', im);
set(handles.extractTopLeft_pushbutton, 'Enable', 'off');
set(handles.fft2_pushbutton, 'Enable','off');
set(handles.fft2Amp_pushbutton,'Enable','on');

% --- Executes on button press in fft2Amp_pushbutton.
function fft2Amp_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fft2Amp_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imTem = getappdata(handles.figure_Main,'img');
im = abs(imTem);
axes(handles.axes_Tag);
imshow(im);
% figure;imshow(im)
setappdata(handles.figure_Main, 'img', im);
set(handles.extractTopLeft_pushbutton, 'Enable', 'off');
set(handles.fft2_pushbutton, 'Enable','off');
set(handles.fft2Amp_pushbutton,'Enable','off');


function dim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dim_edit as text
%        str2double(get(hObject,'String')) returns contents of dim_edit as a double
dim = get(handles.dim_edit,'String');
setappdata(handles.figure_Main,'dim',str2double(dim));


% --- Executes during object creation, after setting all properties.
function dim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
rmMode = getappdata(handles.figure_Main,'rmMode');
rmMode = 1-rmMode;
setappdata(handles.figure_Main,'rmMode',rmMode);


% --- Executes on button press in saveImg_pushbutton.
function saveImg_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveImg_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile({'*.bmp','BMP files';'*.jpg;',...
    'JPG files'},'Pick an Image');
if isequal(filename,0)|| isequal(pathname,0)
    return; 
else
    fpath = fullfile(pathname,filename); 
end
img = getappdata(handles.figure_Main,'img');
img(:,:,2) = img(:,:,1);
img(:,:,3) = img(:,:,1);
imwrite(img,fpath);


% --- Executes on button press in exit_pushbutton.
function exit_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to exit_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(findobj('Tag','figure_Main'));


% --- Executes on button press in canny_pushbutton.
function canny_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to canny_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 img = getappdata(handles.figure_Main,'img');
 if length(size(img)) == 3
     img = rgb2gray(img);
 end
 BW = edge(img,'canny');
 axes(handles.axes_Tag);
 imshow(BW);
 setappdata(handles.figure_Main,'BW',BW);
 set(handles.canny_pushbutton,'Enable','off');
 set(handles.hough_pushbutton,'Enable','on');
 set(handles.houghPeak_pushbutton,'Enable','off');
 set(handles.houghLines_pushbutton,'Enable','off');

% --- Executes on button press in hough_pushbutton.
function hough_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to hough_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BW = getappdata(handles.figure_Main,'BW');
[H,theta,rho] = hough(BW);
setappdata(handles.figure_Main,'H',H);
setappdata(handles.figure_Main,'theta',theta);
setappdata(handles.figure_Main,'rho',rho);
axes(handles.axes_Tag);
imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
    'InitialMagnification','fit');
xlabel('\theta (degrees)'),ylabel('\rho');
axis on, axis normal;
colormap(hot)
set(handles.canny_pushbutton,'Enable','off');
set(handles.hough_pushbutton,'Enable','off');
set(handles.houghPeak_pushbutton,'Enable','on');
set(handles.houghLines_pushbutton,'Enable','off');

function peakNum_edit_Callback(hObject, eventdata, handles)
% hObject    handle to peakNum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peakNum_edit as text
%        str2double(get(hObject,'String')) returns contents of peakNum_edit as a double
peakNum = get(handles.peakNum_edit,'String');
setappdata(handles.figure_Main,'peakNum',str2double(peakNum));

% --- Executes during object creation, after setting all properties.
function peakNum_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakNum_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function peakThr_slider_Callback(hObject, eventdata, handles)
% hObject    handle to peakThr_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = get(hObject, 'Value');
setappdata(handles.figure_Main,'peakThr',val);
set(handles.peakThr_text,'String',[num2str(val) ' * max'])

% --- Executes during object creation, after setting all properties.
function peakThr_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakThr_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in houghPeak_pushbutton.
function houghPeak_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to houghPeak_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
H = getappdata(handles.figure_Main,'H');
peakNum = getappdata(handles.figure_Main,'peakNum');
peakThr = getappdata(handles.figure_Main,'peakThr');
Peaks = houghpeaks(H,peakNum,'threshold',ceil(peakThr*max(H(:))));
setappdata(handles.figure_Main,'Peaks',Peaks);

theta = getappdata(handles.figure_Main,'theta');
rho = getappdata(handles.figure_Main,'rho');
axes(handles.axes_Tag);
imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
    'InitialMagnification','fit');
xlabel('\theta (degrees)'),ylabel('\rho');
axis on, axis normal,hold on;
colormap(hot)

x = theta(Peaks(:,2));
y = rho(Peaks(:,1));
plot(x,y,'s','Color','black');hold off
set(handles.canny_pushbutton,'Enable','off');
set(handles.hough_pushbutton,'Enable','off');
set(handles.houghPeak_pushbutton,'Enable','on');
set(handles.houghLines_pushbutton,'Enable','on');

% --- Executes on button press in houghLines_pushbutton.
function houghLines_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to houghLines_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
img = getappdata(handles.figure_Main,'img');
BW = getappdata(handles.figure_Main, 'BW');
theta = getappdata(handles.figure_Main,'theta');
rho = getappdata(handles.figure_Main,'rho');
Peaks = getappdata(handles.figure_Main,'Peaks');
FillGap = getappdata(handles.figure_Main,'FillGap');
MinLength = getappdata(handles.figure_Main,'MinLength');

Lines = houghlines(BW,theta,rho,Peaks,'FillGap',FillGap,'MinLength',MinLength);
axes(handles.axes_Tag);
imshow(img);hold on
max_len = 0;
for k = 1:length(Lines)
    xy = [Lines(k).point1;Lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
    % Plot beginnings and ends of lines
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    
    % Determine the endpoints of the longest line segment
    len = norm(Lines(k).point1 - Lines(k).point2);
    if(len>max_len)
        max_len = len;
        xy_long = xy;
    end
end
% highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');hold off
set(handles.canny_pushbutton,'Enable','off');
set(handles.hough_pushbutton,'Enable','off');
set(handles.houghPeak_pushbutton,'Enable','on');
set(handles.houghLines_pushbutton,'Enable','off');


function FillGap_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FillGap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FillGap_edit as text
%        str2double(get(hObject,'String')) returns contents of FillGap_edit as a double
FillGap = get(handles.FillGap_edit,'String');
setappdata(handles.figure_Main,'FillGap',str2double(FillGap));

% --- Executes during object creation, after setting all properties.
function FillGap_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FillGap_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MinLength_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MinLength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinLength_edit as text
%        str2double(get(hObject,'String')) returns contents of MinLength_edit as a double
MinLength = get(handles.MinLength_edit,'String');
setappdata(handles.figure_Main,'MinLength',str2double(MinLength));

% --- Executes during object creation, after setting all properties.
function MinLength_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinLength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function file_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function openImg_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to openImg_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveImg_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to saveImg_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function exit_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to exit_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function JahneGene_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to JahneGene_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function edit_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function JahnePattGene_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to JahnePattGene_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function extractTopLef_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to extractTopLef_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fft2_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to fft2_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fft2Amp_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to fft2Amp_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function canny_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to canny_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hough_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to hough_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function houghPeaks_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to houghPeaks_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function houghLines_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to houghLines_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function JahnePatternGenerator_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to JahnePatternGenerator_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LinesDetector_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to LinesDetector_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveAsRaw_pushbutton.
function saveAsRaw_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAsRaw_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile(...
    {'*.raw';'All Files (*.*)'},...
    'Save the img as raw file');
if isequal(filename,0)|| isequal(pathname,0)
    return; 
else
    fpath = fullfile(pathname,filename); 
end
img = getappdata(handles.figure_Main,'img');
img(:,:,2) = img(:,:,1);
img(:,:,3) = img(:,:,1);
delete(fpath);
fileID = fopen(fpath,'w');
figure;imshow(img);
fwrite(fileID,img);
fclose(fileID);
