function varargout = gui_main(varargin)
% gui_main MATLAB code for gui_main.fig
%      gui_main, by itself, creates a new gui_main or raises the existing
%      singleton*.
%
%      H = gui_main returns the handle to a new gui_main or the handle to
%      the existing singleton*.
%
%      gui_main('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gui_main.M with the given input arguments.
%
%      gui_main('Property','Value',...) creates a new gui_main or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_main

% Last Modified by GUIDE v2.5 03-Mar-2016 10:16:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_main_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_main_OutputFcn, ...
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


% --- Executes just before gui_main is made visible.
function gui_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_main (see VARARGIN)

% Choose default command line output for gui_main
handles.output = hObject;
%loadState(handles);
handles.BNCT = evalin('base','BNCT');

% Update handles structure

try
%configfilename = evalin('base','configfilename');
configfilename = handles.BNCT.configfilename;
%configname = strcat('Analysis File: ',configfilename.file);
configname = ['Analysis File: ',configfilename.file];
set(findobj('Tag','AnalysisName'),'String',configname)
analysisfile = strcat(configfilename.path,configfilename.file);
evalin('base',['load(''', analysisfile ''')']);
handles.BNCT = evalin('base','BNCT');
batchfile = handles.BNCT.batchfile;%evalin('base','batchfile');
set(findobj('Tag','cohbatchfile'),'String',['Wrapper File: ',batchfile.file])
catch
end
handles.BNCT = evalin('base','BNCT');
guidata(hObject, handles);


%global alldata;
% UIWAIT makes gui_main wait for user response (see UIRESUME)
% uiwait(handles.gui_main);


% --- Outputs from this function are returned to the command line.
function varargout = gui_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%

function gui_main_CloseRequestFcn(hObject, eventdata, handles)
%% --- Executes when user attempts to close gui_main.

% Hint: delete(hObject) closes the figure
warnuser = questdlg('Save current analysis/workspace variables/results?', 'Warning','Yes');
switch warnuser
    case 'Yes';
        menu_saveanalysis_Callback(hObject, eventdata, handles)
      delete(hObject);
    case 'No';
        delete(hObject);
    case 'Cancel';
        return
end



function cohbatchfile_Callback(hObject, eventdata, handles)
%

function cohbatchfile_CreateFcn(hObject, eventdata, handles)
%% --- Executes during object creation, after setting all properties.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%                DATA LOGGING                %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in logdata.
function logdata_Callback(hObject, eventdata, handles)
% hObject    handle to logdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.BNCT = evalin('base','BNCT');
%%                          CREATE FILE NAME
%logfilename = get(handles.logfilename,'string');
configfilename = handles.BNCT.configfilename;%evalin('base','configfilename');
c = clock;
%include file location
logfilename = strcat(configfilename.path,strrep(configfilename.file,'.mat',[]),strcat('_Logfile_',date,'_',num2str(c(4)),'_',num2str(c(5)),'_',num2str(round(c(6)))),'.txt');

%%                          BATCH PROCESSING PANEL
batch_freqrange = handles.BNCT.config.freqrangelistraw;
batch_percentdata = handles.BNCT.config.batch_percentdata;
batch_chnlist = handles.BNCT.config.batch_chnlist;
batchfile = handles.BNCT.batchfile;
batch_timerange = handles.BNCT.config.batch_timerange;
phenotypelistraw = handles.BNCT.config.phenotypelistraw;
tasklistraw = handles.BNCT.config.tasklistraw;
batchdata = ['===MAIN/BATCH COHERENCE SETTINGS===';'Analysis File:';...
    strcat(configfilename.path,configfilename.file);...
   % 'Analysis File:'; strcat(analysispath,analysisfile); ...
    'Batch File:';strcat(batchfile.path,batchfile.file);...
    'Frequency Ranges:';batch_freqrange;
    'Channel List:';mat2str(batch_chnlist);...
    'Percent Data:';mat2str(batch_percentdata);...
    'Time Ranges (ms):';batch_timerange;...
    'Tasks:';tasklistraw;...
    'Phenotypes:';phenotypelistraw];

dlmcell(logfilename,batchdata,'\t')

%%                           GRAPH THEORY PANEL
try
    thr = handles.BNCT.threshold;%evalin('base','threshold');
    threshold = {'===GRAPH ANALYSIS SETTINGS===';'Upper/Multiplier Threshold:';...
        num2str(thr.highx);'Lower Threshold:';mat2str(thr.low);'Threshold Method:';
        thr.method};
    dlmcell(logfilename,threshold,'\t','-a')
catch
    threshold = {'**Graph theory measures not calculated.'};
    dlmcell(logfilename,threshold,'\t','-a')
end

%%                          POWER ANALYSIS
try
    PowerFeatureNames = handles.BNCT.PowerFeatureNames;%evalin('base','PowerFeatureNames'); %%%%%%%%%%%%%%%%Error here
    power = ['===SPECTRAL ANALYSIS SETTINGS===';'Powers Calculated:';...
        '(Freq Range/Electrodes/Time Range)';PowerFeatureNames];
    dlmcell(logfilename,power,'\t','-a');
catch
    power = {'**Spectral power not calculated.'};
    dlmcell(logfilename,power,'\t','-a');
end
%%                        FEATURE SELECTION PANEL
try
numfeat = handles.BNCT.numfeat;%evalin('base','numfeat');
catch
end
selectionmethod = handles.BNCT.selectionmethod;
tasklistraw = handles.BNCT.config.tasklistraw;
freqrangelistraw = handles.BNCT.config.freqrangelistraw;
TopFeatures = handles.BNCT.TopFeatures;

%ADJUST TASK NAMES
[tasklist] = gui_tasklist(tasklistraw);

%WRITE TOP FEATURES FOR RESPECTIVE SELECTION METHOD
switch selectionmethod
    case 'Single'
        %if strcmp(selectionmethod,'Single')
        features = [];
        for task = 1:1:length(tasklist)
            for freq = 1:1:length(freqrangelistraw)
                features = [features;strcat('>Top Features for: Task-',tasklist{task},', Freq Range-',...
                    freqrangelistraw{freq});TopFeatures.Names.(tasklist{task}){1,freq}'];
            end
        end
    case 'Combo'
%elseif strcmp(selectionmethod,'Combo')%
        features = [strcat('>Top Features for: Tasks-',', Frequency Ranges-'); TopFeatures.Names'];
    case 'Manual'
%elseif strcmp(selectionmethod,'Manual')
        FeatureNames = handles.BNCT.FeatureNames;
        features = ['>Selected Features:';FeatureNames'];
end

           
featuresel = ['===FEATURE ANALYSIS SETTINGS===';'Selection Method:';selectionmethod;...
    'Number of Features to Use:';numfeat;'Selected Features/Top Features:';features];
dlmcell(logfilename,featuresel,'\t','-a')

%%                          CLASSIFIER SETTINGS

svm = handles.BNCT.svm;%evalin('base','svm');
svmlog = {'===SVM CLASSIFIER SETTINGS===';'Classifier Type:';svm.method;...
    'Hold-out Ratio:';num2str(svm.holdout_ratio);...
    'Number of Folds:';num2str(svm.folds);'Dimensionality Reduction Method:';...
    svm.dim_method;'Number of Iterations:';num2str(svm.tst_no);...
    '% Data Training Set';svm.train_pct};

dlmcell(logfilename,svmlog,'\t','-a');

%%                              RESULTS
classacc = {'===SVM Group Classification Results===';'SVM Classifier Accuracy:'};
dlmcell(logfilename,classacc,'\t','-a');

%HARD CODED RESULTS FOR NUM OF FREQUENCIES AND TASKS...
%comb_method = get(handles.comb_method,'value');
selectionmethod = handles.BNCT.selectionmethod;
Results = handles.BNCT.Results;
sensi = handles.BNCT.sensi;
speci = handles.BNCT.speci;
if strcmp(selectionmethod,'Single')%comb_method == 1
    tasklistraw = handles.BNCT.config.tasklistraw;
    result_labels1 = tasklistraw';
    freqlabellistraw = handles.BNCT.config.freqlabellistraw;
    
    %CONCATENATE RESULTS INTO FREQ X TASK MATRIX
    testcell = cell(size(freqrangelistraw,1)+1,size(tasklistraw,1)+1);
    testcell(1,2:end) = tasklistraw';
    testcell(2:end,1) = freqlabellistraw;
    result = testcell;    
    result(2:1+size(Results,1),2:1+size(Results,2)) = Results;
    sensiresult = testcell;
    sensiresult(2:1+size(Results,1),2:1+size(Results,2)) = sensi;
    speciresult = testcell;
    speciresult(2:1+size(Results,1),2:1+size(Results,2)) = speci;
   %{
    emptyIndex = cellfun(@isempty,Results);       %# Find indices of empty cells
    Results(emptyIndex) = {0};
    [x y] = size(Results);
    
    %# OF FREQUENCIES
    if x < length(batch_freqlabel)
        Results(x+1:length(batch_freqlabel),:) = {0};
    end
    
    %# OF TASKS
    if y < length(tasklistraw)
        Results(:,y+1:length(tasklistraw)) = {0};
    end
    result_temp = [result_labels1;Results];
    
    result_labels2{1} = [];
    for i = 1:1:length(batch_freqlabel)
        result_labels2{i+1} = batch_freqlabel{i};
    end
    
    result = [result_labels2' result_temp];
    %}
elseif strcmp(selectionmethod,'Combo')%comb_method == 2    
   result = {Results};
   sensi = {sensi};
   speci = {speci};
elseif strcmp(selectionmethod,'Manual')%comb_method == 3   
   result = {Results};
   sensi = {sensi};
   speci = {speci};
end

dlmcell(logfilename,result,'\t','-a');
dlmcell(logfilename,{'Sensitivity:'},'\t','-a');
dlmcell(logfilename,sensiresult,'\t','-a');
dlmcell(logfilename,{'Specificity:'},'\t','-a');
dlmcell(logfilename,speciresult,'\t','-a');
disp(strcat('File Saved to: ',logfilename));

set(findobj('Tag','Status'),'String','Status: File Saved!');





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               FILE TAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menu_File_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%          SAVE FILE          %%%%%%%%%%%%%%%%%%%%%%%
    function menu_new_analysis_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
warnuser = questdlg('Save current analysis/workspace variables/results?', 'Warning','Yes');
switch warnuser
    case 'Yes';
        %     saveworkspace_Callback(hObject, eventdata, handles)
        %  msgbox('Workspace variables saved!');
        %should eventually replace with clear bionect.struc or something
        menu_saveanalysis_Callback(hObject, eventdata, handles)
        
        [file,path] = uiputfile('*.mat','Create New Analysis');
        if file ~= 0
            configfile = strcat(path,file);
            configtemp = handles.BNCT.config;
          %  evalin('base', ['save(''', configfile ''')']);
          %  assignin('base','configfilename',configfilename);          
            evalin('base',['clear BNCT']);
            %handles.BNCT = evalin('base','BNCT');
%%%%%%%%%%%   %May want to save chorder/allmeasures/etc
            handles.BNCT = [];
            handles.BNCT.config = configtemp;
            handles.BNCT.configfilename.file = file;
            handles.BNCT.configfilename.path = path; 
            assignin('base','BNCT',handles.BNCT);
            BNCT = evalin('base','BNCT');
            save(configfile,'BNCT');
            disp('New analysis created.');
           
            set(handles.AnalysisName,'string',['Analysis Name: ',file]);
         %   set(findobj('Tag','AnalysisName'),'String',configname)
        end
    case 'No';
        [file,path] = uiputfile('*.mat','Create New Analysis');
        if file ~= 0
            configfile = strcat(path,file);
            configtemp = handles.BNCT.config;
            %evalin('base', ['save(''', configfile ''')']);
            evalin('base',['clear BNCT']);
           % configfilename.file = file;
           % configfilename.path = path;
            handles.BNCT = [];
            handles.BNCT.config = configtemp;
            handles.BNCT.configfilename.file = file;
            handles.BNCT.configfilename.path = path; 
            %assignin('base','configfilename',configfilename);
            assignin('base','BNCT',handles.BNCT);
            
            BNCT = evalin('base','BNCT');
            save(configfile,'BNCT');
            disp('New analysis created.');
          %  evalin('base',['clear AllFeatures CalcPowerFeatures FeatureNames ForcedFeatures PowerFeatureNames PowerFeatures Results TopFeatures abs_power graph_features power_features rel_power analysisfile analysispath featureclass numfeat selectionmethod svm configfilename ForcedFeaturesTemp PowerFeaturesTemp']);
            
            set(handles.AnalysisName,'string',['Analysis Name: ',file]);
        end
    case 'Cancel';
        return
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%         LOAD FILE             %%%%%%%%%%%%%%%%%%%%%
    function menu_load_analysis_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE

[file,path] = uigetfile('*.mat','Load Analysis File');
if file ~=0
    analysisfile = strcat(path,file);
    evalin('base',['load(''', analysisfile ''')']);
  %  analysisname = strcat('Analysis Name: ',file);
    analysisname = ['Analysis Name: ',file];
    set(findobj('Tag','AnalysisName'),'String',analysisname)
  %  configfilename.file = file; %%%%REMOVED AS INCLUDED IN BNCT
  %  configfilename.path = path;
   % assignin('base','configfilename',configfilename);
    disp('Analysis Loaded.');
    msgbox('Analysis loaded.');
end

%%%%%%%%%%%%%%%%%%%%%        BATCH FILE               %%%%%%%%%%%%%%%%%%%%%
function menu_batch_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A


    function menu_batch_create_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE
Labels = {'Working Folder' 'EEG Dataset Name' 'To Be Processed (yes/no)' 'Processed' ...
    'Time Range in ms' 'Montage Name' 'Phenotype' 'Subject ID' 'Task'};
Example = {'C:\Documents\BioNeCT\Subject001\data'...
    'Subject001-Resting.set'...
    'yes'...
    []...
    []...
    []...
    'Control'...
    'Subject001'...
    'Resting'};

[file,path] = uiputfile('*.mat','Create New Batch File (.mat)');
filename = strcat(path,file);
if file ~= 0 
batch = [Labels;Example];
save(filename,'batch')
% csvwrite(filename,[1,2]);
% fileID = fopen(filename,'w'); % since Mac system cannot use xlswrite for cell arrays
% formatSpec = '%s %s %s %s %s %s %s %s\n';
% [nrows,ncols] = size(C);
% for row = 1:nrows
%     fprintf(fileID,formatSpec,C{row,:});
% end
% fclose(fileID);
% type(filename)

%ADJUST CELL SIZES/HEADERS
% ExcelApp=actxserver('excel.application');
% ExcelApp.Visible=1;
% NewWorkbook=ExcelApp.Workbooks.Open(strcat(path,file));   
% NewSheet=NewWorkbook.Sheets.Item(1);
% NewRange=NewSheet.Range('A1');
% NewRange.ColumnWidth=40;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('B1');
% NewRange.ColumnWidth=30;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('C1');
% NewRange.ColumnWidth=15;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('D1');
% NewRange.ColumnWidth=10;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('E1');
% NewRange.ColumnWidth=15;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('F1');
% NewRange.ColumnWidth=15;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('G1');
% NewRange.ColumnWidth=10;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('H1');
% NewRange.ColumnWidth=10;
% set(NewRange.Font,'Underline',true,'Bold',true);
% NewRange=NewSheet.Range('I1');
% NewRange.ColumnWidth=12;
% set(NewRange.Font,'Underline',true,'Bold',true);
end
%USE computer COMMAND TO FIND OS
if ispc %adjust for OS ismac, isunix. Need open commands. In future would check OS early in program and set flag
%winopen(strcat(path,file));
end


    function menu_batch_load_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE
[file, path, filterindex] = uigetfile('*.mat','Load Batch File');

if file == 0
else 
    set(handles.cohbatchfile,'string',['Wrapper File: ',file]);
    handles.BNCT.batchfile.file = file;
    handles.BNCT.batchfile.path = path;
    assignin('base','BNCT',handles.BNCT);
    
end
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%       SAVE ANALYSIS             %%%%%%%%%%%%%%%%%%%%% 
    function menu_saveanalysis_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE
handles.BNCT = evalin('base','BNCT');
BNCT = handles.BNCT;
configfile = strcat(BNCT.configfilename.path,BNCT.configfilename.file);
save(configfile,'BNCT');
        disp('Analysis saved.');
        msgbox('Analysis saved.');

guidata(hObject, handles);


    function menu_saveanalysisas_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE 
handles.BNCT = evalin('base','BNCT');
BNCT = handles.BNCT;
try 
    [file,path] = uiputfile('*.mat','Save Analysis As',BNCT.configfilename.file);
catch
    [file,path] = uiputfile('*.mat','Save Analysis As');
end
if file ~= 0
    configfile = strcat(path,file);
    BNCT.configfilename.file = file;
    BNCT.configfilename.path = path;
    assignin('base','BNCT',BNCT);
    save(configfile,'BNCT');
    handles.BNCT = BNCT;
    set(findobj('Tag','AnalysisName'),'String',['Analysis Name: ',BNCT.configfilename.file])
    msgbox('Analysis Saved.');
end
guidata(hObject, handles);

function menu_exit_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_main_CloseRequestFcn(hObject, eventdata, handles)



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               CONFIG TAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menu_config_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A 

    function menu_config_config_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE

gui_batchsettings
warning off
uiwait


function menu_defineclusters_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
%gui_definechanorder_popup;
gui_defineclusters;
%uiwait 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               RUN TAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menu_run_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A
 

    function menu_run_coh_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE


        function menu_run_magcoh_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------

            % --------------------------------------------------------------------
            function menu_run_magcoh_cluster_Callback(hObject, eventdata, handles)
%%
handles.BNCT = evalin('base','BNCT');
filename = strcat(handles.BNCT.batchfile.path,handles.BNCT.batchfile.file);
batch_freqrange = handles.BNCT.config.freqrangelistraw;
batch_percentdata = handles.BNCT.config.batch_percentdata;
batch_chnlist = handles.BNCT.config.batch_chnlist;
batch_timerange = handles.BNCT.config.batch_timerange;


analysisfile = strrep(handles.BNCT.configfilename.file,'.mat','');
warnuser = questdlg('Coherence batch processing may take up to several hours. It may also overwrite existing files. Continue?', 'Warning','Yes');
switch warnuser
    case 'Yes';
    case 'No';
        return
    case 'Cancel';
        return
end
for k = 1:1:size(batch_freqrange,1)
    freq_bin(k,1:2) = str2num(batch_freqrange{k});
end
for j = 1:1:size(batch_timerange,1)
    batch_timebin(j,1:2) = str2num(batch_timerange{j});
end
cohtype = 'magcoh_cluster';
method = 'channel';
handles.BNCT.method = method;
handles.BNCT.cohtype = cohtype;
assignin('base','BNCT',handles.BNCT);
gui_batch_spec_coh_plot_partial_elec(filename,analysisfile,batch_percentdata,batch_chnlist,freq_bin,batch_timebin,cohtype,method)
msgbox('Batch coherence processing complete!');
guidata(hObject, handles);

% --------------------------------------------------------------------
            function menu_run_magcoh_single_Callback(hObject, eventdata, handles)
%%

handles.BNCT = evalin('base','BNCT');
filename = strcat(handles.BNCT.batchfile.path,handles.BNCT.batchfile.file);
batch_freqrange = handles.BNCT.config.freqrangelistraw;
batch_percentdata = handles.BNCT.config.batch_percentdata;
batch_chnlist = handles.BNCT.config.batch_chnlist;
batch_timerange = handles.BNCT.config.batch_timerange;


analysisfile = strrep(handles.BNCT.configfilename.file,'.mat','');
warnuser = questdlg('Coherence batch processing may take up to several hours. It may also overwrite existing files. Continue?', 'Warning','Yes');
switch warnuser
    case 'Yes';
    case 'No';
        return
    case 'Cancel';
        return
end
for k = 1:1:size(batch_freqrange,1)
    freq_bin(k,1:2) = str2num(batch_freqrange{k});
end
for j = 1:1:size(batch_timerange,1)
    batch_timebin(j,1:2) = str2num(batch_timerange{j});
end
cohtype = 'magcoh';
method = 'channel';
handles.BNCT.connmethod = method;
%handles.BNCT.coherence.method = 'source';
handles.BNCT.cohtype = cohtype;%'mag'
assignin('base','BNCT',handles.BNCT);
gui_batch_spec_coh_plot_partial_elec(filename,analysisfile,batch_percentdata,batch_chnlist,freq_bin,batch_timebin,cohtype,method)
msgbox('Batch coherence processing complete!');
guidata(hObject, handles);

        function menu_run_phasecoh_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
handles.BNCT = evalin('base','BNCT');
filename = strcat(handles.BNCT.batchfile.path,handles.BNCT.batchfile.file);
batch_freqrange = handles.BNCT.config.freqrangelistraw;
batch_percentdata = handles.BNCT.config.batch_percentdata;
batch_chnlist = handles.BNCT.config.batch_chnlist;
batch_timerange = handles.BNCT.config.batch_timerange;

analysisfile = strrep(handles.BNCT.configfilename.file,'.mat','');
warnuser = questdlg('Coherence batch processing may take up to several hours. It may also overwrite existing files. Continue?', 'Warning','Yes');
switch warnuser
    case 'Yes';
    case 'No';
        return
    case 'Cancel';
        return
end
for k = 1:1:size(batch_freqrange,1)
    freq_bin(k,1:2) = str2num(batch_freqrange{k});
end
for j = 1:1:size(batch_timerange,1)
    batch_timebin(j,1:2) = str2num(batch_timerange{j});
end
cohtype = 'phasecoh';
method = 'channel';
handles.BNCT.connmethod = method;
handles.BNCT.cohtype = 'phasecoh';
assignin('base','BNCT',handles.BNCT);
gui_batch_spec_coh_plot_partial_elec(filename,analysisfile,batch_percentdata,batch_chnlist,freq_bin,batch_timebin,cohtype,method)
msgbox('Batch coherence processing complete!');
guidata(hObject, handles);

    function menu_run_loadmat_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE

handles.BNCT = evalin('base','BNCT');
filename = strcat(handles.BNCT.batchfile.path,handles.BNCT.batchfile.file);

load(filename,'batch');
handles.BNCT.raw = batch; %{2:end,:};
handles.BNCT.raw(1,:) = [];
%assignin('base','raw',raw);
[m,~] = size(handles.BNCT.raw);
i = 1;
while i <= m
    if strcmp(handles.BNCT.raw{i,3},'no')
        handles.BNCT.raw(i,:) = [];
        m = m - 1;
        i = i - 1;
    end
    i = i + 1;
end
assignin('base','BNCT',handles.BNCT);
try
    chanord = handles.BNCT.chanord;%evalin('base','chanord');
catch
    handles.BNCT.chanord.orig.labels = {};
    handles.BNCT.chanord.new.labels = {};
    handles.BNCT.chanord.orig.locs = [];
    handles.BNCT.chanord.new.locs = [];
    handles.BNCT.chanord.method = {};
  %  assignin('base','chanord',chanord);
    
end
disp('Storing reference EEG data (first file in batch file)');
handles.BNCT.EEG = pop_loadset(strcat(handles.BNCT.raw{1,1},handles.BNCT.raw{1,2}));
assignin('base','BNCT',handles.BNCT);
gui_loaddata_chorder;
uiwait
%Add popup to reorder channels

try
runval = evalin('base','runval');
catch
    runval = 0;
end
%runval = 0;
if runval == 1
    handles.BNCT = evalin('base','BNCT');
    datafolder = handles.BNCT.datafolder;
    %  chanord = evalin('base','chanord');
    handles.BNCT = evalin('base','BNCT');
    disp('Loading data...');
    [alldata, raw, SubjectIDs, Missing, tasklist] = gui_loaddata(handles.BNCT,filename,datafolder,handles.BNCT.config.tasklistraw,handles.BNCT.config.phenotypelistraw,handles.BNCT.chanord);
    
    prog = strcat('Data loaded for (',num2str(size(raw,1)),') instances!');
    disp(prog);
    %chanord = evalin('base','chanord');
    switch handles.BNCT.chanord.method
        case 'orig'
            msgbox('Data loaded with original .set channel locations');
        case 'new'
            msgbox('Data loaded with new channel locations');
    end
    %   msgbox(sprintf('Data loaded!');
    handles.BNCT.alldata = alldata;
    handles.BNCT.raw = raw;
    handles.BNCT.SubjectIDs = SubjectIDs;
    handles.BNCT.Missing = Missing;
    handles.BNCT.config.tasklist = tasklist;
    assignin('base','BNCT',handles.BNCT);
else
end

set(findobj('Tag','Status'),'String','Status: Data Loaded!')
guidata(hObject,handles);

    function menu_run_graph_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------

handles.BNCT = evalin('base','BNCT');
gui_graphanalysis;
uiwait;
try
runval = evalin('base','runval');
catch 
    runval = 0;
end
if runval == 1
   % msgbox('Graph measures complete!');
    set(findobj('Tag','Status'),'String','Status: Graph Measures Complete!')
end
evalin('base',['clear ','runval']);
guidata(hObject,handles);

    function menu_run_power_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- DONE
handles.BNCT = evalin('base','BNCT');

gui_multiplepowers;
uiwait;
try
runval = evalin('base','runval');
catch 
    runval = 0;
end
if runval == 1
    handles.BNCT = evalin('base','BNCT');
    CalcPowerFeatures = handles.BNCT.CalcPowerFeatures;%evalin('base','CalcPowerFeatures');
    [abs_power rel_power] = gui_power_calculation(handles.BNCT,handles.BNCT.raw,handles.BNCT.config.tasklistraw,CalcPowerFeatures,handles.BNCT.config.phenotypelistraw);
    evalin('base',['clear ','runval']);
    msgbox('Power calculatations complete!');
    set(findobj('Tag','Status'),'String','Status: Power calculations complete!')
    handles.BNCT.abs_power = abs_power;
    handles.BNCT.rel_power = rel_power;
end
assignin('base','BNCT',handles.BNCT);
   evalin('base',['clear ','runval']);
guidata(hObject,handles);
   
   
    function menu_run_featuresel_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
handles.BNCT = evalin('base','BNCT');
gui_featureanalysis;
uiwait;
try
    runval = evalin('base','runval');
catch 
    runval = 0;
end
if runval == 1
    gui_topfeatures_popup;
      %  msgbox('Top features extracted!');
        set(findobj('Tag','Status'),'String','Status: Top features extracted!')
end
evalin('base',['clear ','runval']);
guidata(hObject,handles);


    function menu_run_svm_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_runclassifier;
uiwait;
try
    runval = evalin('base','runval');
catch 
    runval = 0;
end
if runval == 1
    disp('All SVM group classification accuracies have been stored in Results in freq (row) x task (column) format');
    msgbox('SVM group classification complete & logged!');
    logdata_Callback(hObject,eventdata,handles)
    set(findobj('Tag','Status'),'String','Status: SVM group classification completed & logged!')
end
evalin('base',['clear ','runval']);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               VIEW TAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menu_view_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A


    function menu_view_coh_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
handles.BNCT = evalin('base','BNCT');
raw = handles.BNCT.raw;%evalin('base','raw');
configfilename = handles.BNCT.configfilename;%evalin('base','configfilename');
analysisfile = strrep(configfilename.file,'.mat','');
%EEG = pop_loadset(strcat(raw(1,1),'\',raw(1,2)));
%assignin('base','EEG',EEG);

gui_coherencetopo


function menu_view_graphmeasures_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_measuretopo;


function menu_view_groupcomparisons_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_groupfeaturecomparison

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               EXPORT TAB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function menu_export_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A

    function menu_export_features_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A

        function menu_export_features_all_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
handles.BNCT = evalin('base','BNCT');
allmeasures = handles.BNCT.allmeasures;
tasklistraw = handles.BNCT.config.tasklistraw;
batch_timerange = handles.BNCT.config.batch_timerange;
numtimebins = size(batch_timerange,1);
graph_features = handles.BNCT.graph_features;
power_features = handles.BNCT.power_features;

numfeat = handles.BNCT.numfeat;
freqlabellistraw = handles.BNCT.config.freqlabellistraw;
freqrangelistraw = handles.BNCT.config.freqrangelistraw;
numfreqs = length(freqlabellistraw);

phenotypelistraw = handles.BNCT.config.phenotypelistraw;


try 
    abs_power = handles.BNCT.abs_power;
    rel_power = handles.BNCT.rel_power;
    CalcPowerFeatures = handles.BNCT.CalcPowerFeatures;
    PowerFeatureNames = handles.BNCT.PowerFeatureNames;
catch
    abs_power = [];
    rel_power = [];
    CalcPowerFeatures = [];%?????????????? CalcPowerFeatures?
    PowerFeatureNames = [];
end
AllFeatures = handles.BNCT.AllFeatures;
FeatureNames = handles.BNCT.FeatureNames;
featureclass = handles.BNCT.featureclass;
%Could try and just pull AllFeatures, but may not be there if another
%feature selection method was used?
%[AllFeatures TopFeatures FeatureNames featureclass] = gui_fisher(allmeasures,tasklistraw,numtimebins,numfreqs,graph_features,power_features,abs_power,rel_power,numfeat,phenotypelistraw,CalcPowerFeatures,PowerFeatureNames,freqrangelistraw,batch_timerange);

%try
%AllFeatures = handles.AllFeatures;
%TopFeatures = handles.TopFeatures;
%FeatureNames = handles.FeatureNames;
%featureclass = handles.featureclass;
%catch
%    msgbox('Features not yet calculated'
%ADJUST TASK NAMES IF NECESSARY
tasklist = tasklistraw;
warn = 0;
for j = 1:1:length(tasklist)
    warncount = 0;
    while any(str2num(tasklist{j}(1)))
        tasklist{j} = circshift(tasklist{j},[1 -1]);
        warncount = warncount + 1;
        if warncount > length(tasklist{j})
            h = warndlg('Invalid task name. Task names cannot be entirely numerical.');
            warn = 1;
            break
        end
    end
    if warn == 1
        return
    end
end

SubjectIDs = handles.BNCT.SubjectIDs;%evalin('base','SubjectIDs');
for task = 1:1:length(tasklist)
    SubjectIDtemp = [];
    for b = 1:1:length(phenotypelistraw)
        SubjectIDtemp = [SubjectIDtemp;SubjectIDs.(phenotypelistraw{b}).(tasklist{task})];
    end
     SubjectID.(tasklist{task}) = SubjectIDtemp;
end
    
count = 1;
h = waitbar(0,'Exporting Feature Set...');

% [file,path] = uiputfile('*.mat','Create New Batch File (.mat)');
% filename = strcat(path,file);
% if file ~= 0 
% batch = [Labels;Example];
% save(filename,'batch')

[file,path] = uiputfile('*.mat','Save As');
    if file ~= 0
        mkdir(strcat(path,file(1:end-4)));
        for task = 1:1:length(tasklist)
            for freq = 1:1:length(freqlabellistraw)
                toSave = {};
                %WRITE FEATURE LABELS
                toSave{1,1} = 'Subject IDs';
                toSave{1,2} = 'Phenotype';
                
                [~,max] = size(FeatureNames.(tasklist{task}){freq});
                for i = 1:max
                    toSave{1,2+i} = FeatureNames.(tasklist{task}){freq}{i};
                end

 %               xlswrite(strcat(path,file),FeatureNames.(tasklist{task}){freq},strcat(tasklistraw{task},',',freqlabellistraw{freq}),'C1')
                %WRITE DATA
                
                [rmax,cmax] = size(AllFeatures.(tasklist{task}){freq});
                for i = 1:cmax
                    for j = 1:rmax
                        toSave{1+j,2+i} = AllFeatures.(tasklist{task}){freq}(j,i);
                    end
                end
 %               xlswrite(strcat(path,file),AllFeatures.(tasklist{task}){freq},strcat(tasklistraw{task},',',freqlabellistraw{freq}),'C2');
                
                %WRITE SUBJECT CLASS LABELS
                classlist = [];
                for subjects = 1:1:length(featureclass{task})
                    classlist{subjects} = phenotypelistraw{featureclass{task}(subjects)};
                end
                
                [~,max] = size(classlist);
                for i = 1:max
                    toSave{1+i,2} = classlist{i};
                    toSave{1+i,1} = SubjectID.(tasklist{task}){i};
                end
                %xlswrite(strcat(path,file),classlist',strcat(tasklistraw{task},',',freqlabellistraw{freq}),'B2');
                %xlswrite(strcat(path,file),SubjectID.(tasklist{task}),strcat(tasklistraw{task},',',freqlabellistraw{freq}),'A2');
                count = count+1;
                waitbar(count/(length(tasklist)*length(freqlabellistraw)),h);
                
                save(strcat(path,file(1:end-4),'/',tasklistraw{task},',',freqlabellistraw{freq},'.mat'),'toSave')
            end
        end
    end
close(h)


        function menu_export_features_top_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
% NOT YET FIXED FOR MAC SYSTEM
handles.BNCT = evalin('base','BNCT');
TopFeatures = handles.BNCT.TopFeatures;
tasklistraw = handles.BNCT.config.tasklistraw;
phenotypelistraw = handles.BNCT.config.phenotypelistraw;
freqlabellistraw = handles.BNCT.config.freqlabellistraw;
featureclass = handles.BNCT.featureclass;
tasklist = handles.BNCT.config.tasklist;

SubjectIDs = handles.BNCT.SubjectIDs;
for task = 1:1:length(tasklist)
    SubjectIDtemp = [];
    for b = 1:1:length(phenotypelistraw)
        SubjectIDtemp = [SubjectIDtemp;SubjectIDs.(phenotypelistraw{b}).(tasklist{task})];
    end
     SubjectID.(tasklist{task}) = SubjectIDtemp;
end

[file,path] = uiputfile('*.xlsx','Save As');
if file ~=0
try x = fieldnames(TopFeatures.(phenotypelistraw{1}));
    %FOR EXPORTING TASK/FREQ STRUCTURE OF ALL INDIVIDUAL FEATURE SETS
    h = waitbar(0,'Exporting Top Features...');
    count = 1;
    for task = 1:1:length(tasklist)
        for freq = 1:1:length(freqlabellistraw)
            xlswrite(strcat(path,file),TopFeatures.Names.(tasklist{task}){freq},strcat(tasklist{task},',',freqlabellistraw{freq}),'C1')
            features = [];
            for pheno = 1:1:length(phenotypelistraw)
                features = [features;TopFeatures.(phenotypelistraw{pheno}).(tasklist{task}){freq}];
            end
            xlswrite(strcat(path,file),features,strcat(tasklist{task},',',freqlabellistraw{freq}),'C2');
            classlist = [];
            for subjects = 1:1:length(featureclass{task})
                classlist{subjects} = phenotypelistraw{featureclass{task}(subjects)};
            end
            xlswrite(strcat(path,file),classlist',strcat(tasklist{task},',',freqlabellistraw{freq}),'B2');
            xlswrite(strcat(path,file),SubjectID.(tasklist{task}),strcat(tasklist{task},',',freqlabellistraw{freq}),'A2');
            count = count+1;
            waitbar(count/(length(tasklist)*length(freqlabellistraw)),h);
        end
    end
    close(h);
catch
    %FOR EXPORTING SINGLE FEATURE SETS (IE ALREADY COMBINED OR MANUALLY
    %CHOSEN
    h = waitbar(0,'Exporting Top Features...');
    count = 1;
    xlswrite(strcat(path,file),TopFeatures.Names,1,'c1')
    features = [];
    for pheno = 1:1:length(phenotypelistraw)
        features = [features;TopFeatures.(phenotypelistraw{pheno})];
    end
    xlswrite(strcat(path,file),features,1,'B2');
    classlist = [];
    for subjects = 1:1:length(featureclass)
        classlist{subjects} = phenotypelistraw{featureclass(subjects)};
    end
    xlswrite(strcat(path,file),classlist',1,'A2');
    %xlswrite(strcat(path,file),SubjectID.(tasklist{task}),1,'A2');
    count = count+1;
    waitbar(count/(length(tasklist)*length(freqlabellistraw)),h);
    close(h);
end
end


function export_features_featurestoweka_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_matlab2weka_settings;

function menu_export_group_comparison_plots_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_measureplotting_settings;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               HELP TAB

function menu_help_Callback(hObject, eventdata, handles)
%% -------------------------------------------------------------------- N/A


    function menu_help_manual_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------



    function menu_help_about_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------


% --------------------------------------------------------------------
%function menu_config_config_Callback(hObject, eventdata, handles)
% hObject    handle to menu_config_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function menu_removesubjects_Callback(hObject, eventdata, handles)
%% --------------------------------------------------------------------
gui_removesubjects;
