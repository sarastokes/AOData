function idx = multicontains(str, pats)
% MULTICONTAINS
%
% Syntax:
%   idx = multicontains(str, pat)
% -------------------------------------------------------------------------

    fun = @(s) ~cellfun('isempty', strfind(str, s));
    out = cellfun(fun, pats', 'UniformOutput', false);
    idx = all(horzcat(out{:}), 2);