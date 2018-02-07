function str=convertToUnixPath(str)
%This function will convert the path from a PC (ie '\') to an Unix path 
%(ie'/')

C = strsplit(str, '\');
str = strjoin(C,'/');