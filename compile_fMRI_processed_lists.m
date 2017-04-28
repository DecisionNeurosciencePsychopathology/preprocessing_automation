function compile_fMRI_processed_lists
%% Transfer processed id lsits
%Script will generate (server side) and copy subject id lists that have
%completely processed data (i.e. finished all blocks)

%Create housing for text files 
if ~exist('processed_id_lists', 'dir')
    mkdir('processed_id_lists');
end

script_path = [ pwd filesep 'transfer_processed_lists.exp'];
script_path = strrep(script_path,'\','/'); %if on windows machine
cmd_str = sprintf('"%s"',script_path);

%set cygwin path string
cygwin_path_sting = 'E:\cygwin\bin\bash --login -c ';

%Run it, kick out if failed
fprintf('Logging into Thorndike now...attempting to transfer processed id lists...\n')
[status]=system([cygwin_path_sting cmd_str]);
if status==1
    error('Connection to Thorndike failed :(')
end

fprintf('\nTransfer complete!\n')

%% Compile fMRI processed lists
fprintf('\nCompiling list files into struct now...\n')

files = glob('processed_id_lists\*.txt')';

proc_id_lists = struct();

for file = files
    %Load in the file to an array
    formatSpec = '%f%[^\n\r]';
    
    %Read in the file
    fileID = fopen(file{:},'r');
    delimiter = '';
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
    
    %Close the text file.
    fclose(fileID);
    
    % Allocate imported array to column variable names
    ids = dataArray{:, 1};

    % Clear temporary variables
    clearvars filename delimiter formatSpec fileID dataArray ans;
    
    %Fill in struct
    task_name=regexp(file,'(ban|clo|trust|trust_bpd|shark)[^_]*','match');
    task_name = task_name{:}; %How can I get arround this?
    proc_id_lists.(task_name{:}) = ids; 
end

%Save the data struct
save proc_id_lists proc_id_lists

fprintf('\nComplete!\n')
    
