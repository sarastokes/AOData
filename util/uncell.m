function out = uncell(data)
    % UNCELL
    %
    % Description:
    %   Some functions run on multiple entities w/ arrayfun require 
    %   UniformOutput = false but return only one cell containing the 
    %   entities. This is a convenience function to "uncell" the output.
    %
    % Syntax:
    %   out = uncell(data)
    %
    % See also:
    %   aod.util.arrayfun
    % ---------------------------------------------------------------------
    if ~iscell(data)
        out = data;
        return
    end

    % Typically this happens because one of the entities queries returned an
    % empty entity, which forces arrayfun into UniformOutput = true
    %idx = cellfun(@isempty, data);
    %if any(idx)
    %    data = data{~idx};
    %end

    out = data{:};