function update_fMRI_usable(task_name)
%Updates the arc master file and writes it to a date to create the excel
%overview spreadsheet
%8/15/17: Added in the manually checked excel file for questionable subjects

%Get usable list
usable_list=readtable([pwd sprintf('/scan_qc_tracking/%s_log.dat',task_name)]);

%Load in task data
try
    load('master_arc_data.mat')
catch
    error('Unable to find master data array "master_arc_data"')
end

%Sort T
T = sortrows(T,'ID','ascend');
T2 = T;

%For now remove any "bad subjs" that leaked in
usable_list(~ismember(usable_list.id,T.ID),:)=[];

%Load in manually reviewed exceptions
try
    [~,~,raw] = xlsread([ pwd '/exception_list.xlsx'],task_name);
catch
    warning('No exception file found, final numbers may be off')
end

%Update fMRI usable list
try
    T.([task_name '_fMRI_usable'])(ismember(T.ID,usable_list.id)) = usable_list.valid_bin;
    
    %Update exception list
    if ~isempty(raw)
        T.([task_name '_fMRI_usable'])(ismember(T.ID,[raw{:}])) = 1;
    end
    
    %Update the master data table
    save([pwd '/master_arc_data.mat'],'T')
    
    %write table data to file
    writetable(T,[pwd '/arc_data.dat'],'Delimiter','\t')
catch
    error('Something''s wrong with the g-diffuser! Actually the fMRI usable list just didn''t update properly')
end