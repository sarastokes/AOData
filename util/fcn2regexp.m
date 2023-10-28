function out = fcn2regexp(fcn)
%FCN2REGEXP Converts common text functions to regexp
%
% Description:
%   Converts a function_handle to a regular expression. The function (FCN) 
%   must be a function handle. Supported functions are: contains, startWith,
%   and endsWith. 
%
% Syntax:
%   out = fcn2regexp(fcn)
%
% Inputs:
%   fcn         function handle
%       The function to convert to a regular expression.
%
% Example:
%   out = fcn2regexp(@(x) contains(x, 'hello'))
%   >> ".*hello.*"
%   out = fcn2regexp(@(x) contains(x, 'hello', 'IgnoreCase', true))
%   >> ".*hello.*/i"

% By Sara Patterson, 2023 (AOData)
% --------------------------------------------------------------------------

    fcn = string(func2str(fcn));
    fcn = erase(fcn, [" ", "'"]);
    fcn = erase(fcn, '"');
    fcn = lower(fcn);

    withinParens = extractBetween(fcn, '(', ')');
    txtVariable = withinParens(1);
    args = withinParens(2);
    indivArgs = strsplit(args, ',');
    varPosition = find(indivArgs == txtVariable);
    if isempty(varPosition)
        error('Could not find variable in function call');
    end
    indivArgs(varPosition) = [];

    % Determine the function
    if contains(fcn, 'contains')
        out = ".*" + indivArgs(1) + ".*";
    elseif contains(fcn, 'startswith')
        out = "^" + indivArgs(1);
    elseif contains(fcn, 'endswith')
        out = ".*" + indivArgs(1) + "$";
    else
        error('fcn2regexp:NotSupported',...
            'The function %s is not supported', fcn);
    end 

    % Decide whether to make it case-sensitive or not
    idx = find(indivArgs == 'ignorecase');
    if ~isempty(idx) && strcmpi(indivArgs(idx+1), 'true')
        caseFlag = true;
    else
        caseFlag = false;
    end
    if caseFlag
        out = out + "/i";
    end