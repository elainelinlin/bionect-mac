function varargout = gui_measureplotting_settings(varargin)
% GUI_MEASUREPLOTTING_SETTINGS MATLAB code for gui_measureplotting_settings.fig
%      GUI_MEASUREPLOTTING_SETTINGS, by itself, creates a new GUI_MEASUREPLOTTING_SETTINGS or raises the existing
%      singleton*.
%
%      H = GUI_MEASUREPLOTTING_SETTINGS returns the handle to a new GUI_MEASUREPLOTTING_SETTINGS or the handle to
%      the existing singleton*.
%
%      GUI_MEASUREPLOTTING_SETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MEASUREPLOTTING_SETTINGS.M with the given input arguments.
%
%      GUI_MEASUREPLOTTING_SETTINGS('Property','Value',...) creates a new GUI_MEASUREPLOTTING_SETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_measureplotting_settings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_measureplotting_settings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_measureplotting_settings

% Last Modified by GUIDE v2.5 05-Jun-2016 21:12:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_measureplotting_settings_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_measureplotting_settings_OutputFcn, ...
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


% --- Executes just before gui_measureplotting_settings is made visible.
function gui_measureplotting_settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_measureplotting_settings (see VARARGIN)

% Choose default command line output for gui_measureplotting_settings
handles.output = hObject;
handles.BNCT = evalin('base','BNCT');
handles.foldersuffix = handles.BNCT.configfilename.path;
handles.filenamesuffix = strrep(handles.BNCT.configfilename.file,'.mat',[]);
handles.filenameappend = date;
handles.fullfilename = horzcat(handles.foldersuffix,handles.filenamesuffix,'_(File specific info)_',handles.filenameappend);
set(findobj('Tag','filename'),'String',handles.fullfilename);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_measureplotting_settings wait for user response (see UIRESUME)
% uiwait(handles.figure1);



function varargout = gui_measureplotting_settings_OutputFcn(hObject, eventdata, handles) 
%% --- Outputs from this function are returned to the command line.
varargout{1} = handles.output;



function siglevel_Callback(hObject, eventdata, handles)
%%


function siglevel_CreateFcn(hObject, eventdata, handles)
%% --- Executes during object creation, after setting all properties.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vstime_Callback(hObject, eventdata, handles)
%% --- Executes on button press in vstime.



function vsfreq_Callback(hObject, eventdata, handles)
%% --- Executes on button press in vsfreq.



function vstask_Callback(hObject, eventdata, handles)
%% --- Executes on button press in vstask.



function showfigs_Callback(hObject, eventdata, handles)
%% --- Executes on button press in showfigs.



function savefigs_Callback(hObject, eventdata, handles)
%% --- Executes on button press in savefigs.




function filenameformat_Callback(hObject, eventdata, handles)
%%
handles.filenameappend = get(hObject,'string');
if isempty(handles.filenameappend)
    handles.filenameappend = date;
end
    
handles.fullfilename = horzcat(handles.foldersuffix,handles.filenamesuffix,'_(File specific info)_',handles.filenameappend);
set(findobj('Tag','filename'),'String',handles.fullfilename);

function filenameformat_CreateFcn(hObject, eventdata, handles)
%% --- Executes during object creation, after setting all properties.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function cancel_Callback(hObject, eventdata, handles)
%% --- Executes on button press in cancel.
close

function createplots_Callback(hObject, eventdata, handles)
%% --- Executes on button press in createplots.
vstime = get(handles.vstime,'val');
vsfreq = get(handles.vsfreq,'val');
vstask = get(handles.vstask,'val');
siglevel = get(handles.siglevel,'string');
siglevel = str2num(siglevel);
showfigs = get(handles.showfigs,'val');
savefigs = get(handles.savefigs,'val');
local = get(handles.uselocal,'val');
channels = get(handles.channels,'val');
fileinfo.foldersuffix = handles.BNCT.configfilename.path;
fileinfo.filenamesuffix = strrep(handles.BNCT.configfilename.file,'.mat',[]);
fileinfo.filenameappend = get(handles.filenameformat,'string');
if isempty(fileinfo.filenameappend)
    fileinfo.filenameappend = date;
end

if local == 1
    gui_measureplotting_local(handles.BNCT,siglevel,savefigs,vstime,vstask,vsfreq,showfigs,fileinfo,channels);
else
    gui_measureplotting(handles.BNCT,siglevel,savefigs,vstime,vstask,vsfreq,showfigs,fileinfo);
end

% --- Executes on button press in uselocal.
function uselocal_Callback(hObject, eventdata, handles)
% hObject    handle to uselocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.channels,'string',handles.BNCT.chanord.(handles.BNCT.chanord.method).labels)
% Hint: get(hObject,'Value') returns toggle state of uselocal


% --- Executes on selection change in channels.
function channels_Callback(hObject, eventdata, handles)
% hObject    handle to channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channels


% --- Executes during object creation, after setting all properties.
function channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
