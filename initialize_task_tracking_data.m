function task_data=initialize_task_tracking_data(task_name)

%Initialize task tracking data
task_data.name=task_name;
task_data.behave_completed=0;
task_data.behave_processed=0;
task_data.fMRI_processed=0;