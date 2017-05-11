function compile_usable_scan_database(tasks)
%Created by Jonathan Wilson & Emily Trea 5/2/2017
%Function will update (or create) all demographic and quality control
%information pertaining to DNPL's fMRI scanning protocols.
%input must be a cell! account for this later
%EX call: compile_usable_scan_database({'trust'})

%% Optional input arg
%Compile all data instead of just indiviual tasks
all_tasks = {'bandit', 'trust', 'trust_bpd', 'clockbpd', 'shark', 'clockrev'};
if strcmp(tasks{:},'all')
    tasks = all_tasks;
end


%% Master excel sheet creation
%Set sheets for indexing
sheets=all_tasks;

%look for file
if ~exist('dnpl_usable_scans.xls','file')
    %     %if it doesn't exist, create it
        headers={'ID'}; %Just need dummy placement variables
    
    for i=1:length(sheets)
        xlswrite('dnpl_usable_scans',headers,i)
    end
    
    %Rename the sheets
    ex_file = actxserver('Excel.Application'); % # open Activex server
    ewb = ex_file.Workbooks.Open([ pwd '/dnpl_usable_scans.xls']); % # open file (enter full path!)
    for i=1:length(sheets)
        ewb.Worksheets.Item(i).Name = sheets{i}; % # rename each sheet as one of the task names
    end
    ewb.Save % # save to the same file
    ewb.Close(false) %Close out file
    ex_file.Quit
end


%% Upload info for each id from master_arc_data
try
    %Var name is T
    load('master_arc_data.mat')
    task_data_cols=T.Properties.VariableNames;
catch
    error('master_arc_data.mat could not be found!')
end

%% Import demographics
subj_demos = import_demographics;

%% Import scanning DB
scan_dbs = import_scan_db;

%% Begin compiling
for task = tasks
    
    %Choose which scanner db to use -- make this a function?
    if strcmp(task,'bandit') || strcmp(task,'trust')
        scan_db = scan_dbs.learn;
    elseif strcmp(task,'clockbpd') || strcmp(task,'trust_bpd')
        scan_db = scan_dbs.bsocial;
    elseif strcmp(task,'clockrev') || strcmp(task,'shark')
        scan_db = scan_dbs.explore;
    else
        error('Not any task I''ve ever heard of...exiting')
    end
    
    %Grab master id list
    id_list = scan_db.LLMDID;
    
    %% Process task data
    task_data_idx = ismember(T.ID,id_list);
    
    %To differentiate between trust and trust_bpd
    if strcmp(task,'trust')
        expresssion = 'trust(?!_bpd)';
    else
        expresssion = [task{:} '.*'];
    end
    
    %Get column index from task data
    task_col_idx=find(cellfun(@(IDX) ~isempty(IDX), regexp(task_data_cols,expresssion)));
    
    %Pull task_data
    sheet_data=T(task_data_idx,[1,task_col_idx(1):task_col_idx(end)]);
    
    %% Process scan db
    scan_db.Properties.VariableNames(1) = {'ID'};
    sheet_data = join(sheet_data,scan_db,'Keys','ID');
    %TODO
    %Clean up un-needed variables from scan db
    
    %% Process demographics
    sheet_data = join(sheet_data,subj_demos,'Keys','ID');
    
    %% Write sheet to work book
    sheet_num=find(cellfun(@(IDX) ~isempty(IDX), regexp(sheets,expresssion)));
    writetable(sheet_data,'dnpl_usable_scans.xls','Sheet',sheet_num)
    
    %% Create historgram of ages if needed
%     stop=1;
%     task_col_idx=find(cellfun(@(IDX) ~isempty(IDX), regexp(task_data_cols,expresssion)));
%     
end

%Move the final file to wherever the RA's want it to be
mkdir('L:/Summary Notes/Scanning Database/task_data/')
copyfile('dnpl_usable_scans.xls','L:/Summary Notes/Scanning Database/task_data/dnpl_usable_scans.xls')


function data=import_demographics
%Snippet will export the ALL_DEMOS table to a local folder in the Y: drive
%which can then be imported into matlab with the table f(x)

% Run macro
h=actxserver('Access.Application');
hardcopy = 'Y:\Protect 2.0.accdb'; %File name
invoke(h,'OpenCurrentDatabase',hardcopy);
h.Visible = 0; %Make it invisible
invoke(h.DoCmd,'RunMacro','exportDemos_local'); %Run macro
%% Garbage collection
h.Quit;
delete(h);

%% Output
data = readtable('Y:/demos_stash/ALL_SUBJECS_DEMO.xlsx');

%Remove duplicates if any
[n, bin] = histc(data.ID, unique(data.ID));
multiple = find(n > 1);
index = ismember(bin, multiple);
data(index,:)=[];


function data=import_scan_db
%Snippet will export protocol (LEARN, EXPLORE, BSOCIAL) datasheets into
%excel which then get compiled into tables and placed under one struct

% Run macro
h=actxserver('Access.Application');
hardcopy = 'L:\Summary Notes\Scanning Database\DNPL Scanning Database'; %File name
invoke(h,'OpenCurrentDatabase',hardcopy);
h.Visible = 0; %Make it invisible
invoke(h.DoCmd,'RunMacro','export_all_scan_forms'); %Run macro
%% Garbage collection
h.Quit;
delete(h);
%% Output
%Compile all the forms under one data struct
data_dir = 'L:/Summary Notes/Scanning Database/form_export/';
files = dir([data_dir '*.xlsx'])';

%Initialize struct
data = struct;

for file  = files
    protocol = regexp(file.name,'\w+(?(?!_)yes)|(EXPLORE)','match');
    protocol = lower(protocol{:});
    data.(protocol) = readtable([data_dir file.name]);
    
    %If any duplicates exists (ie rescans), remove the old row of data
    [n, bin] = histc(data.(protocol).LLMDID, unique(data.(protocol).LLMDID));
    multiple = find(n > 1);
    if ~isempty(multiple)
        index = ismember(bin, multiple);
        dup_ids = unique(data.(protocol).LLMDID(index));
        %This works, but maybe come back to it with a more scalable and elegant solution...
        for dup_id = dup_ids'
            dup_idx=find(dup_id==data.(protocol).LLMDID);
            dup_dates=data.(protocol).SCANDATE(dup_idx);
            [~,newest_date]=max(datetime(dup_dates)); %Use the data associated with the most recent scan
            dup_idx(newest_date)=[];
            data.(protocol)(dup_idx,:) = []; %Remove duplicates
        end
    end
end



