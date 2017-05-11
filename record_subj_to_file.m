function record_subj_to_file(id,task_data)
%% write completed subj data to file
%Write task tracking data to main ARC data file.
%
%Note any new fields added here need to be reflected in initialize_task_tracking_data.m!!!
%

%If master data file doesn't exist create it
data_dir=fileparts(which('autogenerate_regressor_creation'));
if ~exist([data_dir '/master_arc_data.mat'],'file')
    T=create_master_arc_data_file(data_dir);
else
    load([data_dir '/master_arc_data.mat']);
end

%Load in processed lists (proc_id_lists)
load([data_dir '/proc_id_lists.mat'])

%Determine if subject was processed or not
if ismember(id,proc_id_lists.(task_data.name))
    task_data.fMRI_processed=1;
else
    task_data.fMRI_processed=0;
end

%Determine if subject is uasable or not
%BUG ALERT: Currently cannot handle 0's as first digit, code truncates them
%THIS is no longer needed as the update taskes place after the  QC file sync...
% usable_list=readtable([data_dir sprintf('/scan_qc_tracking/%s_log.dat',task_data.name)]);
% if ismember(id,usable_list.id)
%     tmp_idx= ismember(usable_list.id,id);
%     task_data.fMRI_usable=usable_list.valid_bin(tmp_idx);
% end

%If new subject put them in the data table
if ~ismember(id, T.ID)
    T.ID(length(T.ID)+1,1)=id;
end

%Get subject's row index
id_idx = find(ismember(T.ID,id));

%update the task tracking data
T.([task_data.name '_behave_completed'])(id_idx)=task_data.behave_completed;
T.([task_data.name '_behave_processed'])(id_idx)=task_data.behave_processed;
T.([task_data.name '_fMRI_processed'])(id_idx)=task_data.fMRI_processed;
%T.([task_data.name '_fMRI_usable'])(id_idx)=task_data.fMRI_usable; %THIS is no longer needed as the update taskes place after the  QC file sync...

%Update the master data table
save([data_dir '/master_arc_data.mat'],'T')

%write table data to file
writetable(T,[data_dir '/arc_data.dat'],'Delimiter','\t')


%% Sub functions %%

%Initialize the master data file
function T=create_master_arc_data_file(data_dir)
task_names={'bandit','trust','trust_bpd','clockbpd'...
    'clockrev','shark'};
col_names={'ID'};
for i = 1:length(task_names)
    col_names{length(col_names)+1} = [task_names{i} '_behave_completed'];
    col_names{length(col_names)+1} = [task_names{i} '_behave_processed'];
    col_names{length(col_names)+1} = [task_names{i} '_fMRI_processed'];
    col_names{length(col_names)+1} = [task_names{i} '_fMRI_usable'];
end
T = array2table(nan(0,length(col_names)),'VariableNames',col_names);
save([data_dir '/master_arc_data.mat'],'T')