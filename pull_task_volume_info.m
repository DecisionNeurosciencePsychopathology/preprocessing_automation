function pull_task_volume_info(base_proc_path, task_path, n_runs, task_name)
%This function will log into Thorndike and run the command fdMotion, then
%transfer the output to a local folder. This function should be ran in the
%task spcific dir of the task you are processing. i.e. c:\kod\fMRI for
%bandit.
%Example pull_task_volume_info('/Volumes/bek/learn/MR_Proc/', '/bandit_MB_proc/bandit', '3', 'bandit')


%Create the local dir if DNE
if ~exist('vol_info', 'dir')
    mkdir('vol_info')
end

%Get paths
scriptName = mfilename('fullpath');
[currentpath, filename, ~]= fileparts(scriptName);
currfolder = pwd;

%Take care of file seperators
if ispc
    currentpath=strrep(currentpath,'\','/');
    currfolder=strrep(currfolder,'\','/');
    currfolder=strrep(currfolder,':',''); %Apparently cygwin hates ':
end

%Set up the cmd string
cmd_str = sprintf('"%s/%s.exp %s %s %s %s %s"',currentpath,filename,currfolder,base_proc_path,task_path,n_runs,task_name);

%in the future cygwin path should be made to be user specific
cygwin_path_sting = 'E:\cygwin\bin\bash --login -c ';

%Run the cmd
[status,cmd_out]=system([cygwin_path_sting cmd_str]);

if status==1
    error('Connection to Thorndike failed :(')
end
end
