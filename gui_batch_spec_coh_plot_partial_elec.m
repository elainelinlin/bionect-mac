function gui_batch_spec_coh_plot_partial_elec(matfile,analysisfile,percent_data,chn_list,freq_bin,batch_timebin,cohtype,method)
%%
load(matfile,'batch');
[subject_no,~] = size(batch);
%subject_no=size(txt1,1);
h = waitbar(0,'Performing Coherence Analysis...');
for i=2:subject_no 
  try
    to_be_process_flag=batch{i,3};
   if strcmp(to_be_process_flag,'yes')==1
       working_folder=batch{i,1};
       EEG_datasetname=batch{i,2}; 
       tmpEEG=pop_loadset(EEG_datasetname,working_folder);
       warning off;
         if tmpEEG.srate~=500
             tmpEEG = pop_resample( tmpEEG, 500);
         end
       file_name = strcat(EEG_datasetname(1:end-4));%,EEG_datasetname(11:14))
       prestim = 500; 
       if sum(chn_list)==1
           switch method
               case 'source'
                 chn_list = 1:size(tmpEEG.dipfit.model,2);
           
               case 'channel'
                   chn_list = 1:tmpEEG.nbchan;
           end
       end
       if sum(batch_timebin) == 2
           batch_timebin = [1000*tmpEEG.xmin 1000*tmpEEG.xmax];
       end
       %{
        if ~exist('percent_data','var') || isempty(percent_data)
            percent_data=100;
        end
        if ~exist('chn_list','var') || isempty(chn_list)
            chn_list = [1:27];
        end
        if ~exist('time_bin','var') || isempty(timebin)
        end
        if ~exist('freq_bin','var') || isempty(freqbin)
            freq_bin=[4 8;8 12;30 40;40 50]; 
        end
        if ~exist('time_start','var') || isempty(time_start)
            time_start = 500;
        end
       %}
       vol_cond=[1 3];
       time_bin_avg=[1 500];
       switch method
           case 'source'
           case 'channel'
                tmpEEG.data=tmpEEG.data(chn_list,:,:);
                tmpEEG.nbchan=size(chn_list,2);
                tmpEEG.chanlocs=tmpEEG.chanlocs(chn_list);  
       end
       
    
       %chn_list [1:27] normally
       %percent_data 100 normal
       %freq_bin to define theta/alpha/beta/gamma [4 8;8 12;30 40;40 50]
       %i.e. col 1 = start freq, col2 = end freq
   %    percent_data = str2num(percent_data);
   %    [status]=gui_coherence_raster9_partial_elec(tmpEEG,file_name, working_folder, analysisfile, percent_data,freq_bin, vol_cond,prestim,time_bin_avg,batch_timebin);%time_bin_size,time_start);
switch cohtype
    case 'magcoh'
         [status]=coherence_bionect2(tmpEEG,file_name, working_folder, analysisfile,percent_data,freq_bin, vol_cond,prestim,time_bin_avg,batch_timebin,method,cohtype);    
    case 'imagcoh'
        [status]=coherence_bionect2(tmpEEG,file_name, working_folder, analysisfile,percent_data,freq_bin, vol_cond,prestim,time_bin_avg,batch_timebin,method,cohtype);
    case 'phasecoh'
        [status]=coherence_phase(tmpEEG,file_name, working_folder, analysisfile,percent_data,freq_bin, vol_cond,prestim,time_bin_avg,batch_timebin,method);
    case 'magcoh_cluster'
        BNCT = evalin('base','BNCT');
        if ~isfield(BNCT,'clustering');
            gui_defineclusters;  
            uiwait;
            BNCT = evalin('base','BNCT');
            clusters = BNCT.clustering.clusters;
            clusternames = BNCT.clustering.clusternames;
        else
            clusters = BNCT.clustering.clusters;
            clusternames = BNCT.clustering.clusternames;
        end
        [status]=coherence_cluster(tmpEEG,file_name, working_folder, analysisfile,percent_data,freq_bin, vol_cond,prestim,time_bin_avg,batch_timebin,clusters,clusternames);
    case 'psi'
        gui_psi(tmpEEG,file_name, working_folder, analysisfile,percent_data,freq_bin, vol_cond,prestim,time_bin_avg,batch_timebin,method);
end
       waitbar(i/subject_no,h);
     %% Process Done

       % Column 10 writes number of tmpEEG.trials
       
       batch{i,10} = num2str(tmpEEG.trials);

       % is it processed
       batch{i,4} = '1';
          
       prog=strcat(num2str(i),'/',num2str(subject_no),'  has/have been plotted');
       sprintf('%s',prog)
       
       save(matfile,'batch')
  
  
   end 
   
  catch ME
       msgbox(sprintf('Error processing file %s \n\nFunction: %s \nLine %d \n\n%s',file_name,ME.stack.name,ME.stack.line,ME.message))
  end
end
close(h)
end 