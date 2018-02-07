function [currentpath, filename, fileextension] = getPaths
%Simple script that will get the file path of the current file and return
%the path in which it was located and the name of the file.

scriptName = mfilename('fullpath');
[currentpath, filename, fileextension]= fileparts(scriptName);