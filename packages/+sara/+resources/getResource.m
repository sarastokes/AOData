function [filePath, fileExists] = getResource(fileName)
    % GETRESOURCE
    %
    % Description:
    %   Convenience method for getting file paths from sara.resources
    %
    % Syntax:
    %   [filePath, fileExists] = getResource(fileName)
    %
    % History:
    %   06Aug2022 - SSP
    % ---------------------------------------------------------------------
    
    filePath = fileparts(mfilename('fullpath'));
    filePath = fullfile(filePath, fileName);
    
    % Check if file does not exist in resources
    if ~exist(filePath, 'file')
        % Throw warning if fileExists flag was not requested
        if nargout == 1
            warning('File does not exist: %s', filePath);
        end
        fileExists = false;
    else
        fileExists = true;
    end
    