function errorlog(task,id,exception)

    td=date;
    dname = sprintf('%s_errorlog_%s',task,td);
    
    diary(dname)
    
    %display id and error message in diary
    display(id)
    msgText=getReport(exception,'extended','hyperlinks','off');
    ERROR=msgText;
    display(ERROR)
   
    
    diary off