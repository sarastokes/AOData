function setAODataPaths(devFlag)
% Adds AOData to the MATLAB path
%
% Description:
%   Adds the important components of AOData to the search path, omitting 
%   testing folders. Run before using AOData or add to your startup file 
%   to automatically run when MATLAB opens.
%
% Syntax:
%   setAODataPaths()
%
% Notes:
%   Requires AOData to be initialized first
%
% Examples:
%   % Add the following lines to startup.m in "Documents/MATLAB"
%   addpath('../AOData/');
%   setAODataPaths();
%
% See Also: initializeAOData

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    if nargin < 2
        devFlag = false;
    end

    if ~ispref('AOData', 'BasePackage')
        error('setAODataPaths:MissingUserPrefs',...
            'Run initializeAOData first before this function.');
    end

    % Add AOData
    aoData = getpref('AOData', 'BasePackage');
    addpath(aoData);
    addpath(genpath(fullfile(aoData, 'src')));
    addpath(genpath(fullfile(aoData, 'app')));
    addpath(genpath(fullfile(aoData, 'util')));
    
    % Add libraries
    addpath(fullfile(aoData, 'lib'));
    addpath(genpath(fullfile(aoData, 'lib', 'appbox')));
    addpath(genpath(fullfile(aoData, 'lib', 'jsonlab-2.0')));
    addpath(genpath(fullfile(aoData, 'lib', 'ReadImageJROI')));
    addpath(genpath(fullfile(aoData, 'lib', 'h5tools-matlab', 'src')));
    addpath(genpath(fullfile(aoData, 'lib', 'h5tools-matlab', 'util')));

    if devFlag
        addpath(genpath(fullfile(aoData, 'test')));
        addpath(genpath(fullfile(aoData, 'packages')));
    end
        