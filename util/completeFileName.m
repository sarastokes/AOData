function out = completeFileName(fName)
% Ensures file name has full file path
%
% Syntax:
%   out = completeFileName(fName)

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    fPath = fileparts(fName);
    if isempty(fPath)
        out = which(fName);
    else
        out = fName;
    end
