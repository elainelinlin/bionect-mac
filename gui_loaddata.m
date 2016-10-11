function [alldata, raw, SubjectIDs, Missing, tasklist] = gui_loaddata(BNCT,batchfile,analysisfile,tasklistraw,phenotypelistraw,chanord)

load(batchfile,'batch');
raw = batch;
raw(1,:) = [];
[m,~] = size(raw);
i = 1;
while i <= m
    if strcmp(raw{i,3},'no')
        raw(i,:) = [];
        m = m - 1;
        i = i - 1;
    end
    i = i + 1;
end

tasklist = tasklistraw;
for a = 1:1:length(phenotypelistraw)
    sub.(phenotypelistraw{a})(1:length(tasklist)) = 1;
end
h = waitbar(0,'Loading Data...');
%% CREATE TASK VARIABLES/CHECK IF USER HAS INPUT APPROPRIATE VARIABLE NAMES
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

%%                      CLEAN OUT UNPROCESSED DATA
for subject = size(raw,1):-1:1
    if isnan(raw{subject,4})
        %DELETE TRIAL
        raw(subject,:)=[];
    end
end
waitbar(.2,h);  
%%              STORE RASTER DATA FOR ALL SUBJECTS
%EEG = pop_loadset(strcat(raw{1,1},'\',raw{1,2}));

for subject = 1:1:size(raw,1)%length(raw)

 %   EEG = pop_loadset(strcat(raw{subject,1},'\',raw{subject,2}));   

    %FORM FILE NAME
    data_folder = raw{subject,1};
    dataloc = raw{subject,2};
  %old coh  
 %   dataloc = dataloc(1:11);
 %   dataloc = strcat(data_folder,'\',dataloc,'.mat');
  %new coh
  if strcmp(BNCT.cohtype,'magcoh')
      %try
      %  dataloc = strcat(dataloc(1:end-4),'_CohValue.mat');
      %catch
        dataloc = strcat(dataloc(1:end-4),'_CohValueCS.mat');
      %end
  elseif strcmp(BNCT.cohtype,'phasecoh')
    dataloc = strcat(dataloc(1:end-4),'_PhaseCohValueCS.mat');
  elseif strcmp(BNCT.cohtype,'psi');
      dataloc = strcat(dataloc(1:end-4),'_PSIValueCS.mat');
  elseif strcmp(BNCT.cohtype,'imagcoh')
    dataloc = strcat(dataloc(1:end-4),'_ImagCohValueCS.mat');
  elseif strcmp(BNCT.cohtype,'magcoh_cluster')
      dataloc = strcat(dataloc(1:end-4),'_CohValue_Cluster.mat');
  end
    dataloc2 = dataloc;
    dataloc = strcat(data_folder,analysisfile,'/',dataloc);
    if exist(dataloc,'file')
        load(dataloc)
    else
       msgbox(sprintf('Unable to load file %s \n\nFile listed as processed in batch file but not found.',dataloc))

   %     msgbox('Coherence raster file not found for a file labeled as processed in batch file!');
    end
    %STORE DATA  
   % if isempty(newchanord)
        switch chanord.method
            case 'orig'
            %TIME BINS
             %   alldata(:,:,:,:,subject) = raster_mat; %raster_mat loaded above
            %
            %CONTINUOUS TIME, NEED NEW SWITCH/OPTION HERE
            if strcmp(BNCT.cohtype,'magcoh') || strcmp(BNCT.cohtype,'phasecoh') || strcmp(BNCT.cohtype,'imagcoh') || strcmp(BNCT.cohtype,'magcoh_cluster')
                for k = 1:1:size(BNCT.config.freqrangelistraw,1)
                    freq_bin(k,1:2) = str2num(BNCT.config.freqrangelistraw{k});
                end
                time_bin = [];
                for p = 1:1:size(BNCT.config.batch_timerange,1)
                    time_bin(p,1:2) = str2num(BNCT.config.batch_timerange{p});
                end
                
                freqnum = linspace(1,size(BNCT.config.freqrangelistraw,1),size(BNCT.config.freqrangelistraw,1));%[1 2 3 4];%%%%%%%%%%%Update this, frequencies selected I guess?
                timenum = size(time_bin,1);
                for ch1 = 1:size(raw_coh,1)
                    for ch2 = ch1+1:size(raw_coh,2)
                        for y = 1:size(freqnum,2);
                            freqind=find(freqlist>= freq_bin(freqnum(y),1) & freqlist<=freq_bin(freqnum(y),2));

                          %  timeind=find(timelist>= 2000 & timelist<=5000); %Change times here realtime
                          %  for z = 1:size(timeind,2)%realtime
                            for z = 1:size(time_bin,1)%overlap
                                if sum(time_bin)==2 %all times
                                timeind=find(timelist>= 0 & timelist<=max(timelist));    
                                else
                                timeind=find(timelist>= time_bin(z,1) & timelist<=time_bin(z,2));%Change times here
                                end
                               % cohdata(ch1,ch2,z,y) = mean(raw_coh{ch1,ch2}(freqind,timeind(z)));
                               % cohdata(ch2,ch1,z,y) = mean(raw_coh{ch1,ch2}(freqind,timeind(z)));
                                cohdata(ch1,ch2,z,y) = mean(mean(raw_coh{ch1,ch2}(freqind,timeind))); %overlap
                                cohdata(ch2,ch1,z,y) = mean(mean(raw_coh{ch1,ch2}(freqind,timeind)));%overlap
                            end
                        end
                    end
                end
                alldata(:,:,:,:,subject) = cohdata;
            elseif strcmp(BNCT.cohtype,'psi')
                switch BNCT.connmethod
                    case 'source'
                     alldata(:,:,:,:,subject) = {raster_mat};  
                    case 'channel'
                    alldata(:,:,:,:,subject) = raster_mat;    
                end
                
            end
                disp(horzcat('Data loaded for ',num2str(subject),' of ',num2str(size(raw,1))));
               %} 
            %    x=1;
        %else
            case 'new'
                EEG = pop_loadset(strcat(raw{subject,1},'\',raw{subject,2})); 
                disp(sprintf('Reordering channels for file %s (%d/%d)',dataloc2,subject,size(raw,1))); 
                raster_new = gui_reorderchans(EEG,raster_mat,chanord);
                alldata(:,:,:,:,subject) = raster_new;
        end
  %  end
end

waitbar(.4,h);  
%%
%GO THROUGH RAW FOR EACH PHENOTYPE (FROM PHENOTYPE COLUMN) AND TASK (FROM
%FILENAME COLUMN, AND PULLS SUBJECT ID
for i = 1:1:size(raw,1)%length(raw) %# subjects
    for b = 1:1:length(phenotypelistraw) %split into #phenos
        if strfind(raw{i,7},phenotypelistraw{b}) > 0 %if pheno(b) matches subject pheno
            for k = 1:1:length(tasklist) %split into #tasks
                if strfind(raw{i,9},(tasklistraw{k})) > 0 %if task(k) matches, was i,2 before
                    %Create subject x task array of IDs and 1 or 0's to
                    %signify if coherence data is present?
                    SubjectIDs.(phenotypelistraw{b}).(tasklist{k}){sub.(phenotypelistraw{b})(k),1} = raw{i,8};
                    sub.(phenotypelistraw{b})(k) = sub.(phenotypelistraw{b})(k)+1;
                end
            end
        end
    end
end
waitbar(.6,h);  
%% CREATE A SEPERATE SUBJECTIDS WHICH ACCOUNTS FOR SUBJECT DATA THAT IS NOT PRESENT FOR ALL TASKS
if size(tasklistraw,1) > 1
for b = 1:1:length(phenotypelistraw)
    for k = 1:1:length(tasklist)-1
        for n = k:1:length(tasklist)
            try
        [Missing.(phenotypelistraw{b}).ids{k,n}, Missing.(phenotypelistraw{b}).locs{k,n}] = setdiff(SubjectIDs.(phenotypelistraw{b}).(tasklist{k}),SubjectIDs.(phenotypelistraw{b}).(tasklist{n}));
            catch
        Missing.(phenotypelistraw{b}).ids{k,n} = [];
        Missing.(phenotypelistraw{b}).locs{k,n} = [];
            end
        end
    end
end
else Missing = [];
end

%AllSubjects = [];
waitbar(.8,h);  
for b = 1:1:size(phenotypelistraw,1)
    try SubjectIDs.All.(phenotypelistraw{b}) = SubjectIDs.(phenotypelistraw{b}).(tasklist{1});
        if size(tasklistraw,1) > 1
            for k = 2:1:size(tasklist,1)
                SubjectIDs.All.(phenotypelistraw{b}) = [SubjectIDs.All.(phenotypelistraw{b});Missing.(phenotypelistraw{b}).ids{1,k}];
            end
            %Remove repeated subjects
            %    SubjectIDs.All.(phenotypelistraw{b}) = unique(SubjectIDs.All.(phenotypelistraw{b}),'stable');
        end
    catch
    end  
end
close(h)