%This is just a wrapper script to be run 4am every day to update the
%scanning pipeline document


%List all tasks
tasks = {'bandit'
         'trust'
         'bpd_clock'
         'bpd_trust'
         'shark'
         'clock_rev'};

%Update the processed id lists
compile_fMRI_processed_lists

%Run main loop
for i = 1:length(tasks)
    autogenerate_regressor_creation([tasks{i} '.dat'],'force_qc',1);
end
