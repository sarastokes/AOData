function [matches, idx] = multicontains(str, pattern, caseSensitive)
% MULTICONTAINS
%
% Description:
%   Runs "contains" on an array of strings or cellstr
%
% Syntax:
%   [matches, idx] = multicontains(str, pat, caseSensitive)
%
% Inputs:
%   str                 cellstr or string array
%       Text to extract matches from
%   pattern             cellstr or string array
% Optional inputs:
%   caseSensitive       logical (default = false)
%       Whether matching must be case-sensitive
%
% Output:
%   matches             cellstr or string array
%       Members of str matching pattern
%   idx                 logical
%       Array containing 1s at the indices of matches
%       
% See also:
%   CONTAINS
%
% History:
%   29May2022 - SSP
%   25Jul2022 - SSP - Added case sensitive flag, match return
% -------------------------------------------------------------------------

    if nargin < 3
        caseSensitive = false;
    end

    if ~caseSensitive
        pattern = cellfun(@lower, pattern, 'UniformOutput', false);
        strForMatch = lower(str);
    else
        strForMatch = str;
    end

    fun = @(s) ~cellfun('isempty', strfind(strForMatch, s)); %#ok<STRCL1> 
    out = cellfun(fun, pattern', 'UniformOutput', false);
    idx = all(horzcat(out{:}), 2);

    matches = str(idx);