%Created 10.19.16 by Emily Trea
%move regs to Thorndike through Cygwin

function moveregs(currfolder,id,newfolder)


%Convert to string if not already
if ~ischar(id)
    id = num2str(id);
end

%Get paths
scriptName = mfilename('fullpath');
[currentpath, filename, ~]= fileparts(scriptName);

%Hotfix for trust issue, let's clean this up later
if ~isempty(strfind(newfolder,'trust_analyses'))
    filename = 'moveregs_learn_trust';
end

%Take care of file seperators
if ispc
    currentpath=strrep(currentpath,'\','/');
    currfolder=strrep(currfolder,'\','/');
    currfolder=strrep(currfolder,':',''); %Apparently cygwin hates ':
end

%folder in Github
%must change manually for the time being
cmd_str = sprintf('"%s/%s.exp %s %s %s"',currentpath,filename, currfolder,id,newfolder);

%in the future cygwin path should be made to be user specific
cygwin_path_sting = 'E:\cygwin\bin\bash --login -c ';

%Run it kick out if failed
fprintf('Moving reg folders to Thorndike....\n')

[status,cmd_out]=system([cygwin_path_sting cmd_str]);

if status==1
    error('Connection to Thorndike failed :(')
end
end