function autogenerate_regressor_creation(config_file)
%This script will handle the file I/O from our current data storage
%(skinner ie Google Drive) to the local machine, create the task specific
%regressors, and finally move them to the appropreiate place on BEK.

%Inputs will be a config file so we can use this for more than one task
%Since we're writing this in Matlab we might as well make life easy and use
%a csv.

%% Does VBA toolbox exist and on path?
A=exist('f_embed','file');
if A~=2
    error('VBA toolbox is not on path')  
end


%Read in config file 
T = readtable(config_file, 'Delimiter', '\t');
local_dir = T.local_dir{:};
remote_dir = T.remote_dir{:};
file_regex = T.file_regex{:};
id_regex = T.id_regex;
subj_regex = T.subject_regex{:};
task_directory = T.task_directory{:};
reg_output_path = T.reg_out_path{:};
task_func_name = T.task_func_name{:};
%Function names, dirs,..ect

%% File I/O
local_files = glob([local_dir '/*' ]);
local_ids = regexp(local_files,id_regex, 'match');

%First row should always be the names in the directory
remote_dirs = struct2cell(dir(remote_dir)); 
remote_ids = regexp(remote_dirs(1,:),id_regex, 'match')';

%Remove any empty cells
remote_ids=remote_ids(~cellfun('isempty',remote_ids));  
local_ids=local_ids(~cellfun('isempty',local_ids)) ;

%Convert to simple cell, if needed rmved && iscell(local_ids{1})from if
%statement
if iscell(remote_ids) 
    remote_ids=[remote_ids{:}]; 
    local_ids=[local_ids{:}];
end

%Compare 
new_ids = setdiff(remote_ids', local_ids');

%If we have new files move them to the proper directoy
if ~isempty(new_ids)
    fprintf('New IDs found! ');
    for i = 1:length(new_ids)
        fprintf(['Copying subject ' new_ids{i} ' now\n']);
        copyfile([remote_dir '/' new_ids{i}], [local_dir '/' new_ids{i}]);
    end
end

cd(task_directory);

%WHICH function to run
fh=str2func(task_func_name);
fh();

%TO DO:
%Add in functions needed to process or organize the fMRI behavioral data,
%the functions needed to make the regressors, then find a away to transfer
%them to BEK.


stop=0;


