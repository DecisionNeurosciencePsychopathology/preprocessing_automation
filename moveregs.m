%Created 10.19.16 by Emily Trea
%move regs to Thorndike through Cygwin

function moveregs(currfolder,id,newfolder)
    
    %Get paths
    scriptName = mfilename('fullpath');
    [currentpath, filename, fileextension]= fileparts(scriptName);
    
    if ispc
        currentpath=strrep(currentpath,'\','/');
        currfolder=strrep(currfolder,'\','/');
        currfolder=strrep(currfolder,':',''); %Apparently cygwin hates ':
%         currentpath=convertToUnixPath(currentpath);
%         currfolder=convertToUnixPath(currfolder);
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