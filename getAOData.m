function out = getAOData(varargin)
    % GETAODATA
    %
    % Description:
    %   Convenience function for returning the full path for the base 
    %   AOData folder that is not computer-specific. Additional 
    %   optional arguments will be passed to fullfile() and appended to
    %   the AOData folder. 
    %
    % Syntax:
    %   out = getAOData()
    %   out = getAOData(varargin)
    %
    % Optional inputs:
    %   subfolders          char 
    %       Folders and/or files within AOData
    %
    % Examples:
    %   out = getAOData()
    %       Returns the full path to the AOData folder
    %   out = getAOData('src')
    %       Returns the full path to the src folder within AOData
    %   out = getAOData('src', '+aod')
    %       Returns the full path to the +aod folder within AOData
    %
    % See also:
    %   fullfile
    % --------------------------------------------------------------------- 
    if ~ispref('AOData', 'BasePackage')
        error('Run initializeAOData before continuing');
    end

    out = getpref('AOData', 'BasePackage');

    if nargin > 1 
        out = fullfile(out, varargin{:});
    end