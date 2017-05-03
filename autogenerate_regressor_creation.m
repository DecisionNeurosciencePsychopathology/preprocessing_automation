function autogenerate_regressor_creation(config_file, varargin)
%Autogenerate Regressor Creation or ARC
%
%ARC is part of the automatic data processing pipeline customly developed for the fMRI tasks of the DNPL lab.
%
%This script will handle the file I/O from our current data storage
%(skinner ie Google Drive) to the local machine, create the task specific
%regressors, and finally move them to the appropreiate place on BEK (remote imaging server).
%
%Inputs will be a config file so we can use this for more than one task
%Since we're writing this in Matlab we might as well make life easy and use a csv.
%
%Additional arguments are as follows
%force_qc -- Force ARC to generate the voxelwise comparision script and sync the output file to the local dir
%
%Syntax
%autogenerate_regressor_creation('bpd_clock.dat')
%autogenerate_regressor_creation('bpd_clock.dat', 'force_qc', 1)

%% Parser
%Set up parser
p = inputParser;

%Default args
default_force_qc = 1;

%Assign default values to sub args
addParameter(p,'force_qc',default_force_qc,@isnumeric);

%Return error when parameters don't match the schema
p.KeepUnmatched = false;

%Parse to params struct
parse(p,varargin{:})
params = p.Results;

%% Does VBA toolbox exist and on path?
A=exist('f_embed','file');
if A~=2
    error('VBA toolbox is not on path see help for instructions')
end

%% Add current directory to path
addpath(pwd);
current_dir=fileparts(mfilename('fullpath'));

%% check to see if nessecary functions are on path
needed_fxs = {'errorlog','moveregs'};
for needed_fx = needed_fxs
    if exist(needed_fx{:},'file')~=2
        fprintf('\n%s DOES NOT EXIST SEE HELP FOR INSTRUCTIONS\n',upper(needed_fx{:}))
        fprintf('exiting...\n')
        return
    end
end

%% Read in config file
T = readtable(config_file, 'Delimiter', '\t');
local_dir = T.local_dir{:};
remote_dir = T.remote_dir{:};
file_regex = T.file_regex{:};
id_regex = T.id_regex;
subj_regex = T.subject_regex{:};
task_directory = T.task_directory{:};
reg_output_path = T.reg_out_path{:};
task_func_name = T.task_func_name{:};
thorndike_task_name = T.thorndike_task_name{:};
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

%% WHICH function to run
fh=str2func(task_func_name);
fh();

%% Quality check fMRI single subject maps

%cd back to original directory -- not sure how needed this would be if I
%provided full paths, but keep it for now.
cd(current_dir)

%Run the quality check shell script (server side), sync output .dat files
if ~isempty(new_ids) || params.force_qc
    script_path = [ pwd filesep 'quality_check_scans.exp'];
    script_path = strrep(script_path,'\','/'); %if on windows machine
    cmd_str = sprintf('"%s %s %s"',script_path, thorndike_task_name, [thorndike_task_name '_log.dat']);
    
    %set cygwin path string
    cygwin_path_sting = 'E:\cygwin\bin\bash --login -c ';
    
    %Run it, kick out if failed
    fprintf('Logging into Thorndike now...attempting to sync QC data files...\n')
    [status]=system([cygwin_path_sting cmd_str]);
    if status==1
        error('Connection to Thorndike failed :(')
    end
    
    fprintf('\nSync complete!\n')
    
    %TODO
    %Ask nate about from thorndike to UPMC connections or if firewall blocks it
    
end

%% Compile all data into exportable format
%TODO
%run data compiler script
%compile_usable_scan_database(tasks)


