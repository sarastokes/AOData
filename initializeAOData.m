function initializeAOData(varargin)
% INITIALIZEAODATA
%
% Description:
%   Stores relevant information about AOData in the user preferences. The
%   following preferences are initialized: 
%   - BasePackage: the location of AOData folder
%   - SearchPaths: the folder containing AOData or custom classes
%   - GitRepos: the folders of all git repositories to log in HDF5 files
%
% Syntax:
%   initializeAOData()
%   initializeAOData(resetFlag)
%
% Optional key/value inputs:
%   Reset               logical (default = false)
%       Resets all preferences to basic settings (only AOData)
%   NoApp               logical (default = false)
%       Suppresses opening of AODataManagerApp 

% By Sara Patterson, 2022 (AOData)
% -------------------------------------------------------------------------

    ip = aod.util.InputParser();
    addParameter(ip, 'Reset', false, @islogical);
    addParameter(ip, 'NoApp', false, @islogical);
    parse(ip, varargin{:});

    resetFlag = ip.Results.Reset;
    appFlag = ~ip.Results.NoApp;

    thisDir = fileparts(mfilename('fullpath'));

    hasAODataPref = ispref('AOData');
    if ~hasAODataPref || resetFlag
        setpref('AOData', 'BasePackage', thisDir);
        setpref('AOData', 'SearchPaths', string(thisDir));
        % TODO: Check if .git is present
        setpref('AOData', 'GitRepos', thisDir);
        fprintf('AOData is already initialized, add custom packages in AODataManagerApp\n');
    else  % Preferences exist but may have been changed
        if ~isequal(thisDir, getpref('AOData', 'BasePackage'))
            setpref('AOData', 'BasePackage', thisDir);
            searchPaths = semicolonchar2string(getpref('AOData', 'SearchPaths'));
            for i = 1:numel(searchPaths)
                if endsWith(searchPaths(i), ['AOData', filesep, 'src'])... 
                        && ~startsWith(searchPaths(i), thisDir)
                    searchPaths(i) = fileparts(thisDir, 'src');
                    setpref('AOData', 'SearchPaths', string2semicolonchar(searchPaths));
                end
            end
            gitRepos = semicolonchar2string(getpref('AOData', 'GitRepos'));
            for i = 1:numel(gitRepos)
                if endsWith(gitRepos(i), 'AOData') && ~beginsWith(gitRepos(i), thisDir)
                    gitRepos(i) = thisDir;
                    setpref('AOData', 'GitRepos', string2semicolonchar(gitRepos));
                end 
            end
            fprintf('AOData paths have been updated to new location, check custom packages in AODataManagerApp\n');
        end
        fprintf('AOData is already initialized, add custom packages in AODataManagerApp\n');
    end

    if appFlag
        fprintf('Opening AODataManagerApp for addition of any custom code...\n')
        AODataManagerApp();
    end