function levelName = extractLevel(txt, level, delimiter)
% Extract package level
%
% Syntax:
%   levelName = aod.specification.util.extractLevel(txt, level)
%   levelName = extractLevel(txt, level, delimiter)
%
% Inputs:
%   txt         string
%       Text separated by a delimiter
%   level       integer
%       The substring index after separating by delimiter
% Optional inputs:
%   delimiter   char (default = '.')
%       The delimiter to separate out substrings
%
% Examples:
%   aod.specification.util.extractLevel("aod.builtin.devices", 2)
%   >> "builtin"
%   aod.specification.util.extractLevel("aod.core", 4)
%   >> ""

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        txt             string
        level           {mustBeInteger}
        delimiter       char = '.'
    end

    if ~isscalar(txt)
        levelName = arrayfun(@(x) aod.specification.util.extractLevel(x,level), txt);
        return
    end

    txt = char(txt);
    idx = strfind(txt, delimiter);

    if level == 1
        if isempty(idx)
            levelName = txt;
        else
            idx2 = idx(level)-1;
            levelName = txt(1:idx2);
        end
    elseif level > numel(idx) + 1
        levelName = "";
    elseif level == numel(idx) + 1
        idx1 = idx(level-1) + 1;
        levelName = txt(idx1:end);
    else
        idx1 = idx(level-1)+1;
        idx2 = idx(level)-1;
        levelName = txt(idx1:idx2);
    end

    levelName = convertCharsToStrings(levelName);
end