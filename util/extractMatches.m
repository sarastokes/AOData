function [matches, idx] = extractMatches(strs, pat)
    % EXTRACTMATCHES
    %
    % Description:
    %   Identify members of a string array/cellstr matching a pattern
    %
    % Syntax:
    %   [matches, idx] = extractMatches(strs, pat)
    %
    % Inputs:
    %   strs            cellstr or string array to search for matches
    %   pat             matching pattern
    % Output:
    %   matches         members of strs containing pat
    %   idx             Indices of members of strs matching pat
    %
    % History:
    %   24Aug2022 - SSP
    %   27Aug2022 - SSP - Changed output to matches then idx
    % ---------------------------------------------------------------------

    if iscellstr(strs) %#ok<ISCLSTR> 
        strs = string(strs);
        cellstrFlag = true; 
    else
        cellstrFlag = false;
    end

    idx = zeros(1, numel(strs));
    for i = 1:numel(strs)
        if ~isempty(extract(strs(i), pat))
            idx(i) = 1;
        end
    end

    idx = find(idx);

    if ~isempty(idx)
        matches = strs(idx);
        if cellstrFlag
            matches = cellstr(matches);
        end
    else
        matches = [];
    end

