function res = compareVersions(varargin)
    % compareVersions - Semantic version comparison (default: greater than or equal)
    %
    % This function compares an array of semantic versions against a reference version.
    %
    % DISTRIBUTION:
    %  GitHub:       https://github.com/guzman-raphael/compareVersions
    %  FileExchange: https://www.mathworks.com/matlabcentral/fileexchange/71849-compareversions
    %
    % res = COMPAREVERSIONS(verArray, verComp, verCheck)
    % INPUT:
    %   verArray: Cell array with the following conditions:
    %              - be of length >= 1,
    %              - contain only string elements, and
    %              - each element must be of length >= 1.
    %   verComp:  String or Char array that verArray will compare against for
    %             greater than evaluation. Must be:
    %              - be of length >= 1, and
    %              - a string.
    %   verCheck: (Optional) Function handle for comparison with the following conditions:
    %              - Must be of the form @(x,y)
    %              - In an element of verArray, x represents a float for the part to compare
    %              - In verComp, y represents a float for the part to compare
    %              - Default is greater than or equal to i.e. @(x,y) x >= y
    % OUTPUT:
    %   res:      Logical array that identifies if each cell element in verArray
    %             satisfies verCheck.
    % TESTS:
    %   Tests included for reference. From root package directory,
    %   use commands:
    %       suite = TestSuite.fromFolder(pwd, 'IncludingSubfolders', true);
    %       run(suite)
    %
    % EXAMPLES:
    %   output = compareVersions({'3.2.4beta','9.5.2.1','8.0'}, '8.0.0'); %logical([0 1 1])
    %   output = compareVersions({'3.2.4beta','9.5.2.1','8.0'}, '8.0.0', @(x,y) x<y); %logical([1 0 0])
    %   compareVersion_v = compareVersions('version'); %'1.0.9'
    %
    % Tested: Matlab 9.1.0.441655 (R2016b) Linux
    % Author: Raphael Guzman, DataJoint
    %
    % $License: MIT (use/copy/change/redistribute on own risk) $
    % $File: compareVersions.m $
    % History:
    % 001: 2019-06-12 11:00, First version.
    %
    % OPEN BUGS:
    %  - None
    if nargin < 3
        verCheck = @(x,y) x>=y;
    else
        verCheck = varargin{3};
    end
    if nargin < 2 && strcmpi(varargin{1}, 'version')
        res = '1.0.9';
        return;
    elseif nargin < 2
        msg = {
            'compareVersions:Error:VersionRefRequired'
            'Version reference must be supplied.'
        };
        error('compareVersions:Error:VersionRefRequired', sprintf('%s\n',msg{:}));
    end
    verArray = varargin{1};
    verComp = varargin{2};

    res_n = length(verArray);
    if ~res_n || max(cellfun(@(c) ~ischar(c) && ...
            ~isstring(c), verArray)) > 0 || min(cellfun(@length, verArray)) == 0
        msg = {
            'compareVersions:Error:CellArray'
            'Cell array to verify must:'
            '- be of length >= 1,'
            '- contain only string elements, and'
            '- each element must be of length >= 1.'
        };
        error('compareVersions:Error:CellArray', sprintf('%s\n',msg{:}));
    end
    if ~ischar(verComp) && ~isstring(verComp) || length(verComp) == 0
        msg = {
            'compareVersions:Error:VersionRef'
            'Version reference must:'
            '- be of length >= 1, and'
            '- a string.'
        };
        error('compareVersions:Error:VersionRef', sprintf('%s\n',msg{:}));
    end
    if ~isa(verCheck,'function_handle')
        msg = {
            'compareVersions:Error:VersionCheck'
            'Version check must be a function handle.'
        };
        error('compareVersions:Error:VersionCheck', sprintf('%s\n',msg{:}));
    end
    refVer = strsplit(verComp, '.');
    refVer = cellfun(@(x) str2double(regexp(x,'\d*','Match')), refVer(1,:));
    refVer_s = length(refVer);
    res = false(1, res_n);
    for i = 1:res_n
        targetVer = strsplit(verArray{i}, '.');
        targetVer = cellfun(@(x) str2double(regexp(x,'\d*','Match')), targetVer(1,:));
        targetVer_s = length(targetVer);

        if refVer_s > targetVer_s
            targetVer = [targetVer zeros(1,refVer_s - targetVer_s)];
        elseif refVer_s < targetVer_s
            targetVer = targetVer(1:refVer_s);
        end

        diff = targetVer - refVer;
        match = diff ~= 0;

        if ~match % exact match so relying on handle to determine value when same
            res(i) = verCheck(2, 2);
        else
            pos = 1:max(refVer_s, targetVer_s);
            pos = pos(match);
            res(i) = verCheck(targetVer(pos(1)), refVer(pos(1)));
        end
    end
end
