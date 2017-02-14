function record_subj_to_file(id,task_data)

%% write completed subj data to file
%Note: Let's try to clean this code up into a function, well
%have a better idea once we know the final format of dat or
%xlsx file we'll use, but we should still contain it in a
%function to follow the DRY principle!

%2/13/2017 I think it would actually be easier just to have all
%the data present in one .dat file. Store everything in a table
%structure that can be modified then just update the .dat after
%each task is ran through the pipeline.

%Note any new fields added here need to be reflected in initialize_task_tracking_data.m!!!

%If master data file doesn't exist create it
data_dir=fileparts(which('autogenerate_regressor_creation'));
if ~exist([data_dir '/master_arc_data.mat'],'file')
    T=create_master_arc_data_file(data_dir);
else
    load([data_dir '/master_arc_data.mat']);
end

%If new subject put them in the data table
if ~ismember(id, T.ID)
    T.ID(length(T.ID)+1,1)=id;
end

%Get subject's row index
id_idx = find(ismember(T.ID,id));


%update the task tracking data --is there a way to condense it?
%T.([task_data.name '_behave_completed'])(idx) = blah <- this works!
switch task_data.name
    case 'Bandit'
        T.Bandit_behave_completed(id_idx)=task_data.behave_completed;
        T.Bandit_behave_processed(id_idx)=task_data.behave_processed;
        T.Bandit_fMRI_processed(id_idx)=task_data.fMRI_processed;
    case 'BPD_Trust'
        T.BPD_Trust_behave_completed(id_idx)=task_data.behave_completed;
        T.BPD_Trust_behave_processed(id_idx)=task_data.behave_processed;
        T.BPD_Trust_fMRI_processed(id_idx)=task_data.fMRI_processed;
    case 'BPD_Clock'
        T.BPD_Clock_behave_completed(id_idx)=task_data.behave_completed;
        T.BPD_Clock_behave_processed(id_idx)=task_data.behave_processed;
        T.BPD_Clock_fMRI_processed(id_idx)=task_data.fMRI_processed;
    case 'Shark'
        T.Shark_behave_completed(id_idx)=task_data.behave_completed;
        T.Shark_behave_processed(id_idx)=task_data.behave_processed;
        T.Shark_fMRI_processed(id_idx)=task_data.fMRI_processed;
    case 'Rev_Clock'
        T.Rev_Clock_behave_completed(id_idx)=task_data.behave_completed;
        T.Rev_Clock_behave_processed(id_idx)=task_data.behave_processed;
        T.Rev_Clock_fMRI_processed(id_idx)=task_data.fMRI_processed;
    otherwise
        return
end

%Update the master data table
save([data_dir '/master_arc_data.mat'],'T')

%write table data to file
writetable(T,[data_dir '/arc_data.dat'],'Delimiter','\t')

function T=create_master_arc_data_file(data_dir)
task_names={'Bandit','Trust','BPD_Trust','BPD_Clock'...
    'Rev_Clock','Shark'};
col_names={'ID'};
for i = 1:length(task_names)
    col_names{length(col_names)+1} = [task_names{i} '_behave_completed'];
    col_names{length(col_names)+1} = [task_names{i} '_behave_processed'];
    col_names{length(col_names)+1} = [task_names{i} '_fMRI_processed'];
end
T = array2table(nan(0,length(col_names)),'VariableNames',col_names);
save([data_dir '/master_arc_data.mat'],'T')

