function S3 = mergeNestedStructs(S1, S2)
% Merge deeply nested structures (no overwriting)
%
% Syntax:
%   S3 = mergeNestedStructs(S1, S2)
%
% See also:
%   SearchFields

% By Sara Patterson, 2023 (AOData)
% -------------------------------------------------------------------------

    arguments
        S1              struct
        S2              struct
    end

    if numel(fieldnames(S1)) == 0
        S3 = S2;
        return
    elseif numel(fieldnames(S2)) == 0
        S3 = S1;
        return
    end

    f1 = string(SearchFields(S1));
    f2 = string(SearchFields(S2));

    % First input is the structure name
    f1a = erase(f1(2:end), f1(1)+".");
    f2a = erase(f2(2:end), f2(1)+".");

    % Find fields in S2 matching those in S1
    matchedFields = ismember(f2a, f1a);

    % Match original fieldname indexing
    idx = find(matchedFields) + 1;

    % Start with S1 and add S2
    S3 = S1;

    % If no nested fields match, merge at top level
    if isempty(idx)
        S3.(f2a(1)) = S2;
        return
    end

    diffNames = f2(find(~matchedFields) + 1);
    diffStructs = [];
    for i = 1:numel(diffNames)
        [parent, field] = splitPath(diffNames(i));
        eval(sprintf('tf=isfield(%s, "%s");',...
            strrep(parent, 'S2', 'S3'), field));
        if tf
            continue
        end
        value = eval(diffNames(i));
        if isstruct(value)
            eval(sprintf('%s=value;', strrep(diffNames(i), 'S2', 'S3')));
        else
            if ~tf
                eval(sprintf('%s = value;', strrep(diffNames(i), 'S2', 'S3')));
            end
        end
    end
end

function [parent, field] = splitPath(input)
    idx = strfind(input, ".");
    if isempty(idx)
        parent = []; field = input;
    else
        parent = extractBefore(input, idx(end));
        field = extractAfter(input, idx(end));
    end
end