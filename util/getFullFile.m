function out = getFullFile(fileName)
% Appends full file path to all files
%
% Syntax:
%   out = getFullFile(fileName)
%
% Inputs:
%   fileName            string
%       One or more file names
%
% Outputs:
%   out                 string
%       File file names

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        fileName            string
    end

    if ~isscalar(fileName)
        out = arrayfun(@(x) getFullFile(x), fileName);
        return
    end

    if ~exist(fileName, 'file')
        error('getFullFile:FileNotFound',...
            'File %s not found', fileName);
    end

    out = string(which(fileName));
