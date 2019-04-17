function [time,probeData] = readProbe(fileName,lineNumber)
% lineNumber = 50;
% fid = fopen('U_probe2','r');
fid = fopen(fileName,'r');
lineStr = textscan(fid, '%s',1,'delimiter','\n','HeaderLines',lineNumber+1);
lineStr = lineStr{1}{1};
lineStr = strrep(lineStr,'(',''); % Remove bracket
lineStr = strrep(lineStr,')',''); % Remove bracket
lineStr = regexprep(lineStr,' +',' '); % Remove multiple spaces
numArray = str2num(lineStr);
fclose(fid);

time = numArray(1);
probeData = reshape(numArray(2:end),3,[])';
end