function initializeAOData()
% INITIALIZEAODATA
%
% Description:
%   Stores relevant information about AOData in the user preferences
%
% -------------------------------------------------------------------------
    thisDir = fileparts(mfilename('fullpath'));

    hasAODataPref = ispref('AOData');
    if ~hasAODataPref
        setpref('AOData', 'BasePackage', thisDir);
        setpref('AOData', 'SearchPaths', string(thisDir));
    else  % Preferences exist but may have been changed
        if ~isequal(thisDir, getpref('AOData', 'BasePackage'))
            setpref('AOData', 'BasePackage', thisDir);
            searchPaths = string(getpref('AOData', 'SearchPaths'));
            for i = 1:numel(searchPaths)
                if endsWith(searchPaths(i), ['AOData', filesep, 'src'])... 
                        && ~beginsWith(searchPaths(i), thisDir)
                    searchPaths(i) = fileparts(thisDir, 'src');
                    setpref('AOData', 'SearchPaths', searchPaths);
                end
            end
        end
    end
    fprintf('AOData is initialized\n');
    SearchPathApp();